---
name: accessibility-audit
description: >
  Use when auditing accessibility: WCAG, screen reader, keyboard navigation, contrast, ARIA.
  Trigger: "accessibility", "WCAG", "a11y", "screen reader", "keyboard navigation",
  "contrast ratio", "ARIA", "assistive technology", "accessible".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-03-09"
  bucket: verify
  auto_invoke: "Auditing accessibility, WCAG compliance, screen reader testing, keyboard navigation"
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep Bash WebSearch
---

# Accessibility Audit

## Purpose

Systematic WCAG 2.2 AA compliance auditing for web applications. Covers keyboard navigation, screen reader compatibility, color contrast, ARIA attributes, and focus management. Produces actionable remediation reports with severity-prioritized findings.

## When to Use

- Auditing a web application for WCAG 2.2 AA compliance
- Reviewing components for keyboard navigation and focus management
- Checking color contrast ratios and visual accessibility
- Validating ARIA attributes on custom components
- During sdd-verify as an additional quality check for web projects
- Before launch of any user-facing web interface
- When building or reviewing a design system's component library

## Critical Patterns

### Pattern 1: Automated Tools Catch Only ~30%

Automated tools (Lighthouse, axe-core) are necessary but insufficient. They catch structural issues (missing alt text, contrast ratios, missing labels) but miss interaction and cognitive issues.

```
AUDIT METHODOLOGY:
├── Layer 1: Automated Scan (~30% of issues)
│   ├── axe-core or Lighthouse for structural violations
│   ├── Reports missing alt text, low contrast, missing labels, broken ARIA
│   └── Green Lighthouse score does NOT mean accessible
│
├── Layer 2: Keyboard-Only Testing (~30% of issues)
│   ├── Navigate the entire UI using ONLY Tab, Shift+Tab, Enter, Space, Arrow keys, Escape
│   ├── Check: Can you reach every interactive element?
│   ├── Check: Is focus visible at all times?
│   ├── Check: Can you escape modals/overlays with Escape?
│   ├── Check: Does focus return to trigger after modal closes?
│   └── Any keyboard trap = CRITICAL
│
├── Layer 3: Screen Reader Testing (~25% of issues)
│   ├── Test with NVDA (Windows) or VoiceOver (macOS)
│   ├── Does the reading order make sense?
│   ├── Are dynamic updates announced (aria-live regions)?
│   ├── Do custom components announce their role and state?
│   └── "Works with a mouse" is NOT a test
│
└── Layer 4: Visual & Cognitive Review (~15% of issues)
    ├── Test at 200% and 400% zoom — does layout break?
    ├── Test with prefers-reduced-motion — are animations respected?
    ├── Test with high contrast / forced colors mode
    └── Is information conveyed by color alone? (must have secondary indicator)
```

### Pattern 2: WCAG 2.2 AA Quick Reference

Reference specific success criteria by number. Never say "it's not accessible" without citing the criterion:

| Criterion | Name | Common Violations |
|-----------|------|-------------------|
| 1.1.1 | Non-text Content | Images without alt text, icon buttons without labels |
| 1.3.1 | Info and Relationships | Visual headings not using `<h1>`-`<h6>`, tables without headers |
| 1.4.3 | Contrast (Minimum) | Text below 4.5:1 ratio, large text below 3:1 ratio |
| 1.4.11 | Non-text Contrast | UI components and graphical objects below 3:1 ratio |
| 2.1.1 | Keyboard | Interactive elements not reachable via keyboard |
| 2.1.2 | No Keyboard Trap | Focus enters a component and cannot leave via keyboard |
| 2.4.3 | Focus Order | Tab order does not follow logical reading order |
| 2.4.7 | Focus Visible | No visible focus indicator on keyboard navigation |
| 4.1.2 | Name, Role, Value | Custom components missing ARIA roles, states, or properties |
| 4.1.3 | Status Messages | Dynamic content changes not announced to screen readers |

### Pattern 3: Keyboard Navigation Audit

Every interactive element must be keyboard-accessible with correct key bindings:

| Component | Expected Keyboard Behavior |
|-----------|---------------------------|
| Button | Enter or Space activates |
| Link | Enter activates |
| Checkbox | Space toggles |
| Tab panel | Arrow keys switch tabs, Tab moves to tab content |
| Menu | Arrow keys navigate items, Enter/Space activates, Escape closes |
| Modal/Dialog | Focus trapped inside, Escape closes, focus returns to trigger |
| Dropdown | Arrow keys navigate options, Enter selects, Escape closes |
| Carousel | Arrow keys navigate slides, pause control accessible |
| Data table | Headers use `scope` or `headers` attributes |

