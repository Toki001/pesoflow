# Wave glass and motion review — 20 October 2026

Scope: app-owned motion and configured framework transitions across all routes,
sheets, repeated filters/navigation, loading states and theme changes. The
`review-animations` skill was applied only to motion; the visual changes are
separately authorized by the owner's wave/glass reference request.

| Before | After | Why |
| --- | --- | --- |
| Framework Android task routes used 450ms; iOS used 500ms. | `app_motion.dart:6` sets 250ms entrance and 200ms exit. Native predictive-back and Cupertino builders remain (`app_motion.dart:10`, `:19`). | Occasional navigation becomes brief and asymmetric, within the skill's modal/drawer budget and under its 300ms general UI limit. |

**Interruptibility & timing:** A new widget regression pushes Settings, reverses
at 80ms and verifies return to Home without an exception. Tests assert route
budgets and existing reduced-motion behavior. Native sheets already use 250/200ms
and their existing reduced-motion handling; they were retained. Theme changes
already use 200ms. Repeated dock/period/filter actions stay immediate.

**Performance:** Wave ribbons are static native paths (`app_backdrop.dart:40`),
not animated layouts. Card/dock blur is static, clipped and disabled for high
contrast. Card filters retain the route backdrop group. No animation controllers,
layout tweens, recurring decorative animations or new animation dependencies were
added. This is not a frame-rate certification.

**Origin, physicality & cohesion:** Framework task/dialog/sheet geometry remains.
No app-owned scale-from-zero, delayed ease-in, hover motion or stagger was found.
Loading indicators continue to indicate actual work, rather than fake progress.
Reduced-motion route/sheet regressions remain passing.

**Approve** for the reviewed application motion after the route-duration fix.
Native camera/gallery/crop dialogs and physical iPhone gestures are outside this
verification. A device compile does not establish iPhone runtime behavior.

Visual verification covers the updated deterministic Home, Analytics, Add and
Budgets renders in both themes, alongside the complete existing golden suite.
Category colors remain stable across feature mappings; text contrast includes
wave/background/panel combinations and every category foreground. The reference's
extremely pale small labels were not copied literally where they lose legibility.
