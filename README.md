# Dash-Shell Template

Create a react-ts project with:

```
yarn create vite app3 --template react-ts
```

Install via:

```
yarn install
```

Update `vite.conig.ts` and use GitHub Actions to deploy. A corresponding workflow is included in the repository.

## Multi-language stories

Each `##` section in `src/stories/**/story.md` is one variant. Keep its shared
description before the first code fence, then add a code/preview pair for each
available language. The R/Py/JS toggle switches both code and plot without
changing the description or route. Existing R-only stories need no changes.

For example, `src/stories/charts/alluvial/story.md` uses:

````markdown
## Basic

Shared explanation of the plot.

```r
!r(plot01.R)
```

![](./plot01-r.svg)

```python
!py(plot01.py)
```

![](./plot01-py.svg)

```jsx
!js(plot01-js.jsx)
```

!plot(plot01-js.jsx)
````

Code may be inline or referenced from local `.R`, `.py`, `.js`, or `.jsx` files.
Supported fences are `r`, `python`/`py`, `javascript`/`js`, and `jsx`.
Each language needs its own preview immediately after its code fence: either a
saved image using `![](./filename.svg)` (PNG/JPEG/GIF also supported), or a
`!plot(filename.jsx)` reference to a local React component with a default export.
JSX is highlighted as JSX and shown under JS in the toggle. Plot components are
trusted, bundled application code, not a runtime code runner; their dependencies
must be installed in this project. R and Python are not executed in the browser;
generate and commit their images separately.

Run `yarn test` for story parser and asset-resolution checks.

## CSS

 Key Improvements for MFE Architecture:

  1. Scoped CSS Custom Properties

   - All variables now prefixed with --mfe-template-* to avoid conflicts with host app 
  or other MFEs
   - Added semantic tokens: --mfe-template-heading, --mfe-template-surface, 
  --mfe-template-elevated

  2. BEM-Style Class Names

   - Changed from generic IDs (#center, #docs) to scoped classes (.mfe-template__center,
   .mfe-template__docs)
   - Follows the pattern: .mfe-template (block) → .mfe-template__element (element)
   - Prevents CSS collisions when multiple MFEs are on the same page

  3. Component-Scoped Styles

   - Root container .mfe-template wraps everything
   - All child elements inherit scoped tokens
   - Uses * { box-sizing: border-box } within scope only

  4. Modern CSS Improvements

   - clamp() for fluid typography instead of fixed breakpoints
   - Improved transition consistency (0.15s ease everywhere)
   - Better focus states with ring-style outlines
   - Enhanced button states (hover, active, disabled)