## Decision Trees

| Situation | Severity | Action |
|-----------|----------|--------|
| Keyboard trap (cannot escape component) | CRITICAL | Fix immediately — blocks all keyboard users |
| Missing form labels | CRITICAL | Add `<label>` or `aria-label` — forms are unusable without |
| Color contrast below 4.5:1 | SERIOUS | Fix before launch — affects low vision users |
| Missing alt text on informational images | SERIOUS | Add descriptive alt text |
| Missing skip navigation link | MODERATE | Add skip link — improves efficiency for keyboard users |
| Decorative image with alt text | MINOR | Set `alt=""` or use CSS background — screen readers announce needlessly |
| Missing `lang` attribute on `<html>` | MODERATE | Add language — affects screen reader pronunciation |
| Custom component without ARIA | CRITICAL | Add appropriate role, states, and properties per WAI-ARIA Authoring Practices |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| "Green Lighthouse = accessible" | Automated tools catch ~30% of issues | Run full 4-layer audit (automated + keyboard + screen reader + visual) |
| "Works with a mouse" as test | Ignores keyboard-only and screen reader users | Test with keyboard only, then screen reader |
| `div` with `onclick` instead of `button` | Not focusable, not announced as interactive | Use semantic `<button>` elements |
| `tabindex="5"` (positive values) | Creates unpredictable tab order | Use `tabindex="0"` (natural order) or `tabindex="-1"` (programmatic focus only) |
| Hiding content with `display: none` that should be screen-reader-accessible | Hidden from ALL users, including assistive tech | Use `.sr-only` / `visually-hidden` CSS class |
| Color as sole indicator | Colorblind users cannot distinguish | Add icon, text, or pattern as secondary indicator |
| Auto-playing video/audio | Disorienting for screen reader users, violates 1.4.2 | Require user interaction to start media |
| `aria-label` on non-interactive elements | Most ARIA attributes only work on interactive elements | Use visible text or `aria-describedby` |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| SDD Pipeline | Can be invoked during sdd-verify as additional quality layer for web projects |
| React/Next.js | Validate JSX components for semantic HTML, ARIA, and keyboard handling |
| E2E Testing | Integrate axe-core into Playwright tests for automated baseline |
| CI/CD | Add `@axe-core/cli` or `pa11y` to pipeline for regression detection |

## Code Examples

```bash
# Example: axe-core automated scan via CLI
npx @axe-core/cli http://localhost:3000 --exit

# Example: Lighthouse accessibility audit
npx lighthouse http://localhost:3000 --only-categories=accessibility --output=json --output-path=./a11y-report.json
```

```typescript
// Example: axe-core in Playwright E2E test
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('homepage has no accessibility violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

```html
<!-- Example: Accessible modal dialog -->
<dialog id="confirm-dialog" aria-labelledby="dialog-title" aria-describedby="dialog-desc">
  <h2 id="dialog-title">Confirm Action</h2>
  <p id="dialog-desc">Are you sure you want to proceed?</p>
  <button autofocus>Confirm</button>
  <button>Cancel</button>
</dialog>
<!-- Focus trapped inside while open, Escape closes, focus returns to trigger -->
```

## Commands

```bash
# Run axe-core accessibility audit
npx @axe-core/cli http://localhost:3000 --exit

# Run pa11y for WCAG 2.2 AA compliance
npx pa11y http://localhost:3000 --standard WCAG2AA

