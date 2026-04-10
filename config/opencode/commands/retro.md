---
description: Review what was built on this branch and update any stale in-repo documentation
agent: build
---

You are reviewing the work done on the current branch and updating any documentation that has gone stale as a result. Follow the steps below carefully.

Here is the current state of the branch:

**Current branch:**
!`git branch --show-current`

**Commits on this branch (since diverging from main):**
!`git log --oneline main..HEAD 2>/dev/null || git log --oneline -10`

**Files changed on this branch:**
!`git diff --name-only main...HEAD 2>/dev/null || git diff --name-only HEAD~5..HEAD 2>/dev/null || echo "Could not determine changed files"`

**Summary of changes:**
!`git diff --stat main...HEAD 2>/dev/null || git diff --stat HEAD~5..HEAD 2>/dev/null || echo "Could not determine diff stats"`

---

## Steps

### 1. Understand what was built

Read the full diff to understand the changes:
```
git diff main...HEAD
```

If the diff is very large, read it in sections or focus on the most significant files first. Build a mental model of:
- What features or behaviors were added, changed, or removed
- What modules, components, or APIs were affected
- Any new patterns introduced or existing patterns changed

### 2. Find nearby documentation

Look for documentation **near the files that changed**. For each directory that contains changed files, check for:
- `README.md` or `README` files in the same directory or parent directories
- Inline JSDoc / TSDoc comments on exported functions, types, or components that were modified
- Code comments that describe the behavior of changed code
- Any `.md` files in the same directory that look like documentation

Also check for project-level docs:
- The root `README.md`
- A `docs/` directory if one exists
- `.opencode/architecture/` docs if they exist and are relevant

Do NOT search the entire repo. Stay focused on directories that were actually touched.

### 3. Identify what's stale

Compare the documentation you found against what was actually built. Look for:
- **Outdated descriptions**: docs that describe old behavior that this branch changed
- **Missing documentation**: new exports, APIs, components, or behaviors that have no docs
- **Stale examples**: code examples in docs that no longer reflect the current API
- **Incorrect references**: docs that reference files, functions, or patterns that were renamed or removed

### 4. Propose updates

For each piece of stale documentation, present the user with:
- **Where**: the file and section that needs updating
- **What's stale**: what the doc currently says
- **What changed**: what the code actually does now
- **Proposed edit**: your suggested update

Wait for the user to approve, modify, or skip each proposed update before making it.

Be precise and surgical with edits. Don't rewrite entire documents -- update only the specific sections that are stale.

### 5. Summarize

After all updates are done (or skipped), give a brief summary:
- What docs were updated
- What was skipped
- Any documentation gaps you noticed but didn't address (e.g., a whole new module with no README -- flag it but don't create one unless the user asks)

If the user provided arguments, treat them as guidance for what to focus on: $ARGUMENTS
