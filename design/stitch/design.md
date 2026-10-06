---
version: alpha
name: "PesoFlow — Calm Financial Intelligence"
description: "Premium, calm, mobile-first fintech design system for a personal finance app."
colors:
  primary: "#2563EB"
  primary-strong: "#1D4ED8"
  primary-soft: "#DBEAFE"
  secondary: "#0F766E"
  secondary-soft: "#CCFBF1"
  accent: "#7C3AED"
  accent-soft: "#EDE9FE"
  positive: "#16A34A"
  positive-soft: "#DCFCE7"
  warning: "#D97706"
  warning-soft: "#FEF3C7"
  danger: "#DC2626"
  danger-soft: "#FEE2E2"
  ink: "#0F172A"
  ink-secondary: "#475569"
  ink-muted: "#64748B"
  surface: "#FFFFFF"
  surface-subtle: "#F8FAFC"
  surface-muted: "#F1F5F9"
  border: "#E2E8F0"
  border-strong: "#CBD5E1"
  dark-surface: "#0B1220"
  dark-surface-subtle: "#111827"
  dark-surface-muted: "#1E293B"
  dark-ink: "#F8FAFC"
  dark-ink-secondary: "#CBD5E1"
  dark-ink-muted: "#94A3B8"
  dark-border: "#334155"
typography:
  display:
    fontFamily: "Inter"
    fontSize: "34px"
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.03em"
  h1:
    fontFamily: "Inter"
    fontSize: "28px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.025em"
  h2:
    fontFamily: "Inter"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  h3:
    fontFamily: "Inter"
    fontSize: "18px"
    fontWeight: 650
    lineHeight: 1.25
    letterSpacing: "-0.01em"
  body-lg:
    fontFamily: "Inter"
    fontSize: "16px"
    fontWeight: 450
    lineHeight: 1.5
  body:
    fontFamily: "Inter"
    fontSize: "14px"
    fontWeight: 450
    lineHeight: 1.45
  body-sm:
    fontFamily: "Inter"
    fontSize: "12px"
    fontWeight: 450
    lineHeight: 1.4
  label:
    fontFamily: "Inter"
    fontSize: "12px"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0.01em"
  numeric-xl:
    fontFamily: "Inter"
    fontSize: "32px"
    fontWeight: 750
    lineHeight: 1.0
    letterSpacing: "-0.035em"
  numeric-lg:
    fontFamily: "Inter"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.0
    letterSpacing: "-0.025em"
  numeric-md:
    fontFamily: "Inter"
    fontSize: "18px"
    fontWeight: 700
    lineHeight: 1.0
    letterSpacing: "-0.02em"
rounded:
  xs: "6px"
  sm: "10px"
  md: "14px"
  lg: "18px"
  xl: "24px"
  full: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  2xl: "32px"
  3xl: "40px"
  4xl: "48px"
elevation:
  none: "none"
  subtle: "0 1px 2px rgba(15,23,42,0.04)"
  card: "0 4px 16px rgba(15,23,42,0.06)"
  elevated: "0 10px 30px rgba(15,23,42,0.10)"
  modal: "0 20px 50px rgba(15,23,42,0.18)"
---

## Overview

PesoFlow is a premium mobile personal-finance application. The interface should make complicated financial information feel **calm, clear, trustworthy, and actionable**.

Visual personality: **modern fintech + premium productivity + editorial clarity**.

The emotional goal is: **“I understand my money now.”**

The app should feel safe and non-judgmental. It should never look like a spreadsheet, old accounting software, crypto trading terminal, generic SaaS admin dashboard, or gamified children’s budget app.

This is a true **mobile-first** product. Design for one-handed use, thumb reach, scrolling, safe areas, keyboard behavior, and compact phone widths. Do not squeeze desktop layouts into a phone.

## Colors

Primary blue is the trusted interaction color. Use it for the main CTA, selected navigation, key controls, and links.

Teal represents stable/positive financial progress. Purple is an occasional intelligence/productivity accent, not a second primary color.

Green, amber, and red are semantic only:
- green = positive / under budget / successful
- amber = approaching limit / needs attention
- red = exceeded / failed / destructive

Do not use entire screens or large cards as red/green decoration. Prefer small accents, icons, values, progress bars, and badges.

Never rely on color alone to communicate status.

## Typography

Use **Inter** throughout. Financial numbers are the visual anchors of the product, so currency and percentages should use larger, heavier numeric styles than surrounding labels.

Use no more than two font weights in one compact component. Avoid ultra-thin text for money and avoid decorative fonts.

Use locale-aware PHP formatting, e.g. `₱30,650`.

## Layout & Spacing

