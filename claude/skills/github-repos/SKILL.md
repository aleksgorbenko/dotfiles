---
name: github-repos
description: >
  Use whenever the user wants to create, rename, delete, or reconfigure a GitHub repo
  (visibility, wiki, merge settings, default branch) under the aleksgorbenko account, or
  asks "do we have a repo for X", "make this repo private", "create a GitHub repo". All
  repos here are Terraform-managed — never create/edit repos via the GitHub UI or `gh repo
  create`.
---

# GitHub Repos on This Machine

Files: `/Users/gbko/Dropbox/src/proj/infra-github` — `repos.auto.tfvars` (repo list),
`repos.tf` (for_each logic), `Makefile` (plan/apply/fmt/state-list). State in HCP
Terraform, workspace `infra-github`.

ALWAYS:
- Add or edit a repo via `repos.auto.tfvars`.
- Run `terraform fmt -recursive` before `make plan`.
- Run `make plan` and read the full output before any apply.
- Show the plan to the user and get explicit approval before every apply, even a rerun of an already-approved plan.
- Stop and explain exactly what would change if the plan shows anything beyond a clean `+ create` (destroy, in-place update, visibility→public, name change) — wait for confirmation naming that specific resource.
- Add matching config to `repos.auto.tfvars` before importing a manually-created repo.
- Push a repo only when the user asks for that push, in that instance.
- Wire up a freshly-created empty repo with `git remote add origin git@github.com:aleksgorbenko/<repo>.git` then `git push -u origin main`.
- Ask the user if a request is ambiguous (which repo, which setting, plan vs apply).

NEVER:
- Run `make apply` / `terraform apply` yourself.
- Create, rename, or delete repos via the GitHub UI or `gh repo create`.
- Import a repo without matching `repos.auto.tfvars` config first.
