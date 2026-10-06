# CODEX.md — PesoFlow Engineering & UI Implementation Guide

## 0. Purpose

This file is the authoritative engineering instruction set for Codex when building **PesoFlow**, a Flutter personal-finance application for Android and iOS.

PesoFlow already has an approved UI design produced in Stitch.

**Do not redesign the product. Implement the approved design faithfully.**

The visual design references are a product requirement, not loose inspiration.

The application includes:
- expense tracking
- income tracking
- transfers
- receipt OCR
- automatic transaction categorization
- bank/e-wallet account connections where legitimate APIs are available
- budgets and expense limits
- subscriptions
- financial analytics
- notifications
- spending comparisons
- balance and cash-flow views

This is a financial-data application. Security, privacy, transaction correctness, consent, and UI trust are first-class requirements.

---

# 1. Highest-Priority Rule: Preserve the Stitch UI

The existing Stitch export is the visual source of truth.

Codex must NOT:
- replace the approved UI with generic Material defaults
- invent a different design system
- simplify screens without a product reason
- rearrange sections merely because another structure is easier to code
- change approved colors, typography, spacing, radii, or hierarchy arbitrarily
- turn the app into a generic Flutter starter design
- redesign a screen unless explicitly instructed
- add random gradients, glassmorphism, decorative cards, or animations
- substitute a desktop-style dashboard for the mobile layout
- remove meaningful UI states shown in the designs

Codex SHOULD:
- inspect the visual reference before implementing each screen
- inspect the corresponding Stitch HTML for measurable clues
- translate web/CSS concepts into idiomatic Flutter widgets
- extract reusable design tokens
- create reusable Flutter components
- maintain responsive behavior
- preserve information hierarchy
- preserve financial semantics
- preserve touch ergonomics
- preserve accessibility

When there is a conflict between:
1. screenshot visual result
2. Stitch design system
3. exported HTML implementation

Use this priority:

```text
Screenshot visual intent
    >
Design system/tokens
    >
HTML implementation details
```

The HTML is implementation reference, not source code to copy into Flutter.

---

# 2. Expected Design Reference Location

When setting up the repository, store the Stitch export in a dedicated design reference directory.

Recommended:

```text
/
├── CODEX.md
├── design/
│   └── stitch/
│       ├── design.md
│       ├── calm_financial_intelligence/
│       │   └── DESIGN.md
│       ├── home_dashboard/
│       │   ├── screen.png
│       │   └── code.html
│       ├── transactions/
│       │   ├── screen.png
│       │   └── code.html
│       ├── transaction_detail/
│       │   ├── screen.png
│       │   └── code.html
│       ├── add_expense/
│       │   ├── screen.png
│       │   └── code.html
│       ├── analytics/
│       │   ├── screen.png
│       │   └── code.html
│       ├── budgets/
│       │   ├── screen.png
│       │   └── code.html
│       ├── subscriptions/
│       │   ├── screen.png
│       │   └── code.html
│       ├── connected_accounts/
│       │   ├── screen.png
│       │   └── code.html
│       └── receipt_scanner_review/
│           ├── screen.png
│           └── code.html
├── mobile/
├── backend/
├── docs/
└── ...
```

If the repository uses another path, locate the equivalent Stitch files before implementing UI.

Do not delete the Stitch references after implementation.

They should remain available for visual regression and future screens.

---

# 3. Existing Approved Screens

The current Stitch export contains approved references for:

1. **Home Dashboard**
2. **Transactions**
3. **Transaction Detail**
4. **Add Expense**
5. **Analytics**
6. **Budgets**
7. **Subscriptions**
8. **Connected Accounts**
9. **Receipt Scanner / OCR Review**

Treat these as approved design targets.

Additional screens not yet present should be designed by extrapolating from the same system, not by creating a new visual language.

Examples of screens that may need extrapolation:
- authentication
- onboarding
- add income
- add transfer
- create/edit budget
- notification center
- settings
- account connection consent
- account detail
- subscription detail
- filters
- empty/error/offline states

For new screens:
1. reuse existing components
2. reuse design tokens
3. reuse navigation patterns
4. reuse spacing/radius patterns
5. preserve the "Calm Financial Intelligence" style

---

# 4. Approved Design Language

The approved design concept is:

> **Calm Financial Intelligence**

Product personality:
- modern
- premium
- calm
- clear
- trustworthy
- precise
- non-judgmental
- mobile-first
- editorial
- finance-focused

The emotional goal:

> "I understand my money now."

Do not make the app look like:
- crypto trading software
- stock trading software
- old accounting software
- an Excel spreadsheet
- a generic SaaS dashboard
- a gaming app
- a childish budgeting app
- a neon fintech concept

---

# 5. Approved Core Colors

The Stitch files contain both base product tokens and Material-derived surface roles.

Use semantic token names in Flutter instead of scattering raw hex values throughout the codebase.

Core brand/semantic colors:

```text
primary            #2563EB
primaryStrong      #1D4ED8
primarySoft        #DBEAFE

secondary          #0F766E
secondarySoft      #CCFBF1

accent             #7C3AED
accentSoft         #EDE9FE

positive           #16A34A
positiveSoft       #DCFCE7

warning            #D97706
warningSoft        #FEF3C7

danger             #DC2626
dangerSoft         #FEE2E2

ink                #0F172A
inkSecondary       #475569
inkMuted           #64748B

surface            #FFFFFF
surfaceSubtle      #F8FAFC
surfaceMuted       #F1F5F9

border             #E2E8F0
borderStrong       #CBD5E1
```

Approved dark-mode direction:

```text
darkSurface          #0B1220
darkSurfaceSubtle    #111827
darkSurfaceMuted     #1E293B

darkInk              #F8FAFC
darkInkSecondary     #CBD5E1
darkInkMuted         #94A3B8

darkBorder           #334155
```

The exported Material roles may include additional shades.

Centralize them in a token/theme layer.

Do NOT put literals such as:

```dart
Color(0xFF2563EB)
```

throughout arbitrary widgets.

Prefer:

```dart
context.colors.primary
AppColors.primary
```

or equivalent theme extensions.

---

# 6. Typography

The Stitch design uses **Inter**.

Use Inter consistently.

If the font package is used, make the dependency intentional and centralized.

Recommended semantic styles:

```text
display
headlineLarge
headlineMedium
headlineSmall

numericXL
numericLarge
numericMedium

bodyLarge
bodyMedium
bodySmall

labelMedium
labelSmall
```

Approximate approved values:

```text
display:
34px / 700

headlineLarge:
28px / 700

headlineMedium:
22px / 700

headlineSmall:
18px / 650

numericXL:
32px / 750

numericLarge:
24px / 700

numericMedium:
18px / 700

bodyLarge:
16px / ~450

bodyMedium:
14px / ~450

bodySmall:
12px / ~450

labelMedium:
12px / 600
```

Use the actual Stitch visual result to tune final Flutter metrics.

Financial values are visual anchors.

Use tabular figures if supported.

PHP formatting example:

```text
₱30,650.00
```

Do not use ultra-light font weights for money.

---

# 7. Spacing

Use a shared spacing system.

Approved rhythm:

```text
4
8
12
16
24
32
40
48
```

Suggested Dart tokens:

```dart
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 48.0;
}
```

Do not invent arbitrary spacing values unless needed to match a Stitch screenshot.

When a one-off value is required for fidelity, document why.

---

# 8. Radii

Approved visual radius family:

```text
micro       6
control     10
standard    14
feature     18
hero/sheet  24
pill        full
```

Use shared radius tokens.

Avoid:
- 4 different radii in one small component
- excessive pill shapes
- square finance cards inconsistent with the rest of the app

---

# 9. Shadows and Elevation

The approved UI is subtle.

Use:
- borders
- tonal surfaces
- low-opacity shadows

Avoid:
- large Material elevation
- huge blur shadows
- neon glow
- excessive floating surfaces

Approximate reference tiers:

```text
subtle:
0 1px 2px rgba(15,23,42,0.04)

card:
0 4px 16px rgba(15,23,42,0.06)

elevated:
0 10px 30px rgba(15,23,42,0.10)

modal:
0 20px 50px rgba(15,23,42,0.18)
```

Translate to Flutter BoxShadow conservatively.

---

# 10. UI Implementation Method

For every Stitch-backed screen:

## Step 1 — Inspect

Before coding, inspect:
- `screen.png`
- corresponding `code.html`
- design token files

Identify:
- screen structure
- margins
- vertical rhythm
- dominant value
- sections
- card hierarchy
- typography
- iconography
- bottom navigation
- progress indicators
- interactive affordances
- semantic states

## Step 2 — Decompose

Define reusable components.

Do NOT build a 1,000-line `build()` method.

## Step 3 — Build Tokens First

Use the centralized theme.

## Step 4 — Build Static Fidelity

First reproduce:
- visual structure
- spacing
- text hierarchy
- cards
- icons
- charts
- navigation

Use fixture/mock data.

## Step 5 — Add State

After visual structure is correct:
- Riverpod
- loading states
- real models
- repositories
- API data

## Step 6 — Add Interaction

Add:
- navigation
- filters
- forms
- bottom sheets
- editing
- state transitions

## Step 7 — Validate

Compare the running Flutter screen against the Stitch screenshot.

Do not call a screen complete without visual comparison.

---

# 11. Pixel Fidelity vs Flutter Idioms

The goal is high fidelity, not literal HTML translation.

Do:
- reproduce visual rhythm
- reproduce size relationships
- reproduce information hierarchy
- reproduce border/radius/elevation feel
- use Flutter's native rendering