Use an 8pt rhythm: 4, 8, 12, 16, 24, 32, 40, 48px.

Default phone horizontal padding: 16px, increasing to 20–24px on larger screens.

Prefer whitespace and progressive disclosure over dense card grids.

A screen should have one dominant story, clear secondary groups, and enough breathing room that users can scan without reading everything.

## Elevation & Depth

Use subtle borders and soft shadows. Cards should feel gently lifted, never floating dramatically.

Avoid heavy shadows, neon glows, large blurred backgrounds, and excessive glassmorphism.

## Shapes

Use a consistent rounded language:
- 10px controls
- 14px standard cards
- 18px feature/hero cards
- 24px special hero containers
- full-radius only for pills/chips

Do not make every element a pill.

## Components

### Bottom Navigation

Five destinations: Home, Transactions, Add, Analytics, Budgets. Selected state uses primary blue and a subtle active indicator. Unselected state is muted.

### Dashboard Hero

The balance is the most visually important element.

Example:

`Total available`

`₱30,650`

`↑ ₱2,430 this month`

Do not surround the hero with decorative clutter.

### Income / Expense Summary

Use a clean two-column or compact segmented summary. Numbers are prominent; labels are secondary.

### Budget Meters

Use compact horizontal progress bars with explicit values:

`Food`
`₱6,900 / ₱8,000`
`86%`

Use primary for normal, amber for at-risk, red for exceeded.

Do not turn every budget into a giant circular gauge.

### Category Breakdown

Prefer ranked horizontal bars or a restrained donut plus textual labels. Always expose the actual amount and percentage.

### Transaction Rows

Left: category/merchant icon. Center: merchant, category/account/date metadata. Right: PHP amount and optional status.

Examples:

`Jollibee        -₱325`
`Food · GCash · 12:32 PM`

`Salary       +₱45,000`
`Income · BDO`

`BDO → GCash     ₱5,000`
`Transfer`

Transfers must never visually read as ordinary expenses.

### Buttons

Primary: filled blue, 48–52px minimum comfortable touch area, 10–14px radius.

Secondary: tonal or outlined.

Tertiary: text action.

Destructive: red only when genuinely destructive.

### Inputs

Labels should be obvious. Money input should visually prioritize the amount:

`Amount`

`₱ 5,250.00`

### Bottom Sheets

Use for filters, category selection, account selection, budget creation, and transaction actions. Preserve context behind the sheet where possible.

### Charts

Use readable line/area trends and simple category bars. Avoid 3D charts, cluttered legends, dual axes, and chart-only communication. Provide textual summaries under charts.

### Alerts

Use concise, factual, supportive language:

`Food budget is almost reached`
`You’ve used 90% of your ₱8,000 monthly Food budget.`

Do not use shame or fear.

### Financial Connection Cards

These screens must feel exceptionally trustworthy. Show provider, account type, balance, connection state, last synced time, and permissions. Explain what the app can and cannot do.

Never imply PesoFlow is the bank/e-wallet.

### Receipt Scanner

Camera state should have a subtle receipt guide, capture control, flash, and gallery import. Review state should show extracted merchant, items, totals, category, date, and account. Uncertain OCR fields are editable and visibly reviewable.

### Subscription Cards

Show merchant, recurring amount, frequency, and next expected date. Keep them informational, not promotional.

### Insight Cards

Use human language:

`You spent 18% more on Transportation than last month.`

Then, when possible:

`Transportation increased by ₱1,300, mainly from ride-hailing.`

## Navigation & Screen System

Primary screens:
- Onboarding / Welcome
- Home Dashboard
- Transactions
- Transaction Detail
- Add Expense
- Add Income
- Add Transfer
- Receipt Scanner
- Receipt Review
- Analytics
- Budgets
- Budget Detail
- Create Budget
- Subscriptions
- Connected Accounts
- Connection Consent
- Account Detail
- Notifications
- Settings

### Home

Must be scannable in under 10 seconds. Show balance, income/expenses/savings, budget progress, category spending, recent transactions, upcoming recurring items, and one key insight.

### Transactions

Search/filter/date range at top. Group by date. Support expense, income, transfer, refund, pending, and fee states.

### Analytics

Show total expense, period comparison, Day/Week/Month/Year switcher, trend, category breakdown, top merchants, average spend, and spending pace.

### Budgets

Show overall budget first, category budgets second. Include spent, remaining, used percentage, and projected end-of-period spending where available.

### Connected Accounts

Show account balance, status, last sync, and permissions. A disconnected/error state must be explicit.

## Responsive Mobile Composition

Small phones: single column, compact metadata, short labels, readable charts.

