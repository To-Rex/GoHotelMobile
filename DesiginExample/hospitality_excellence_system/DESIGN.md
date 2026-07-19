---
name: Hospitality Excellence System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#434655'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#747686'
  outline-variant: '#c4c5d7'
  surface-tint: '#2151da'
  primary: '#0037b0'
  on-primary: '#ffffff'
  primary-container: '#1d4ed8'
  on-primary-container: '#cad3ff'
  inverse-primary: '#b7c4ff'
  secondary: '#0058be'
  on-secondary: '#ffffff'
  secondary-container: '#2170e4'
  on-secondary-container: '#fefcff'
  tertiary: '#7f2500'
  on-tertiary: '#ffffff'
  tertiary-container: '#a73400'
  on-tertiary-container: '#ffc9b7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b7c4ff'
  on-primary-fixed: '#001551'
  on-primary-fixed-variant: '#0039b5'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#ffdbcf'
  tertiary-fixed-dim: '#ffb59c'
  on-tertiary-fixed: '#390c00'
  on-tertiary-fixed-variant: '#832700'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  h1:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  h2:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  status-badge:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 20px
  stack-gap: 16px
  inline-gap: 12px
  section-margin: 32px
---

## Brand & Style

This design system is engineered for high-end hotel operations, focusing on the rigorous demands of housekeeping staff and management. The brand personality is **authoritative, efficient, and impeccably clean**, mirroring the standards of a five-star international hotel. 

The aesthetic follows a **Premium Minimalism** approach. It prioritizes high legibility and rapid information processing through a disciplined use of whitespace and a refined "light-on-light" layering technique. The goal is to reduce cognitive load in high-pressure environments while maintaining a sophisticated, modern professional atmosphere. All interface elements are translated into Uzbek to ensure local operational clarity within an international structural framework.

## Colors

The palette is anchored by a deep **Royal Blue (#1D4ED8)**, signaling trust and professional rigor. The background is strictly white (#FFFFFF) to emphasize a "sterile" and clean environment. 

Status colors are used as functional signifiers rather than decorative elements:
- **Tozalangan (Cleaned):** Green is used for completed tasks.
- **Tayyor (Ready):** Bright Blue indicates the room is verified and open for guests.
- **Jarayonda (In Progress):** Orange signals active work to avoid management double-booking.
- **Muammo (Issue):** Red highlights maintenance or guest service blocks that require immediate attention.
- **Tozalanishi kerak (To be Cleaned):** A neutral gray/white denotes the baseline state of pending work.

## Typography

The typography utilizes **Inter**, chosen for its exceptional legibility on mobile screens and its systematic, neutral character. 

The hierarchy is structured to lead with the room number or primary task. Headlines use tighter letter spacing for a more "designed" and premium feel. Body text is optimized for quick scanning of guest preferences or cleaning notes. All labels for status indicators and navigation items are presented in Uzbek, ensuring terms like *"Xona holati"* (Room status) and *"Vazifalar"* (Tasks) are immediately recognizable.

## Layout & Spacing

This system utilizes a **Mobile-First Fluid Grid** designed for one-handed operation. 
- **Margins:** A generous 20px side margin ensures content does not feel cramped and prevents accidental touches on edge-to-edge displays.
- **Vertical Rhythm:** A base 8px spacing system is used. Card elements are separated by 16px gaps to clearly define task boundaries.
- **Touch Targets:** All interactive elements (buttons, toggles, status switchers) maintain a minimum height of 48px to accommodate staff wearing gloves or moving quickly between rooms.

## Elevation & Depth

Depth is achieved through **Soft Ambient Shadows** rather than heavy borders. Surfaces use a very subtle "Level 1" shadow (Y: 4px, Blur: 12px, Opacity: 0.05) to separate white cards from the white background. 

When a task is active or "In Progress," the card may elevate slightly to "Level 2" (Y: 8px, Blur: 20px, Opacity: 0.08) to draw focus. Background blurs are used sparingly behind modal sheets for inventory checklists, ensuring the user stays grounded in the current context without losing sight of the underlying room dashboard.

## Shapes

The design system employs a **Rounded** aesthetic with a specific focus on the 16px to 20px range for primary containers. This high corner radius softens the "industrial" feel of hospitality software, making the app feel approachable and modern. Smaller elements like buttons use a 12px radius, while status badges are fully pill-shaped (rounded-full) to distinguish them from structural UI cards.

## Components

### Cards (Xona Kartochkalari)
The primary layout element. Each card represents a room. It features a large room number in the top left, a status badge in the top right, and secondary details (Guest name, Stay dates) below. Border radius is fixed at 18px.

### Buttons (Tugmalar)
- **Primary:** Solid #1D4ED8 with white text. High-contrast for "Boshlash" (Start) or "Yakunlash" (Finish).
- **Secondary:** Light blue tint background with #1D4ED8 text for "Hisobot" (Report) or "Tafsilotlar" (Details).

### Status Badges
Pill-shaped indicators. For "Tozalanishi kerak" (To be cleaned), the badge is #F3F4F6 with dark gray text. For all other statuses, use the designated color with high-contrast text.

### Progress Indicators
Thin linear bars located at the top of a room detail view to show cleaning checklist completion percentage.

### Checklist Items
Large-format list items with a 24px circular checkbox. Tapping the entire row toggles the completion state to facilitate rapid movement through the room.