Do not:
- embed Stitch HTML into WebViews
- copy Tailwind classes into Flutter comments
- use a web renderer to avoid implementing the UI
- ship screenshots as screen backgrounds
- hardcode every coordinate with Stack/Positioned
- create brittle fixed-position layouts

Prefer real responsive Flutter layout primitives.

---

# 12. Responsive Rules

The approved design is mobile-first.

Support at minimum:
- compact phones
- normal phones
- large phones
- landscape without catastrophic breakage

Use:
- SafeArea
- MediaQuery
- LayoutBuilder
- Flexible
- Expanded
- Wrap
- constrained widths
- scrollable content

Do NOT hard-code a specific iPhone width as the entire layout model.

If Stitch was generated around a specific viewport:
- preserve its proportions at that viewport
- adapt gracefully on nearby device widths

Use sensible max-width constraints on tablets.

---

# 13. Navigation

Primary bottom navigation:

```text
Home
Transactions
Add
Analytics
Budgets
```

Preserve this unless requirements explicitly change.

Use GoRouter.

Recommended high-level route concepts:

```text
/home
/transactions
/transactions/:id
/add
/add/expense
/add/income
/add/transfer
/receipt
/analytics
/budgets
/budgets/:id
/subscriptions
/accounts
/accounts/:id
/settings
```

The center Add action may open a modal/bottom sheet before routing to a specific creation flow.

Navigation must preserve:
- selected tab
- back-stack behavior
- deep-link compatibility
- Android back behavior
- iOS gesture expectations

---

# 14. Reusable UI Component Library

Before duplicating similar UI, create reusable components.

Suggested component families:

```text
AppScaffold
AppTopBar
AppBottomNavigation

MoneyText
PercentageChange
StatusBadge

FinanceCard
HeroBalanceCard
InsightCard

TransactionTile
TransactionGroupHeader

BudgetProgressBar
BudgetSummaryCard
BudgetCategoryTile

AccountConnectionTile
SyncStatus
InstitutionIcon

CategoryIcon
CategorySelector

SectionHeader
MetricPair
MetricRow

PeriodSelector
FilterChipGroup

PrimaryButton
SecondaryButton
DestructiveButton

AppTextField
MoneyInput
DateField

EmptyState
ErrorState
OfflineBanner
LoadingSkeleton
```

Do not over-generalize components too early.

Create shared abstractions when:
- at least two screens use the pattern
- the pattern clearly belongs to the design system

---

# 15. Icons

The Stitch HTML uses Material-style icon semantics.

In Flutter, prefer:
- Material Symbols / Material Icons where visually close
- a consistent icon family

Do not mix:
- Cupertino icons
- Material icons
- random SVG packs

unless necessary for a specific provider brand or design fidelity.

Category icon examples:
- fast food
- transport
- groceries
- shopping
- bills
- subscriptions

Use consistent icon containers.

---

# 16. Provider Logos

Do not invent official financial-provider logos.

If official logo assets are included and licensing/use is appropriate, use them.

Otherwise:
- use tasteful institution initials
- use generic wallet/bank icon
- preserve provider name text

The current Stitch screens already demonstrate initials/generic icon fallback behavior.

Do not imply PesoFlow is GCash, Maya, BDO, BPI, etc.

---

# 17. Charts

Implement charts to visually match Stitch.

Use one maintained Flutter chart package if needed.

Do not add multiple chart packages.

Charts must:
- remain readable
- support dark mode
- have accessible textual summaries
- not require hovering
- not hide critical numbers

Avoid:
- 3D charts
- excessive legends
- unnecessary axes
- giant donuts

If a chart is decorative in Stitch, preserve its intent without over-engineering.

---

# 18. Loading States

Do not replace the entire app with generic circular spinners.

Use:
- skeleton rows
- lightweight placeholders
- section-level loading

Preserve layout stability.

Examples:
- transaction skeleton tiles
- chart skeleton
- budget meter skeleton
- balance placeholder

Never show stale values as freshly synced without indicating status.

---

# 19. Empty States

Empty states should use the same calm design language.

Required examples:

### No transactions

```text
No transactions yet

Add your first expense or connect an account to start tracking.
```

### No budgets

```text
Create your first budget

Set a spending limit and let PesoFlow help you stay on track.
```

### No subscriptions

```text
No recurring expenses found yet.
```

Keep them restrained.

---

# 20. Error States

Errors should:
- explain the user impact
- preserve existing cached data
- offer a clear next action

Example:

```text
We couldn't update your financial data.

Your previous data is still available.

[ Try Again ]
```

Do not expose:
- stack traces
- exception class names
- internal IDs
- provider credentials
- database errors

---

# 21. Offline UI

Offline support should be visible but calm.

Possible states:

```text
Offline
Pending sync
Last synced 2h ago
```

Users should still be able to:
- view cached transactions
- view cached budgets
- add manual expenses
- add income

Never imply that cached balances are current.

---

# 22. Dark Mode

Dark mode is a first-class implementation.

