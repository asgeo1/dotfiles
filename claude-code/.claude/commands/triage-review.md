Interactively triage review findings one issue at a time using a tabbed question interface.

## CRITICAL: NO CD, NO GIT -C
You are already in the correct working directory. Do NOT `cd` to the project root. Do NOT use `git -C /path`. Just run commands directly.

## Step 1: Load Review Findings

```
$ARGUMENTS = "$ARGUMENTS"
```

Find the review findings file to triage:

### If `$ARGUMENTS` contains a file path:
Use that specific findings file. Read it with `mcp__plan-tools__read_plan`.

### If no file path in arguments:
Auto-detect the latest findings:

1. **If a plan file is in context** (e.g., `proud-skipping-wirth.md`):
   - Extract the plan slug (filename without `.md`)
   - Search for both `{plan-slug}-code-review-round-` and `{plan-slug}-plan-review-round-` using `mcp__plan-tools__find_plan_by_title`
   - Pick the most recent file (highest round number; if both types exist at the same round, pick the most recent by date)
   - Read it with `mcp__plan-tools__read_plan`

2. **If no plan in context**:
   - Search for any plans with "Code Review" or "Plan Review" in the title using `mcp__plan-tools__find_plan_by_title`
   - Pick the most recent by date (from frontmatter)
   - Read it with `mcp__plan-tools__read_plan`

3. **If nothing found**:
   - Tell the user: "No review findings found. Run a review command first (`/claude-code-review`, `/claude-review-against-plan`, `/claude-review-plan`, etc.)"
   - Stop.

After loading, extract the `review_type` from frontmatter (`code-review` or `plan-review`) and the `source_plan` path. Tell the user which findings file was loaded, its type, and round number.

## Step 2: Parse Items to Triage

The format differs based on review type. Parse accordingly:

### For code reviews (`review_type: code-review`):

Extract individual issues by splitting on the `Issue N:` pattern.

**Pattern A (Claude review merger output):**
```
Issue N: [Title]
Severity: [critical|warning|suggestion]
Source: [correctness|security|quality|plan-compliance]
Plan Item: [phase reference]
Location: [file:line]
Problem: [description]
Why it matters: [impact]
Suggested fix: [fix description and/or code]
```

**Pattern B (Gemini/Codex synthesized output):**
```
### Issue N: [Title]
**Severity:** [critical|warning|suggestion]
**Focus:** [correctness|security|quality|plan-compliance]
**Location:** [file:line]
**Problem:** [description]
**Why it matters:** [impact]
**Suggested fix:** [fix description]
```

For each issue, extract:
- `number` — the issue number
- `title` — the descriptive title
- `severity` — critical, warning, or suggestion
- `focus` — the focus area that produced this finding (correctness, security, quality, plan-compliance). If the Focus field is missing (older findings), set to "unknown"
- `location` — file path and line number
- `problem` — condensed problem description (1-2 sentences)
- `suggested_fix` — condensed fix description (1-2 sentences)
- `full_text` — the complete original text of the issue

### For plan reviews (`review_type: plan-review`):

Extract items from the structured sections: Concerns, Suggestions, and Questions.

**Pattern C (Claude principal engineer output):**
Look for sections like `### Concerns`, `### Suggestions`, `### Questions` (or `## Concerns`, etc.).
Each bullet point under these sections is a separate item to triage.

**Pattern D (Gemini/Codex plan review output):**
Same structure — `### Concerns`, `### Suggestions`, `### Questions` with bullet points.

For each item, extract:
- `number` — assign sequentially (1, 2, 3, ...)
- `category` — "Concern", "Suggestion", or "Question"
- `title` — first sentence or phrase of the bullet (truncated to ~60 chars)
- `full_text` — the complete bullet point text

Store as a list. Tell the user: "Found N items to triage (X concerns, Y suggestions, Z questions)." or "Found N issues to triage." for code reviews.

If no items found in the file, tell the user and stop.

## Step 3: Present Items in Batches

