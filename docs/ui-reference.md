# Approved UI reference — Stitch v7

The 13 PNG/HTML pairs directly under `design/stitch/` are authoritative. All 28
files match the latest user-provided v7 export. Both `pesoflow_minimal_tracker/DESIGN.md`
and `calm_financial_intelligence/DESIGN.md` were read. The user's explicit palette
and truthful product behavior override conflicting generated tokens and sample
claims. Previous exports and prototype baselines remain in Git history.

## Screen mapping

All layouts are native Flutter. Financial values come from the encrypted workspace;
only tests inject samples. Routes without a separate URL are states of one flow.

| Approved folder | Flutter implementation / entry | Retained behavior |
| --- | --- | --- |
| home_dashboard | `HomeScreen`, `/home` | Tracked balance, monthly cash flow, accounts, budgets, recent records |
| transactions | `TransactionsScreen`, `/transactions` | Search, type/account/category filters, period selection, detail, CSV export |
| add_expense | `AddExpenseScreen`, `/add` | Quick amounts, category/account, merchant/date/time/note, receipt entry, durable save |
| add_income_record_transfer | Same form, income/transfer modes; `/add?kind=income` | Income destination; distinct transfer source/destination; neutral internal transfer totals |
| all_accounts_wallets | `AccountsScreen`, `/accounts` | Grouped banks/wallets/cards/cash, visibility toggle, manual creation, history/edit/archive |
| budgets | `BudgetsScreen`, `/budgets` | Overall cap, actual category progress, period/filter/sort, edits/reallocation |
| analytics | `AnalyticsScreen`, `/analytics` | Day/week/month/year, prior-period comparison, real trajectory, category ring, merchants and payment sources |
| transaction_detail | `TransactionDetailScreen`, `/transactions/:id` | Locally recorded status, info, budget impact, notes, receipt reopen, supported edit/delete |
| subscriptions_bills | `SubscriptionsScreen`, `/subscriptions` | Monthly commitment, next-seven-day renewals, active/annual/paused tracking, management and observed history |
| receipt_camera_scanner | `ReceiptScanner`, initial `/receipt` state | Native camera/gallery, permission recovery, real processing stages |
| receipt_review | `ReceiptReviewScreen`, captured `/receipt` state | Actual image/zoom/crop, editable totals/merchant/date/category/account/items/notes, explicit confirmation and atomic save |
| notifications_inbox | `NotificationsScreen`, `/notifications` | Persisted budget/renewal/spending alerts, filters, read state, preferences |
| settings | `SettingsScreen`, `/settings` | Appearance, currency information, visible categories, default account, alert toggles, installed version, local privacy information |

Account detail/editor, budget editor, subscription detail/editor/history, saved
receipt and correction dialogs retain supported existing workflows and reuse the
same secondary header, cards, fields and buttons. They do not introduce new
banking or identity features.

## Shared visual patterns

- Inter is bundled; amounts use tabular figures. Page headings use 18px/24px,
  body 14px/20px, secondary text 12px/17px, dominant amounts 30px/36px.
- Primary `#2563EB`, canvas `#F7F8FA`, surface `#FFFFFF`, ink `#111827`, secondary
  `#6B7280`, border `#E5E7EB`, success `#16A34A`, warning `#D97706`, danger `#DC2626`.
  Category charts use shades of the interaction blue; semantic colors indicate
  actual financial states. Dark mode uses the shared dark surfaces/semantic roles.
- 16px screen margins and card padding; 20px summary padding; 4/8px spacing rhythm;
  16–18px cards, 12px inputs, restrained borders/shadows.
- `MainAppBar` provides the 56px primary header with notice and Settings actions.
  `TaskScreen` owns focused headers and forms; no identity/avatar prerequisite.
- One bottom navigation: Home, Transactions, Add, Analytics, Budgets. Focused
  forms/details suppress it. Home has no duplicate global creation action.
