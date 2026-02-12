---
name: leet-remotion
description: Generate algorithm visualization animations using Remotion for LeetCode study guides
---

# Algorithm Visualization Animations with Remotion

## Purpose

This skill creates **frame-synchronized algorithm visualization animations** using Remotion. Each animation teaches how an algorithm works step-by-step, with the tree/data structure animating in sync with a guide panel that explains each phase.

**What this skill does:**
- Creates Remotion compositions that visualize algorithm execution
- Animates data structures (trees, arrays, graphs) showing each step of the algorithm
- Syncs visual changes (node highlights, edge rewiring, position transitions) with explanatory text and code

**What this skill does NOT do:**
- Create generic video content or presentations
- Build interactive web apps
- Animate without teaching the algorithm

## Prerequisite

The animation MUST be based on an existing mental model study guide created by the `leet-mental` skill. The mental model's "Building the Algorithm Step-by-Step" section defines the steps that the animation visualizes.

**Required input:** A `mental-model.md` file at:
`/Users/snesjhon/Developer/snesjhon/ysk/study-guides/[problem-number]-[problem-name]/mental-model.md`

## Output Location

Create the animation project at:
`/Users/snesjhon/Developer/snesjhon/ysk/study-guides/[problem-number]-[problem-name]/animation/`

## Required Workflow

1. **Read the mental model** — Extract the algorithm steps, analogy, and trace example
2. **Map steps to animation phases** — Each step from "Building the Algorithm Step-by-Step" becomes a timeline phase
3. **Define data structure states** — Pre-compute position maps for each visual state (original, intermediate, final)
4. **Define edge states** — Track which edges exist, appear, disappear, or change color at each phase
5. **Write the single-file composition** — All animation logic in one file, driven by `useCurrentFrame()`
6. **Verify** — Run `npx remotion studio` and scrub through the timeline

---

## Architecture: The Single-Source-of-Truth Pattern

**Everything derives from the frame number.** No React state, no useEffect, no timers. The current frame is the ONLY input, and all visual output is a pure function of it.

```
frame → getPos(val)         → node positions
frame → computeEdges()      → edge colors, opacity, dashing
frame → getNodeStyle(val)   → node fill, stroke, ring
frame → getGuideContent()   → panel text, code, tag
frame → getActiveStep()     → progress indicator
```

### File Structure

```
animation/
├── package.json
├── tsconfig.json
├── remotion.config.ts
└── src/
    ├── index.ts
    ├── Root.tsx              (Composition wrapper — fps, dimensions, duration)
    └── [ProblemName].tsx     (Single-file composition with ALL animation logic)
```

**The composition is a SINGLE FILE.** Inline all sub-components (TreeNodeCircle, ArrowEdge, SvgLabel, GuidePanel). This keeps the tight frame-based coupling explicit and debuggable.

---

## Timeline Design

### Frame Budget

- **Target:** 540-600 frames at 30fps (18-20 seconds)
- **Canvas:** 1280×1000 (tree top half, guide panel bottom half)

### Phase Structure

Map each step from the mental model to a timeline phase. Use named frame constants for EVERY transition point:

```typescript
// ── Timeline (540 frames @ 30fps = 18s) ──────────────────────────
const INTRO_START = 0;       // Data structure entrance animation
const OVERVIEW_START = 70;   // Algorithm overview in guide panel

const STEP1_START = 120;     // Step 1 from mental model
const STEP2_START = 180;     // Step 2 from mental model
const STEP3_START = 250;     // Step 3 from mental model

const TRACE_START = 320;     // Full algorithm trace
const FPN = 30;              // Frames per node/element during trace

const FINAL_START = 500;     // Final state transition
```

### Sub-Phase Granularity

Within each step, define sub-phases that sync tree animations with guide panel content. The guide panel text should change at the SAME frame that the tree animation changes:

```typescript
// Step 2 sub-phases (example: walk order for tree traversal)
const t = frame - STEP2_START;
if (t < 25)  { /* highlight group A + show explanation A */ }
if (t < 50)  { /* highlight group B + show explanation B */ }
if (t >= 50) { /* highlight group C + show explanation C */ }
```

---

## Data Structure Visualization Patterns

### Pre-Computed Position Maps

Define explicit positions for each visual state. NEVER compute positions dynamically from a layout algorithm during the animation — pre-compute them.