Do not just invert colors.

Use approved dark tokens.

Test every existing Stitch-backed screen in:
- light mode
- dark mode

Even if a screenshot is light-only, dark mode should preserve the same hierarchy.

---

# 23. Accessibility

UI fidelity must not break accessibility.

At minimum:
- semantic labels
- 44–48px touch targets
- readable contrast
- dynamic text tolerance
- chart summaries
- screen-reader labels for icons
- don't use color alone for status
- logical focus/order

If exact Stitch dimensions conflict with accessibility:
- preserve design intent
- prefer accessible interaction
- document the adjustment

---

# 24. Home Dashboard Reference

The current Home Dashboard includes:

- PesoFlow header
- date / sync status
- greeting
- calm overview subtitle
- Net Available Balance
- month change
- multi-account context
- inflow
- outflow
- savings rate
- Spending Pace insight
- Monthly Budgets
- overall limit
- category budget progress
- Recent Transactions
- additional lower content

Known sample values include:

```text
Net Available Balance:
₱30,650.00

This month:
+₱2,430 / +8.6%

Inflow:
+₱45k

Outflow:
-₱16.8k

Savings:
₱28.2k
62.7%

Overall Budget:
₱16,800 / ₱25,000
67%

Food:
₱6,900 / ₱8,000

Shopping:
₱3,400 / ₱5,000

Transport:
₱2,150 / ₱3,500
```

Preserve the calm hierarchy.

Do not turn all metrics into equal-size cards.

---

# 25. Transactions Reference

The current Transactions screen includes:

- title/header
- month selector
- spent
- income
- net flow
- search
- filters
- transaction type chips
- account/category filters
- date groups
- group totals
- transaction rows

Sample transaction semantics include:

```text
Jollibee
Food & Dining · GCash
-₱325.00

Grab Car
Transport · Maya
-₱210.00

Starbucks Reserve
Pending
-₱240.00

BDO Savings → GCash
Transfer
₱5,000.00

Monthly Salary
Income
+₱45,000.00
```

Preserve distinct presentation for:
- expense
- pending
- transfer
- income

Do not color all expenses bright red.

---

# 26. Transaction Detail Reference

The current Transaction Detail includes:

- amount
- merchant
- category
- completion/sync status
- provenance/account information
- date/time
- category editing
- budget impact
- reference number
- notes
- linked receipt
- extracted receipt items
- expense sharing/split section

This design is more detailed than a simple transaction card.

Do not collapse it into a generic form.

Imported transaction provenance must remain visible.

---

# 27. Add Expense Reference

The current Add Expense design includes:

- Expense / Income / Transfer mode
- currency
- hero amount entry
- quick amount buttons
- merchant/payee
- recent merchant suggestions
- category selection
- monthly category budget impact
- payment source
- available account balance
- date
- note/tags
- receipt upload/scan
- final Save Expense CTA

Preserve the speed-focused flow.

Do not replace it with a long generic form.

---

# 28. Analytics Reference

The current Analytics design includes:

- selected month
- Day/Week/Month/Year
- Total Expense
- comparison vs previous period
- daily average
- spending trajectory
- actual vs target pace
- projected end-of-month spend
- Financial Intelligence insight
- category breakdown
- category percentage
- category trends
- target context
- additional merchant/stat insights

The analytics screen should feel informative, not like BI software.

---

# 29. Budgets Reference

The current Budgets design includes:

- Active period
- remaining days
- New budget action
- overall monthly budget
- spent
- percent utilized
- remaining
- safe daily pace
- estimated month-end
- smart reallocation suggestion
- category budget list
- filter/sort
- risk/on-track states
- projected category overage

The smart budget card should remain supportive.

Never use judgmental copy.

---

# 30. Subscriptions Reference

The current Subscriptions screen includes:

- total monthly commitment
- annualized commitment
- next renewal
- intelligence tip
- upcoming timeline/list
- active subscriptions
- renewal dates
- payment source
- category

Preserve the financial-management feel.

Do not make subscriptions look like products for sale.

---

# 31. Connected Accounts Reference

The current Connected Accounts screen includes:

- read-only sync reassurance
- encrypted/security messaging
- non-custodial statement
- total net liquid balance
- Sync All
- number of institutions
- last updated
- linked sources list
- GCash
- BDO
- Maya
- BPI reauthentication state
- masked identifiers
- balances
- sync times
- settings/disconnect

This screen is a trust surface.

Security messaging and connection state are part of the UI.

Do not remove them merely to reduce density.

---

# 32. Receipt Scanner / OCR Review Reference

The current Receipt Review screen includes:

- receipt detected confidence
- crop/frame controls
- OCR status
- merchant
- date/time
- parse verification
- low-confidence warning
- extracted item list
- item-level confidence
- subtotal
- VAT
- total
- editable fields
- save/confirm flow

Important:
- confidence is visible
- uncertain extraction can be reviewed
- line items are structured

