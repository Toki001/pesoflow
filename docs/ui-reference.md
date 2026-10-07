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
- Home, Transactions, Transaction Detail, Add Expense, Budgets, Analytics and Connected Accounts are implemented. Other destinations explicitly identify themselves
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

The receipt action opens the fixture-backed native review screen; capture/upload/OCR remains unconnected. Unverified
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

## Connected Accounts implementation

Native widgets preserve the Back/Link header, reassurance banner, balance hero,
linked-source count, GCash/BDO/Maya/BPI card order, masked identifiers, right-aligned
balances, sync/action footers, amber stale-BPI state, provider/trust card, purple
insight and docked connect CTA. Layout uses 16px outer margins, 14px reassurance,
18px hero/trust and 16px source-card radii, existing Inter/semantic tokens and
generic wallet/bank icons. No provider logos or remote assets were introduced.

Balances: GCash ₱4,250, BDO ₱28,400, Maya ₱1,850, BPI last-known ₱12,200.
The three active balances sum to **₱34,500**, correcting the export's ₱34,300
hero. Stale BPI is excluded from available balance and never promoted by a demo
refresh. The institution count includes its listed profile. Home retains its
independent reference balance; no transactions are deleted by demo removal.

Reference claims about 256-bit encryption, authorized Open Finance access,
ISO/NPC compliance, direct provider support, “18 more” providers and 42 minutes
saved are unverified. Their visual containers remain, with accurate demo copy:
sample profiles, no credentials, no financial connections and no fund access.
Each source shows a demo sync/active qualification; the hero displays the fixed
October 24, 2024 snapshot instead of a misleading “Just now”.

Home's balance card opens `/accounts`; Back returns to its tab/scroll, or Home
for a direct link. Settings show masked provenance/date and unavailable live
features. Sync All performs a local check, retains timestamps, shows safe errors
and supports retry. Disconnect confirms session-only removal; Link/Connect opens
an explicitly demo-only catalog that restores a missing sample after confirmation.
All existing profiles are marked Listed. Reconnect explains that real authorization
is unavailable and retains the stale balance. No credential entry exists.

Human screenshot comparison retained the approved hierarchy and corrected large
text action overflow and a clipped bottom insight. Light/dark goldens use
390 × 1632 to show the full screen with 48px touch targets; the reference is
390 × 1527. Remaining differences are taller accessible controls/source footers,
wrapped demo-qualified badges, native font/icon rendering, truthful trust copy
and the corrected total. Compact/200% text stacks balances; safe areas and the
connect CTA stay usable. The shared task header defaults preserve older screens.


## Subscriptions implementation

Native widgets retain the Back/Add header, commitment hero, annualized line,
amber renewal strip, purple cloud tip, four-date timeline, service list and
Budgets-selected shared bottom navigation. Cards retain Netflix/Spotify/Google/
iCloud+/Disney order, 40px tinted icons, active/annual badges, right-aligned prices,
account/renewal footer, 12px radius and 16px outer margins. Inter and existing
light/dark semantic roles are reused; no assets, HTML or WebViews were added.

Amounts match the service rows: ₱549, ₱239, ₱479, ₱49 monthly and Disney+ ₱2,950
annually (₱245.83 monthly equivalent). These yield **₱1,561.83/month** and
**₱18,742/year**, with **5 active services**, correcting inconsistent export hero
values. Upcoming dates are Oct 28, Nov 2, Nov 12 and Nov 18, so the heading says
Upcoming renewals. Home's separate Spotify amount and screen-specific budget/
analytics subscription totals remain unchanged. The sample clock is Oct 24, 2024.

The HTML's Subscription History card appears below the five plans; it is below the
screenshot crop. Its subtitle accurately says View recorded recurring charges,
showing only observed posted recurring expenses from the shared demo ledger.
The session note discloses the fixed demo date. Add/edit/detail/history sheets use
existing native form/dialog patterns; cancellation/payment functions are not implied.
Home's Upcoming Bills card opens the Budgets-nested Subscriptions route. Back goes
to Budgets; the existing bottom tabs remain functional and preserve state.