```typescript
type Pos = { x: number; y: number };

// Original data structure layout
const POS_ORIGINAL: Record<number, Pos> = {
  1: { x: 640, y: 140 },
  2: { x: 420, y: 270 },
  // ...
};

// Final state (e.g., flattened linked list)
const POS_FINAL: Record<number, Pos> = {
  1: { x: 640, y: 95 },
  2: { x: 640, y: 170 },
  // ...
};
```

### Position Interpolation

Use `lerpPos` with Remotion's `interpolate` and `Easing` for smooth transitions between states:

```typescript
function lerpPos(a: Pos, b: Pos, t: number): Pos {
  return { x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t };
}

const tFinal = interpolate(frame, [FINAL_START, FINAL_START + 35], [0, 1], {
  extrapolateLeft: "clamp", extrapolateRight: "clamp",
  easing: Easing.inOut(Easing.quad),
});

const getPos = (val: number): Pos => {
  if (frame < FINAL_START) return POS_ORIGINAL[val];
  return lerpPos(POS_ORIGINAL[val], POS_FINAL[val], tFinal);
};
```

### Edge State Machine

Edges are the most complex part. Build the edge array explicitly per-frame using if/else chains on frame ranges:

```typescript
type RenderedEdge = {
  from: number; to: number;
  color: string; opacity: number;
  dashed?: boolean; strokeWidth?: number;
};

const edges: RenderedEdge[] = [];

if (frame < TRACE_START) {
  // Original edges with entrance animation
  for (let i = 0; i < EDGES_ORIG.length; i++) {
    edges.push({ from: e.from, to: e.to, color: C.edge, opacity: edgeEntrance(i) });
  }
} else if (frame < FINAL_START) {
  // Trace: edges appear/disappear/change color based on processing state
  // NEW edges: fade in with blue color, then turn green
  // REMOVED edges: turn red + dashed, then fade out
  // CHAIN edges: turn green when their node is processed
} else {
  // Final: all edges in final color
  for (const e of EDGES_FINAL) {
    edges.push({ from: e.from, to: e.to, color: C.done, opacity: 1 });
  }
}
```

**Edge color semantics:**
| Color | Meaning |
|-------|---------|
| Gray (`#94A3B8`) | Default/original edge |
| Blue (`#3B82F6`) | New edge being created |
| Red (`#EF4444`) | Edge being destroyed (+ dashed) |
| Green (`#10B981`) | Finalized/chain edge |

### Node State System

Nodes change appearance based on their role in the current phase:

```typescript
const getNodeStyle = (val: number) => {
  let fill = C.node;       // white
  let stroke = C.border;   // dark gray
  let ring: string | undefined;

  // Walk highlights (e.g., subtree groups during traversal explanation)
  if (walkHighlight.has(val)) { fill = C.activeBg; stroke = C.active; }

  // Active node during trace: amber with dashed ring
  if (val === activeNode) { fill = C.activeBg; stroke = C.active; ring = C.active; }

  // Processed node: green
  if (processedNodes.has(val)) { fill = C.doneBg; stroke = C.done; }

  return { fill, stroke, ring };
};
```

**Node visual states:**
| State | Fill | Stroke | Ring |
|-------|------|--------|------|
| Default | White | Dark gray | None |
| Highlighted | Amber bg | Amber | None |
| Active (being processed) | Amber bg | Amber | Dashed amber |
| Processed | Green bg | Green | None |

---

## SVG Components (Inline)

### TreeNodeCircle

```tsx
const TreeNodeCircle: React.FC<{
  x: number; y: number; val: number;
  fill: string; stroke: string; scale?: number; opacity?: number;
  ring?: string;
}> = ({ x, y, val, fill, stroke, scale = 1, opacity = 1, ring }) => (
  <g transform={`translate(${x},${y}) scale(${scale})`} opacity={opacity}>
    {ring && (
      <circle r={NODE_RADIUS + 7} fill="none" stroke={ring} strokeWidth={3}
        strokeDasharray="5 3" opacity={0.8} />
    )}
    <circle r={NODE_RADIUS} fill={fill} stroke={stroke} strokeWidth={2.5} />
    <text textAnchor="middle" dominantBaseline="central"
      fill={C.text} fontSize={17} fontWeight={700} fontFamily={FONT}>
      {val}
    </text>
  </g>
);
```

### ArrowEdge

