#!/usr/bin/env python3
"""Kill isolated Flutter restore workers and verify their databases in new processes.

POSIX host test, not physical-device/power-loss verification. No user databases,
platform keys or installed apps are touched. Requires Flutter on PATH.
"""
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time


def run_case(flutter, mobile, journal, phase):
    with tempfile.TemporaryDirectory(prefix="pf-interruption-") as temporary:
        directory = Path(temporary)
        (directory / "isolated-test-marker").touch()
        env = dict(os.environ, PF_INTERRUPT_DIR=temporary,
                   PF_INTERRUPT_PHASE=phase, PF_INTERRUPT_JOURNAL=journal)
        command = [flutter, "test", "--no-pub", "--reporter", "expanded",
                   "test/device/backup_interrupt_worker.dart"]
        log = directory / "worker.log"
        with log.open("w+") as output:
            worker = subprocess.Popen(command, cwd=mobile, env=env,
                                      stdout=output, stderr=subprocess.STDOUT,
                                      start_new_session=True)
            try:
                ready = directory / "ready.json"
                deadline = time.monotonic() + 90
                while not ready.exists():
                    if worker.poll() is not None or time.monotonic() > deadline:
                        raise RuntimeError("Worker did not reach barrier:\n" + log.read_text())
                    time.sleep(0.1)
                marker = json.loads(ready.read_text())
                target = marker["pid"]
                if marker["phase"] != phase or target <= 1 or os.getpgid(target) != worker.pid:
                    raise RuntimeError("Refusing to signal a process outside this test group.")
                os.kill(target, signal.SIGKILL)
                if worker.wait(timeout=30) == 0:
                    raise RuntimeError("Killed worker unexpectedly succeeded.")
            finally:
                # Also clean up descendants on timeout/failure. This group was
                # created solely for this test; never signal unrelated processes.
                try:
                    os.killpg(worker.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                worker.wait(timeout=10)
        env["PF_INTERRUPT_PHASE"] = "verify-before" if phase == "before-commit" else "verify-after"
        checked = subprocess.run(command, cwd=mobile, env=env, capture_output=True,
                                 text=True, timeout=90)
        if checked.returncode:
            raise RuntimeError(checked.stdout + checked.stderr)
        print(f"PASS {journal}: abrupt exit {phase}; fresh process verified complete data and images.", flush=True)


def main():
    if os.name != "posix":
        raise SystemExit("This host process-kill test requires POSIX.")
    flutter = shutil.which("flutter")
    if flutter is None:
        raise SystemExit("Flutter must be on PATH; run flutter pub get in mobile first.")
    mobile = Path(__file__).resolve().parent.parent / "mobile"
    for journal in ("delete", "wal"):
        for phase in ("before-commit", "after-commit"):
            run_case(flutter, mobile, journal, phase)


if __name__ == "__main__":
    main()
