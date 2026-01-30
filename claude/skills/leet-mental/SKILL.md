---
name: leet-mental
description: Generate mental model study guides for LeetCode problems with strong analogies
---

# Mental Model Building for LeetCode Problems

## Purpose
This skill creates mental model study guides that help understand algorithm concepts through **a single, powerful analogy**.

**What this skill does:**
- Builds deep understanding of the problem and solution approach
- Explains the "why" behind algorithmic choices
- Creates memorable mental models using real-world analogies

**What this skill does NOT do:**
- Analyze or debug existing code
- Fix bugs in implementations
- Review or critique current solutions
- Compare multiple solution approaches

## Study Guides Location
- Always create study guide directories in `/Users/snesjhon/Developer/snesjhon/ysk/study-guides/`
- Never create directories in the leetcode folder itself
- Use the format: `/Users/snesjhon/Developer/snesjhon/ysk/study-guides/[problem-number]-[problem-name]/`

## Required Workflow
1. Choose ONE powerful analogy and commit to it
2. Build the case for why this analogy fits perfectly
3. Create mental-model.md using only that analogy throughout
4. Use mermaid charts for visualizations
5. **MUST validate all mermaid charts** using the validation script
6. Fix any validation errors before considering the file complete

**Validation command:**
```bash
~/Developer/dotfiles/claude/skills/leet-mental/validate-mermaid.sh mental-model.md
```

---

## Core Principles

1. **Choose ONE analogy and commit** - Select a single real-world metaphor and use it consistently
2. **Defend your analogy choice** - Explain why this specific analogy maps perfectly to the problem
3. **Stay in the analogy** - Never break character; keep all explanations using analogy terms
4. **Build from ground up** - Start with the simplest case, show the pattern emerging
5. **Focus on intuition, not math** - Avoid formulas and equations until after understanding
6. **Use clear visualizations** - Leverage mermaid charts and tables
7. **Explain every piece** - Never assume understanding of any component

## Why Defend the Analogy?

**A strong mental model requires justification.**

Don't just pick an analogy - prove it's the right one. Address:
- **Perfect mapping:** Show how every algorithm concept has a natural real-world parallel
- **Edge case clarity:** Demonstrate that weird edge cases make sense in your analogy
- **Natural constraints:** Show that algorithm rules/limitations mirror real-world physics
- **Aha moment:** Explain what insight becomes obvious through this lens

**Example defense:**
> "The odometer analogy works perfectly for subarray sums because:
> - Running sum = total miles driven (only goes forward)
> - Subarray = segment between two checkpoints
> - Negative numbers = going backward (odometer decreases)
> - Finding target sum = finding exact distance traveled between checkpoints
> - Why use a hashmap? Because you keep a logbook of every checkpoint!"

The defense makes the choice feel inevitable, not arbitrary.

### Structure Template

```markdown
# [Problem Name] - Mental Model

## The [Single Analogy Name] Analogy

[Opening statement: "Understanding this problem is like..."]

### Why This Analogy Works

**The core insight:** [One sentence explaining the key parallel]

**Perfect mappings:**
- Algorithm concept A → Real-world element X
- Algorithm concept B → Real-world element Y
- Algorithm operation C → Real-world action Z

**Why this analogy and not others:**
[Defend why this specific analogy is superior to alternatives]
- Rules/constraints map naturally
- Edge cases make intuitive sense
- The "aha moment" becomes obvious

## Building from the Ground Up

### The Simplest Case: [minimal example]

[Trace through using ONLY analogy terms, with concrete values]
[Show each step as it happens in the analogy]

### Adding Complexity: [slightly larger example]

[Stay in analogy - show how the pattern scales]
[What changes? Why does it still work?]

## What Just Happened?

[Reflect on the insight discovered through the analogy]
[Why does this approach make sense in analogy terms?]

## Why [Key Component] Works This Way

[Explain design decisions entirely through the analogy]
[Concrete examples using analogy vocabulary]

## Common Misconceptions

### ❌ "[Wrong assumption]"
Why it's wrong: [Counterexample in analogy terms]

### ✅ "[Correct understanding]"
Why it's right: [Concrete example in analogy terms]

## Try It Yourself

[Hands-on exercise using analogy vocabulary]
Given: [concrete scenario in analogy]
Predict: [expected outcome]

## The Algorithm in Plain English

**Using our [analogy] framework:**
1. Start with [analogy term]
2. For each [analogy element], perform [analogy action]
3. Check if [analogy condition]
4. Update [analogy state]
5. Return [analogy result]

[Never leave the analogy - every step should make sense in real-world terms]

## Complete Solution

```typescript
function solveProblem(input: number[]): number {
    // Variable names reflect the analogy
    const analogyStorage = new Map<number, number>();
    let analogyState = 0;

    for (const element of input) {
        // Comments use analogy vocabulary
        // "In our analogy, this is like..."
        analogyState += element;

        const targetCondition = analogyState - k;
        if (analogyStorage.has(targetCondition)) {
            // Found in analogy terms
        }

        analogyStorage.set(analogyState,
            (analogyStorage.get(analogyState) || 0) + 1);
    }

    return result;
}
```

**Tracing the analogy:**
[Walk through the code entirely using analogy vocabulary]
```