Edges shortened to stop at node borders, with SVG arrow markers:

```tsx
const ArrowEdge: React.FC<{
  x1: number; y1: number; x2: number; y2: number;
  color: string; opacity: number; dashed?: boolean; strokeWidth?: number;
}> = ({ x1, y1, x2, y2, color, opacity, dashed, strokeWidth = 2.5 }) => {
  const dx = x2 - x1, dy = y2 - y1;
  const len = Math.sqrt(dx * dx + dy * dy);
  if (len === 0) return null;
  const ux = dx / len, uy = dy / len;
  return (
    <line
      x1={x1 + ux * NODE_RADIUS} y1={y1 + uy * NODE_RADIUS}
      x2={x2 - ux * NODE_RADIUS} y2={y2 - uy * NODE_RADIUS}
      stroke={color} strokeWidth={strokeWidth} opacity={opacity}
      strokeDasharray={dashed ? "6 4" : undefined}
      markerEnd={`url(#arrow-${color.replace("#", "")})`} />
  );
};
```

### SvgLabel

For contextual labels on the tree ("lastLinked", ".left", ".right", order numbers):

```tsx
const SvgLabel: React.FC<{
  x: number; y: number; text: string; color: string;
  opacity: number; fontSize?: number; bold?: boolean;
}> = ({ x, y, text, color, opacity, fontSize = 12, bold }) => (
  <text x={x} y={y} fill={color} fontSize={fontSize}
    fontWeight={bold ? 700 : 500} fontFamily={FONT} opacity={opacity}
    textAnchor="middle">
    {text}
  </text>
);
```

### SVG Arrow Marker Definitions

Always include in the SVG `<defs>`:

```tsx
<defs>
  {[C.edge, C.done, C.newEdge, C.removedEdge, C.active].map((color) => (
    <marker key={color} id={`arrow-${color.replace("#", "")}`}
      viewBox="0 0 10 7" refX="9" refY="3.5"
      markerWidth="8" markerHeight="6" orient="auto-start-reverse">
      <polygon points="0 0, 10 3.5, 0 7" fill={color} />
    </marker>
  ))}
</defs>
```

---

## Guide Panel

The bottom panel has two parts: **step progress dots** and **content area** (description + code).

### Guide Content Function

Returns different content based on frame ranges. This is the TEXT counterpart to the tree animation — both must change at the same frame boundaries:

```typescript
type GuideContent = {
  tag: string;        // "STEP 1", "CONNECT", "NODE 4", "COMPLETE"
  tagColor: string;   // Color for the tag badge
  title: string;      // Bold heading
  description: string; // Explanation paragraph
  code: string;       // Code snippet (monospace)
};

function getGuideContent(frame: number): GuideContent {
  if (frame < STEP1_START) return { tag: "OVERVIEW", ... };
  if (frame < STEP2_START) return { tag: "STEP 1", ... };
  // Sub-phases within steps:
  if (frame < STEP3_START) {
    const t = frame - STEP2_START;
    if (t < 25) return { tag: "STEP 2", title: "Sub-phase A", ... };
    if (t < 50) return { tag: "STEP 2", title: "Sub-phase B", ... };
    return { tag: "STEP 2", title: "Sub-phase C", ... };
  }
  // During trace: dynamic content per node
  if (frame < FINAL_START) {
    const idx = Math.floor((frame - TRACE_START) / FPN);
    const val = PROCESS_ORDER[idx];
    return { tag: `NODE ${val}`, title: `Processing node ${val}`, ... };
  }
  return { tag: "COMPLETE", ... };
}
```

### Step Progress Dots

A horizontal row of numbered circles with connecting lines. Shows which step is active/done:

- **Done** (i < activeStep): Green fill
- **Active** (i === activeStep): Step color fill, slightly larger
- **Pending** (i > activeStep): Empty with gray border

### Layout

```
┌─────────────────────────────────────────────────┐
│  Title bar (60px)                                │
│─────────────────────────────────────────────────│
│                                                  │
│  SVG: Tree / Data Structure (top ~520px)         │
│  - Nodes with entrance animations                │
│  - Edges with arrow markers                      │
│  - Labels (.left, .right, order numbers)         │
│  - Guide ring on active node                     │
│                                                  │
│═════════════════════════════════════════════════│
│  Guide Panel (bottom ~480px)                     │
│  ● ─── ● ─── ● ─── ●  (step progress)          │
│  [TAG]                                           │
│  Title              │ code block │               │
│  Description        │            │               │
└─────────────────────────────────────────────────┘
```

---

## Entrance Animations

Stagger node and edge entrance with spring + opacity:

```typescript
const nodeEntrance = (_val: number, idx: number) => {
  const delay = OVERVIEW_START + idx * 5;
  const s = spring({ frame: frame - delay, fps, config: { damping: 200 } });
  const o = interpolate(frame, [delay, delay + 8], [0, 1], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });
  return { scale: s, opacity: o };
};

