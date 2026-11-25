---
name: Harianku
colors:
  surface: '#faf8ff'
  surface-dim: '#d6d9ec'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#ebedff'
  surface-container-high: '#e4e7fb'
  surface-container-highest: '#dfe1f5'
  on-surface: '#171b29'
  on-surface-variant: '#444651'
  inverse-surface: '#2c303e'
  inverse-on-surface: '#eff0ff'
  outline: '#757682'
  outline-variant: '#c5c5d2'
  surface-tint: '#465aa1'
  primary: '#072369'
  on-primary: '#ffffff'
  primary-container: '#253b80'
  on-primary-container: '#94a8f5'
  inverse-primary: '#b6c4ff'
  secondary: '#006c45'
  on-secondary: '#ffffff'
  secondary-container: '#86f9bc'
  on-secondary-container: '#00734a'
  tertiary: '#5c0012'
  on-tertiary: '#ffffff'
  tertiary-container: '#810f22'
  on-tertiary-container: '#ff898d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#00164f'
  on-primary-fixed-variant: '#2d4287'
  secondary-fixed: '#86f9bc'
  secondary-fixed-dim: '#69dca1'
  on-secondary-fixed: '#002112'
  on-secondary-fixed-variant: '#005233'
  tertiary-fixed: '#ffdad9'
  tertiary-fixed-dim: '#ffb3b3'
  on-tertiary-fixed: '#40000a'
  on-tertiary-fixed-variant: '#8b1728'
  background: '#faf8ff'
  on-background: '#171b29'
  surface-variant: '#dfe1f5'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system embodies a modern, calm, and meticulous approach to personal financial management. Finance applications often induce cognitive fatigue and anxiety; this system counters that by instilling clarity, reliability, and lightness. Visual noise is stripped down to allow data and financial progress to take center stage.

The style merges **Modern Corporate Precision** with a **Soft Contemporary** mobile aesthetic:
- **Atmosphere:** Clean, open, and trustworthy. Screens feel airy and breathable rather than dense or utilitarian.
- **Tone:** Encouraging, pragmatic, and clear. Content and microcopy in Bahasa Indonesia are concise, polite, and direct (e.g., "Catat Pengeluaran", "Ringkasan Bulan Ini").
- **Visual Weight:** Surfaces are crisp, card elevations are subtle with ambient soft lighting, and functional colors (income/expense) provide distinct, low-stress semantic markers.

## Colors

The palette establishes firm trust through deep structural blues, balanced with soft neutral backdrops and muted chromatic accents for transaction flows.

### Color Tokens & Roles

- **Primary (`#253B80`):** Anchors major callouts, primary buttons, dynamic charts, active navigation, and key balance totals. 
  - Sub-shade / Interactive (`#1D2E66`): Pressed states.
  - Tint Soft (`#EDF1FD`): 10% opacity equivalent for active pill badges and icon container backings.
- **Secondary / Income (`#22A06B`):** Denotes incoming funds, positive budget deltas, investment yields, and affirmative status indicators.
  - Surface Tint (`#EAF6F0`): Background for income category chips and badge containers.
- **Tertiary / Expense (`#E45B64`):** Denotes outgoing cash, negative balances, warning boundaries, and critical actions.
  - Surface Tint (`#FDF1F2`): Background for expense indicators and negative delta labels.
- **Neutral Primary (`#202432`):** Primary typography, numeric metric displays, and active icon glyphs.
- **Neutral Secondary (`#8A90A0`):** Subtitles, inactive labels, timestamps, and secondary metadata.
- **Background Canvas (`#F8F9FC`):** Base canvas layer for Flutter `Scaffold` views, creating crisp contrast behind pure white cards.
- **Surface (`#FFFFFF`):** High-level card backgrounds, bottom sheets, and input fields.
- **Borders & Dividers (`#ECEEF3`):** Single-pixel perimeter strokes that stabilize visual architecture without adding heaviness.

## Typography

The type system is powered by **Plus Jakarta Sans**, chosen for its geometric balance, open counter spaces, and exceptional legibility on high-density mobile screens.

### Numerical Guidelines
- Currency figures and financial numbers (e.g., `Rp 1.450.000`) prioritize `FontWeight.w600` or `FontWeight.w700`.
- Enable tabular figures (`FontFeature.tabularFigures()`) across financial data lists and balance widgets to align decimal points and numbers vertically.
- Use `headline-xl-mobile` for main dashboard aggregate balance cards, dropping to `headline-md` on summary breakdown cards.
- Negative sums are preceded by a standard minus sign without extra whitespace (e.g., `-Rp 45.000`).

## Layout & Spacing

The layout is built around a mobile-first 4-column dynamic grid, scaling fluidly across smartphone form factors up to tablets.

### Grid & Canvas Structure
- **Outer Canvas Margins:** `1.25rem` (20px) horizontal padding across mobile views, ensuring interactive targets clear curved device bezels and safe areas.
- **Vertical Rhythm:** 
  - Standard spacing between consecutive cards is `0.75rem` (12px) to `1rem` (16px).
  - Section titles are spaced `1.5rem` (24px) above cards with an internal margin of `0.5rem` (8px) between the title and its respective content group.
