#!/usr/bin/env bash
set -ex
## x = exit immediately if a pipeline returns a non-zero status.
## e = print a trace of commands and their arguments during execution.
## See: http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin



# ----- Variable Defaults -----------------------------------------------------

# If we aren't running under Jenkins, some variables will be unset so set them 
# to a reasonable value.

if [ -z "$WORKSPACE" ]; then
  export WORKSPACE=`parentwith .git`;
fi

if [ -z "$NUGET_DIR" ]; then
  NUGET_DIR="$WORKSPACE/.nuget"
fi

if [ -z "$NUGET_EXE" ]; then
  NUGET_EXE="$NUGET_DIR/nuget.exe"
fi

if [ -z "$MYGET_REPO_URL" ]; then
  MYGET_REPO_URL="http://www.myget.org/F/versionone/api/v2/"
fi



# ----- Publish Changes to Staging --------------------------------------------

for PKG in *[0-9].nupkg; do
  echo "Pushing $PKG to MyGet.org"
  "$NUGET_EXE" push $PKG $MYGET_API_KEY -Source "$MYGET_REPO_URL"
done