### Visualization Guidelines

**USE MERMAID CHARTS FOR:**
- Tree/graph structures (binary trees, graphs, decision trees)
- Flow diagrams showing algorithm progression
- State transitions and recursion paths
- Sequence of operations over time

**USE TABLES FOR:**
- State changes across steps with multiple variables
- Comparison of values at different stages
- Lookup tables and mappings

**Mermaid Chart Best Practices:**
- Always validate charts with `mmdc` before considering them complete
- Label nodes with concrete values from your example (not abstract variables)
- Use analogy-based labels (e.g., "Mile 70" instead of "sum=70")
- Keep hierarchy clear with proper indentation
- Include legend or key when needed

**DON'T:**
- Don't use abstract variable names in diagrams
- Don't skip showing intermediate states
- Don't create charts without validating them first

### Mermaid Chart Examples by Problem Type

**Binary Tree Problems:**
```mermaid
graph TD
    A["Root: 5<br/>Altitude: 0"] --> B["Left: 3<br/>Going up (+3)"]
    A --> C["Right: 8<br/>Going up (+8)"]
    B --> D["Left: 1<br/>Peak! (+1)"]
    B --> E["Right: 4<br/>Still climbing (+4)"]
```

**Backtracking/Decision Trees:**
```mermaid
graph TD
    A["Start: []<br/>open=3, close=3"] --> B["Add (<br/>[(]<br/>open=2, close=3"]
    A --> C["Can't add )<br/>close <= open"]
    B --> D["Add (<br/>[((]<br/>open=1, close=3"]
    B --> E["Add )<br/>[(]<br/>open=2, close=2"]
    style C fill:#f99
```

**State Machine/Flow:**
```mermaid
stateDiagram-v2
    [*] --> Driving: Start at Mile 0
    Driving --> Checkpoint: Record odometer reading
    Checkpoint --> Driving: Continue journey
    Checkpoint --> Found: Target segment exists!
    Found --> [*]

    note right of Checkpoint: Store reading in log<br/>Check if (current - target) exists
```

**Sequence/Timeline:**
```mermaid
sequenceDiagram
    participant Array
    participant Odometer
    participant Log

    Array->>Odometer: Element: 1
    Odometer->>Log: Record Mile 1
    Array->>Odometer: Element: 2
    Odometer->>Log: Record Mile 3
    Odometer->>Log: Check: Mile 3 - 2 = Mile 1 ✓
    Note over Log: Found segment!
```

### Validating Mermaid Charts

**CRITICAL: Always validate charts before completion**

After creating a mental model with mermaid charts, you MUST validate them:

```bash
# Run the validation script on your mental-model.md file
~/Developer/dotfiles/claude/skills/leet-mental/validate-mermaid.sh mental-model.md
```

The script will:
1. Extract all mermaid blocks from the markdown file
2. Validate each chart using `mmdc`
3. Report which charts are valid or have errors
4. Exit with error code if any chart is invalid

**Validation workflow:**
1. Create mental-model.md with mermaid charts
2. Run validation script
3. If errors found: fix the mermaid syntax and re-run
4. Only consider the file complete when all charts pass validation

The validation ensures charts render correctly in GitHub, Obsidian, and other markdown viewers.

**Manual validation (alternative):**
```bash
# Extract a single chart and test it
mmdc -i chart.mmd -o /dev/null
```

### Example: Good vs Bad Explanations

**❌ BAD:**
```
We check if (current_sum - k) exists in the hashmap.
If it does, we found a subarray.
```

