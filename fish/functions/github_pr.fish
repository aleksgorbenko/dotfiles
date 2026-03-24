function github_pr --description "Create a draft GitHub PR for the current branch"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "gh-pr: not a git repository" >&2
        return 1
    end

    set -l branch (git rev-parse --abbrev-ref HEAD)
    set -l root (git rev-parse --show-toplevel)
    set -l base (gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null)
    test -z "$base"; and set base main

    if test (count (git log $base...HEAD --oneline)) -eq 0
        echo "gh-pr: no commits ahead of $base" >&2
        return 1
    end

    # Push branch if no upstream tracking
    if not git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1
        echo "Pushing $branch to origin..."
        git push -u origin $branch; or return 1
    end

    # Find PR template
    set -l template "$HOME/engbook/_template/pull_request_template.md"
    if test -f "$root/.github/pull_request_template.md"
        set template "$root/.github/pull_request_template.md"
    end

    # Derive title from first commit message
    set -l title (git log $base...HEAD --oneline --reverse | head -1 | string replace -r '^[a-f0-9]+ ' '')

    set -l pr_url (gh pr create \
        --draft \
        --base $base \
        --title $title \
        --body-file $template 2>&1)

    if test $status -ne 0
        echo "gh-pr: $pr_url" >&2
        return 1
    end

    echo $pr_url
    open $pr_url
end