Do not reduce receipt OCR to "merchant + total" only.

---

# 33. Financial Data Model

A normalized transaction should support at least:

```text
id
user_id
account_id
provider_id
external_transaction_id

type
status

merchant_id
merchant_name
normalized_merchant_name
description

amount
currency

transaction_date
posted_date

category_id
subcategory_id

source
confidence

is_transfer
transfer_group_id

receipt_id

metadata

created_at
updated_at
```

Transaction types:

```text
EXPENSE
INCOME
TRANSFER
REFUND
FEE
REVERSAL
```

Transaction status:

```text
PENDING
POSTED
SETTLED
REVERSED
CANCELLED
```

Transaction source:

```text
BANK_SYNC
EWALLET_SYNC
RECEIPT
MANUAL
IMPORT
SYSTEM
```

Use decimal/numeric money arithmetic.

Never use floating-point arithmetic for persisted money.

---

# 34. Balance Concepts

Do not merge these concepts.

## Financial account balance

Reported by provider.

## Budget remaining

Budget limit minus qualifying expenses.

## Safe-to-spend estimate

A derived product estimate.

## Net flow

Income minus expenses for a time period.

Label each clearly.

Do not show stale account data as live.

---

# 35. Transfers

Internal account transfers must not count as expenses.

Example:

```text
BDO → GCash
₱5,000
```

This is a transfer.

It should:
- appear neutrally in Transactions
- preserve source/destination
- be excluded from expense totals
- not reduce net worth merely because it moved between owned accounts

Create transfer matching logic where imported feeds create two sides.

---

# 36. Refunds and Reversals

Financial analytics must correctly account for:
- refunds
- reversed transactions
- charge reversals
- fees

Example:

```text
Purchase ₱500
Refund ₱500

Net expense: ₱0
```

Add tests.

---

# 37. Categorization

Use layered categorization:

1. transaction-type classification
2. provider metadata / MCC where available
3. normalized merchant rule
4. user-specific merchant rule
5. global rule
6. AI/ML classification where useful
7. user confirmation/correction

Never make AI the only classification mechanism.

User correction should take precedence for that user.

---

# 38. Receipt OCR

Preferred pipeline:

```text
Capture
→ Crop
→ Perspective correction
→ Enhance
→ OCR
→ Parse
→ Extract merchant/date/items/total
→ Confidence
→ User review
→ Persist
```

Use on-device OCR where practical.

Do not silently save uncertain OCR values.

The existing Receipt Review UI explicitly supports confidence and correction.

---

# 39. Financial Provider Abstraction

Never hard-code business logic to one financial provider.

Define a provider interface conceptually like:

```text
FinancialProvider
  connect()
  getConnectionStatus()
  getAccounts()
  getBalances()
  getTransactions()
  refresh()
  disconnect()
```

Provider-specific code belongs in adapter modules.

Do not invent provider APIs.

If a real integration is unavailable:
- implement mock/fake provider
- document blocker
- preserve interface
- continue development

Never scrape consumer bank/e-wallet websites.

Never collect:
- bank passwords
- e-wallet passwords
- PINs
- CVVs

---

# 40. Flutter Stack

Use:

```text
Flutter
Dart
Riverpod
GoRouter
Dio
Freezed
json_serializable
Drift / SQLite
flutter_secure_storage
local_auth
camera
ML Kit / suitable OCR package
Firebase Cloud Messaging
```

Package choices can evolve, but:
- use mature packages
- avoid redundant packages
- explain new dependencies

---

# 41. Flutter Project Architecture

Recommended:

```text
mobile/
└── lib/
    ├── app/
    │   ├── app.dart
    │   ├── router.dart
    │   └── theme/
    │       ├── app_colors.dart
    │       ├── app_spacing.dart
    │       ├── app_radius.dart
    │       ├── app_typography.dart
    │       ├── app_shadows.dart
    │       └── app_theme.dart
    │
    ├── core/
    │   ├── errors/
    │   ├── network/
    │   ├── storage/
    │   ├── security/
    │   ├── logging/
    │   ├── formatting/
    │   └── widgets/
    │
    ├── features/
    │   ├── auth/
    │   ├── dashboard/
    │   ├── transactions/
    │   ├── accounts/
    │   ├── financial_connections/
    │   ├── budgets/
    │   ├── analytics/
    │   ├── receipts/
    │   ├── subscriptions/
    │   ├── notifications/
    │   └── settings/
    │
    └── main.dart
```

Within feature:

```text
data/
domain/
application/
presentation/
```

Business logic must not live in presentation widgets.

---

# 42. State Management

Use Riverpod.

State classes should explicitly represent:

```text
initial
loading
data
empty
error
refreshing
offline
```

where relevant.

Avoid:
- global mutable singleton state
- manually passing giant model trees through constructors
- business logic in `setState`

`setState` is fine for truly local ephemeral UI state.

---

# 43. Backend

