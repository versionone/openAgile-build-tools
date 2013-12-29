#!/usr/bin/env bash

# ----- Save Variables --------------------------------------------------------
## Save envars corresponding to this build run for future promotion
cat > $WORKSPACE/buildtime.properties <<EOF

GIT_URL=`git config --get remote.origin.url`
GIT_BRANCH=$GIT_BRANCH
GIT_COMMIT=$GIT_COMMIT
BUILDTIME_VERSION_NUMBER=$VERSION_NUMBER
BUILDTIME_BUILD_NUMBER=$BUILD_NUMBER
BUILDTIME_BUILD_TAG=$BUILD_TAG
BUILDTIME_BUILD_ID=$BUILD_ID

EOF