- Shared `FinanceCard`, `CategoryIcon`, `FinancialAccountRow`, amount formatting,
  progress bars, status badges, and input/button theme keep composition consistent.
  Lists scroll; compact/large-text layouts wrap or stack rather than clip actions.

## Deliberate differences from illustrative screenshots

Screenshots are layout references, not runtime records. No hard-coded balances,
merchants, confidence percentages, provider verification, cloud sync or scheduled
payments are shown. Manual institution icons replace unavailable licensed logos.
Credit limits remain separate from cash; debit metadata belongs to its account.

The scanner opens the system camera and does not simulate a live camera feed,
auto-edge detection, torch state or multi-page scanning. Receipt review retains
parser warnings, original text and explicit confirmation; it never claims all OCR
fields match automatically. Those controls make review longer than the clean
Stitch sample. Receipt attachment enters the existing scan-and-review expense
flow rather than pretending an image is attached to an unsaved manual draft.

Settings currency is currently PHP information, not an FX converter. Category
management hides/shows existing categories; it does not rename historical ones.
Alerts are in-app and use actual configured budget thresholds. Weekly scheduled
summaries and OS delivery are not implemented. About reads native package/bundle
metadata and provides actual local privacy information rather than placeholder URLs.

## Verification

`production_app_test.dart` covers 12 screen states in light/dark; receipt review
has five additional goldens for normal, uncertain, missing-item, failure and dark
states. All 13 approved screens therefore have current visual regression coverage.
The fixtures are deterministic under `mobile/test/fixtures/`; device receipts are
never committed. Captures were inspected against the new PNGs, with the largest
hierarchy mismatches corrected. Remaining differences include native icon glyphs,
font wrapping, denser validation controls and content-dependent card heights.
This is not a claim of pixel-identical rendering or physical-device acceptance.
See [readiness](production-readiness.md) for exact command results and limits.


## Owner follow-up — borderless sections and logo

The October 16 direction supersedes generated DESIGN.md prose prescribing card
outlines: section cards use surfaces and restrained shadows without border lines
in either theme. Inputs and selected-category indicators retain their meaningful
outlines. Subscriptions & Bills is reachable directly from Budgets and Settings.
The owner's `logo.svg` is the launcher artwork; regenerate native icons on macOS
with `swift scripts/generate-app-icons.swift`. Screen layouts remain native.


## Owner screenshot corrections — 16 October 2026

Notifications uses an alert-type dropdown plus an independent Unread only switch;
its count distinguishes filtered results from unread notices across the inbox.
Budgets places New beside Category Budgets, keeps the period on its own row, and
moves Subscriptions & Bills below the category list. Icons consistently use brand
blue; financial amounts, warning text and progress bars retain semantic colors.
Icon-bearing filled actions use pale surfaces to keep blue glyphs legible.
Receipt review has separate Rotate (left) and Crop (right) controls below the image.


## Receipt preparation — 17 October 2026

Per the owner's request, camera/gallery input opens Prepare Receipt before OCR.
It reuses the focused receipt header, borderless image card, zoomable photo and
blue Rotate/Crop controls, with a larger preview and explicit Scan receipt action.
Successful later image edits return to this step; the approved extraction review
layout follows only after scanning. No speculative edge-detection controls or
fake confidence states were introduced. Light/dark preview goldens are reviewed.

The 18 October follow-up keeps this hierarchy and adds immediate scan status,
accessible live announcements and reduced-motion handling. Native Android crop
uses the brand-blue toolbar/frame/active controls. Narrow portrait and landscape
preparation/review are checked at 200% text without changing the approved palette
or introducing decorative motion.

### Accessibility follow-up — 19 October 2026

The Apple Design review preserves the approved visual system. Appearance's native
choice sheet scrolls when space is limited, and Subscriptions' sort menu has a
48px minimum touch target. Its subsequent content is 4px lower; the hierarchy and
control order are unchanged. See the [UI/UX review](verification/ui-ux-review-20261019.md)
for tested coverage and remaining contrast/motion/assistive-navigation work.
