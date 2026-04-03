# Design Specification — Australian Constitution Reference Application

## Design philosophy

The application draws from neoclassical architectural aesthetics: warm stone surfaces, authoritative serif typography, and restrained ornamentation that supports rather than obscures the content. Every visual choice serves readability and navigability first. The site should feel like consulting a beautifully bound reference volume, not browsing a decorative portfolio.

The guiding principle is **elegant utility**. The Constitution and its associated case law are working documents for researchers, students, lawyers, and citizens. The design must never impede access to that content.

---

## Colour palette

### Foundation colours

| Token | Hex | Name | Usage |
|---|---|---|---|
| `--color-bg-primary` | `#F5F0E8` | Parchment | Primary page background. Warm off-white base for all content areas |
| `--color-bg-secondary` | `#EDE7DB` | Stone | Secondary surfaces: cards, sidebar backgrounds, code blocks, table headers |
| `--color-text-primary` | `#3D3229` | Walnut | Primary text colour. All body copy, headings, and constitutional text |
| `--color-text-secondary` | `#6B5D4F` | Sandstone | Secondary text: subheadings, captions, metadata, timestamps, breadcrumbs |
| `--color-border` | `#D4C9B8` | Warm border | All standard borders: cards, dividers, table rules, input outlines |

### Accent colours

| Token | Hex | Name | Role |
|---|---|---|---|
| `--color-accent-primary` | `#2E5A4A` | Forest green | Primary interactive colour (see below) |
| `--color-accent-secondary` | `#B8935A` | Gilt gold | Decorative and secondary interactive colour |
| `--color-accent-reserved` | `#8B2E2E` | Burgundy | High-signal moments only (see below) |

### Forest green — primary accent (`#2E5A4A`)

The workhorse interactive colour. Used wherever the user needs a signal that something is clickable, active, or selected.

- Text links (default and visited states)
- Primary buttons and call-to-action elements
- Active navigation item indicators and underlines
- Focus rings on form inputs and interactive elements
- Selected tab indicators
- Toggle and checkbox active states
- Progress bars and loading indicators
- Search result highlighting borders

### Gilt gold — secondary accent (`#B8935A`)

A warm metallic tone for decorative and secondary interactive elements. Complements the green without competing for attention.

- Hover states on links (transition from green to gold)
- Decorative horizontal rules and section dividers
- Active section markers in sidebar navigation
- Breadcrumb separators
- Star/bookmark icons for saved sections
- Highlighted search terms within results
- Decorative drop caps or initial letters on chapter openings

### Burgundy — reserved accent (`#8B2E2E`)

Used sparingly for high-signal moments. Its rarity gives it visual weight when it does appear.

- Error states and form validation messages
- Amendment and referendum callout boxes (e.g. "amended by referendum, 1967")
- Important judicial dissent indicators in case summaries
- Pull quote borders on landmark case excerpts
- Destructive action buttons (delete saved items, clear history)

### Tinted backgrounds for callouts

| Token | Hex | Usage |
|---|---|---|
| `--color-tint-green` | `#E8F0EC` | Informational callout background |
| `--color-tint-gold` | `#F5EFE0` | Highlight or note background |
| `--color-tint-burgundy` | `#F3EAEA` | Warning or amendment callout background |

Use these lightly tinted backgrounds for callout boxes and alert banners, paired with a left border (3px) in the corresponding accent colour.

---

## Typography

### Font stack

| Role | Stack |
|---|---|
| Primary (serif) | `Georgia, 'Times New Roman', serif` |
| Secondary (sans-serif) | `system-ui, -apple-system, 'Segoe UI', sans-serif` |
| Monospace | `'Fira Code', 'SF Mono', 'Cascadia Code', monospace` |

Georgia is the foundation of the typographic identity. It is available on every major platform without loading, renders crisply at all sizes, and carries the authority appropriate to constitutional text. Sans-serif is used **only** for secondary headings, navigation labels, and UI chrome.

### Type scale

| Element | Font | Size | Weight | Extras |
|---|---|---|---|---|
| Page title (H1) | Georgia | 32px / 2rem | 400 | Colour: Walnut |
| Section heading (H2) | Georgia | 24px / 1.5rem | 400 | Green bottom border (2px) |
| Subsection heading (H3) | System sans | 14px / 0.875rem | 600 | Uppercase, letter-spacing 0.5px, colour Sandstone |
| Body text | Georgia | 16px / 1rem | 400 | Line-height 1.75, colour Walnut |
| Constitutional text | Georgia | 17px / 1.0625rem | 400 | Line-height 1.8, colour Walnut |
| Section references | Monospace | 14px | 400 | Colour Sandstone, Stone background, rounded corners |
| Captions / metadata | System sans | 13px | 400 | Colour Sandstone |
| Navigation labels | System sans | 14px | 500 | Walnut (active: Forest Green) |

### Key typographic rules

- Body text minimum 16px everywhere, including mobile. No exceptions.
- Line height 1.75 for body text; 1.8 for constitutional text (the primary reading content).
- Maximum reading width of `72ch` (~680px) for all prose content.
- Paragraph spacing via `margin-bottom` (1rem), not double line breaks.
- Serif headings use normal weight (400); their size provides emphasis. Sans headings use semibold (600) and uppercase to differentiate.

---

## Glass and transparency effects

Frosted glass overlays give depth to navigation and modal layers while maintaining the warm parchment aesthetic. The effect should feel like looking through textured glass at the page beneath.

