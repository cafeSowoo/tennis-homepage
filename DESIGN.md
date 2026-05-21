---
name: Ace & Clay
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#3d4947'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#6d7a77'
  outline-variant: '#bcc9c6'
  surface-tint: '#006a60'
  primary: '#00685d'
  on-primary: '#ffffff'
  primary-container: '#008376'
  on-primary-container: '#f4fffb'
  inverse-primary: '#6fd8c8'
  secondary: '#556500'
  on-secondary: '#ffffff'
  secondary-container: '#ceed3e'
  on-secondary-container: '#596a00'
  tertiary: '#97422b'
  on-tertiary: '#ffffff'
  tertiary-container: '#b65a41'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#8cf5e4'
  primary-fixed-dim: '#6fd8c8'
  on-primary-fixed: '#00201c'
  on-primary-fixed-variant: '#005048'
  secondary-fixed: '#d1f041'
  secondary-fixed-dim: '#b5d321'
  on-secondary-fixed: '#181e00'
  on-secondary-fixed-variant: '#3f4c00'
  tertiary-fixed: '#ffdbd2'
  tertiary-fixed-dim: '#ffb4a1'
  on-tertiary-fixed: '#3c0800'
  on-tertiary-fixed-variant: '#7c2e19'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Montserrat
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style

The design system is built to evoke the physical energy of a premium tennis club—sun-drenched courts, crisp white lines, and the vibrant pop of a new ball. It targets club administrators, coaches, and active members, necessitating a balance between high-utility management tools and an inviting, community-focused atmosphere.

The aesthetic follows a **Modern / Sporty** movement. It prioritizes clarity and "airiness" through significant whitespace, while using high-energy accent colors to drive engagement and highlight critical status updates (like court availability or match results). The UI is clean and professional, yet retains a rhythmic vitality that avoids the coldness of traditional enterprise software.

## Colors

The palette is derived from the textures and equipment of the sport.

*   **Deep Court Green (#2A9D8F):** Used for primary actions, navigation headers, and stable UI elements. It represents the foundation of the club.
*   **Fresh Tennis Ball Yellow (#DFFF4F):** A high-visibility accent used for highlights, active states, and "New" indicators. Due to its brightness, it should primarily be paired with dark text for accessibility.
*   **Clay Court Orange (#E07A5F):** A strategic highlight color used for alerts, booking conflicts, or secondary call-to-outs.
*   **White & Neutral:** Pure white (#FFFFFF) is the primary canvas to ensure the "airy" feel. A light grey (#F8F9FA) is used for section grouping to maintain high contrast without visual clutter.

## Typography

This design system utilizes a dual-font approach to balance personality with readability.

**Montserrat** is used for all headlines and display text. Its geometric, wide-set nature feels athletic and modern. **Inter** is used for all functional UI elements, body copy, and data tables. Inter’s high x-height and neutral character ensure that dense information—such as match schedules and member lists—remains legible even on smaller mobile devices.

Use `label-md` for buttons and navigation items to ensure they are distinct from standard body text. For numerical data in match scores, use `headline-md` with tabular lining figures if available.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a 12-column structure for desktop and a 4-column structure for mobile.

To maintain the "airy" feel, the design system utilizes generous outer margins and gutters. Components are grouped using a consistent 8px base unit.
- **Desktop:** 48px margins to allow the content to breathe.
- **Mobile:** 16px margins to maximize screen real estate.

Spacing between sections should typically be `lg` (40px) or `xl` (64px) to clearly define different functional areas of the management suite, such as separating "Court Bookings" from "Upcoming Events."

## Elevation & Depth

To achieve a "friendly and communal" feel, the design system avoids harsh borders in favor of **Ambient Shadows**.

Depth is communicated through three primary tiers:
1.  **Level 0 (Base):** White (#FFFFFF) background.
2.  **Level 1 (Cards/Containers):** Subtle, diffused shadows (0px 4px 20px rgba(0,0,0,0.05)) are used for court cards, member profiles, and dashboard widgets.
3.  **Level 2 (Overlays/Modals):** A more pronounced shadow (0px 12px 32px rgba(0,0,0,0.12)) to lift interactive dialogs and dropdown menus above the primary interface.

Low-contrast outlines (1px solid #E9ECEF) may be used within cards to separate internal content without adding visual weight.

## Shapes

The shape language is defined by **Rounded** corners, reinforcing the friendly and approachable brand personality.

A base radius of `0.5rem (8px)` is applied to standard buttons, input fields, and small cards. Larger containers like page headers or main dashboard cards use `1rem (16px)`. Icons should ideally feature rounded terminals to match the container style. Avoid sharp 90-degree angles to keep the interface feeling soft and modern.

## Components

### Buttons
Primary buttons use **Deep Court Green** with white text. Secondary buttons use a "ghost" style with a green outline or a subtle grey fill. For high-energy calls to action (e.g., "Join Tournament"), use the **Tennis Ball Yellow** with dark text.

### Chips & Badges
Used for court status (e.g., "Available", "Maintenance"). Use **Clay Court Orange** for "Occupied" or "Alert" states. Use rounded-pill shapes for all chips to contrast against the more rectangular cards.

### Input Fields
Fields should have a 1px light grey border that shifts to **Deep Court Green** on focus. Ensure labels are always visible above the field using `label-sm`.

### Cards
Cards are the primary container for the design system. They must have a white background, a Level 1 shadow, and 16px of internal padding. For "Member of the Month" or featured content, a top-border accent of **Tennis Ball Yellow** can be added.

### Lists & Tables
To maintain high contrast for attendee lists, use zebra-striping with the neutral light grey (#F8F9FA) and ensure 16px of vertical padding per row to keep the "airy" aesthetic.
