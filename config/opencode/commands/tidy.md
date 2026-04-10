---
description: Lint, format, and type-check changed files, auto-fix what's possible, and offer to fix the rest
agent: build
---

You are tidying up the codebase before a commit. Follow the steps below carefully.

Here is the current state of the repo:

**Changed files (unstaged + staged):**
!`git diff --name-only HEAD 2>/dev/null || git diff --name-only`

**Untracked files:**
!`git ls-files --others --exclude-standard`

**package.json scripts:**
!`cat package.json | grep -A 50 '"scripts"' | head -60 2>/dev/null || echo "No package.json found"`

---

## Steps

### 1. Detect the project's tooling

Read `package.json` (or the equivalent config) to identify available scripts. Look for:
- **Linting**: scripts named `lint`, `lint:fix`, `eslint`, or similar
- **Formatting**: scripts named `format`, `prettier`, or similar
- **Type-checking**: scripts named `typecheck`, `type-check`, `check:types`, `tsc`, or similar
- **General check**: scripts named `check` that combine multiple tools

If you can't find relevant scripts, look for config files (`.eslintrc*`, `prettier.config*`, `biome.json`, `tsconfig.json`) to infer what tools are available and run them directly.

Tell the user what you found and what you plan to run.

### 2. Determine the changed files

Get the list of files changed relative to the base branch:
```
git diff --name-only main...HEAD 2>/dev/null
```

If that fails (e.g., no `main` branch or not on a feature branch), fall back to:
```
git diff --name-only HEAD
```

If there are also untracked files that look like they're part of the work (not noise), include them.

Filter to only files relevant to each tool (e.g., `.ts`, `.tsx`, `.js`, `.jsx` for ESLint; all supported files for Prettier).

### 3. Run auto-fixable tools first

Run tools that can auto-fix, scoped to the changed files:

1. **Formatter** (e.g., `prettier --write`, `biome format --write`) -- run this first
2. **Linter with fix** (e.g., `eslint --fix`, `biome lint --fix`) -- run this second

Scope each tool to only the changed files. Most tools accept file paths as arguments.

If the project uses a combined script (like `lint:fix`), check whether it can be scoped to specific files. If not, run the underlying tool directly with file paths.

### 4. Run non-fixable checks

Run checks that only report issues without fixing:

1. **Type-checker** (e.g., `tsc --noEmit`) -- this typically runs on the whole project, which is fine
2. **Linter in report-only mode** if there were unfixable lint errors in step 3

### 5. Report results

Summarize what happened:
- What was auto-fixed (list the files that changed)
- What issues remain that couldn't be auto-fixed

If everything is clean, say so and you're done.

### 6. Offer to fix remaining issues

If there are unfixable issues (type errors, lint errors that need manual intervention):
- List each issue clearly with its file, line, and error message
- Offer to fix them one at a time
- For each fix, explain what you're changing and why before making the edit
- After fixing, re-run the relevant check to confirm the fix didn't introduce new issues

If the user provided arguments, treat them as instructions for what to focus on: $ARGUMENTS
