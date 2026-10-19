# PesoFlow engineering and UI guide

## Product and authority

PesoFlow is a local-first personal expense tracker for Android and iOS. It opens
without login, registration, identity profiles, a backend connection or mandatory
onboarding. Backup and restore are removed product features. Do not reintroduce
them, cloud sync, payment processing, provider verification, membership or banking
shortcuts. Financial accounts are manually tracked assets/liabilities, not login
accounts. Internal transfers record movement between the user's accounts; they do
not move real money.

The 13 version 7 Stitch PNG/HTML pairs directly under `design/stitch/` are the
approved flow and layout reference. The owner-authorized 19 October visual
refresh adds blue gradients, layered surfaces and floating glass navigation,
guided by the supplied inspiration images; this supersedes the earlier flat
surface styling. Read the PNG,
HTML and both DESIGN.md files before updating a screen. The explicit palette
below overrides conflicting generated tokens. Priority: product truth and data
safety, screenshot visual hierarchy, design tokens, HTML structure. Implement
native Flutter widgets; never WebViews, screenshot backgrounds or static runtime
financial fixtures. Preserve all supported controls when translating layouts.

Approved screen folders: `home_dashboard`, `transactions`, `add_expense`,
`analytics`, `budgets`, `all_accounts_wallets`, `transaction_detail`,
`subscriptions_bills`, `receipt_camera_scanner`, `receipt_review`,
`notifications_inbox`, `add_income_record_transfer`, `settings`.

## Data safety

Never clear, reseed, uninstall or reset an existing installation to make a change
work. Never change the Android application ID, database name, schema/key handling
without a verified non-destructive migration. Existing finances, receipt images
and preferences must survive a normal update. Do not touch external saved files.

Retain Drift database `pesoflow`, schema 1 and historical migrations. Financial
workspace and receipt bytes are AES-256-GCM encrypted before SQLite persistence.
Secure storage owns `pesoflow.financial-data-key.v1`. Keep nonce generation and
record-bound associated data unchanged. Missing keys/corruption fail safely;
never replace unreadable financial data with an empty workspace. Old optional
identity/sync JSON fields may be ignored by the local-only codec; valid financial
fields and receipt evidence versions must remain readable.

Financial money is integer minor units. No floating point persisted balances.
Keep source/destination account identities distinct from display names. Transfers
must not count as income or expenses. Refunds/reversals must reduce corresponding
expenses correctly. Credit limits must never inflate cash totals; debit cards
are metadata on their underlying account, not duplicate balances. Do not invent
provider balances or label manual accounts synced, linked or verified.

## Architecture

Use the existing feature folders (`domain`, `data`, `application`, `presentation`).
FinanceBootstrap opens encrypted storage before Riverpod/GoRouter render. One
FinanceController serializes durable commands; publish state only after a
successful atomic commit. A failed save retains committed records and form inputs.
All financial projections derive from this workspace. Preserve the existing
engines unless fixing a demonstrated defect. Test clocks/adapters/fixtures belong
in `mobile/test` only. Do not create anonymous cloud users or auth dependencies.

Use Flutter, Riverpod, GoRouter, Drift, secure storage, Freezed/json_serializable
and the existing native receipt adapters. Add packages only for supported needs.
The optional NestJS health backend is independent of mobile startup; do not build
speculative server functionality. Receipt camera/gallery/crop and on-device ML Kit
must remain real. Explicitly review uncertain extracted fields. Save image,
metadata and expense atomically; reopen images after restart; delete associated
images only with an explicit transaction deletion.

## Shared design system

Inter is bundled locally; monetary text uses tabular figures. Primary #2563EB,
Light canvas pale blue with ink #111827 and secondary text #596779; Dark canvas
#0A1016 with ink #F7F8FA, secondary #CBD5E1 and muted #BBC6D5.
Use blue-only gradients for prominent summary surfaces, restrained depth, and
solid floating navigation and solid section cards over blue ambient
backgrounds. Keep dense financial
content readable. Category colors are stable identities: food orange, shopping
violet, bills teal, subscriptions indigo, transport blue and other neutral.
Category icons/chart accents use softer pastel hues with pale opaque badge fills;
category names and amounts retain readable text colors. Income/refunds use green;
risk and over-limit states use amber/red. Avoid random
decorative accents. Dark mode preserves
hierarchy using the established dark surfaces and readable semantic variants.
Both appearances share static abstract blue ribbons with unequal slopes, bends
and thicknesses, following the owner's 20 October refinement. Light retains a
pale sapphire/white base; Dark retains deep navy. Section cards are opaque white
in Light and opaque navy in Dark, without backdrop blur. The dock also uses the
solid theme surface without blur. Keep background paths static.
High contrast keeps opaque readable theme surfaces.

