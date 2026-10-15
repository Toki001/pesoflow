---
name: PesoFlow Minimal Tracker
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
  tertiary: '#943700'
  on-tertiary: '#ffffff'
  tertiary-container: '#bc4800'
  on-tertiary-container: '#ffede6'
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
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
  currency-display:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  currency-card:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  currency-row:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
---

## Brand & Style

This design system is tailored for a dedicated, deliberate personal expense tracker. Unlike transactional consumer banks, multi-tier wallets, or fintech super-apps, this design system avoids noisy promotional banners, gamified points counters, redundant transfer shortcuts, and decorative AI gradients.

### Brand Personality & Emotional Tone
- **Composed & Grounded:** The interface acts as a silent, reliable ledger. It respects the user's cognitive bandwidth when logging and reviewing financial outflow.
- **Human & Purposeful:** Designed with meticulous visual cadence. Every pixel, line weight, and spacing interval conveys intentional craft rather than algorithmic filler.
- **Trustworthy Clarity:** Numbers are front and center, presented without visual distortion or excessive styling.

### Design Movement: Modern Functional Minimalism
The system pairs pure white functional card layers over an ultra-soft, warm neutral canvas (`#F7F8FA`). Elevation is driven primarily by crisp structural borders (`#E5E7EB`) and delicate, low-contrast diffuse micro-shadows rather than heavy drop shadows. High-contrast sans-serif typography (Inter) anchors information hierarchy, relying on strict typographical scales and tabular figures for financial data.

## Colors

The palette establishes clarity and restraint. It avoids multi-colored accents, gradients, and purple tints, focusing solely on meaningful status indication and focused interaction targets.

### Core System Palette
- **Primary Interaction (`#2563EB`):** Dedicated to active states, selected navigation tabs, primary submission buttons, and key progress indicators.
- **Primary Text (`#111827`):** Maximum contrast for currency figures, section headlines, and primary labels.
- **Secondary Text (`#6B7280`):** Supporting metadata, timestamps, account categories, and table subtitles.
- **Muted Text (`#9CA3AF`):** Input placeholders, inactive tab labels, and trailing indicators.
- **Page Canvas (`#F7F8FA`):** Warm, calming light neutral ground that provides subtle contrast against card surfaces.
- **Card Surfaces (`#FFFFFF`):** Crisp pure white containers holding transactions, analytics modules, and summary blocks.
- **Neutral Containers (`#F3F4F6`):** Applied to icon backgrounds, segmented control wells, and tag pills.
- **Dividers & Structural Borders (`#E5E7EB`):** Consistent 1px boundary across cards, bottom bar separators, and list rows.

### Semantic Status
- **Positive / Inflow (`#16A34A`):** Income transactions, budget surpluses, and savings gains.
- **Warning (`#D97706`):** Approaching budget limit (80%–99%).
- **Error / Overspending (`#DC2626`):** Exceeded budget limits, negative balances, and destructive actions.

## Typography

The typography is built around **Inter** to ensure maximum legibility, neutral aesthetic tone, and systematic optical consistency across all viewport densities.

### Rules for Financial Data & Tabular Figures
- **Tabular Numerals (`font-feature-settings: "tnum"`):** All instances displaying the Philippine Peso (`₱`) alongside numbers must activate OpenType tabular lining figures. This prevents jitter during list scanning and vertically aligns decimals.
- **Currency Symbol Formatting:** The Peso sign (`₱`) must match the font-weight of its numerical value and follow standard formatting without an extra space (e.g., `₱12,450.00`).
- **Hierarchy of Values:**
  - Net Balance / Monthly Expense: `currency-display` (30px/700 on desktop, 26px on compact mobile).
  - Category summaries & budget card allocations: `currency-card` (18px/600).
  - Transaction list rows: `currency-row` (15px/600).
- **Secondary & Meta Content:** Transaction categories, merchant subtexts, and timestamps strictly utilize `body-md` (14px) and `label-sm` (11px).

## Layout & Spacing

The layout employs a focused, centered fluid model optimized for thumb-reach and clear vertical rhythm on mobile devices, with adaptive containment for tablet and desktop viewports.

### Rhythm & Grid Model
- **Mobile Container:** Fluid width with `margin` of `1rem` (16px) and internal component gaps governed by the 4px baseline system (`0.25rem` intervals).
- **Tablet & Desktop Containment:** Content is capped at a centered max-width of `480px` for pure tracking views or `768px` for comparative analytics, preventing oversized stretched cards. Canvas margins scale to `2rem`.
- **Card Padding Cadence:** Internal card padding is consistently set to `1rem` (16px) or `1.25rem` (20px) for key hero cards, ensuring balanced white space around lists and stat readouts.

### App Shell Structure
- **Top App Bar (56px):** Universal height of 56px across all views. Contains current view title in `headline-md`, subtle back navigation (if drill-down), and optional date selector. Background matches canvas `#F7F8FA` or uses white `#FFFFFF` with a 1px bottom border `#E5E7EB`.
- **Universal Bottom Navigation (64px + safe area):**
  - Solid `#FFFFFF` surface with a crisp `1px` top border (`#E5E7EB`).
  - Strict 5-tab layout: **Home**, **Transactions**, **Add**, **Analytics**, **Budgets**.
  - The middle "Add" icon acts as the single primary expense entry point in the application.
  - Zero redundant "Add Expense" buttons or floating action buttons (FABs) on Home, Transactions, Analytics, or Budgets.

