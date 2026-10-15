---
name: Calm Financial Intelligence
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#434655'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#575e70'
  on-secondary: '#ffffff'
  secondary-container: '#d9dff5'
  on-secondary-container: '#5c6274'
  tertiary: '#006329'
  on-tertiary: '#ffffff'
  tertiary-container: '#007f36'
  on-tertiary-container: '#c7ffca'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#dce2f7'
  secondary-fixed-dim: '#c0c6db'
  on-secondary-fixed: '#141b2b'
  on-secondary-fixed-variant: '#404758'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.005em
  currency-display:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  currency-card:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.005em
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-xs:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.25rem
  gutter-tablet: 1.5rem
  gutter-desktop: 2rem
  margin: 1.25rem
  margin-tablet: 2rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
---

## Brand & Style

The design system establishes a focused, calm, and human-crafted financial workspace engineered specifically for personal expense tracking, ledger discipline, and budgeting intelligence. Unlike transactional consumer banks or aggressive retail lending apps that bombard users with promotional loan carousels, cashback marketing cards, and speculative crypto widgets, this design system embodies high-clarity utility.

The aesthetic philosophy merges **Modern Fintech Functionalism** with **Calm Tactile Minimalism**. Every screen prioritizes cognitive ease:
- The interface acts as a quiet, trustworthy paper ledger brought into the digital age, stripping away marketing friction to let daily cashflow numbers speak with clarity.
- Visual hierarchy is immediate: high-contrast dark slate ink against pristine white card surfaces, underpinned by an ultra-soft neutral ground that eliminates eye fatigue.
- Primary engagement is intentional and precise—anchoring exclusively around a focused utility blue for transactional logging, categorical filtering, and budget tracking.
- The emotional tone evokes control, serenity, and financial agency.

## Colors

The color palette is purposefully disciplined, rejecting decorative rainbow gradients and saturated marketing accents in favor of functional financial utility.

### Palette Architecture
- **Primary Interactive (`#2563EB`)**: Refined utility blue reserved strictly for actionable items—primary submit buttons, expense logging triggers, active tab indicators, and date-range highlights.
- **Secondary / Ink Base (`#111827`)**: Deep slate ink delivering maximum typographic legibility for primary currency balances, account names, and structural headings.
- **Tertiary / Inflow Positive (`#16A34A`)**: A balanced, restrained emerald used exclusively for incoming cashflow, income logs, and positive budget variance.
- **Neutral Core (`#6B7280`)**: Neutral slate used for metadata, timestamps, category tags, and secondary row descriptions.

### Surface, Border, and Feedback Tones
- **Canvas Ground**: `#F7F8FA` — A soft, warm-neutral off-white that separates cleanly from foreground card modules without harsh glare.
- **Surface Elevation**: `#FFFFFF` — Pure crisp white reserved for functional containers, ledger cards, transaction lists, and bottom sheets.
- **Border & Hairline**: `#E5E7EB` — Crisp 1px structural outlines framing all cards, table rows, and input surfaces.
- **Muted Supporting Text**: `#9CA3AF` — For placeholders, disabled counters, and subtle ledger hints.
- **Pacing Alert (`#D97706`)**: Warm amber for budget thresholds approaching limits (e.g., 85%+ category spending).
- **Critical / Overspending (`#DC2626`)**: Direct crimson for negative balances, over-budget line items, and transaction deletion confirmation.

## Typography

The typography uses Inter across all levels to optimize micro-legibility and structural numeric clarity.

### Numeric & Currency Formatting Rules
- All numeric ledger values, account balances, and table cells must enforce tabular figures using CSS `font-variant-numeric: tabular-nums` or `font-feature-settings: "tnum" 1`. This aligns Philippine Peso currency amounts (`₱ 12,450.00`) cleanly across columnar layouts.
- Currency symbols (`₱`) share the font weight and color of their numeric figures but must not scale beyond standard headline thresholds. Huge promotional font scales are strictly prohibited; balances emphasize confident, compact authority over marketing dramatization.