### CSS implementation

```css
.glass {
  background: rgba(237, 231, 219, 0.78);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  border: 0.5px solid rgba(212, 201, 184, 0.5);
}
```

### Where to use glass

- Mobile navigation drawer (slide-in from left)
- Desktop sticky header/navigation bar when scrolled
- Search overlay / command palette
- Modal dialogs (case detail popups, section cross-references)
- Table of contents sidebar on desktop when overlaying content
- Tooltip and popover backgrounds

### Glass rules

- Always pair with a subtle border (0.5px, rgba warm tone) to define edges.
- The blur radius (14px) is calibrated for the parchment background — increase for darker overlays, decrease for subtle headers.
- Never stack glass on glass (two translucent layers). One level of depth only.
- Fallback for browsers without `backdrop-filter` support: solid Stone (`#EDE7DB`) background.

---

## Component patterns

### Cards

Used for case summaries, document listings, and section previews.

```css
.card {
  background: var(--color-bg-primary);
  border: 0.5px solid var(--color-border);
  border-radius: var(--radius-md);       /* 8px */
  padding: 1.25rem;
  transition: box-shadow 0.2s ease;
}
.card:hover {
  box-shadow: var(--shadow-hover);       /* 0 2px 8px rgba(61, 50, 41, 0.08) */
}
```

### Constitutional section display

The primary reading view for constitutional text.

- Max-width `72ch`
- Generous vertical padding (2rem top/bottom)
- Section numbers in Sandstone monospace, set slightly apart from the text
- Margin notes or annotations in a narrower column on desktop, collapsed to inline callouts on mobile

### Case summary cards

- Year badge in top-left corner: small, Stone background, monospace
- Case name as Georgia heading
- One-line ratio/principle beneath in Sandstone
- Expandable for full summary
- Green left border (3px) for majority decisions
- Burgundy left border (3px) for significant dissents

### Navigation

- **Desktop:** persistent left sidebar with table of contents. Chapter headings in Georgia, section links in sans-serif. Active section highlighted with gold left marker.
- **Mobile:** hamburger menu triggering glass slide-in drawer. Sticky header with glass effect on scroll.

### Search

- Full-width search bar with Parchment background, warm border
- Glass overlay results panel
- Results grouped by document type (Constitution, Cases, Related Documents)
- Search terms highlighted in gold within results
- Monospace section references as filter chips

### Buttons

```css
/* Primary */
.btn-primary {
  background: var(--color-accent-primary);
  color: #FFFFFF;
  border: none;
  border-radius: var(--radius-md);
  font-family: var(--font-sans);
  font-size: 14px;
  font-weight: 500;
  padding: 0.5rem 1.25rem;
}

/* Secondary */
.btn-secondary {
  background: transparent;
  color: var(--color-accent-primary);
  border: 1px solid var(--color-accent-primary);
  border-radius: var(--radius-md);
  font-family: var(--font-sans);
  font-size: 14px;
  font-weight: 500;
  padding: 0.5rem 1.25rem;
}

/* Ghost */
.btn-ghost {
  background: transparent;
  color: var(--color-text-secondary);
  border: none;
  font-family: var(--font-sans);
  font-size: 14px;
  font-weight: 500;
  padding: 0.5rem 1rem;
}
.btn-ghost:hover {
  background: var(--color-bg-secondary);
}
```

---

## Responsive behaviour

### Breakpoints

| Breakpoint | Width | Layout |
|---|---|---|
| Mobile | < 640px | Single column, hamburger nav, stacked cards |
| Tablet | 640–1024px | Collapsible sidebar, two-column card grid |
| Desktop | > 1024px | Persistent sidebar, max-width content column (72ch), optional annotation margin |

### Mobile priorities

- Constitutional text at 16px minimum, line-height 1.75. Readability is non-negotiable.
- Glass navigation drawer with full-height slide-in.
- Section references as tappable pill-shaped anchors (44px minimum touch target).
- Case cards stack vertically with full-width layout.
- Search accessible from sticky header, results in full-screen overlay.

---

## CSS custom properties

Define these at `:root` for consistent theming across all components. This is the single source of truth for the design language.

```css
:root {
  /* Foundation */
  --color-bg-primary: #F5F0E8;
  --color-bg-secondary: #EDE7DB;
  --color-text-primary: #3D3229;
  --color-text-secondary: #6B5D4F;
  --color-border: #D4C9B8;

  /* Accents */
  --color-accent-primary: #2E5A4A;
  --color-accent-secondary: #B8935A;
  --color-accent-reserved: #8B2E2E;

  /* Tinted backgrounds */
  --color-tint-green: #E8F0EC;
  --color-tint-gold: #F5EFE0;
  --color-tint-burgundy: #F3EAEA;

  /* Glass */
  --glass-bg: rgba(237, 231, 219, 0.78);
  --glass-border: rgba(212, 201, 184, 0.5);
  --glass-blur: 14px;

  /* Typography */
  --font-serif: Georgia, 'Times New Roman', serif;
  --font-sans: system-ui, -apple-system, 'Segoe UI', sans-serif;
  --font-mono: 'Fira Code', 'SF Mono', 'Cascadia Code', monospace;
  --line-height-body: 1.75;
  --line-height-constitutional: 1.8;
  --max-reading-width: 72ch;

  /* Spacing & shape */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --shadow-hover: 0 2px 8px rgba(61, 50, 41, 0.08);
}
```