// After entrance completes, clamp to 1 so nodes don't bounce forever:
const fs = frame >= OVERVIEW_START + 30 ? Math.max(scale, 1) : scale;
```

---

## Color Palette

Use this consistent palette across all algorithm animations:

```typescript
const C = {
  bg: "#FAFAFA",             // Canvas background
  node: "#FFFFFF",           // Default node fill
  border: "#334155",         // Default node stroke
  text: "#0F172A",           // Node text
  edge: "#94A3B8",           // Default edge color
  active: "#F59E0B",         // Active/highlighted (amber)
  activeBg: "#FEF3C7",      // Active node background
  done: "#10B981",           // Processed/complete (green)
  doneBg: "#D1FAE5",        // Processed node background
  newEdge: "#3B82F6",        // New edge appearing (blue)
  removedEdge: "#EF4444",    // Edge being removed (red)
  title: "#0F172A",          // Title text
  sub: "#64748B",            // Subtitle/secondary text
  codeBg: "#F1F5F9",         // Code block background
  codeText: "#334155",       // Code text
  panelBg: "#FFFFFF",        // Guide panel background
  panelBorder: "#E2E8F0",    // Guide panel border
  dimText: "#94A3B8",        // Dimmed/inactive text
};
```

---

## Checklist Before Completion

1. Read the mental model's "Building the Algorithm Step-by-Step" section
2. Each step maps to a timeline phase with named frame constants
3. Guide panel text changes at the SAME frames as tree animations
4. Edges animate: new (blue fade-in), removed (red dashed fade-out), chain (green)
5. Nodes animate: default → active (amber + ring) → processed (green)
6. Final state: data structure transitions to result layout (lerp positions)
7. SVG arrow markers defined for all edge colors
8. Entrance animations staggered with spring + opacity
9. `npx tsc --noEmit` passes
10. `npx remotion studio` — scrub through all phases, verify sync

---

## Edge Tracking: Per-Edge Fate Planning

Before writing any edge animation code, plan the **fate of every edge** — what happens to each original edge and what new edges appear. Document this as comments in the trace section:

```typescript
// Original edges and their fate:
//   1→2 (L): stays, becomes chain R when node 1 is processed
//   1→5 (R): destroyed when node 1 is processed
//   2→3 (L): stays, becomes chain R when node 2 is processed
//   2→4 (R): destroyed when node 2 is processed
//   5→6 (R): stays, becomes chain when node 5 is processed
//
// New chain edges:
//   4→5 (R): created when node 4 is processed
//   3→4 (R): created when node 3 is processed
```

Each edge falls into one of these categories:
- **Survives unchanged**: stays with same color throughout
- **Survives + recolors**: original edge that becomes part of the result (gray → green)
- **Destroyed**: fades out with red + dashed styling when its owner node is processed
- **Created**: new edge that fades in with blue styling, then turns green when finalized

Handle each edge individually in the trace section using `done.has(node)` and `isBeingProcessed(node)` checks, with `traceSubFrame`-based interpolation for mid-processing animations.

---

## Trace Sub-Frame Timing

Within each node's processing window (`FPN` frames), use consistent sub-frame offsets for the three micro-animations:

```typescript
const traceSubFrame = traceFrame % FPN;

// New edge fade-in: starts at sub-frame 8, completes by 18
if (isBeingProcessed(node) && traceSubFrame >= 8) {
  const p = interpolate(traceSubFrame, [8, 18], [0, 1], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });
  edges.push({ from: node, to: target, color: C.newEdge, opacity: p, strokeWidth: 3 });
}

// Destroyed edge fade-out: starts at sub-frame 5, completes by 18
if (isBeingProcessed(node)) {
  const fadeP = interpolate(traceSubFrame, [5, 18], [1, 0], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });
  if (fadeP > 0) {
    edges.push({ from: node, to: old, color: C.removedEdge, opacity: fadeP, dashed: true });
  }
}

