# Australian Constitution Reference App — Design Document

## Overview

A web application for browsing the Australian Constitution, related historical documents, landmark constitutional cases, and referendum history. Built as a Progressive Web App with Next.js, statically exported and deployed to Cloudflare Pages.

The guiding principle is **elegant utility**. The Constitution and its associated case law are working documents for researchers, students, lawyers, and citizens. The design must never impede access to that content.

---

## 1. Visual Design Language

The application draws from neoclassical architectural aesthetics: warm stone surfaces, authoritative serif typography, and restrained ornamentation that supports rather than obscures the content. The site should feel like consulting a beautifully bound reference volume, not browsing a decorative portfolio.

Full visual specification (colour palette, typography, glass effects, component patterns, responsive breakpoints, and CSS custom properties) is defined in [`docs/DESIGN_SPEC.md`](../../DESIGN_SPEC.md).

### Key design tokens (summary)

| Token | Value | Role |
|---|---|---|
| Parchment | `#F5F0E8` | Primary background |
| Stone | `#EDE7DB` | Secondary surfaces |
| Walnut | `#3D3229` | Primary text |
| Sandstone | `#6B5D4F` | Secondary text |
| Forest green | `#2E5A4A` | Primary accent / interactive |
| Gilt gold | `#B8935A` | Secondary accent / decorative |
| Burgundy | `#8B2E2E` | Reserved accent / amendments |
| Georgia | Serif | Primary typeface |
| System sans | Sans-serif | Navigation and UI chrome |

---

## 2. Information Architecture

### Tab structure

The app has four main tabs accessible from a persistent bottom navigation bar (mobile) or left sidebar (desktop):

| Tab | Icon | Content |
|---|---|---|
| **Constitution** | Scroll | Chapter list, section reading view |
| **Documents** | File | Historical documents, referendums |
| **Cases** | Gavel | Landmark constitutional cases |
| **Saved** | Star | User-bookmarked sections, cases, documents |

### Constitution tab

- **Home view:** List of chapters (I through VIII + Schedules). Each chapter card shows the chapter number, title, and section count.
- **Chapter view:** List of sections within the selected chapter. Each section shows its number and title.
- **Section reading view:** Full constitutional text for the selected section with cross-links to related cases, referendums, and documents.
- **Pill shortcuts on home:** Quick-access pills at the top of the chapter list for common entry points (e.g. "Referendums", "Preamble", "s 51 Powers").

### Documents tab

- List of historical and explanatory documents related to the Constitution
- Includes: covering clauses, Statute of Westminster, Australia Acts, royal proclamations
- Referendums section accessible here as well as from the Constitution tab pill shortcut
- Each document has a reading view with cross-links back to relevant constitutional sections

### Cases tab

- List of landmark constitutional cases, displayed as summary cards
- Sortable by year or by constitutional section
- Each case card shows: year badge, case name, one-line principle
- Expandable detail view with full summary, relevant sections (as tappable pills), and outcome
- Green left border for majority decisions; burgundy for significant dissents

### Saved tab

- All user-bookmarked content in one place
- Grouped by type: Sections, Cases, Documents
- Bookmarks stored in localStorage
- Empty state with guidance on how to save items

### Navigation flows

- **Cross-linking:** Section reading views link to related cases and referendums. Case detail views link back to the constitutional sections they interpret. This creates a web of connections users can explore naturally.
- **Breadcrumbs:** Constitution > Chapter III > Section 75 — always visible at the top of reading views.
- **Back behaviour:** Respects browser/device back button. Tab state is preserved when switching between tabs.

---

## 3. Data Model

### Content-as-files approach

All content lives as structured files in a `content/` directory, processed at build time. No database, no CMS, no API.

```
content/
  constitution/
    chapter-01/
      _meta.json          # Chapter title, number, description
      section-001.mdx     # Section 1 text + frontmatter
      section-002.mdx
      ...
    chapter-02/
      ...
  cases/
    cole-v-whitfield-1988.mdx
    amalgamated-society-of-engineers-1920.mdx
    ...
  documents/
    statute-of-westminster-1931.mdx
    australia-act-1986.mdx
    ...
  referendums/
    1967-aboriginal-people.mdx
    1999-republic.mdx
    ...
```

