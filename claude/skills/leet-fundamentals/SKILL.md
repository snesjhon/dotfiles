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

- Brief introduction (2-3 sentences)
- Why this topic matters in interviews and real-world applications
- What you'll learn by the end of this guide

---

#### 2. Core Concept & Mental Model

**Explanation**:

- Clear, intuitive explanation of the fundamental concept
- Avoid jargon initially, then introduce formal terms
- Real-world analogy that maps to the concept

**Concept Map** (Mermaid):

```mermaid
graph TD/LR
    {Show core properties, relationships, key operations}
```

Include:

- Core properties of the data structure/technique
- How it relates to concepts they already know
- Key operations and their O() complexity
- Visual representation if applicable

---

#### 3. Building Blocks - Progressive Learning

**Level 1: Simplest Form**

- Start with the most basic version
- Annotated TypeScript/JavaScript code example
- Explain each line with inline comments
- What makes this simple

**Level 2: Adding Complexity**

- Introduce one additional layer
- Show how the basic version extends
- Annotated code example
- Why this complexity is needed

**Level 3: Full Pattern**

- Complete, production-ready template
- Heavily annotated TypeScript/JavaScript
- Cover all edge cases
- Time/Space complexity analysis

Use mermaid diagrams to show the progression visually where helpful.

---

#### 4. Key Patterns

Cover 2-3 most common patterns for this topic.

For each pattern:

**Pattern: {Name}**

**When to Use**:

- Input characteristics that suggest this pattern
- Problem types where this appears

**Template**:

```typescript
// Heavily annotated TypeScript/JavaScript template
// Explain the approach, why each step matters
// Include complexity in comments
```

**Walkthrough** (optional mermaid diagram):

- Show execution on a simple example if it aids understanding

**Complexity**:

- Time: O(?)
- Space: O(?)
- Why this complexity

---

#### 5. Decision Framework

**Mermaid Decision Tree**:

```mermaid
graph TD
    {How to recognize when to use this technique}
    {What input patterns suggest this approach}
    {When to prefer alternatives}
```

**Recognition Signals**:

- List clear indicators that this technique applies
- Contrast with similar techniques

**When NOT to Use**:

- Situations where alternatives are better
- What to use instead

---

#### 6. Common Gotchas & Edge Cases

**Typical Mistakes**:

- List 3-5 common errors
- Why they happen
- How to avoid them

**Edge Cases**:

- Cases to always test
- Boundary conditions
- Special inputs (empty, single element, etc.)

**Debugging Tips**:

- How to trace through the algorithm
- What to print/log
- Common failure points

---

#### 7. Practice Path

**Problems from Your DSA Guide**:
Organize by difficulty, link to study guides if they exist:

**Starter Problems** (Build Intuition):

- [ ] [Problem Name](leetcode-link) {link to study guide if exists}
- [ ] Problem 2

**Core Problems** (Master the Pattern):

- [ ] Problem 3
- [ ] Problem 4

**Challenge Problems** (Test Mastery):

- [ ] Problem 5

**Suggested Order**:

1. Start with {specific problem} - it's the clearest example
2. Then try {problem 2} - adds {specific complexity}
3. Work through remaining problems in any order

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

- **Depth**: Focused fundamentals (aim for 30-45 min read time)
- **Code Language**: Always TypeScript/JavaScript with detailed inline comments
- **Annotations**: Every code block should be heavily commented - explain WHY, not just WHAT
- **Visualizations**: Use mermaid for:
  - Concept maps (relationships between ideas)
  - Decision trees (when to use this technique)
  - Flow diagrams (for complex algorithms)
  - Graph representations (for graph-based concepts)
- **Tone**: Educational, encouraging, progressive (build confidence step by step)
- **Links**: Always link to existing study guides when available
- **Prerequisites**: Extract from DSA path order - show what should be learned first
- **Progression**: Each section should build on the previous
- **Practical Focus**: Balance theory with practical problem-solving

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