Present items in batches of up to 4 using `AskUserQuestion` (the tool's maximum).

### For code reviews:

For each issue in the batch, create one question:

```
header: "Issue N"
question: "Issue N (severity) [focus]: [Title] — how to handle?"
multiSelect: false
options:
  - label: "Fix as suggested"
    description: "Apply the suggested fix (press n to add notes)"
    preview: [full_text of the issue, formatted as markdown — see formatting rules below]
  - label: "Skip"
    description: "Not important, don't address this issue"
    preview: [same full_text as above — identical preview on ALL options]
  - label: "Disagree"
    description: "I disagree this is an issue (press n to explain why)"
    preview: [same full_text as above — identical preview on ALL options]
```

**Question text is plain text only** (Claude Code limitation) — keep it to one line: issue number, severity, and title. **Put the SAME preview on ALL options** so the user can see the full issue details regardless of which option is focused.

**CRITICAL: Preview content must be a VERBATIM copy-paste from the findings file.** Do NOT summarize, condense, paraphrase, abbreviate, or rewrite the issue text in any way. Copy the EXACT characters from the findings file for each issue — every word, every line, every code block, exactly as written. The preview must be byte-for-byte identical to what appears in the findings file between "Issue N:" and the next issue. If you summarize or shorten the text, the user loses critical detail needed for informed decisions.

### For plan reviews:

For each item in the batch, create one question:

```
header: "[Cat] N"   (e.g., "Concern 1", "Suggest 2", "Question 3" — max 12 chars)
question: "[Category] N: [title] — how to handle?"
multiSelect: false
options:
  - label: "Accept & revise plan"
    description: "Incorporate this feedback into the plan (press n to add notes)"
    preview: [full_text of the item, formatted as markdown — see formatting rules below]
  - label: "Skip"
    description: "Not important, don't change the plan for this"
    preview: [same full_text as above — identical preview on ALL options]
  - label: "Disagree"
    description: "I disagree with this feedback (press n to explain why)"
    preview: [same full_text as above — identical preview on ALL options]
```

**Preview renders markdown, question does not.** The question field is plain text only (Claude Code limitation). Use the `preview` field on the first option for the full formatted issue content.

**IMPORTANT: The preview renders markdown.** Use full markdown formatting throughout — bold for labels, backticks for inline code, fenced code blocks with language hints, etc. Apply these formatting rules:

1. **Short fields on one line with gutter.** Fields with short values (Severity, Source, Plan Item, Location) use a consistent gutter. Align all values to the same column (longest label + 2 spaces). Continuation lines indent to the gutter column.

2. **Long fields: extra spacing via blank unicode line.** Fields with long prose values (Problem, Why it matters, Suggested fix) need extra visual separation. Before each of these labels, insert a line containing a single Unicode braille blank character `⠀` (U+2800). This forces an extra blank line since markdown collapses empty lines but not lines with content. Then the label on the next line in bold.

3. **Use markdown for code.** The preview renders markdown, so use proper markdown syntax:
   - **Inline code**: wrap short references in backticks, e.g., `\`field :key_phrases\``
   - **Code blocks**: use fenced code blocks with language hint. Add 4 spaces of leading indentation to the code content inside the fence to visually indent it from the surrounding prose:
     ````
     ```ruby
         field :key_phrases, [String], null: true
     ```
     ````
   Separate code blocks from surrounding prose with blank lines.

4. **Blank line between every section.**

5. **Do NOT hard-wrap prose.** Let the preview renderer handle line display. Do not insert line breaks into prose text.

Example (this is markdown that will be rendered in the preview box):

````markdown
### Issue 1: `key_phrases` Field Type Mismatch in GraphQL Type and Factory

**Severity:** critical

**Focus:** correctness

**Plan Item:** Phase 6 (new GraphQL types) / Phase 3 (FactoryBot expansion)

**Location:** `api/app/graphql/types/development_factor_type.rb:12` and `api/test/factories/development_factors.rb:8`

⠀
**Problem:**

The database column `development_factors.key_phrases` is defined as

```ruby
    t.text "key_phrases", default: [], array: true
```

— a PostgreSQL text array. The GraphQL type declares it as

```ruby
    field :key_phrases, String, null: true
```

(a single scalar String). At runtime, GraphQL will call `.to_s` on the Ruby array, returning a string like `["phrase one", "phrase two"]` to API consumers.

Separately, the factory sets

```ruby
    key_phrases { "phrase one, phrase two, phrase three" }
```

— a plain string — which will either fail ActiveRecord type casting or produce an array with one element containing the entire comma-separated string.

⠀
**Why it matters:**

API consumers will receive corrupt, unparseable data from the `developmentFactors` query. Tests using the factory will be testing against a wrong data shape, masking bugs in code that processes this field as an array.

⠀
**Suggested fix:**

In `development_factor_type.rb`, change line 12 to:

```ruby
    field :key_phrases, [String], null: true
```

In `development_factors.rb`, change line 8 to:

```ruby
    key_phrases { ["phrase one", "phrase two", "phrase three"] }
```
````

**User input via "n for notes":** With the preview layout, users press `n` to add notes to any selected option. The notes ARE passed back to Claude via the `annotations` field. Remind users in option descriptions (e.g., "press n to add notes").

**Batching:** If there are N items:
- Items 1-4: first AskUserQuestion call
- Items 5-8: second call
- Items 9-12: third call
- Continue until all items are presented

After each batch, collect the responses before presenting the next batch.

## Step 4: Write Triage Decisions INTO the Findings File

After all batches are answered, compile the decisions.

**CRITICAL: Write into the SAME findings file, not a separate file.** Read the current findings file content using `mcp__plan-tools__read_plan`, then APPEND the triage decisions section to the end and write the whole thing back using `mcp__plan-tools__write_plan` to the SAME file path. Do NOT create a separate `-triage.md` file. The findings file must be self-contained — anyone reading it should see both the original issues AND the triage decisions in one place.

**CRITICAL: Preserve user notes VERBATIM.** When the user adds notes via "n for notes" or "Type something", copy their EXACT text into the decisions. Do NOT summarize, condense, paraphrase, or truncate their notes. If they wrote 5 sentences, include all 5 sentences. Their notes contain critical context for implementation.

Append this section to the existing content:

```markdown

---

## Triage Decisions

Triaged on: [current ISO date]

### Issue 1: [Title]
**Decision:** Fix as suggested
**User notes:** [VERBATIM copy of everything the user typed — do NOT summarize]

### Issue 2: [Title]
**Decision:** Skip

### Issue 3: [Title]
**Decision:** Fix as suggested
**User notes:** [VERBATIM copy — preserve every word, every sentence]

### Issue 7: [Title]
**Decision:** Other
**User response:** [VERBATIM copy of the user's full typed response]

---

### Summary
- Fix: X issues
- Skip: X issues
- Disagree: X issues
- Other: X issues

### Source Plan
[Path to original plan file from the findings frontmatter `source_plan` field]
```

## Step 5: Present Summary and Confirm

Present the summary table to the user:

```
Triage Summary ([review type]):
- Fix/Accept: X items
- Skip: X items
- Disagree: X items
- Other: X items

Decisions written to: [findings file path]
```

Then ask: "Ready to implement the X action items? Say 'go ahead' when ready, or 'stop' to just save the triage decisions without implementing."

## Step 6: Implement (on user approval)

**Only proceed when the user confirms.**

### For code reviews (`review_type: code-review`):

For each action item (Fix or Other decisions):
1. Read the relevant source file(s) at the specified location
2. Understand the issue and the suggested fix
3. Apply the fix, incorporating any user notes
4. Move to the next action item

### For plan reviews (`review_type: plan-review`):

For each action item (Accept or Other decisions):
1. Read the original plan file (from `source_plan` in frontmatter) using `mcp__plan-tools__read_plan`
2. Understand the concern/suggestion and what change it implies for the plan
3. Update the plan file using `mcp__plan-tools__write_plan` to incorporate the feedback
4. For questions: add clarifications or additional detail to the relevant plan section
5. Move to the next action item

**Important for plan reviews:** The original plan file is the target of changes, not source code. Read it, modify the relevant sections to address the accepted feedback, and write it back.

After implementing all items, report:

```
[Review Type] Triage Complete:
- Implemented/Revised: X items
- Skipped: X items
- Disagreed: X items
- Other: X items
```

## Key Principles

- **The user has already read the full review output** — they scrolled through it before running this command. The tabbed interface is for making decisions, not for reading the full review.
- **Keep question text condensed** — put the full details in the preview field so the interface stays clean.
- **Preserve all user notes** — notes added to selections are critical context for implementation.
- **Write decisions before implementing** — if implementation fails or is interrupted, the triage decisions are still saved.
- **Plan reviews update the plan** — code reviews fix code, plan reviews revise the plan. The review type determines the target.

<task>$ARGUMENTS</task>