// Recolor transition: starts at sub-frame 10, completes by 22
if (isBeingProcessed(node)) {
  const p = interpolate(traceSubFrame, [10, 22], [0, 1], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });
  edges.push({ from: node, to: target, color: p > 0.5 ? C.done : C.edge, opacity: 1 });
}
```

---

## Step Preview Animations

Before the full trace, use the "Step 3" phase to preview the algorithm's core operation on a single example node. This teaches the viewer what to watch for during the fast trace:

```typescript
// Step 3 example: preview connect/snip/update on node 4
if (inStep3 && s3t >= 10) {
  // Show new edge appearing (blue, fading in)
  const p = interpolate(s3t, [10, 25], [0, 1], { ... });
  edges.push({ from: 4, to: 5, color: C.newEdge, opacity: p, strokeWidth: 3 });
}
```

The guide panel should break this into labeled sub-phases (e.g., "CONNECT", "SNIP", "UPDATE") with distinct tag colors matching the edge operation colors.

---

## Contextual SVG Labels

Add labels that appear/disappear at the right moments to reinforce understanding:

- **Edge direction labels** (`.left`, `.right`): Show during overview and step phases, hide during trace to reduce clutter
- **Processing order numbers**: Appear after the walk order is explained (late in step 2), positioned beside each node
- **Active pointer labels** (e.g., `lastLinked`): Track the current node during the trace phase
- **Final state labels** (e.g., `.right`): Fade in after the final position transition to label the result structure

```typescript
// Processing order labels — appear after walk order explanation
const showOrderLabels = frame >= STEP2_START + 55 && frame < TRACE_START;

// Active pointer during trace
{activeNode && (
  <SvgLabel x={pos.x} y={pos.y + 44}
    text="lastLinked" color={C.active} opacity={0.85} fontSize={11} bold />
)}

// Final .right labels after position transition
{frame >= FINAL_START + 15 && EDGES_FINAL.map((e) => {
  const lo = interpolate(frame, [FINAL_START + 15, FINAL_START + 30], [0, 0.6], { ... });
  return <SvgLabel text=".right" color={C.done} opacity={lo} fontSize={11} />;
})}
```

---

## Walk Order Highlights (Subtree Grouping)

When explaining traversal order, highlight entire subtrees as groups rather than individual nodes. This teaches the viewer to see the recursive structure:

```typescript
const RIGHT_SUBTREE = [5, 6];
const LEFT_SUBTREE = [2, 3, 4];

let walkHighlight = new Set<number>();
if (frame >= STEP2_START && frame < STEP3_START) {
  const t = frame - STEP2_START;
  if (t < 25) walkHighlight = new Set(RIGHT_SUBTREE);    // "Go right first"
  else if (t < 50) walkHighlight = new Set(LEFT_SUBTREE); // "Then go left"
  else walkHighlight = new Set([1]);                       // "Finally, process self"
}
```

Each sub-phase highlights a group with amber fill/stroke while the guide panel explains WHY that group is processed in that order.

---

## Main Composition Structure

The main composition function should follow this exact ordering of concerns:

1. **Frame and config**: `useCurrentFrame()`, `useVideoConfig()`
2. **Intro animations**: title opacity, tree visibility gate
3. **Entrance functions**: `nodeEntrance()`, `edgeEntrance()` using `spring` + `interpolate`
4. **Position transitions**: `tFinal` interpolation, `getPos()` function
5. **Trace state derivation**: `inTrace`, `traceIdx`, `traceSubFrame`, `processedNodes` set, `activeNode`
6. **Edge computation**: Full if/else chain building the `edges[]` array
7. **Highlight state**: Walk highlights, step example highlights
8. **Node styling**: `getNodeStyle()` combining all highlight/trace/final states
9. **Guide content**: `getGuideContent(frame)`, `getActiveStep(frame)`, panel opacity
10. **Render**: `<AbsoluteFill>` → title → SVG (defs → edges → labels → nodes → active labels) → GuidePanel

Clamp entrance animations after they complete so nodes don't oscillate:
```typescript
const fs = frame >= OVERVIEW_START + 30 ? Math.max(scale, 1) : scale;
const fo = frame >= OVERVIEW_START + 30 ? Math.max(opacity, 1) : opacity;
```