### Hierarchy & Legibility
- Section headers rely on `headline-md` and `headline-sm` with slight negative tracking (`-0.01em`) to maintain sharp editorial composure.
- Secondary descriptions, transaction timestamps, and account types utilize `body-md` and `body-sm` rendered in `#6B7280`.
- Category badges, table metadata, and status indicators strictly employ `label-sm` or `label-xs` with uppercase tracking (`0.02em`) for immediate scannability.

## Layout & Spacing

The design system implements a column-based fluid grid anchored to a strict **4px/8px incremental base unit**.

### Rhythm & Breakpoints
- **Mobile (`< 640px`)**: Single-column layout with fixed `1.25rem` (20px) horizontal page margins. Inter-card vertical gap is set to `1rem` (16px), with a standard `1.5rem` (24px) vertical section rhythm separating major modules (e.g., Summary Cards to Transaction History).
- **Tablet (`640px - 1024px`)**: 6-column grid with `1.5rem` (24px) gutters and margins. Expense metrics form a 2-up responsive row, while category charts sit alongside monthly budgets.
- **Desktop (`> 1024px`)**: 12-column grid constrained to a maximum content container of `1200px`, using `2rem` (32px) gutters and `3rem` (48px) canvas margins. The ledger pane occupies 8 columns, while receipt previews, categorical drilldowns, and month-to-month analytics lock into a 4-column sticky sidebar.

### Component Internal Density
- Cards maintain `1.25rem` (20px) internal padding on desktop and tablet, flexing to `1rem` (16px) on compact mobile viewports.
- List items within transactional ledgers maintain a consistent `0.75rem` (12px) vertical cell padding to preserve dense, information-rich scanning without feeling congested.

## Elevation & Depth

Visual hierarchy is communicated through **tonal stacking, subtle low-contrast outlines, and whisper-soft ambient diffusion** rather than heavy drop shadows.

### Elevation Levels
- **Layer 0 (Canvas Base)**: `#F7F8FA` — Background canvas providing a restful foundational plane.
- **Layer 1 (Card & Content Containers)**: `#FFFFFF` surface bordered by a crisp `1px solid #E5E7EB` stroke. Shadow is restrained to an ambient blur: `box-shadow: 0 1px 3px 0 rgba(17, 24, 39, 0.04), 0 1px 2px -1px rgba(17, 24, 39, 0.02)`.
- **Layer 2 (Feature & Highlight Modules)**: For prime summary cards (e.g., Total Monthly Spend, Active Budget Progress), the card maintains a `#FFFFFF` fill with an elevated ambient diffusion: `box-shadow: 0 4px 6px -1px rgba(17, 24, 39, 0.05), 0 2px 4px -2px rgba(17, 24, 39, 0.03)` with a `1px solid #E5E7EB` perimeter.
- **Layer 3 (Overlays, Modals, & Bottom Sheets)**: Expense logging dialogs, category selection pickers, and receipt OCR camera drawers rise with `box-shadow: 0 20px 25px -5px rgba(17, 24, 39, 0.08), 0 8px 10px -6px rgba(17, 24, 39, 0.04)`, framed with `#E5E7EB` borders.
- **Layer 4 (Tooltips & Micro-popovers)**: Solid `#111827` dark slate popups with crisp white text, cast with zero colored aura.

No neon highlights, multi-colored glow effects, or translucent frosted blurs are permitted on core data surfaces.

## Shapes

The shape system balances modern mobile softness with the crisp precision demanded by corporate financial software.

