---
name: leet-fundamentals
description: Generate foundational concept guides for DSA topics with progressive learning structure
tags: [leetcode, dsa, fundamentals, learning]
---

# LeetCode Fundamentals Guide Generator

Generate comprehensive foundational guides for DSA topics that build deep conceptual understanding through progressive learning.

## When to Use

Use this skill when:

- Starting a new topic in your DSA learning path
- Need to build foundational understanding before solving problems
- Want concept maps and mental models for a topic
- Looking for annotated code templates and patterns

Example: `/leet-fundamentals Binary Trees` or `/leet-fundamentals Sliding Window`

## Instructions

You are generating a **foundational concept guide** that helps the user build deep understanding of a DSA topic through progressive learning.

### Step 1: Extract Topic Information

1. Read `/Users/snesjhon/Developer/snesjhon/ysk/dsa/00-complete-dsa-path.md`
2. Find the section matching the user's requested topic (case-insensitive search)
3. Extract:
   - Topic name and duration
   - "What You Learn" points
   - "Key Problems" list
   - "Why Now" explanation
   - Prerequisites (identify what topics come before this in the DSA path)

### Step 2: Check for Existing Study Guides

1. Use Glob to search for study guides: `ysk/study-guides/**/mental-model.md`
2. Parse the directory names to match against key problems
3. For each key problem in the topic, check if a study guide exists
4. If found, note the path for linking in the guide

### Step 3: Generate Comprehensive Guide

**Reference example**: `ysk/fundamentals/graphs-fundamentals.md` and `ysk/fundamentals/graph-traversal-dfs-fundamentals.md` are the canonical examples of this style. Read them before generating to match the tone, depth, and structure.

Create a guide following this structure:

---

#### Front Matter

```markdown
# {Topic} - Fundamentals

> 📚 **Part of**: [Complete DSA Learning Path](../dsa/00-complete-dsa-path.md)
>
> **Generated**: {current date}
>
> **Duration**: {duration from DSA path}
>
> **Prerequisites**: {list topics that come before, linked if guides exist}
```

---

#### 1. Overview

- 2-3 sentences: what this topic is and why it matters
- One sentence on what the user already knows that connects to this topic
- What the three building-block levels will cover

---

#### 2. Core Concept & Mental Model

**Real-world analogy** — always open with a concrete analogy (city map, building, maze, etc.) that maps directly to the concept. Name its components explicitly: what the nodes are, what the edges are, what the algorithm does in analogy terms.

**Concept Map** (Mermaid): show relationships between the core ideas, not a flowchart of steps.

```mermaid
graph TD
    {core idea} --> {property 1}
    {core idea} --> {property 2}
    ...
```

**Complexity table**: one table covering all operations.

---

#### 3. Building Blocks — Progressive Learning

Each level has this exact structure — do not skip any part:

**Level N: {Name}**

**Why this level matters**
One paragraph: why you need this concept, what problem it solves, how it connects to what came before.

**How to think about it**
One or two paragraphs: the mental model in plain language. No code yet. Explain what the algorithm is *doing*, not just what it *is*. Reference the analogy from Section 2.

**Walking through it**
A manual step-by-step trace on a small, concrete example. Show the state at every step — visited sets, queues, distances, paths, colors, etc. Use plain text tables or indented steps, not code. The reader should be able to follow along with pencil and paper.

**The one thing to get right**
One or two sentences identifying the single most important insight, gotcha, or ordering constraint for this level. Then show the consequence of getting it wrong (wrong output, infinite loop, etc.).

**Code** — short, focused TypeScript. The prose above does the explaining. The code is the confirmation. Avoid inline comments restating what the prose already said. Keep it under ~20 lines when possible.

**Mental anchor** — one sentence in a blockquote that the reader can memorize:
> "DFS = go deep, mark first, backtrack. The visited set is the only thing stopping cycles from looping forever."

**→ Bridge to Level N+1**
One sentence explaining *why* the next level exists: what problem the current level can't solve, and how the next level addresses it.

---

#### 4. Key Patterns

Cover 2 patterns that go beyond the building blocks — real problem variations the user will encounter. Follow this structure per pattern:

**Pattern: {Name}**

**When to use**: problem characteristics that indicate this pattern.

**How to think about it**: prose explanation of the key insight (not just what the code does, but *why* this approach works).

**Code**: complete, runnable TypeScript. Shorter than you think — avoid restating things already covered in Building Blocks.

**Complexity**: Time and Space.

---

#### 5. Decision Framework

Mermaid decision tree: how to recognize which pattern applies. Should be actionable — each leaf should name a specific technique.

**Recognition signals table**: problem keywords → technique.

**When NOT to use**: clear contrast with the alternative.

---

#### 6. Common Gotchas & Edge Cases

- 3-5 mistakes, each with: what goes wrong, why it's tempting, how to fix it
- Edge cases list
- Debugging tips (what to print/trace, how to spot the failure)

---

#### 7. Practice Path

Organize problems from the DSA path into Starter / Core / Challenge tiers. For each problem, add one sentence explaining *what specifically it tests* from this guide. Link to existing study guides when available.

End with a Suggested Order: numbered list with a reason for each step.

---

### Step 4: Save the Guide

1. Create filename from topic:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Add `-fundamentals.md`
   - Example: "Binary Trees" → `binary-trees-fundamentals.md`

2. Create directory if needed: `/Users/snesjhon/Developer/snesjhon/ysk/fundamentals/`

3. Save the generated guide to the path

4. Confirm successful save

---

### Step 5: Generate TypeScript Exercise Files

Create one `.ts` file per building-block level in a subdirectory named after the topic slug.

