---
name: epub
description: Fetch a URL (usually Wikipedia), generate a deep ~10-page summary, and save it as an EPUB to ~/Downloads
---

# EPUB Generator

## Purpose

Given a URL (typically Wikipedia), fetch the content and produce a polished, in-depth EPUB (~10 pages / ~4,000–5,000 words) saved to `~/Downloads/`. The file should be suitable for uploading to Publish or reading in any EPUB reader.

## Required Workflow

1. **Fetch** the URL with WebFetch — extract all meaningful content (intro, sections, key facts, context, history, significance)
2. **Write** a comprehensive markdown document (see structure below)
3. **Convert** markdown → EPUB using pandoc
4. **Save** to `~/Downloads/<slug>.epub`
5. **Confirm** the file exists and report the path

## Pandoc Check

Before converting, check if pandoc is installed:

```bash
which pandoc || (echo "pandoc not found — install with: brew install pandoc" && exit 1)
```

If not installed, tell the user to run `brew install pandoc` and stop.

## Document Structure

Write to `/tmp/<slug>.md` before converting. Use this structure:

```markdown
---
title: "<Full Title>"
author: "Generated Summary"
date: "<YYYY-MM-DD>"
---

# <Title>

## Overview

[3–5 paragraph intro. Cover what it is, why it matters, and the big picture context.]

## Background & History

[Detailed history — origins, key dates, pivotal moments, how it evolved.]

## Core Concepts

[The fundamental ideas, mechanisms, or principles. Use sub-sections if needed.]

### <Sub-concept 1>
### <Sub-concept 2>
### <Sub-concept 3>

## Key Figures & Contributors

[People, organizations, or forces that shaped the subject. Who, what role, when.]

## Significance & Impact

[Why does this matter? What changed because of it? Cultural, scientific, social, political impact.]

## Controversies & Debates

[Any major disagreements, competing interpretations, ethical concerns, or open questions.]

## Current State

[Where things stand today — ongoing developments, current relevance, future directions.]

## Key Facts at a Glance

[A bullet list of the most important facts, dates, and figures — quick reference.]

## Further Context

[Anything else worth knowing — related topics, broader connections, nuances that didn't fit above.]
```

## Content Quality Rules

- **Depth over breadth** — each section should have multiple paragraphs, not bullets alone
- **No filler** — every sentence should add information
- **Use the source** — pull actual facts, dates, names, and data from the fetched page
- **~4,000–5,000 words total** — aim for a document that prints to ~10 pages
- **No fabrication** — only include information present in the fetched content or well-established facts directly related to it

## Conversion Command

```bash
SLUG="<slug-from-title>"
pandoc /tmp/$SLUG.md \
  -o ~/Downloads/$SLUG.epub \
  --metadata title="<Title>" \
  --toc \
  --toc-depth=2
```

- Derive `<slug>` from the title: lowercase, spaces → hyphens, remove special chars
- Example: "Roman Empire" → `roman-empire`

## Output

After writing the EPUB, confirm with:

```bash
ls -lh ~/Downloads/<slug>.epub
```

Then tell the user:
- The full path: `~/Downloads/<slug>.epub`
- Word count of the document
- Sections included
