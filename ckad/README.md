Feature branch notes:
Lets begin


git checkout -b feature/login
git push --set-upstream origin feature/login

Great question — these two Git commands are closely related but have an important difference depending on your context.

---

## 🧠 **Difference Between `git push` and `git push origin master`**

---

### 1. ✅ `git push`

This command pushes your local changes to the **default remote** (usually called `origin`) and its **default branch** (often `main` or `master`, depending on setup).

### 🔍 What it means:

- Equivalent to:
    
    ```bash
    git push <default-remote> <current-branch>
    
    ```
    

### 💡 Behavior:

- If you're on `main`, it pushes to `origin/main`
- If you're on `feature/login`, it pushes to `origin/feature/login`
- Requires upstream tracking to be configured (`git branch --set-upstream-to`)

---

### 2. ✅ `git push origin master`

This command **explicitly** tells Git:

- Push the **local `master` branch**
- To the **`origin` remote**

### 💡 Behavior:

- It **ignores your current branch**
- Always pushes `master` — even if you’re on another branch

---

## 🧪 Example:

Assume you’re currently on a `feature/login` branch:

| Command | What Happens |
| --- | --- |
| `git push` | Pushes `feature/login` to `origin/feature/login` (if upstream set) |
| `git push origin master` | Pushes `master` branch to `origin/master` regardless of current branch |

---

## ⚡ Quick Insight Recap

| Command | Pushes What? | Pushes Where? | Notes |
| --- | --- | --- | --- |
| `git push` | Current branch | Default remote | Needs upstream set |
| `git push origin master` | Local `master` branch | Explicit `origin` | Ignores current branch |

---

Would you like to also see how `--set-upstream` works or how to change your default remote and branch behavior?

Great — let’s go deeper into how to **set upstreams** in Git and how to **change or view your default push settings**. This helps you control what happens when you run `git push` **without arguments**.

---

## 🧭 1. **What Is an Upstream Branch?**

An **upstream branch** is the remote branch your local branch is tracking. When you do:

```bash
git push

```

Git will:

- Push the **current branch**
- To its configured **upstream remote/branch**

---

## 🛠️ 2. **Setting the Upstream Branch**

### ✅ When creating a new branch and want to track it:

```bash
git checkout -b feature/login
git push --set-upstream origin feature/login

```

This sets the upstream so that:

- `git pull` knows where to pull from
- `git push` knows where to push to

---

### ✅ Alternatively, you can do:

```bash
git branch --set-upstream-to=origin/feature/login

```

Or shorter (on the current branch):

```bash
git push -u origin feature/login

```

---

## 🔄 3. **Check Upstream Configuration**

```bash
git status

```

You’ll see:

```
Your branch is up to date with 'origin/feature/login'.

```

Or explicitly:

```bash
git branch -vv

```

Shows each branch and its upstream remote + commit status.

---

## 🧰 4. **Change Default Push Behavior (Optional)**

By default, Git uses this setting:

```bash
git config --global push.default simple

```

| Setting | Behavior |
| --- | --- |
| `simple` | Push current branch to same-named upstream branch (default for Git ≥2.0) |
| `matching` | Push all local branches with matching remote branches |
| `current` | Push current branch to a branch of the same name on the remote |
| `upstream` | Push current branch to its upstream (even if names differ) |
| `nothing` | Disable `git push` without arguments |

To change it:

```bash
git config --global push.default current

```

---

## ⚡ Quick Insight Recap

| Command/Option | Purpose |
| --- | --- |
| `--set-upstream` / `-u` | Set upstream on first push |
| `branch --set-upstream-to` | Manually link to remote branch |
| `push.default` | Configures what `git push` (no args) does |
| `git branch -vv` | Shows tracking info and status for all branches |

---

Would you like a **cheat sheet PDF** or a **real-world Git workflow diagram** (e.g., feature branch + pull request)?