function git_describe_latest_tag --description "Get latest git tag"
    git describe --tags (git rev-list --tags --max-count=1)
end
