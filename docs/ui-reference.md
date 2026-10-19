# Approved UI reference — Stitch flows and modern surfaces

The 13 PNG/HTML pairs directly under `design/stitch/` define the flows and layout
hierarchy. The 19 October modern-surface refresh below supersedes their flat
visual treatment, as authorized with the supplied inspiration images. All 28
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

### Readable foreground variants — 19 October 2026

Light-theme action text uses #1D4ED8; semantic foregrounds use success #166534,
warning #92400E and error #991B1B. Primary fills and light-surface icons retain
#2563EB. Dark badge icons use #60A5FA where needed; icons on pale blue controls
retain #2563EB. Dark semantic text roles remain unchanged. Shared budget bars keep
the original semantic fill palette. These are contrast corrections within the
approved hierarchy, not new color categories or a layout redesign.

System reduced-motion disables spatial page/bottom-sheet transitions and theme
animation. Normal-mode platform transitions remain. Main/task titles are exposed
as screen-reader headings without changing visual typography.

### Visual consistency — 19 October 2026

Home's Spending/Income pair and Accounts' balance/credit pair share equal widths
and heights in their two-column layout, including wrapped captions. Larger text
retains the existing stacked layout. All four main destinations use a filled blue
icon when selected and an outlined blue icon otherwise; Add retains its creation
button treatment. Receipt review notices, uncertain item rows, pending labels and
increased-spending comparison badges use neutral surfaces instead of yellow
highlights. Their messages and confirmation requirements remain intact.

### Modern surface direction — 19 October 2026

The five supplied plant-care, finance and smart-home inspiration images guide
materials and depth. They are visual references, not bundled app assets. Existing
Stitch screen composition and functional controls remain.

- A deep-blue-to-sapphire gradient anchors Home's tracked balance. White amounts
  and readable pale signed-flow labels sit above darker translucent inset chips.
- Cool blue ambient gradients support translucent white-to-ice cards; dark mode
  uses a navy gradient with tinted glass surfaces. Cards use 24px corners,
  inset fields 18px, pill buttons and sheets 28px, with soft shadows and no
  section outlines.
- A floating, clipped glass navigation panel uses native 18px backdrop blur,
  a tinted surface, a selected-tab capsule and the consistent filled icons.
  Its content is 72px high plus outer spacing and safe area; large text grows it.
  High-contrast mode uses opaque surfaces without blur.
- Header icon buttons use circular wells. Inputs use inset translucent fills and
  explicit focus/error outlines. Primary buttons have clipped blue pill gradients;
  secondary controls use pale wells. Expense and receipt confirmation actions
  retain blue icons within white circles. Forms, lists, Analytics, Budgets and
  Settings share this treatment.
- Keep financial content readable: no photographic backgrounds, rainbow accents,
  extra widgets, demo data or new financial claims. Neutral review/status panels
  and the equal-height summary pairs remain. Default glass cards use clipped 10px
  backdrop filters grouped per route for non-overlapping surfaces. Custom-color
  and summary-gradient cards do not add blur. High contrast removes the ambient
  gradient and card blur, with opaque card surfaces.

Category selectors measure wrapped labels so every tile shares the same height,
including 200% text. The large amount placeholder retains its field typography.

The follow-up glass correction reduces light card tint opacity to 18–48% and dark
tints to 18–24%, with a directional reflection gradient over a more pronounced
blue ambient backdrop. Sections reveal the background without outline borders;
dark muted text is #AFBDD0 and light secondary text is #43536B. The dock also uses
a lighter tint and sits 8px higher above its existing safe-area gap. Navigation
pointer taps have no gray splash/highlight; blue keyboard focus and selected
capsules remain. Transactions' search-clear X has no circular background or border,
and the search field uses the shared translucent fill.
Home's inner Spending/Income and net-flow wells use translucent fills rather than
opaque white, without adding nested backdrop filters.

The approved “Charcoal + Blue Glow” background replaces Dark appearance's navy
wash with neutral charcoal and localized muted blue light at upper-right and
lower-left. Native gradients render it; the generated mockup is not an app asset.
Only the backdrop changes. Existing cards/controls/spacing and Light appearance
remain intact, including the raised dock and plain search-clear icon.

### Transparent glass and blue glows — 19 October 2026