**Directory**: `/Users/snesjhon/Developer/snesjhon/ysk/fundamentals/{topic-slug}/`
- Example: "Graph Traversal DFS" → `graph-traversal-dfs/`

**Reference examples**: `ysk/fundamentals/graph-fundamentals/level-1-representing-a-graph.ts`, `level-2-dfs.ts`, `level-3-bfs.ts`, and `level-grid-dfs.ts` show the exact format to follow.

**File naming**: `level-1-{concept-name}.ts`, `level-2-{concept-name}.ts`, etc.

**Each file must follow this structure exactly**:

```typescript
// =============================================================================
// Level N: {Level Name from guide}
// =============================================================================
// Before running: npx ts-node {filename}.ts
// Goal: {one sentence describing what this level practices}
//
// {Optional: one or two lines of context if the level has a key shift
//  from previous levels — e.g. "There is no adjacency list to build here.
//  Each cell IS the node."}

// -----------------------------------------------------------------------------
// Exercise 1
// {Clear description of what the function should do.}
// {One or two sentences of context if needed.}
//
// Example:
//   {functionName}({input}) → {expected output}
//   {functionName}({input2}) → {expected output2}
// -----------------------------------------------------------------------------
function {functionName}({params}): {returnType} {
  throw new Error("TODO");
}

test('{description}', {functionName}({input}), {expected});
test('{description}', {functionName}({input2}), {expected2});
// ... 4-6 tests per exercise covering normal cases and edge cases

// -----------------------------------------------------------------------------
// Exercise 2
// ...same structure...
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Exercise 3
// ...same structure...
// -----------------------------------------------------------------------------

// =============================================================================
// Tests — all should print PASS
// =============================================================================

function test(desc: string, actual: unknown, expected: unknown): void {
  const pass = JSON.stringify(actual) === JSON.stringify(expected);
  console.log(`${pass ? 'PASS' : 'FAIL'} ${desc}`);
  if (!pass) {
    console.log(`  expected: ${JSON.stringify(expected)}`);
    console.log(`  received: ${JSON.stringify(actual)}`);
  }
}
```

**Rules for exercise files**:
- **Leave all function bodies as `throw new Error("TODO")`** — the user fills in implementations
- Each file has exactly 3 exercises, each slightly harder than the last
- Exercises progress: basic case → variation → combined/harder
- Test cases: 4-6 per exercise, covering a normal case, edge cases (single element, empty, etc.), and boundary conditions
- The `test()` helper goes at the **bottom** of the file
- Tests are called inline after each function definition (not grouped at bottom)
- Keep exercise descriptions concrete: show the exact input/output in the example block

---

### Validating Mermaid Charts

**CRITICAL: Always validate charts before completion**

After creating a mental model with mermaid charts, you MUST validate them:

```bash
# Run the validation script on your mental-model.md file
~/Developer/dotfiles/claude/skills/leet-mental/validate-mermaid.sh mental-model.md
```

The script will:

1. Extract all mermaid blocks from the markdown file
2. Validate basic syntax (diagram type, structure, common errors)
3. Report which charts pass syntax validation
4. Exit with error code if any chart has syntax errors

**Validation workflow:**

1. Create mental-model.md with mermaid charts
2. Run validation script
3. If errors found: fix the mermaid syntax and re-run
4. Only consider the file complete when all charts pass validation

**Note:** This performs basic syntax validation without rendering. Charts should still be visually verified in GitHub, Obsidian, or other markdown viewers.

---

## Output After Generation

After generating and saving the guide, provide:

```markdown
✅ **Generated**: {topic} Fundamentals Guide

📁 **Saved to**: `ysk/fundamentals/{filename}`

📊 **Guide Includes**:

- {n} Key Patterns with annotated templates
- {n} Mermaid diagrams (concept maps & decision trees)
- {n} Practice problems from your DSA path
- {n} Existing study guides linked

🎯 **Prerequisites**: {list them}

💡 **Next Steps**:

1. Read through "Core Concept & Mental Model" to build intuition
2. Work through "Building Blocks" progressively
3. Study the key patterns and their templates
4. Practice with the problems in suggested order

Ready to dive in? Start with the 'Building Blocks' section! 🚀
```

---

## Important Guidelines

- **Prose first, code second**: the explanations ("Why this level matters", "How to think about it", "Walking through it") do the teaching. Code is short and confirming, not the primary explanation vehicle. Avoid restating in inline comments what the prose already said.
- **State traces over diagrams**: for Building Blocks levels, a manual step-by-step trace showing the visited set / queue / path at each step teaches more than a flowchart.
- **Depth**: focused fundamentals (aim for 30-45 min read time)
- **Code Language**: TypeScript
- **Visualizations**: Use mermaid for concept maps (Section 2) and decision trees (Section 5). Do not use mermaid to show algorithm steps — use prose traces instead.
- **Tone**: plain, direct, progressive. Build confidence with each level.
- **Links**: always link to existing fundamentals guides for prerequisites, and to existing study guides for practice problems
- **Prerequisites**: extract from DSA path order — show what should be learned first
- **Progression**: each level solves exactly one new problem the previous level couldn't handle. Name that problem explicitly in the bridge sentence.
- **Exercise files**: always generate alongside the markdown guide (Step 5). Leave all implementations as `throw new Error("TODO")` — never fill them in.

---

## Example Invocations

```bash
/leet-fundamentals Binary Trees
/leet-fundamentals Sliding Window
/leet-fundamentals Dynamic Programming
/leet-fundamentals Two Pointers
/leet-fundamentals Graphs
```

The skill will:

1. Find the topic in the DSA path
2. Extract all relevant information
3. Check for existing study guides
4. Generate a comprehensive, progressive guide
5. Save to `ysk/fundamentals/`
6. Provide a summary and next steps
