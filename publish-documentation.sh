#!/usr/bin/env bash
set -ex
## x = exit immediately if a pipeline returns a non-zero status.
## e = print a trace of commands and their arguments during execution.
## See: http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin

# ----- Prepare Branches ------------------------------------------------------
## Stash changes so we can checkout gh-pages and a clean master.
if ! git diff-index --quiet HEAD --; then
  git stash
fi
git checkout gh-pages
git checkout master



# ----- Publish Documentation -------------------------------------------------
## Publishes a subdirectory "doc" of the main project to the gh-pages branch.
## From: http://happygiraffe.net/blog/2009/07/04/publishing-a-subdirectory-to-github-pages/
doc_sha=$(git ls-tree -d HEAD doc | awk '{print $3}')
new_commit=$(echo "Auto-update docs." | git commit-tree $doc_sha -p refs/heads/gh-pages)
git update-ref refs/heads/gh-pages $new_commit



# ----- Push Docs -------------------------------------------------------------
## Push changes and pop the stack, if any.
git push origin gh-pages
git stash pop
