---
description: Commit, push, and open a PR with a summary of code changes
agent: build
---

You are opening a pull request. Follow the steps below carefully.

Here is the current state of the repo:

**Current branch:**
!`git branch --show-current`

**Git status:**
!`git status --short`

**Unstaged changes (summary):**
!`git diff --stat`

**Staged changes (summary):**
!`git diff --cached --stat`

**Recent commits:**
!`git log --oneline -5`

**Diff of all uncommitted changes:**
!`git diff`
!`git diff --cached`

---

## Steps

### 1. Check the branch

If you are on `main` or `master`, you MUST create a new feature branch before doing anything else.
- Pick a short, descriptive branch name based on the changes (e.g., `add-usage-metrics-export`, `fix-auth-redirect`).
- Confirm the branch name with the user before creating it.
- Create and switch to it with `git checkout -b <branch-name>`.

If you are already on a feature branch, proceed.

### 2. Stage changes

Review `git status` and be intentional about what you stage:
- **Modified tracked files**: stage these by default.
- **Deleted tracked files**: stage these by default.
- **Untracked files**: review them. Skip obvious noise (`.env`, build artifacts, `node_modules`, `.DS_Store`, etc.). For anything ambiguous, ask the user which untracked files to include.
- Do NOT blindly `git add .`.
- If files are already staged, respect that -- don't unstage them.

### 3. Commit

- Write a concise commit message focused on the "why", not just the "what".
- If the changes are logically separate and would benefit from multiple commits, ask the user if they want to split them. Otherwise, a single commit is fine.

### 4. Push

Push the branch with `-u` to set upstream tracking:
```
git push -u origin <branch-name>
```

### 5. Open the PR

Use `gh pr create` targeting `main`.

If the user provided arguments, use them as the PR title: $ARGUMENTS

Otherwise, generate a clear, concise PR title from the changes.

Write the PR body with a `## Summary` section containing a few bullet points describing what changed and why. Use a HEREDOC for the body:
```
gh pr create --title "the title" --body "$(cat <<'EOF'
## Summary
- ...
- ...
EOF
)"
```

### 6. Return the PR URL

After the PR is created, show the user the PR URL so they can review it.