Recommended:

```text
NestJS
TypeScript
PostgreSQL
Redis
Queue worker
Object storage
```

Modules:

```text
auth
users
accounts
financial-connections
transactions
merchants
categories
receipts
budgets
analytics
subscriptions
notifications
sync
audit
```

Provider adapters remain isolated.

---

# 44. API Design

Use versioned routes:

```text
/v1
```

Examples:

```text
GET    /v1/accounts
POST   /v1/connections
POST   /v1/connections/:id/sync
DELETE /v1/connections/:id

GET    /v1/transactions
POST   /v1/transactions
GET    /v1/transactions/:id
PATCH  /v1/transactions/:id

POST   /v1/receipts/scan
GET    /v1/receipts/:id

GET    /v1/budgets
POST   /v1/budgets
PATCH  /v1/budgets/:id

GET    /v1/analytics/summary
GET    /v1/analytics/categories
GET    /v1/analytics/trends
GET    /v1/analytics/comparisons

GET    /v1/subscriptions
```

Never expose provider secrets to Flutter.

---

# 45. Security

Treat this as a financial application.

Minimum requirements:
- TLS
- secure authentication
- object-level authorization
- short-lived access credentials
- token rotation where applicable
- secure local token storage
- encryption at rest
- secrets manager
- KMS/key management
- input validation
- rate limiting
- webhook signature checks
- audit logs
- safe file uploads
- dependency scanning
- security testing

Use OWASP MASVS concepts for mobile and OWASP API Security guidance for backend.

---

# 46. Sensitive Data

Never log:
- authentication tokens
- provider credentials
- bank passwords
- card numbers
- CVV
- PIN
- raw secrets

Mask:
- account identifiers
- reference numbers where necessary

Receipt data may contain personal information.

Restrict access.

---

# 47. Authentication UX

Authentication screens not currently in Stitch must inherit the same design language.

Prioritize:
- clean typography
- minimal form density
- security reassurance
- optional biometric unlock after successful login

Do not make login visually inconsistent with approved screens.

---

# 48. Income / Expense / Transfer Modes

The Add Expense Stitch screen already establishes a three-mode concept:

```text
Expense
Income
Transfer
```

Use this pattern for new Add Income / Add Transfer screens.

Preserve:
- segmented mode control
- hero money input
- contextual fields
- clear final CTA

Do not build three unrelated visual systems.

---

# 49. Budget Status

Use semantic statuses like:

```text
Healthy
On track
Slow down slightly
At risk
Exceeded
```

Budget color:
- normal: primary
- approaching: warning
- exceeded: danger

Do not shame users.

---

# 50. Budget Forecasting

Support:

```text
spent
limit
remaining
percentageUsed
percentagePeriodElapsed
safeDailyPace
projectedEndTotal
projectedOverage
```

The existing Budgets screen already contains:
- safe daily pace
- estimated month-end
- projected overage

The domain model must support the approved UI.

---

# 51. Analytics

Precompute or efficiently query aggregate data.

Dimensions:
- day
- week
- month
- year
- category
- merchant
- account

Metrics:
- total expenses
- total income
- net flow
- savings
- savings rate
- transaction count
- average spend
- category percentage
- projected spend

Do not calculate huge histories from raw rows on every render.

---

# 52. Comparison Engine

Support:

```text
current vs previous day
current week vs previous week
current month vs previous month
current year vs previous year
same month last year
```

Return:
- absolute change
- percent change
- direction

When previous value is zero:
- do not divide by zero
- represent as new spending/income

---

# 53. Subscriptions

Detect recurring transactions using:
- normalized merchant
- amount similarity
- date interval
- repeated history

Support:
- weekly
- monthly
- quarterly
- yearly

The domain model should support:
- amount
- monthly equivalent
- annualized amount
- next renewal
- payment source
- category
- confidence

---

# 54. Notifications

Support:
- budget warning
- budget exceeded
- subscription renewal
- unusual spending
- large transaction
- sync failure
- connection expiry
- low balance
- monthly report

UI should use calm copy.

Avoid notification spam.

Add deduplication/cooldowns.

---

# 55. Financial Language

Never use shame-based copy.

Bad:

```text
You failed your budget.
You wasted money.
Bad spending.
```

Approved tone:

```text
You're approaching your limit.
Spending is higher than last month.
This category is trending above plan.
You're still within your overall budget.
```

---

# 56. Testing — UI

For Stitch-backed screens, add:

- widget tests
- golden/screenshot tests where practical

Goldens should test:
- stable fixture data
- light mode
- primary supported viewport
- optionally dark mode

Do not create fragile goldens for live timestamps/random values.

Use deterministic fixture data.

Golden comparison is a supplement to human visual review, not a replacement.

---

# 57. Testing — Domain

Required tests include:

### Transfer

```text
BDO → GCash ₱5,000
expense impact = ₱0
```

### Expense

```text
Jollibee ₱325
food expense = ₱325
```

