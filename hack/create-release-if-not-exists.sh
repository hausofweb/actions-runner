#!/bin/bash
set -eux

# find the runner version in Dockerfile
actions_runner_version="$(grep RUNNER_VERSION= Dockerfile | cut -f2 -d=)"

# post a comment if pull request
if [[ $GITHUB_EVENT_NAME == pull_request ]]; then
  if gh release view "$actions_runner_version"; then
    gh pr comment "$GITHUB_HEAD_REF" --body-file - <<EOF
:warning: If you need to release this change, [create a next release](https://github.com/quipper/actions-runner/releases/new) after merge.
EOF
    exit
  fi

  gh pr comment "$GITHUB_HEAD_REF" --body-file - <<EOF
:robot: GitHub Actions will automatically create a release ${actions_runner_version} after merge.
EOF
  exit
fi

if gh release view "$actions_runner_version"; then
  exit # already exists
fi

# create a release if not exists
gh release create "$actions_runner_version" --generate-notes
