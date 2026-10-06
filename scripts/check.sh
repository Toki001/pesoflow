#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
(
  cd mobile
  dart format --output=none --set-exit-if-changed lib test
  flutter analyze
  flutter test
)
(
  cd backend
  npm run format:check
  npm run lint
  npm run build
  npm test
)