Use shared typography, 4/8px spacing rhythm, 16px screen margins, 16–20px card
padding, 24px cards, 18px inset fields, pill buttons and 28px sheets. Main app bar is 56px.
Bottom navigation is one reusable component: Home, Transactions, Add, Analytics,
Budgets, 72px within a floating panel plus safe area. Add is the single global creation action; no duplicate
Home Add Expense/FAB or banking shortcuts. Focused forms/details can hide the bar.
Settings is reached directly through the settings icon.

Ordinary header, receipt, account and navigation icons use neutral gray, resolved
against their actual surface. Category badges may use their stable category color.
Selected navigation tiles use #2563EB with white icons; inactive tiles remain gray.
Header icon circles, unselected Transactions filter pills and the Analytics date
control use the same solid theme surface. Transactions filters have no border;
their selected state retains the blue fill and white text.
Readable foregrounds on charcoal use blue #93C5FD, success #86EFAC, warning
#FBBF24 and error #FCA5A5. Light uses blue #1E40AF, success #166534, warning
#92400E and error #991B1B. Primary fills and pale-surface icons retain #2563EB.
Financial text and progress bars retain semantic colors. Period/Budget filters
use compact raised surface pills with blue selected text inside a muted track.
Keep their 48px touch targets while making the visible pill slimmer.
System bars derive icon brightness from the actual canvas luminance. Android's
navigation bar is transparent without an automatic contrast scrim, allowing the
app backdrop to show behind the system buttons.

Section cards have no outline borders in either theme. Use surfaces and subtle
shadows for separation; retain borders on inputs and explicit selection controls.
Default section cards use the solid theme surface. The Home balance card retains
its blue gradient without an inset reflection layer or visible inner rectangle.
The dock has an additional 8px lift above its safe-area spacing. Navigation pointer
taps have no splash/highlight overlay; keyboard focus remains visible in blue.
Subscriptions & Bills is directly accessible from Budgets and Settings.
Task routes retain native Android predictive-back/iOS transition behavior with
250ms entrance and 200ms exit. Tabs/filters remain instant; reduced motion keeps
its existing static routes/sheets. Do not add decorative entrance sequences.

Share app bars, cards, amounts, rows, account/category selectors, inputs, buttons,
filters, sheets, dialogs and loading/empty/error states. Avoid giant build methods
and premature abstractions. Use responsive scrollable layouts, SafeArea,
Flexible/Wrap and constrained widths. Verify compact/normal/large phones,
landscape, keyboard, large text, light/dark and 44–48px interactive targets.

Only display genuine data and supported states. Screenshot balances, merchants,
versions, confidence rates, auto-debit claims and cloud-sync labels are illustrative.
Do not fabricate insights. Empty installs have zero financial records. Settings
shows the installed application version and only functional options. Do not add
fake help/privacy links, notification schedules or receipt-scanning controls.
Authentic institution logos require available licensed assets; otherwise use
neutral initials/icons and accurate names, never invented official branding.

## Verification and workflow

Read this guide and `docs/production-readiness.md` before changes. Inspect current
code and relevant verification reports; do not repeat completed work. Make small
coherent changes and commit verified milestones. Never commit secrets or private
receipt images/text. Log safe error categories, never keys or raw finances.

Run formatting, analysis, relevant unit/widget tests, then full tests and builds.
Golden fixtures must be deterministic and test-only. Review Flutter captures
against each approved PNG; fix hierarchy, spacing, component sizes and typography
before decorative details. Do not weaken golden comparisons to hide differences.
Include empty/error/retry and financial correctness regressions. Required domain
cases include transfers, refunds, zero baselines, failed-save rollback, stale
writes, duplicate submits, receipt image persistence and existing-data upgrades.

Commands from `mobile/`:

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk
flutter build appbundle
flutter build ios --debug --no-codesign
```

`scripts/check.sh` also runs retained backend format/lint/build/health tests.
Only claim actual physical-device checks performed. On a connected Redmi, upgrade
in place and verify records before/after restart. Never uninstall or clear data to
work around signing errors. Report the blocker instead. Android builds currently
use development signing; do not claim store-ready signed artifacts.

A screen is complete only with live persisted data, supported interactions,
loading/empty/error states, responsive/accessibility checks, visual comparison,
passing tests and unchanged financial semantics. Update architecture/readiness/UI
mapping docs and record exact verification limits. If execution ends mid-task,
commit verified milestones and explicitly list remaining work.