- **Card Padding:** Standardized to `1rem` (16px) or `1.25rem` (20px) internal padding, preventing compact data from touching card borders.
- **Safe Area Insets:** Strict enforcement of system top safe area for custom AppBars and bottom padding offset for devices without hardware navigation buttons.

## Elevation & Depth

Visual hierarchy uses a refined blend of subtle surface separation, thin structural outlines, and diffuse ambient shadows to create clarity without heavy skeuomorphic effects.

### Elevation Hierarchy

1. **Level 0 (Canvas Base):**
   - Background Color: `#F8F9FC`.
   - Used for the root background and non-interactive sections.

2. **Level 1 (Card & Content Surface):**
   - Background Color: `#FFFFFF`.
   - Border: `1px solid #ECEEF3`.
   - Shadow: `0px 2px 8px rgba(32, 36, 50, 0.04)`.
   - Used for balance summary cards, transaction rows, and settings tiles.

3. **Level 2 (Floating & Active Interaction):**
   - Background Color: `#FFFFFF`.
   - Border: `1px solid #ECEEF3`.
   - Shadow: `0px 8px 24px rgba(37, 59, 128, 0.08)`.
   - Used for floating action buttons, focused input fields, and active segmented control pills.

4. **Level 3 (Overlays & Modals):**
   - Background Color: `#FFFFFF`.
   - Shadow: `0px -4px 32px rgba(32, 36, 50, 0.12)`.
   - Used for bottom sheets (`ModalBottomSheet`), date pickers, and modal transaction creation flows.

## Shapes

The geometric identity relies on friendly, curved contours balanced by structured horizontal cards.

- **Primary Cards & Containers:** Radii between `16px` and `20px` (`BorderRadius.circular(18)` in Flutter). Gives cards an approachable, modern feel while keeping layout boundaries distinct.
- **Chips, Pills, & Badges:** `12px` (`BorderRadius.circular(12)`), keeping tags compact and distinct from main cards.
- **Buttons & Interactive Bars:** Full pill form (`BorderRadius.circular(999)` / `StadiumBorder`) for action buttons, segment switch backgrounds, and floating elements.
- **Input Fields:** `14px` (`BorderRadius.circular(14)`), pairing comfortably with adjacent cards and primary buttons.

## Components

Implementation guidelines optimized for Flutter widgets:

### 1. App Bar
- **Specs:** Transparent background on `#F8F9FC`, zero elevation, centered or left-aligned page title using `headline-md`.
- **Actions:** Circle avatar button (36x36px) or icon action buttons wrapped in a `#FFFFFF` circle with a `1px solid #ECEEF3` outline.

### 2. Buttons
- **Primary Button:** Pill-shaped (`StadiumBorder`), height 52px, background `#253B80`, text `#FFFFFF` (`label-lg`). Pressed state: `#1D2E66`.
- **Secondary Button:** Pill-shaped, height 52px, background `#EDF1FD`, text `#253B80`, no outline.
- **Destructive/Tertiary Button:** Pill-shaped, background `#FDF1F2`, text `#E45B64`.

### 3. Transaction Tile
- **Structure:** `ListTile` or custom `Row` inside a `#FFFFFF` card or grouped container.
- **Icon Container:** 44x44px rounded square (radius `12px`), background `#F1F3F7` (or `#EAF6F0` for income, `#FDF1F2` for expense), containing a 20px primary accent icon.
- **Copy:** Leading title `body-md` in `#202432`, subtitle `body-sm` in `#8A90A0` with timestamp/category.
- **Trailing Amount:** `label-lg`. Prefixed with `+` in `#22A06B` for income, or `-` in `#E45B64` for expense.

### 4. Segmented Control / Filter Pills
- **Container:** Pill-shaped (`StadiumBorder`), background `#ECEEF3`, internal padding 4px.
- **Active Pill:** Full pill `#FFFFFF`, shadow `0px 2px 6px rgba(32, 36, 50, 0.08)`, text `#253B80` (`label-md`).
- **Inactive Pill:** Transparent, text `#8A90A0`.

### 5. Input Fields
- **Container:** Height 54px, background `#FFFFFF`, border `1px solid #ECEEF3`, radius `14px`, horizontal padding 16px.
- **Focused State:** Border `1.5px solid #253B80`, subtle shadow glow `0px 0px 0px 3px rgba(37, 59, 128, 0.08)`.
- **Currency Field Variant:** Prefix fixed with `Rp` in `#8A90A0`, input values styled in bold `headline-md` `#202432`.

### 6. Summary Balance Card
- **Background:** Primary `#253B80` or crisp `#FFFFFF` with `1px solid #ECEEF3`.
- **Padding:** 20px all around, border radius 20px.
- **Data Architecture:** Total Balance on top, subdivided into two inner soft-tinted tiles for "Pemasukan" (Income) with `#22A06B` indicators and "Pengeluaran" (Expense) with `#E45B64` indicators.

### 7. Bottom Navigation Bar
- **Design:** Floating or docked white bar (`#FFFFFF`), top border `1px solid #ECEEF3`, shadow `0px -4px 16px rgba(32,36,50,0.03)`.
- **Center Action:** Elevated circular "Tambah Transaksi" (+) button (52x52px) in `#253B80` with a white icon.
- **Item States:** Active icon & label `#253B80`; inactive icon & label `#8A90A0`.