Large phones: slightly wider cards and richer chart detail without turning into a desktop dashboard.

Tablets later: use split layouts and wider detail views rather than simply scaling phone UI.

## Motion

Motion should communicate progress, navigation, and confirmation. Prefer 150–300ms transitions and subtle progress animation. Avoid bouncing, particles, perpetual motion, and gimmicky transitions.

Financial software should feel stable.

## Dark Mode

Dark mode is first-class. Use deep navy/slate surfaces rather than pure black and inverted white. Preserve hierarchy with tonal surfaces and subtle borders.

## Accessibility

Aim for WCAG AA-level contrast where applicable. Use accessible touch targets, semantic labels, clear focus states, dynamic text support, and textual summaries for charts. Never communicate status through color alone.

## Financial UX Rules

Never shame users. Prefer neutral language:
- “Above your planned budget.”
- “Spending is increasing.”
- “Higher than your usual spending.”

When a budget is exceeded, help the user understand why.

## Data Trust UX

Imported financial records should expose provenance when appropriate: account, provider, source, pending/posted state, and last sync. Never present stale provider data as live.

## Do's and Don'ts

### Do
- Do make the primary financial number immediately obvious.
- Do use whitespace to simplify complex financial information.
- Do keep one primary action per screen.
- Do use semantic color sparingly.
- Do show actual chart values alongside visuals.
- Do make financial connection permissions explicit.
- Do show last-sync information.
- Do make corrections easy for users.
- Do keep the tone supportive and non-judgmental.
- Do design for small phones first.
- Do reuse patterns consistently across screens.

### Don't
- Don't create a desktop admin dashboard squeezed into a phone.
- Don't use gradients everywhere.
- Don't use crypto/trading aesthetics.
- Don't overuse glassmorphism.
- Don't make every metric its own card.
- Don't use giant circular charts for everything.
- Don't hide important values in tooltips.
- Don't use color as the only status cue.
- Don't use shame-based language.
- Don't fabricate provider capabilities or financial institution branding.

## Screen Prompt Starters

### Home
“Design a premium mobile personal-finance dashboard for PesoFlow. Use a calm white/slate surface, Inter typography, a large PHP balance hero, subtle blue trust accents, compact income-vs-expense comparison, clean budget progress bars, ranked category spending, recent transactions, upcoming recurring payments, and one helpful financial insight. Use generous whitespace and strong hierarchy. Avoid dense admin-dashboard cards, loud gradients, crypto aesthetics, or excessive decoration.”

### Analytics
“Design a mobile financial analytics screen for PesoFlow. Show a large total expense value, comparison versus the previous period, Day/Week/Month/Year segmented control, a clean trend chart, category breakdown with readable labels and percentages, and concise insights. Prioritize readability of PHP values and avoid chart clutter.”

### Budgets
“Design a calm mobile budgeting screen for PesoFlow. Show overall budget progress at the top, then ranked category budgets with current spend, limit, remaining amount, percentage used, and subtle warning states. Make it visually obvious which budgets are on track versus at risk without aggressive colors.”

### Transactions
“Design a premium mobile transaction list for PesoFlow. Group transactions by date, use clear category/merchant icons, place merchant metadata on the left and right-align PHP amounts. Distinguish expense, income, transfer, refund, pending, and fee states clearly. Provide search and filter controls.”

### Receipt
“Design a focused receipt-scanning workflow for PesoFlow. Start with a camera capture screen with a subtle receipt guide. After OCR, show a polished review screen with merchant, line items, subtotal, tax, total, category, date, and account. Highlight uncertain extracted values subtly and make correction fast.”

### Connections
“Design a high-trust connected-accounts flow for PesoFlow. Show provider, account type, balance, connection state, last synced time, and permissions. Explicitly communicate that the app reads financial information and cannot send money. Use restrained, trustworthy visuals.”

### Subscriptions
“Design a clean mobile subscription-management screen for PesoFlow. Show total monthly recurring commitment, then subscription rows with merchant, amount, frequency, and next expected date. Keep it informational and premium.”

## Design Quality Gate

Every screen should answer yes to:
1. Is the primary number understandable within 2 seconds?
2. Is there one obvious primary action?
3. Can the screen be scanned quickly?
4. Are financial values more prominent than decoration?
5. Does the screen feel calm rather than stressful?
6. Is it genuinely mobile-first?
7. Are charts readable without interaction?
8. Are warnings understandable without color alone?
9. Does the screen reuse the same design system?
10. Does the UI feel shippable by a professional fintech/product team?

When iterating, preserve this visual language. Change composition and information hierarchy before changing colors, typography, radius, or overall personality.