**✅ GOOD:**
```
Imagine your car's odometer shows 100 miles.
If you want to find when you drove exactly 30 miles,
you look in your logbook for when the odometer read 70.
The segment between 70 and 100 is exactly 30 miles!
```

### Choosing Your Single Analogy

**CRITICAL: Pick ONE analogy and commit to it completely.**

Don't mix analogies. Don't switch metaphors mid-explanation. The power comes from consistency.

#### Proven Analogies by Problem Type

**Subarray Sum Problems:**
- **Odometer journey** (running sums = cumulative distances traveled)
  - Why it works: Segments between checkpoints = subarrays
  - Natural fit for prefix sums, looking back at previous readings
- Alternative: Bank account balance (but less visual)

**Tree Problems:**
- **Mountain climbing** (going up to children, down to parent)
  - Why it works: Height/altitude maps to depth, peaks = leaves
  - Natural fit for DFS, path concepts
- Alternatives: Family tree, org chart (but less dynamic)

**Backtracking:**
- **Maze exploration** (try paths, hit walls, backtrack)
  - Why it works: Dead ends = invalid states, retracing steps = backtracking
  - Natural fit for constraint checking, state restoration
- Alternative: Building with rules (but less about exploration)

**Graph Problems:**
- **City/road map** (cities = nodes, roads = edges)
  - Why it works: Distance, connectivity, paths all intuitive
  - Natural fit for BFS/DFS, shortest path
- Alternative: Social network (but less spatial)

**Selection criteria:**
- Does every algorithm concept have a natural real-world parallel?
- Do edge cases make sense in the analogy?
- Will someone remember this analogy weeks later?
- Can you explain the entire solution without leaving the analogy?

### Variable Naming in Solutions

When implementing with the analogy:
- Use analogy-based names: `odoLog`, `milesDriven`, `segmentsFound`
- Avoid generic names: `map`, `sum`, `count`
- Make the connection to mental model obvious

**Example:**
```typescript
// ✅ GOOD - Uses analogy
const odoLog = new Map();
let milesDriven = 0;
const targetReading = milesDriven - k;

// ❌ BAD - Generic
const map = new Map();
let sum = 0;
const target = sum - k;
```

### Testing Your Mental Model

Before considering a mental model complete, verify:

1. **Single analogy test:** Did you stay in ONE analogy throughout?
2. **Can you explain it without code?** Walk through entirely using analogy terms
3. **Does it answer "why"?** Not just "what" or "how"
4. **Can you predict behavior?** Given new inputs, trace outcome in analogy terms
5. **Does it handle edge cases?** Explain why base cases exist using the analogy
6. **Is it memorable?** Will you remember the analogy days/weeks later?
7. **No code analysis?** Did you avoid debugging or reviewing existing code?
8. **Analogy justification:** Did you defend WHY this analogy is the right choice?

**The ultimate test:** Can someone read this once and solve similar problems by thinking in terms of your analogy?

### What to Avoid

**Never do these:**
- ❌ Analyzing or debugging existing code implementations
- ❌ Fixing bugs in current solutions
- ❌ Reviewing code quality or suggesting refactors
- ❌ Mixing multiple analogies or switching metaphors mid-explanation
- ❌ Starting with "The algorithm does X" instead of analogy
- ❌ Breaking out of the analogy to use technical terms
- ❌ Using mathematical notation before building intuition
- ❌ Comparing multiple solution approaches (focus on understanding ONE way)
- ❌ Assuming knowledge of data structures (explain why through analogy)
- ❌ Skipping the "why this exists" for each component
- ❌ Using confusing phrasing like "subtract an old running total"
- ❌ Missing the progression from simple to complex examples
- ❌ Generic variable names (use analogy-based names always)

**Remember:** This is about building understanding, not analyzing code.

### Reference Examples

**Excellent mental models:**
- `/Users/snesjhon/Developer/snesjhon/ysk/study-guides/022-generate-parentheses/mental-model.md`
  - Uses mountain climbing analogy
  - Builds from n=1 to n=3
  - Explains constraints naturally

- `/Users/snesjhon/Developer/snesjhon/ysk/study-guides/560-subarray-sum-equals-k/mental-model.md`
  - Uses odometer/checkpoint analogy
  - Shows why hashmap stores counts
  - Traces duplicate readings clearly