Screenshots were compared visually at 390 × 1205, with full light/dark captures at
390 × 1420. Largest initial mismatches fixed: title/badge wrapping, centered account
footers, header inset and excess heading spacing. Remaining differences: native
font/icon rendering, slightly taller rows/spacing (roughly 6–13px cumulative list
offset), 48px interactive targets, corrected financial/count/date copy and the
truthful history/session copy. Compact/200% text deliberately stacks content.
Older screen goldens and approved Stitch assets remain unchanged.


## Receipt Scanner Review implementation

The native `/receipt` task route preserves the dark preview/HUD, flash/gallery/
frame controls, 24px rounded review surface, handle, wrapped review heading,
merchant/date card, amber uncertainty warning, four numbered item rows with
confidence, subtotal/VAT/blue total, category/account cards and save/retake/discard
controls. No bottom navigation appears. Preview and sheet scroll together with
safe insets, a 512px maximum canvas and keyboard-safe item editors.

The preview is a native illustration of the original SM Supermarket sample;
no local licensed thermal-receipt photo exists. It is labelled Demo receipt,
98% sample confidence, and Demo frame preview. No perpetual scan animation,
remote image request, camera feed, capture permission or live OCR is implied.
Flash changes only a demo preference. Gallery/Retake confirms sample reloading;
Adjust Frame explains the unavailable actual crop/capture integration.

Items retain ₱108.50 milk, ₱75 bread, ₱160 apples and two ₱91 corned-beef units;
confidence is 99%, 98%, 95% and 81%. Total stays **₱525.50**. The export's
₱63.06 is 12% of the gross amount, inconsistent with its included-tax label.
The illustrative included portion is **₱56.30**, calculated as gross × 12/112,
rounded half-up to centavos and never added again. This demo assumes every line
has the same sample tax treatment; mixed taxes/discounts/exemptions are deferred.
The loyalty-points claim becomes Demo receipt · no rewards applied. Account copy
says Demo source and makes no current balance or payment claim.

Ready to review replaces the misleading Ready to save while a line remains
uncertain. Saving directs the user to the first flagged editor and cannot insert
a transaction until it is confirmed or removed. Item correction preserves the
original sample confidence and shows Reviewed; it never fabricates improved OCR
confidence. Adding/removing/correcting items recomputes monetary totals.

Add Expense's Scan opens the review and preserves its original unsaved form and
scroll on discard. Close/system Back/discard requires confirmation; direct links
fall back to Add. Saving opens Transaction Detail with a session snapshot of the
reviewed items and receipt provenance. Reopening the same sample is read-only and
offers View saved transaction, preventing duplicate postings. This saves an
independent expense rather than submitting the still-unsaved Add Expense form.

Light/dark goldens use the exact **427 × 1600** reference viewport. Human comparison
corrected heading wrapping, item font/row density, summary amount alignment,
secondary button widths and dark warning intensity. Remaining differences: the
synthetic preview, truthful demo/confidence/tax/rewards/source copy, native fonts/
icons, a taller accessible merchant/date card and item-header control (item list
starts about 35px lower), and shorter payment-source cards without a fake balance.
Preview text keeps illustration proportions at 200% scaling and has an accessible
summary; review text and controls scale normally. Only Add Expense's two goldens
change among earlier screens, for its now-available demo review caption.

## Onboarding / demo entry (inferred, not a Stitch-approved screen)

No onboarding screenshot or HTML exists in the approved export. The native
three-step introduction inherits Home's balance and budget previews, the Budgets
PF identity, 16px gutters, Inter hierarchy, semantic badges, neutral cards and
48px primary actions. It introduces only the necessary demo disclosures and
step navigation. It does not replace or redesign any approved screen.

Steps: Understand your money; Make room for your plans; Explore PesoFlow with
sample data. Preview amounts come from the existing October 2024 Home fixture.
Next and Back control local state, Skip reaches the disclosure and Explore demo
opens Home. There is no sign-in or account connection form. The introduction
has a scrolling body, safe-area footer and no bottom navigation.

Six 390 × 844 light/dark goldens were reviewed for hierarchy, spacing, typography,
card shape and colors against neighboring references. Header height stays stable
when Skip disappears. There is no pixel-level Stitch baseline for this new UI;
its layout and copy are an implementation inference and await product review.
Existing Stitch-backed screens and their goldens are unchanged.