# Check contrast ratio (requires contrast-ratio npm package)
npx contrast-ratio "#333333" "#FFFFFF"  # Should be >= 4.5:1 for normal text
```

## Rules

- Always reference specific WCAG 2.2 success criteria by number and name (e.g., 1.4.3 Contrast Minimum)
- Severity scale: CRITICAL > SERIOUS > MODERATE > MINOR — use consistently
- Never rely solely on automated tools — they catch ~30% of issues
- Custom components are guilty until proven accessible — validate keyboard, screen reader, and ARIA
- Green Lighthouse accessibility score is a starting point, not a certification
- Every finding must include: criterion, severity, user impact, specific location, and remediation code
- Keyboard traps are always CRITICAL — they completely block keyboard-only users
- Color must never be the sole means of conveying information
- Test at 200% zoom minimum — layout must remain usable

## What This Means (Simply)

> **For non-technical readers**: This skill makes sure our software works for everyone, including people who navigate with a keyboard instead of a mouse, people who use screen readers because they cannot see the screen, and people with low vision who need high contrast. Think of it like building a physical store — you would not build one without a wheelchair ramp. This skill is the digital equivalent: making sure no one is locked out of using our product because of how it was built. Automated tools catch some issues, but most require human testing to find.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Lighthouse score is green, we're accessible" | Lighthouse and axe-core catch ~30% of WCAG issues. Green score means "no automated violations" — keyboard traps, screen reader chaos, and cognitive issues all pass automated checks. Run the full 4-layer audit. |
| "Screen reader users are rare" | ~25% of users have a disability that affects software use. Screen reader users alone are millions. "Rare" is also irrelevant — accessibility is a legal requirement (ADA in US, EAA in EU, Ley 1618 in Colombia), not a usage statistic. |
| "We'll add a11y after launch" | A11y patches retrofitted onto a finished UI cost 10-100x more than building it correctly the first time. Semantic HTML, keyboard handling, and focus management are foundational, not cosmetic. |
| "Just add aria-label everywhere to fix it" | ARIA can MAKE accessibility worse. First rule of ARIA: don't use it. Use semantic HTML (`<button>`, `<nav>`, `<h1>`) — it's accessible by default. ARIA is for cases semantic HTML cannot express. |
| "Users can zoom if they need bigger text" | WCAG 1.4.4 requires content to remain functional at 200% zoom. Most layouts break at 200%. Zoom is a fallback, not a substitute for proper responsive design and semantic markup. |

## Red Flags

- `<div onclick>` instead of `<button>` — not focusable, not announced, not keyboard-accessible
- `tabindex="5"` or any positive tabindex value — creates unpredictable tab order
- No visible focus indicator (or `outline: none` without replacement) — keyboard users lost
- Color used as the sole way to convey state (red = error, green = success) — colorblind users excluded
- Auto-playing video or audio without user control — violates WCAG 1.4.2
- Modal dialogs without focus trap, without Escape to close, without focus return to trigger
- Form inputs without `<label>` or `aria-label` — completely unusable with screen readers
- `aria-label` on non-interactive elements (most ARIA only works on interactive elements)
- Missing `lang` attribute on `<html>` — affects screen reader pronunciation
- `display: none` used to hide content meant to be screen-reader-accessible (use `.sr-only` instead)
- Image carousels or sliders without keyboard navigation, pause control, or focus management
- Custom dropdowns/comboboxes built from `<div>` without ARIA combobox pattern

## Verification Checklist

- [ ] Layer 1 (Automated) run: axe-core or Lighthouse, all violations documented with WCAG criterion
- [ ] Layer 2 (Keyboard-only) run: every interactive element reachable, focus visible, no traps, Escape works on overlays
- [ ] Layer 3 (Screen reader) run: NVDA or VoiceOver, reading order makes sense, dynamic updates announced
- [ ] Layer 4 (Visual/cognitive) run: 200% and 400% zoom, prefers-reduced-motion, high contrast mode
- [ ] All findings cite specific WCAG 2.2 criterion by number and name (e.g., 1.4.3 Contrast Minimum)
- [ ] All findings include severity (CRITICAL / SERIOUS / MODERATE / MINOR), user impact, location, and remediation code
- [ ] No keyboard traps anywhere — every component can be entered AND exited via keyboard
- [ ] All form inputs have associated labels (`<label for>`, `aria-label`, or `aria-labelledby`)
- [ ] Color contrast: text >= 4.5:1, large text >= 3:1, UI components >= 3:1
- [ ] No information conveyed by color alone — every color cue has an icon, text, or pattern equivalent
- [ ] Custom components (dropdowns, tabs, modals, carousels) follow WAI-ARIA Authoring Practices
- [ ] `lang` attribute set on `<html>` element
- [ ] Modal dialogs: focus trapped, Escape closes, focus returns to trigger, `aria-labelledby` and `aria-describedby` set
- [ ] axe-core integrated into Playwright E2E tests for regression detection
- [ ] CI pipeline runs `@axe-core/cli` or `pa11y` and fails on new violations
