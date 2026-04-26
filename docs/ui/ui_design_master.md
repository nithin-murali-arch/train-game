# Rail Empire — UI Design Master Document

## 1. Design System: The Governor's Archive
The UI represents a tactile, 19th-century Colonial Bengal digital ledger. It avoids modern SaaS or mobile flat aesthetics. The interface is composed of heavy parchment papers, dark ink, oxidized brass buttons, and muted indigo highlights. Boundaries are defined by tonal shifts and minimal "ink-drawn" lines. Information density is high, suited for a complex PC strategy game.

## 2. Color Tokens
- **Background / Parchment Base**: `#F5E6C8` (Warm Sepia)
- **Primary Text / Dark Ink**: `#1A1A1A`
- **Primary Accent / Polished Brass**: `#D4AF37`
- **Secondary Accent / Muted Indigo**: `#4B0082`
- **Button Base / Tarnished Brass**: `#B8860B`
- **Warning / Rust**: `#BA1A1A`
- **Disabled / Faded Ink**: `#708090` (Steel Grey)

## 3. Typography
- **Headlines & Display**: `Noto Serif` (Used for official titles, large numbers, and headers to evoke a stamped document feel).
- **Body & Tabular Data**: `Noto Sans` (Used for dense ledgers, tooltips, and functional mechanics for readability).
- **Monospace**: (Optional) Used for raw ID strings or debug data.

## 4. Spacing & Density
- **Global Padding**: 16px to 24px between major panel sections.
- **Data Density**: Tight. Tabular data and ledger entries should use minimal vertical padding (4px-8px) to maximize on-screen information without scrolling.

## 5. Component States
### Button States (Brass Style)
- **Normal**: Background `#B8860B`, Text `#1A1A1A`, subtle 1px border `#1A1A1A`.
- **Hover/Focus**: Lighter fill (`#D4AF37`), border thickness increases to 2px.
- **Pressed**: Darker fill, translated 1px down, simulating physical compression.
- **Disabled**: Background `#E0D8C8` (desaturated parchment), text `#708090`, no hover effect.

### Panel States
- **Base Panel**: `#F5E6C8` with 1px `#1A1A1A` border.
- **Nested Well**: Slightly darker/cooler tint (e.g., `#E8DAB7`) to indicate a recessed area for inputs or inner tables.

### Tables & Lists
- Alternating row tints: Base `#F5E6C8`, secondary row `#EFE0C2`.
- No vertical divider lines. Horizontal lines are 1px `#1A1A1A` at 20% opacity.

### Tooltip Style
- Floating parchment card. High z-index.
- Background `#F5E6C8`, solid 1px `#1A1A1A` border. Drop shadow: 0px 4px 12px rgba(0,0,0,0.15).

### Alert/Event Style
- Styled like a telegram or newspaper clipping.
- Left-edge colored indicator strip: Rust (`#BA1A1A`) for warnings, Indigo (`#4B0082`) for info.

## 6. Dynamic Pricing Visual Language
UI states for cargo price based on market conditions:
- **Shortage**: High price. Labeled explicitly as "Shortage". Muted rust tint.
- **Balanced**: Normal price. Labeled "Balanced". Neutral ink text.
- **Oversupplied**: Low price. Labeled "Oversupplied". Muted indigo tint.
*(Note: Color supports the state but is not the only indicator—always use readable text labels).*
