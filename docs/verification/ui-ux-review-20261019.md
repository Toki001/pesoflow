# UI/UX review — 19 October 2026

Applied the apple-design skill's principles of flexibility, predictability,
feedback and restraint to the native Flutter app. Stitch v7 remains the visual
authority: Inter, opaque surfaces, borderless section cards, blue icons and the
five-item navigation remain. Web-specific glass and custom gesture springs were
not imposed on native Flutter controls.

## Decision: stop handwriting research for now

Handwritten amounts/dates remain a known recognition limitation, not a promised
capability. Further model/dataset experiments are deferred at the owner's request.
Keep on-device scanning, preparation/crop/rotate, editable review, uncertainty
warnings and required confirmation. Manual entry is the reliable fallback.
This does not mean handwriting recognition is impossible; the evaluated candidates
do not justify more implementation time or replacement of the current engine.

## Review and fixes

Reviewed app shell/theme/router/shared controls, existing native feedback paths,
and production captures for Home, Transactions, Accounts, Budgets, Analytics,
Expense/Income, Detail, Subscriptions, Notifications, Settings, Scanner and Receipt
Review. Read both design guides and the Settings/Subscriptions PNG/HTML references
before changing those screens. Other captures were reviewed for hierarchy and
readability, not a new pixel-by-pixel comparison against every Stitch export.

| Finding | Evidence and action |
| --- | --- |
| Appearance sheet fails at large text in landscape | Reproduced 141px bottom overflow at 844×390, 200% text. Replaced its fixed Column with a shrink-wrapped scrollable list. Regression opens sheet, scrolls to Dark and selects it successfully. |
| Subscription sort touch target too short | Flutter Android guideline reported 44px height. Set minimum 48px while retaining right alignment, label and menu. Light/dark goldens reviewed; following content moves down 4px. |
| Screen entry controls generally labeled and reachable | Added label and 48px target checks for 12 route states at 390×844 with deterministic persisted-workspace fixtures. All pass after the sort fix. This does not cover every offscreen row, modal or receipt-review state. |
| Main hierarchy and wayfinding are coherent | Shared app bars and bottom navigation, clear financial headings, focused forms with close/back, local-data explanations and genuine empty states retained. No redesign needed. |
| Existing interaction feedback is restrained | Native InkWell/buttons, scrolling, menus and sheets remain. Receipt scanning has immediate status/live announcements and a reduced-motion path. Global route/sheet motion still needs an explicit reduced-motion audit. |

## Remaining UI priorities

1. **Contrast:** token calculations give green `#16A34A` on white **3.30:1**,
   amber `#D97706` on white **3.19:1**, and blue `#2563EB` on dark muted surface
   `#1E293B` **2.83:1**. Small semantic text and some dark icon backgrounds need
   attention. The existing secondary text `#6B7280` on canvas `#F7F8FA` is about
   **4.55:1**. These are token-pair measurements, not screenshot antialiasing tests.
   Use dedicated readable semantic text shades and blue dark-mode icon variants
   while retaining brand/progress colors and layout; reconcile the explicit
   palette in CODEX.md as part of that change. W3C's
   [text contrast](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
   and [non-text contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
   provide the comparison criteria. This audit does not claim conformance.
2. **Assistive navigation:** perform actual TalkBack reading/focus-order and
   keyboard traversal checks, including long lists and form errors. Passing label
   checks alone does not establish useful spoken navigation.
3. **Motion and overlays:** verify reduced-motion navigation and dismissal,
   cancellation mid-transition, and all sheets with keyboard/large text. No custom
   gesture animation is warranted without a demonstrated problem.

Existing compact 200%-text, landscape, keyboard, empty-state and financial
correctness regressions remain. Physical iPhone testing is unavailable. Device
refresh results and build verification are recorded in production-readiness.md.
