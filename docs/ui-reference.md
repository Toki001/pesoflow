# Approved Stitch UI reference

## Audit and authority

Inspected all 9 `screen.png` / `code.html` pairs, `design/stitch/design.md`,
`design/stitch/calm_financial_intelligence/DESIGN.md`, and the complete `CODEX.md`.
The initial repository contained these references, README, environment/ignore
templates, six empty docs, and empty mobile/backend/infrastructure/workers/scripts
directories. There was no application code, test suite, or Git repository metadata.
Original design artifacts are retained unchanged.

Authority: **screenshot > design tokens > HTML**. All screens use Inter and
Material Symbols. PNG dimensions below are export dimensions, not mandatory
device sizes; some exports are scaled full-page captures.

## Screen inventory

| Reference (PNG and adjacent HTML) | Export | Approved structure and patterns |
| --- | --- | --- |
| [Home](../design/stitch/home_dashboard/screen.png) | 390 × 1447 | 56px brand header; sync strip; greeting; dominant ₱30,650 balance; segmented inflow/outflow/savings; purple Spending Pace; overall/category budgets; 4 transactions; 2 upcoming bills; five-item navigation. |
| [Transactions](../design/stitch/transactions/screen.png) | 517 × 1600 | Month summary and switcher; search; horizontal filters; dated groups; icon/merchant/metadata/amount rows; pending, transfer, income, refund and receipt badges. |
| [Transaction Detail](../design/stitch/transaction_detail/screen.png) | 442 × 1600 | Task header without bottom navigation; centered merchant/amount/status hero; source account and timestamp; category and budget impact; notes; receipt and item breakdown; sharing/tags; utility actions. |
| [Add Expense](../design/stitch/add_expense/screen.png) | 437 × 1600 | Expense/Income/Transfer segments; hero monetary input; quick amounts; merchant suggestions; category tiles; budget meter; account selector; date/notes/receipt; fixed Save CTA. |
| [Analytics](../design/stitch/analytics/screen.png) | 384 × 1600 | Month and period controls; expense hero; cumulative actual/target chart; insight; stacked category bar with ranked amounts; merchant ranking; bottom navigation. |
| [Budgets](../design/stitch/budgets/screen.png) | 323 × 1600 | Period and New action; monthly limit/spent/remaining; daily pace and forecast; reallocation insight; category filters/cards, warnings and explanatory text; bottom navigation. |
| [Subscriptions](../design/stitch/subscriptions/screen.png) | 390 × 1205 | Commitment hero; annualized cost; renewal warning; intelligence tip; date timeline; five service rows with account, cadence, status and renewal; bottom navigation. |
| [Connected Accounts](../design/stitch/connected_accounts/screen.png) | 390 × 1527 | Back/Link header; read-only explanation; liquid balance; institution cards with masked IDs, balance, sync and disconnect; expired BPI state; supported-institution/trust copy; connect CTA. |
| [Receipt Review](../design/stitch/receipt_scanner_review/screen.png) | 427 × 1600 | Dark camera/crop region; 24px rounded review sheet; merchant/date; low-confidence warning; 4 itemized entries with confidence; subtotal/VAT/total; category/account; save/retake/discard. |

## Shared tokens and primitives

- Color families: brand blue `#2563EB`, strong `#1D4ED8`, soft `#DBEAFE`;
  teal `#0F766E`/`#CCFBF1`; purple `#7C3AED`/`#EDE9FE`;
  positive `#16A34A`/`#DCFCE7`, warning `#D97706`/`#FEF3C7`,
  danger `#DC2626`/`#FEE2E2`. Expense amounts remain ink, transfers neutral.
- Home's exported roles are retained separately: link blue `#004AC6`,
  ink `#131B2E`, secondary teal `#006A63`, insight purple `#6A1EDB`.
- Light surfaces: white, `#F8FAFC`, `#F1F5F9`; borders `#E2E8F0`/`#CBD5E1`.
  Dark surfaces: `#0B1220`, `#111827`, `#1E293B`; text `#F8FAFC`,
  `#CBD5E1`, `#94A3B8`; border `#334155`. Dark accent foregrounds use
  brighter tints for contrast while retaining the same hierarchy.
- Inter display 34/38, headlines 28/32, 22/26, 18/22; money 32/32,
  24/24, 18/18; body 16/24, 14/20, 12/17; labels 12/14 and 11/13.
  Numeric text uses tabular figures. Font is bundled with its OFL license.
- Spacing: 4, 8, 12, 16, 24, 32, 40, 48. Home has 16px outer margins,
  16px section gaps, 12px card padding, 16px hero padding.
- General radius family: 6, 10, 14, 18, 24, full. **Home exception: 12px
  cards** match its screenshot and HTML's overridden `rounded-xl`; do not
  silently substitute the design document's 24px `xl` mapping.