## Settings (inferred, not a Stitch-approved screen)

No Settings screenshot or HTML exists in the export. The screen reuses Connected
Accounts' task header, standard neutral cards, 16px gutters and restrained trust
copy, plus Transaction Detail's grouped rows and existing theme typography.
Appearance rows offer System/Light/Dark with explicit checked semantics and native
icon/radio glyphs; the card and all controls adapt to the existing dark palette.
Settings uses no bottom navigation and keeps its body scrollable.

Home's avatar now opens Settings without changing its visible placement or size;
the invisible interaction area is 44 × 48px and has an explicit accessible label.
Settings links to sample accounts and the introduction. Currency/formatting and
demo limitations are informational. Restore device appearance preserves demo
edits. No notification, biometric, real connection or persistence control is
presented as functional.

Two 390 × 1100 light/dark goldens were reviewed against neighboring reference
patterns for grouping, density, spacing, typography and color. This inferred
layout awaits product review; there is no pixel-level Settings reference. All
existing Stitch-backed and onboarding goldens remain unchanged.

## Notifications (inferred, not a Stitch-approved screen)

No notification-center screenshot or HTML exists in Stitch. The new native task
screen inherits Connected Accounts' back header and neutral cards, Home's bell
and subtle unread dot, Inter hierarchy, 16px gutters, semantic icon containers
and text badges. It groups fixed sample events by date with All/Unread filters,
individual read/unread actions, Mark all read and links to existing screens.
Cards use explicit Read/Unread labels and wrap actions at compact/large-text sizes.
Loading skeletons, safe retry, no-alert and caught-up states retain that language.

The demo banner identifies historic October 2024 snapshots and says they do not
update with session edits. There is no push delivery/live monitoring claim.
Three existing bells now route to the inbox; their visible geometry is unchanged.
Home's existing unread dot follows the shared count and disappears when read.

Two 390 × 1480 light/dark goldens were reviewed against neighboring card/header
patterns for hierarchy, density, gutters, typography, icons and dark fill.
There is no pixel-level Stitch inbox baseline; the inferred screen awaits product
review. Every earlier screen golden remains unchanged.

## Account Detail (inferred, not a Stitch-approved screen)

No dedicated account-detail screenshot or HTML exists. The native screen reuses
Connected Accounts' task header, read-only demo reassurance, masked identities,
semantic connection badges and neutral balance cards; Transaction Detail informs
its grouped provenance and activity. The numeric hero retains reported balance
semantics and the original timestamp. BPI has a last-known balance, explicit stale
warning and a truthful reconnection explanation.

Related activity reuses native Transactions rows with text wrapping enabled and
date groups; transfers retain their full source/destination and neutral amount.
Activity does not reconcile the reported balance. Local check and confirmed
removal reuse existing state. Empty activity, unknown/removed profiles, loading
and safe retry states follow the same system. Account identity and the existing
Settings action open detail without altering Connected Accounts' visible layout.

Four active/stale light/dark goldens (GCash 390 × 1700, BPI 390 × 1300) were reviewed
against neighboring references for margins, hierarchy, typography, card shape,
metadata, status and dark colors. Review fixed truncated transfer identities and
activity date alignment. This inferred layout has no pixel-level Stitch baseline
and awaits product review; all earlier goldens remain unchanged.

## Demo connection review (inferred, not a Stitch-approved screen)

Stitch has no consent screenshot or HTML. `/connections/demo/:id` therefore
inherits Connected Accounts' task header, 16px gutters, neutral bordered cards,
Inter typography and read-only trust language. It reuses Account Detail's masked
identity, balance hero, semantic status and reported timestamp. Disclosure cards
explain sample-only visibility, no credentials or money movement, and session
removal with preserved history. Stale BPI retains a last-known warning and stays
excluded from the available total.

An unchecked acknowledgment card gates Add demo account. Actions scroll with the
content to remain reachable in landscape and at 200% text. Cancel/Back preserve
the list; successful addition replaces the review with Account Detail. Listed
profiles offer View sample profile instead of a duplicate add. Missing profiles,
loading and safe retry retain the same visual language. Existing Accounts and
other Stitch-backed layouts remain unchanged.