### File format

Each content file uses MDX with YAML frontmatter for metadata:

```mdx
---
id: "s51"
title: "Legislative powers of the Parliament"
chapter: 1
sectionNumber: 51
relatedCases:
  - "cole-v-whitfield-1988"
  - "amalgamated-society-of-engineers-1920"
relatedReferendums:
  - "1967-aboriginal-people"
relatedDocuments: []
---

The Parliament shall, subject to this Constitution, have power to make
laws for the peace, order, and good government of the Commonwealth with
respect to:

(i) trade and commerce with other countries, and among the States;
...
```

### Chapter metadata (`_meta.json`)

```json
{
  "number": 1,
  "title": "The Parliament",
  "description": "Establishment and powers of the Commonwealth Parliament",
  "sections": ["section-001", "section-002", "section-003"]
}
```

### Case frontmatter

```yaml
---
id: "cole-v-whitfield-1988"
name: "Cole v Whitfield"
year: 1988
court: "High Court of Australia"
citation: "(1988) 165 CLR 360"
principle: "Reinterpreted s 92 — free trade among states is about protectionism, not all trade regulation"
outcome: "majority"
relatedSections:
  - "s92"
relatedCases:
  - "barley-marketing-board-v-norman-1990"
---
```

### Referendum frontmatter

```yaml
---
id: "1967-aboriginal-people"
year: 1967
question: "To alter the Constitution so as to omit certain words relating to Aboriginal people and so that Aboriginals are to be counted in reckoning the population"
outcome: "carried"
yes_percentage: 90.77
relatedSections:
  - "s51"
  - "s127"
---
```

### Bidirectional cross-referencing

- Sections declare their related cases, referendums, and documents in frontmatter
- Cases and referendums declare their related sections
- At build time, a script resolves these into full bidirectional link maps
- This means navigating from a section to its cases, or from a case to its sections, is equally fast and complete

### Content type definitions

```typescript
interface ConstitutionSection {
  id: string;
  title: string;
  chapter: number;
  sectionNumber: number;
  content: string;            // MDX body
  relatedCases: string[];     // Case IDs
  relatedReferendums: string[]; // Referendum IDs
  relatedDocuments: string[]; // Document IDs
}

interface Case {
  id: string;
  name: string;
  year: number;
  court: string;
  citation: string;
  principle: string;
  outcome: "majority" | "dissent";
  content: string;            // MDX body (full summary)
  relatedSections: string[];
  relatedCases: string[];
}

interface Referendum {
  id: string;
  year: number;
  question: string;
  outcome: "carried" | "defeated";
  yesPercentage: number;
  content: string;            // MDX body (context and analysis)
  relatedSections: string[];
}

interface Document {
  id: string;
  title: string;
  year: number;
  description: string;
  content: string;            // MDX body
  relatedSections: string[];
}
```

---

## 4. Search

### Approach: client-side full-text search with Flexsearch

All search runs entirely in the browser. A search index is pre-built at build time and shipped as a static JSON file. No API calls, no external service, instant results.

### Indexed content

| Content type | Indexed fields |
|---|---|
| Constitution sections | Section number, title, full text |
| Cases | Case name, year, summary, key principles |
| Documents | Title, description, full text |
| Referendums | Year, question text, outcome, related sections |

### Build-time index generation

A Next.js build script crawls all `content/` files, tokenises them, and writes the Flexsearch index to `public/search-index.json`. The app lazy-loads this file on first search interaction so it doesn't affect initial page load.

### Search UX

- **Trigger:** Search icon in the sticky header, always accessible
- **Desktop:** Command-palette style dropdown overlay with glass effect
- **Mobile:** Full-screen glass overlay
- **As-you-type results** grouped by content type: Constitution, Cases, Documents, Referendums
- **Result format:** Title + short context snippet with matched terms highlighted in gilt gold
- **Section references** shown as monospace pill chips (e.g. `s 51(xxxi)`)
- **Empty state:** "Search the Constitution, cases, and historical documents"
- **No results state:** Suggestion to try broader terms