- Shadows: subtle 0/1/2 at 4% ink; card 0/4/16 at 6%; elevated
  0/10/30 at 10%; modal 0/20/50 at 18%. No generic Material elevation.
- Shared primitives implemented now: FinanceCard, MoneyText, StatusBadge,
  CategoryIcon, BudgetProgressBar, SectionHeader, TransactionTile, app shell
  and bottom navigation. Forms/charts/connection components wait for their screens.
- Bottom bar: 64px plus safe inset; Home/Transactions/Add/Analytics/Budgets;
  centered 44px blue Add circle. Native taps have at least 48px target height.
- Measured Home exceptions: 22px sync-to-greeting gap, 10px label-to-balance
  gap, 18px balance-to-divider gap, and a 6px upward Add-circle offset preserve
  the screenshot's optical alignment across Flutter/web font metrics. Section
  headers include 48px links, so adjacent gaps absorb the extra hit-target space.

## Home fixture contract

Frozen demo clock: 2024-10-24 12:34, Philippine local wall time. Exact sample:
balance 3,065,000 centavos; month change 243,000 / 8.6%; inflow 4,500,000;
outflow 1,680,000; savings 2,820,000 / 62.7%; overall budget 2,500,000;
Food 690,000/800,000, Shopping 340,000/500,000, Transport 215,000/350,000.
Transactions: Jollibee 32,500 expense; Grab 21,000 expense; BDO→GCash
500,000 transfer; Acme salary 4,500,000 income. Bills: Spotify 19,400,
Meralco estimate 342,000. Aggregates are fixture snapshots, not sums of the
four recent rows. A persistent, quiet Demo label prevents simulated sync
copy from being mistaken for live provider data.

## Reference inconsistencies and deliberate adjustments

- Home Transport limit is ₱3,500; Budgets uses ₱2,500. Home Spotify is ₱194;
  Subscriptions uses ₱239. Analytics Food is ₱5,200 versus Home ₱6,900.
  These are separate screen fixtures, not a single reconciled ledger.
- Account totals, subscription counts/totals, and receipt VAT copy are also
  illustrative and must be validated before any real financial calculation.
- Claims about provider support, certification, encryption and regulatory
  compliance in the reference are not verified product capabilities. They
  are not implemented or asserted by this foundation.
- The Home avatar is a remote image without a bundled asset/license. Use
  an initials fallback until asset rights are confirmed; no substitute image.
- Native layouts keep currency sign and amount together, unlike the export's
  wrapped transaction signs. Compact widths and large text wrap metadata and
  budget pairs instead of clipping. Links receive 48px tap areas.
- Home, Transactions, Transaction Detail, Add Expense, Budgets and Analytics are implemented. Other destinations explicitly identify themselves
  as unavailable in this demo. Their placeholders are not approved-screen replacements.

## Visual validation

Stable full-page reference viewport: 390 × 1447, DPR 1, no platform safe insets.
Also test a normal 390 × 844 viewport, compact 320px, large phone 430px,
landscape, dark theme, safe insets, and increased text scale. Goldens use
bundled Inter and fixed data; no network font or image requests.
See `docs/architecture.md` for regeneration and check commands.

## Transactions implementation

Native feed includes the approved October snapshot, search (merchant/note/amount),
month selection, type/account/category filters, dated cards and pending, transfer,
income, refund and receipt states. Nine immutable records reproduce the feed.
Month totals are a full-period fixture snapshot, not the sum of these nine rows.
The demo ledger is session-only; no provider is connected.

Financial correction: Yesterday shows -₱180 net rather than the screenshot's
+₱4,820, which incorrectly treats an internal ₱5,000 transfer as income. Pending
Starbucks is excluded from posted cash flow. Transactions sort by timestamp,
so SM Supermarket precedes Salary on October 20. Native icons, ellipsis and font
rasterization differ from the web export. Full-page light/dark goldens at
420 × 1300, phone interactions and 200% text at 320px are tested.

## Transaction Detail implementation

Detail opens as a task screen without bottom navigation. The Jollibee fixture
reproduces the hero, provenance, Food budget meter, receipt line items, sharing
preview, tags and actions. Notes/category/tags/exclusion update the session
ledger; synced financial fields remain read-only. Unknown IDs have a missing
record state. Exclusion changes budget impact only, not spending/cash flow.

The receipt photo is represented by a native receipt icon because no licensed
image is bundled. OCR/security copy explicitly identifies fixture/demo data.
Sharing is an equal-split preview, not recorded debt or a payment. Reports and
receipt export explain their unavailable state. Detail goldens cover both
themes at 390 × 1447; 320px with 200% text remains scrollable.

## Add Expense implementation

Native amount input, +₱50/+₱100/+₱500, Exact focus, merchant suggestions, six
category tiles, more categories, contextual budget meter, account switching,
date/time, note/tags, Reset and fixed Save action follow the approved form.
Expense/Income/Transfer selectors share its form language. Transfer additionally
requires distinct source/destination accounts. Savings and budgets reflect
session edits through baseline deltas, while reported balances stay unchanged.

