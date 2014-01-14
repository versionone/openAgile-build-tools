#!/usr/bin/env bash
set -ex
## x = exit immediately if a pipeline returns a non-zero status.
## e = print a trace of commands and their arguments during execution.
## See: http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin

# ----- Variables -------------------------------------------------------------
# Variables in the build.properties file will be available to Jenkins
# build steps. Variables local to this script can be defined below.
. ./build.properties

# fix for jenkins inserting the windows-style path in $WORKSPACE
cd "$WORKSPACE"
export WORKSPACE=`pwd`



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