Two 390 × 1500 light/dark goldens were visually reviewed against adjacent Accounts
patterns for gutters, hierarchy, numeric treatment, cards, badges, icons and dark
fill. There is no pixel-level approved baseline for this screen; the inferred
layout awaits product review.

## Stable account references (no visual redesign)

Account associations and filters now use internal IDs while preserving visible
labels, card layouts and all 36 golden baselines. Transfers appear once for each
involved account, including a receiving-only account filter. Separate BDO products
retain their individual labels; legacy records without an ID remain in All and
are not guessed into an account view. No new screen or visual token is introduced.

## Local demo activity storage (inferred additions)

Native Settings conditionally adds a local activity card when bootstrap enables
persistence. It reuses existing task headers, Inter hierarchy, 16px gutters,
bordered neutral cards and outlined controls; the card explains stored versus
session-only data, shows save status/retry and confirms Reset demo activity.
Memory-only previews retain their prior layout. Onboarding disclosure and
transaction feedback use truthful local-storage copy only in persistent mode.

A restrained global save-error banner exposes safe retry on every route and
labels retained in-memory changes. A reset progress message temporarily blocks
pointer edits. Startup loading/recovery uses the same typography and calm
reassurance, with retry and explicitly confirmed reset; it never renders a
replacement fixture ledger after a read failure.

Two local Settings light/dark 390 × 1600 goldens were reviewed for hierarchy,
spacing, typography, card shape, state messaging and dark fill. All 36 prior
baselines remain unchanged. There is no approved Stitch storage/reset screenshot;
these inferred additions await product review.


The local Settings card now discloses saved budget/subscription plans and adds a
separate outlined Reset demo plans control. Its confirmation preserves transactions
and saved receipts and explains that tracking changes cannot cancel services or
create charges. Reset demo activity explicitly preserves both plan stores.
Startup recovery names all stored collections before confirming a full reset.
Budget/subscription editor and onboarding disclosures use local-storage copy only
when bootstrap enables persistence. The approved screen hierarchy, components,
financial typography and navigation remain unchanged; memory-mode golden baselines
are retained. Local Settings additions still have no dedicated Stitch reference.


Persistent Settings now states that appearance survives restart; its existing
Restore device appearance action saves System while preserving financial edits
and demo entry completion. The local storage card and onboarding disclosure name
these two saved preferences. No controls, tokens or layout patterns were added.
Returning demo users enter the existing Home layout with their saved appearance;
View introduction still opens the existing native introduction. Only the two
local Settings goldens change for disclosure text; these inferred Settings views
still have no dedicated approved Stitch screenshot.


Persistent inbox disclosure now states that read markers survive restart. Mark
read/unread, Mark all read, navigation actions, filter controls, badges and alert
cards retain their established layouts. Native Settings adds Reset demo alerts as
another existing outlined control, with explicit confirmation of three-unread/
one-read defaults and preserved financial/preferences data. Startup full-reset
copy also names markers. Compact 200% text and safe-inset layouts are checked.
Two persistent inbox light/dark 390 × 1480 goldens supplement the earlier memory
baselines; local Settings captures change for copy/control height. There is no
separate approved Stitch inbox or reset screen, so these inferred views retain the
existing design language and await dedicated product visual approval.

## Production-data checkpoint

The approved Stitch exports remain the visual source of truth. The production
runtime now uses the same screen hierarchy and design tokens with real saved
records. Test-only workspaces supply the 14 `production_*.png` light/dark goldens;
the original screenshot aggregates are not injected into application totals.

Home retains its balance, flow, insight, budgets, recent activity and upcoming
bills sequence. Counts and card heights follow available data. Manual account
cards retain the approved balance/card/action structure with actual account names
and calculated balances. Transaction detail retains the amount hero, provenance,
budget impact, notes, tags and edit controls; invented receipt contents, contact
names and bank identifiers are omitted. The receipt reference remains available
for the later OCR task; its prototype implementation is test-only.

See [production readiness](production-readiness.md) for native restart evidence,
current verification and remaining fidelity differences.