### Refund

```text
purchase ₱500
refund ₱500
net expense = ₱0
```

### Budget

```text
limit = ₱8,000
spent = ₱6,900
used = 86.25%
```

### Zero comparison

```text
previous = 0
current = 500
```

No infinite percentage.

### Salary double-count prevention

Planned salary and imported salary must not both count as received income.

---

# 58. Visual QA Checklist

Before marking a Stitch-backed screen complete:

- compare against `screen.png`
- check header height
- check horizontal margins
- check section spacing
- check font sizes
- check font weights
- check numeric hierarchy
- check icon sizes
- check icon containers
- check card radius
- check borders
- check shadow subtlety
- check progress-bar thickness
- check list-row height
- check bottom navigation
- check safe-area handling
- check scroll behavior
- check long-text behavior
- check small-device width
- check large-device width
- check loading state
- check empty state
- check error state
- check dark mode
- check accessibility

Do not accept "close enough" when obvious visual drift remains.

---

# 59. Screenshot Comparison Workflow

When the environment supports screenshots/emulator capture:

1. run the Flutter target screen
2. capture at approximately the Stitch reference viewport
3. compare side-by-side with Stitch `screen.png`
4. identify the largest 3–5 mismatches
5. fix layout/tokens/components
6. repeat

Prioritize mismatches by:
1. hierarchy
2. spacing
3. component size
4. typography
5. color
6. micro-detail

Do not chase one-pixel decorative differences before fixing hierarchy.

---

# 60. Do Not Overfit to HTML

The Stitch export contains `code.html`.

Use it to understand:
- exact labels
- icon names
- section structure
- rough CSS dimensions
- color use
- hierarchy

Do not:
- copy HTML architecture
- copy utility classes
- reproduce web-only behavior
- make Flutter dependent on HTML

---

# 61. Asset Handling

If the Stitch export references imagery:
- locate the original reference
- add it to Flutter assets if allowed
- preserve aspect ratio
- use appropriate resolution

Do not download random substitute images without instruction.

Do not bundle remote provider logos unnecessarily.

---

# 62. Formatting Money

Create a centralized formatter.

Examples:

```text
₱325.00
₱16,800.00
+₱45,000.00
-₱325.00
```

The UI may use condensed forms in specific approved places:

```text
+₱45k
-₱16.8k
```

Do not scatter formatting logic throughout widgets.

---

# 63. Dates and Time

Centralize:
- local date format
- relative time
- month labels
- transaction timestamps

Examples from design:

```text
Thursday, Oct 24
Today, 12:32 PM
Synced 5m ago
```

Do not hard-code dates.

Fixture/demo data can reproduce Stitch values for visual testing.

---

# 64. Demo / Fixture Data

Maintain a fixture layer that matches Stitch sample values.

Purpose:
- UI development
- golden tests
- Storybook-like component previews if implemented
- offline demos

Example fixture entities:
- GCash Personal
- BDO Checking
- Maya Wallet
- BPI Savings
- Jollibee
- Grab
- SM Supermarket
- Netflix
- Spotify
- Google One
- iCloud+

Fixtures are not production-provider integrations.

---

# 65. Database

Use PostgreSQL migrations.

Money:
- NUMERIC/DECIMAL

Never:
- FLOAT for persisted financial values

Indexes should cover:
- user
- account
- date
- category
- merchant
- external transaction ID

Use uniqueness constraints for provider identity where appropriate.

---

# 66. Observability

Log:
- request ID
- sync run ID
- provider adapter name
- safe status/error category
- duration

Do not log raw sensitive financial payloads by default.

Monitor:
- API latency
- sync failure
- queue lag
- OCR failure
- duplicate rate
- notification delivery
- crashes

---

# 67. CI/CD

Every PR should run:
- formatting
- analyzer/lint
- Flutter tests
- backend tests
- security/dependency checks

Where practical:
- golden UI tests for stable screens

Never commit:
- `.env`
- API secrets
- provider credentials
- signing keys
- private certificates

---

# 68. Git Practice

Prefer focused commits:

```text
feat(ui): implement Stitch home dashboard
feat(ui): add transaction tile component
feat(ui): match budget progress states
feat(receipts): implement OCR review screen
fix(ui): align analytics spacing with Stitch reference
fix(finance): exclude transfers from expense totals
test(ui): add home dashboard golden
```

Do not mix unrelated backend and visual refactors in the same large commit.

---

# 69. Codex Working Rules

When Codex receives a task:

1. Read this file.
2. Inspect relevant existing code.
3. Inspect relevant Stitch references.
4. Identify reuse opportunities.
5. Make the smallest coherent change.
6. Run formatting/analyzer.
7. Run relevant tests.
8. Visually validate UI when applicable.
9. Review financial correctness.
10. Review security/privacy.
11. Update docs only if the change affects architecture or product behavior.

Do not rewrite the project from scratch unless explicitly requested.