## Elevation & Depth

This design system deliberately rejects heavy, dark, or dramatic drop shadows, iridescent borders, and frosted glass treatments. Depth is communicated strictly through surface layering and fine micro-borders.

### Depth Mechanics
1. **Canvas Layer (Level 0):** The background canvas rests at `#F7F8FA`.
2. **Surface Layer (Level 1):** Content containers and cards rest at `#FFFFFF`. Depth is established by:
   - A crisp 1px structural outline: `border: 1px solid #E5E7EB`.
   - A near-invisible micro-shadow: `box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.04)`.
3. **Interactive & Floating Layer (Level 2):** Bottom sheets, modal entry prompts (triggered by the primary Add tab), and dropdown menus:
   - `box-shadow: 0 4px 16px -2px rgba(17, 24, 39, 0.08)`.
   - Structural outline: `border: 1px solid #E5E7EB`.
4. **Recessed Wells:** Input fields, segment switchers, and icon badges rest recessed within cards using background color `#F3F4F6` with no inner shadow.

## Shapes

The geometric architecture pairs soft, balanced ergonomics with structured tabular discipline.

### Radius Hierarchy
- **Cards & Primary Modules:** 16px to 18px radius (`rounded-lg` to `rounded-xl`). Strikes a human, friendly feel without becoming circular or toy-like.
- **Buttons & Input Fields:** 10px to 12px radius. Provides comfortable, ergonomic tap targets.
- **Segmented Controls & Tags:** 8px radius. Maintains crisp density inside smaller UI blocks.
- **Circular Indicators & Icon Badges:** Completely circular (`rounded-full`) reserved strictly for transaction category icons (e.g., 40x40px rounded circles) and status dots.

## Components

### 1. Cards
- **Architecture:** Pure white (`#FFFFFF`), `16px–18px` border radius, `1px` solid border (`#E5E7EB`), soft micro-shadow (`0 1px 3px rgba(0,0,0,0.04)`).
- **Internal Padding:** `16px` for transaction groups; `20px` for overview balance metrics.
- **Restrictions:** No decorative background gradients, no glowing edge treatments, and no multi-colored illustration badges.

### 2. Universal Navigation Bar (Bottom Tabs)
- **Structure:** 5 equal tab slots: `Home`, `Transactions`, `Add`, `Analytics`, `Budgets`.
- **Styling:** Height 64px (excluding safe-area inset). Background `#FFFFFF`. Border-top `1px solid #E5E7EB`.
- **Selected Tab:** Icon and label rendered in `#2563EB`. Label uses `label-sm` (11px, weight 600).
- **Unselected Tab:** Icon and label rendered in `#9CA3AF`.
- **Global "Add" Tab:** Center tab rendered either with a subtle 44px circular filled blue container (`#2563EB` with white plus icon) or standard active tab styling. It is the single universal creation trigger. No secondary Add Expense buttons on any view.

### 3. Buttons
- **Primary Button:** Background `#2563EB`, text `#FFFFFF`, font weight 600, border radius 12px, padding `12px 20px`. Hover/Active state darkens to `#1D4ED8`.
- **Secondary / Ghost Button:** Background transparent or `#F3F4F6`, text `#111827`, border radius 12px.
- **Destructive Button:** Background transparent, text `#DC2626`, hover background `#FEE2E2`.

### 4. Transaction List Rows
- **Layout:** Horizontal alignment:
  - Left: 40x40px category icon container (colored `#F3F4F6` with `#111827` or category-specific muted neutral iconography).
  - Middle: Category title in `body-md` (`#111827`, weight 500) above secondary note/time in `label-md` (`#6B7280`).
  - Right: Tabular amount in `currency-row`. Outflow displayed in primary text `#111827` (`-₱350.00`); Inflow displayed in positive semantic `#16A34A` (`+₱25,000.00`).
- **Dividers:** 1px hairline divider (`#E5E7EB`) inset to align with the text start, or clean card separation.

### 5. Input Fields
- **Container:** Height 48px, background `#F3F4F6` or `#FFFFFF` with `1px solid #E5E7EB`.
- **Focused State:** Border changes to `1.5px solid #2563EB`, no outer glow.
- **Labeling:** Clean top-aligned label in `label-md` (`#111827`), placeholder in `#9CA3AF`.
- **Numeric Keypad Input (Modal Add Flow):** Large hero input field using `currency-display` (36px tabular figures) with fixed `₱` prefix.

### 6. Chips & Segmented Controls
- **Segmented Control (e.g., Weekly / Monthly / Yearly):** Container background `#F3F4F6`, 8px radius, 4px internal padding. Active segment has white card background (`#FFFFFF`), subtle `0 1px 2px rgba(0,0,0,0.05)` shadow, and `#111827` text. Inactive segments have `#6B7280` text.
- **Filter Chips:** 8px radius, border `1px solid #E5E7EB`, background `#FFFFFF`. Selected state: border `#2563EB`, background `#EFF6FF`, text `#2563EB`.

### 7. Budget Progress Bars
- **Track:** Height 8px, background `#F3F4F6`, border radius 9999px.
- **Fill:**
  - Standard fill: `#2563EB`.
  - Near limit (>= 80%): `#D97706`.
  - Exceeded (>= 100%): `#DC2626`.