The owner clarified that Light must retain its white base; Dark retains charcoal.
Both use stronger sapphire corner glows with the same geometry. Default cards use
6–12% colored tint with 4px blur; the dock uses 8px blur and no white frosting.
Light keeps dark text; Dark keeps light text. Solid overlays and native date-picker
surfaces follow their appearance, with readable financial/action foregrounds.
High contrast retains opaque cards and no blur.

Analytics separates its period row from a compact, left-aligned calendar/date
selector by 12px, with summary action at the right. Large date labels can wrap
without touching the period controls. Period selections and Budget All/At Risk/
On Track filters use blue fills with white labels; inactive choices use transparent
blue tints. Android system bars use transparent backgrounds without a forced
contrast scrim, and icon brightness follows the actual canvas luminance.

The Add screen now has a full-width Expense/Income/Transfer selector below its
Record Transaction header. Equally sized options pair a blue icon with a label;
the selected option uses a blue fill. It remains scrollable with large text and
available before creating the first account. Edit flows keep their fixed type.

Phone review refined the dock labels to fit on one line at the device's text size.
System status/navigation icon brightness follows the active theme, including cold
launches, so light surfaces retain dark system icons. Dark header wells preserve
contrast for the blue icons.

### Rounded ambient background — 20 October 2026

The new reference's large, softly shaded circular forms replace the simple corner
glows. A partial orb enters at the top, with larger forms cropped along the left
and lower-right edges. Native static radial gradients use the existing blue
palette: white/ice blue in Light, deep navy in Dark. Their color remains visible
through the existing transparent cards. Shapes are background decoration only;
screen composition, controls, typography and financial data remain unchanged.
High contrast retains its flat background.

### Wave glass and semantic color refinement — 20 October 2026

The owner's wave/liquid-glass references supersede the earlier orb background and
blue-only chrome. Native static cubic ribbon paths with translucent highlights
sit over the ambient blue/cyan canvas; Light stays white/ice blue and Dark navy.
Section panels now use 38–62% Light / 26–38% Dark tints and 12px clipped grouped
blur; the floating dock uses 16px blur. This is a layered glass treatment, not a
physical refraction simulation. No screenshot assets or animated blur are used.

Analytics and Budget segments share a slimmer raised surface pill within a muted
track, blue selected text and 48px interaction targets. Gray chrome recedes behind
financial content. Selected dock tiles are solid blue with white icons. Gray text
is softer while retaining the composited-background contrast checks.

Food/orange, shopping/violet, bills/teal, subscriptions/indigo and transport/blue
identify categories consistently in entry, transactions, budgets and Analytics;
other stays neutral. Green income/refunds and amber/red budget risk retain their
financial meaning. Amounts, labels and legends accompany colors. The Home blue
card now has a compact wallet/title row, directional cash-flow label, a subtle
light reflection and an account-count/month footer, all from actual projections.

Task transitions keep native geometry/back behavior with 250ms entrance and 200ms
exit. Tabs and filters remain instant. See the [motion review](verification/ui-ux-review-20261020.md).

### Solid sections and abstract blue background — 20 October 2026

The owner refined the wave-glass direction: section boxes now use opaque white
in Light and opaque navy in Dark. This supersedes the earlier translucent card
materials; their backdrop filters are removed. The floating dock keeps its glass
material. Existing semantic insets, icon colors, controls and layout are retained.

The canvas shifts from cyan toward sapphire blue. Ribbon contours have fixed,
unequal start/end heights, curvature and thickness instead of evenly repeated
waves. They remain static and deterministic across rebuilds/restarts. High contrast
retains its flat background. The Home hero's clipped radial reflection was removed
because its bounds appeared as an inner rectangle on the Redmi; only the original
continuous blue gradient and financial content remain.

### Solid navigation/chrome and softer categories — 20 October 2026

The owner extended solid surfaces to the dock, circular header buttons, inactive
Transactions filter pills (including account/category filters) and Analytics date
control. They are white in Light and navy in Dark. Transactions pills have no
outline; selected filters keep their blue fill/white text. Active dock tiles keep
the same blue/white treatment. Layout, touch targets and behavior are unchanged.

The dock no longer filters the backdrop; its shared component is now named
NavigationPanel. Category orange/violet/teal/indigo/blue/green/neutral accents are
lighter and less saturated, with opaque pastel badge fills. Labels and amounts
retain text-role colors. Non-text category icons/charts are checked at 3:1 contrast;
text roles retain 4.5:1. Financial income/refund and risk colors remain unchanged.