### Geometric Rules
- **Standard Cards**: Governed by `rounded-lg` (16px radius), creating approachable yet neatly structured container blocks.
- **Feature & Hero Cards**: Governed by `rounded-xl` (20px radius) for prominent account summaries and cashflow overviews.
- **Interactive Controls (Buttons & Text Fields)**: Uses an exact radius between 10px and 12px (specifying standard `rounded-md` / 10px on mobile and 12px on desktop) to ensure interactive elements feel distinctly clickable without turning into playful pill shapes.
- **Badges, Status Chips, & Toggle Switches**: Pill-shaped (`rounded-full` / 9999px) for atomic, compact metadata labeling.
- **Modal Windows & Bottom Sheets**: Top corners are curved at 20px to 24px (`rounded-t-2xl`) for natural thumb-driven drag dismissals on mobile devices.

## Components

### Buttons
- **Primary Button**: Solid `#2563EB` fill, `#FFFFFF` text, 10–12px radius, font weight 600. Active state shifts to `#1D4ED8`. Strictly used for primary logging flows ("Add Expense", "Save Budget", "Confirm Entry").
- **Secondary / Outline Button**: `#FFFFFF` fill with a `1px solid #E5E7EB` border, text `#111827`, font weight 500. Hover state shifts background to `#F9FAFB`. Used for "Export CSV", "Filter", or "Cancel".
- **Ghost Button**: Transparent fill, text `#6B7280`, hover background `#F3F4F6`. Used for auxiliary toolbar actions and secondary pagination.

### Expense Logging Inputs & Form Fields
- **Amount Input Field**: Large tabular input featuring a fixed prefix `₱` in `#6B7280` followed by bold numeric entry in `#111827`. Background is `#FFFFFF` with a crisp `1px solid #E5E7EB` border and 12px radius. Focused state applies a sharp `2px` ring in `#2563EB` with zero external glow.
- **Standard Text Fields & Dropdowns**: 44px minimum tap target height, 10px radius, `#FFFFFF` background, `#111827` value text, and `#9CA3AF` placeholders. Clear visual labels sit above input fields in `label-sm` (`#374151`).

### Transaction Rows & List Views
- **Layout**: Clean horizontal arrangement with category icon container (40x40px, 10px rounded corner, `#F3F4F6` background), transaction title in `body-md` bold (`#111827`), timestamp and account tag in `body-sm` (`#6B7280`).
- **Right-Aligned Cashflow**: Tabular monetary figures. Expenses render in deep ink `#111827` (or negative marker `-₱450.00`). Inflows/income render strictly in `#16A34A` (`+₱25,000.00`).
- **Dividers**: 1px hair-line border `#F3F4F6` between items; no heavy card packaging per single transaction item.

### Budget Progress Bar
- **Track**: 6px height, pill-rounded, neutral background `#E5E7EB`.
- **Indicator Fill**: Normal pacing under 80% renders in `#2563EB`; pacing between 80%–99% shifts to warning amber `#D97706`; over-budget (100%+) shifts to alert crimson `#DC2626`.

### Chips & Filter Tabs
- **Segmented Time Filters (Weekly / Monthly / Yearly)**: Compact container in `#F3F4F6` with 8px radius containing sliding or active chips in `#FFFFFF` with `box-shadow: 0 1px 2px rgba(0,0,0,0.05)`, text `#111827`, and inactive text `#6B7280`.
- **Category Filter Chips**: 32px height, 1px solid `#E5E7EB`, text `label-sm` (`#4B5563`). When active: `#111827` fill with `#FFFFFF` text.

### Account Overview Cards (Read-Only)
- Pristine white card containers framed with 16px radius and 1px `#E5E7EB` borders.
- Institution icon, masked identifier (`•••• 4166`), and balance shown in tabular numbers.
- Strictly read-only: displays available balance and credit utilization without transfer, deposit, or wire-action buttons.

### Receipt Scanner Drawer
- Clean modal bottom sheet with camera frame view-finder bordered by clean 1px targeting guides.
- Post-scan breakdown card immediately parses merchant, date, VAT/tax, and line items into editable fields before user confirmation.