---

# 70. Codex UI Rules

When a user asks to implement an approved screen:

Codex must:
- open the screenshot
- inspect HTML
- identify tokens
- implement using existing components
- preserve copy unless functionality requires dynamic data
- wire fixture data first if backend is unavailable
- then connect to application state

Codex must NOT respond by:
- proposing an entirely new design
- replacing the screen with generic scaffold
- simplifying it to speed up implementation without explaining
- ignoring the provided Stitch reference

---

# 71. Codex New-Screen Rules

If a requested screen does not exist in Stitch:

1. inspect neighboring screens
2. reuse existing shell/navigation
3. reuse design tokens
4. reuse component patterns
5. preserve typography hierarchy
6. preserve mobile spacing
7. create only the new elements needed
8. avoid introducing a new visual concept

Example:

Add Income should inherit most of Add Expense.

Add Transfer should inherit the same shell and amount-entry design.

---

# 72. Definition of Done — UI Feature

A UI feature is complete only when:

- it matches the approved visual reference closely
- it supports actual application state
- loading works
- empty state works
- error state works
- responsive layout works
- safe area works
- accessibility is considered
- dark mode is handled
- navigation works
- tests exist where valuable
- no sensitive values are logged
- no financial semantics are broken

Compiling is not sufficient.

---

# 73. Definition of Done — Financial Feature

A financial feature is complete only when:

- ownership/authorization is correct
- money arithmetic is decimal-safe
- transfer behavior is correct
- refund/reversal behavior is correct
- duplication behavior is correct
- source/provenance is preserved
- analytics implications are correct
- UI communicates status accurately
- relevant tests pass

---

# 74. Implementation Phases

## Phase 1 — Repository / Design Foundation

- place Stitch export in design reference directory
- set up Flutter
- add theme tokens
- add typography
- add routing
- add component primitives
- add fixture data
- establish golden-test strategy

## Phase 2 — Approved UI Screens

Implement, preferably in this order:

1. Home Dashboard
2. Transactions
3. Transaction Detail
4. Add Expense
5. Budgets
6. Analytics
7. Connected Accounts
8. Subscriptions
9. Receipt Scanner Review

Reason:
- Home establishes shell/theme
- Transactions establishes lists
- Transaction Detail establishes deeper information patterns
- Add Expense establishes form language
- Budgets/Analytics establish visualization
- Accounts establishes trust/security UI
- Receipt establishes OCR/review patterns

## Phase 3 — Missing UI Screens

Add:
- authentication
- onboarding
- add income
- add transfer
- create budget
- settings
- notifications
- connection consent
- account detail

Infer from approved system.

## Phase 4 — Domain / Persistence

Wire:
- models
- repositories
- local data
- backend API

## Phase 5 — Integrations

- OCR
- notifications
- financial provider adapters
- sync workers

## Phase 6 — Hardening

- accessibility
- dark mode polish
- performance
- security review
- integration tests
- visual regression

---

# 75. First Codex Task for an Empty Repository

If starting from scratch:

1. Read `CODEX.md`.
2. Inspect all Stitch files.
3. Create `docs/ui-reference.md` listing every approved screen.
4. Scaffold Flutter application.
5. Create design token/theme layer based on Stitch.
6. Set up GoRouter.
7. Set up Riverpod.
8. Create fixture/demo data matching Stitch.
9. Implement shared shell and bottom navigation.
10. Implement Home Dashboard with fixture data.
11. Compare visually against Stitch.
12. Add widget/golden tests.
13. Implement Transactions.
14. Continue screen-by-screen.
15. Do not start real bank/e-wallet integrations before the application architecture is ready.

---

# 76. Product Priorities

When tradeoffs are required:

```text
Security
>
Financial correctness
>
UI fidelity
>
Reliability
>
Accessibility
>
Maintainability
>
Performance
>
Feature breadth
```

UI fidelity is intentionally high priority because approved screens already exist.

But never sacrifice:
- security
- financial correctness
- accessibility-critical behavior

for exact pixels.

---

# 77. Product North Star

Every feature should help answer one or more:

1. How much money do I have?
2. How much did I spend?
3. Where did the money go?
4. Am I within my limits?
5. What changed?
6. What recurring expenses do I have?
7. What needs my attention?
8. What can I safely improve?

Do not prioritize decorative features over these goals.

---

# 78. Final Instruction to Codex

This project is **not in the design-discovery phase for existing screens**.

The approved Stitch screens already define the visual direction.

Your job is to:

> **Translate the approved PesoFlow Stitch UI into a high-quality Flutter application while preserving its design fidelity, financial semantics, accessibility, security, and maintainable architecture.**

When uncertain:
- inspect the screenshot
- inspect the design tokens
- inspect the HTML
- reuse existing Flutter components
- favor financial correctness
- avoid unnecessary redesign

Do not invent a new PesoFlow.
Build the approved PesoFlow.