### Why Flexsearch

- ~6KB gzipped — minimal bundle impact
- Faster and smaller than Lunr
- No external dependency or cost (unlike Algolia)
- Perfect fit for a static dataset that doesn't change between builds

---

## 5. Progressive Web App

### Service worker strategy

- **next-pwa** plugin generates the service worker at build time
- **Precaching:** All constitutional text, case summaries, document content, and app shell are precached on first visit (estimated <5MB total)
- **Runtime caching:** Search index file cached on first use with stale-while-revalidate strategy
- **Cache invalidation:** On new deployment, service worker updates in background and prompts "New content available — tap to refresh"

### Offline behaviour

| Scenario | Behaviour |
|---|---|
| Full content browsing | Works completely offline after first visit |
| Search | Works offline (index is cached locally) |
| Saved/bookmarked sections | Stored in localStorage, always available |
| No prior visit | Graceful offline page: "Connect to the internet to load the Constitution" |

### Web app manifest

| Property | Value |
|---|---|
| App name | Australian Constitution |
| Short name | Constitution |
| Theme colour | `#2E5A4A` (forest green) |
| Background colour | `#F5F0E8` (parchment) |
| Display mode | `standalone` |
| Orientation | Portrait primary, landscape supported |
| Icons | 192px and 512px (crest or scales motif on parchment) |

### Install prompt

- No popup on first visit
- Subtle "Add to Home Screen" card appears after the **third visit**
- Styled as a warm-toned card at bottom of screen
- Dismissible; does not return for 30 days if dismissed

### Out of scope

- Push notifications — content doesn't update frequently enough
- Background sync — nothing to sync; read-only content
- IndexedDB — localStorage sufficient for bookmarks

---

## 6. Error Handling

### 404 — Page Not Found

- Warm parchment page
- Georgia heading: "Section not found"
- Forest green button to return home
- Search bar to find what they were looking for
- No decorative illustrations — dignified and functional

### Content loading errors

- If search index fails to load: search bar shows "Search is temporarily unavailable" in sandstone text; rest of app remains fully functional
- If a content file fails to parse at build time: build fails loudly — fix before deploy

### Offline fallback

- First-time visitors without connection see a styled offline page
- Returning visitors with cached service worker see everything normally

### Client-side errors

- React error boundary wraps the app at the layout level
- On crash: parchment-styled fallback with "Something went wrong" heading and a "Reload" button
- Errors logged to console in development
- No external error tracking initially (Sentry can be added later if needed)

### Out of scope

- Toast notifications — app is read-only; bookmark state changes use icon animation only
- Retry logic — static content; if it loaded once, it's cached
- Complex error taxonomy — three states: working, not found, broken

---

## 7. Deployment

### Platform: Cloudflare Pages

- Fully static export (`next export`) — no server-side rendering, no API routes, no serverless functions
- Unlimited bandwidth on free tier
- Global edge CDN
- Custom domain support on free tier with automatic SSL
- Preview deployments on branches

### Build & deploy pipeline

| Trigger | Action |
|---|---|
| Push to `main` | Auto-deploy to production |
| Push to any other branch | Preview deployment with unique URL |

### Performance targets

| Metric | Target |
|---|---|
| Lighthouse Performance | 95+ |
| First Contentful Paint | < 1.2s |
| Time to Interactive | < 2s |
| Total bundle size | < 150KB JS (gzipped) |
| Full content cache | < 5MB |

### Out of scope

- Docker / self-hosting
- GitHub Actions CI/CD (Cloudflare's git integration handles everything)
- Separate staging environment (preview deployments serve this purpose)

---

## 8. Tech Stack Summary

| Layer | Technology |
|---|---|
| Framework | Next.js (static export) |
| Language | TypeScript |
| Styling | CSS custom properties + CSS modules |
| Content | MDX + JSON files in `content/` directory |
| Search | Flexsearch (client-side, build-time index) |
| PWA | next-pwa (service worker + manifest) |
| Deployment | Cloudflare Pages |
| Storage | localStorage (bookmarks/saved items) |
| Icons | TBD — proper SVG icon library needed |