The receipt action explains that capture/upload/OCR is not connected. Unverified
read-only sync/security claims are replaced with explicit demo labels. Stable
light/dark full-page goldens use 390 × 1600. At 390px the form is taller than
the scaled Stitch screenshot because quick actions, selectors and links use
48px touch targets. Native glyphs and input typography differ slightly. The
keyboard, errors and 200% text flow naturally without hiding the docked action.

## Budgets implementation

`/budgets` now implements the approved brand/context header, monthly hero, spent
and remaining panels, 8px meters, safe daily pace, month-end estimate, supportive
reallocation card and all six category allowances. Snapshot: monthly ₱25,000;
spent ₱16,800; remaining ₱8,200; 67% used; 7 days left; safe daily allowance
₱1,171.42; estimated month-end ₱22,400. Category limits: Food ₱8,000, Shopping
₱5,000, Transport ₱2,500, Bills ₱2,500, Subscriptions ₱1,600, Entertainment
₱2,000. Bills and Subscriptions retain settled/fixed states rather than becoming
variable-spending warnings solely from utilization.

Month selection, All/At Risk/On Track, sorting, New and category/monthly limit
editing are functional. Reallocation requires an explicit Apply, moves ₱500 of
allowance from Entertainment to Food, and preserves the monthly limit and
spending. Dismissal is scoped to the period. There is no payment or money move.
New/edited allowances affect Add Expense and Detail. Explicit limit edits also
update Home, including restoring an edited limit to its original Stitch value.
The initial Home Transport ₱3,500 and 8-day display remain approved snapshot
variants; Budgets has ₱2,500 and 7 days (excluding the current day).

Native light/dark full-page goldens use 390 × 1932, proportional to the supplied
323 × 1600 export. Hero/insight radius is 16px (`rounded-2xl` in this export);
category cards remain 12px. Measured category rhythm uses 10px header-to-value,
6px value-to-meter and 4px footer spacing. The month header's whole left area is
the accessible period-selection target. Native 48px action/filter targets make
those controls taller than Stitch. Long category descriptions ellipsize on
normal phones and wrap with large text; native glyphs/font rasterization differ.
Provider/reset claims in the source footer are replaced by honest session-demo
copy. Loading skeletons, retry, empty periods/filters, 320/390/430px, landscape,
safe insets and 200% text with a keyboard are covered by tests.

## Analytics implementation

The native Analytics screen preserves the approved section order, 16px outer/card
padding, 12px card radius, split currency/32px amount, green comparison pill,
cumulative blue area/line with dashed target and endpoint, purple intelligence
card, 12px stacked category strip, six category rows and four ranked merchants.
The PF initials header and shared bottom navigation remain native widgets.

Reference fixture: October 2024 expense ₱16,800, previous-period expense ₱18,340,
8.4% / ₱1,540 decrease, ₱541.93 daily average, ₱21,800 projected month-end and
12% below a ₱25,000 monthly target. Categories are Food ₱5,200, Shopping ₱3,400,
Transport ₱2,150, Bills ₱2,000, Subscriptions ₱1,550 and Other ₱2,500. Targets
start at ₱6,000/₱4,000/₱2,500 for the first three categories, independently of
Home/Budgets until explicitly edited. The ranked merchant values/counts match
the export, including SM Supermarket ₱3,420.50 and Jollibee ₱975.

The export's Food “6%” trend and ₱1,200-decrease narrative do not form a consistent
prior-category calculation. They remain separate illustrative fixture examples;
changed categories suppress reference trends, and a changed category snapshot
switches the intelligence narrative to an aggregate comparison. The initial
trajectory uses four illustrative reference points with dated interpolation;
actual session deltas apply at their dates. Forecasts are demo estimates, not a
production forecasting engine. Chart details disclose these limitations. Day/
Week show available dated records; Year includes the October aggregate and
labels incomplete coverage. The September total is a comparison-only fixture.

Date selection, period controls, Amount/% toggle, chart detail sheet, loading,
empty/reset and retry states work. Share opens an explicitly labelled selectable
demo summary; file export/system sharing and notifications are unavailable.
Budget exclusion retains Analytics spending; refunds, transfers and pending state
keep the existing ledger semantics.

Light/dark goldens use the exact 384 × 1600 reference viewport. Human comparison
fixed the missing category bar, cramped month selector, wrapped Month label,
stacked hero badge and extra bends from redundant chart points. Remaining
intentional differences: controls use 48px touch areas, making the header and
category control taller; compact/large text layouts stack rows; Material Icons
and native Inter rendering differ from the export. Chart dates map to actual
calendar positions (the export's Oct 24 marker is at x=240/350 and does not align
with its evenly spaced calendar labels). Tappable chart values supplement the
accessible textual summary. No reference assets or earlier screen goldens changed.
