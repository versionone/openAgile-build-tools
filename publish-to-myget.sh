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

source $WORKSPACE/../build-tools/common.sh



# ----- Variable Defaults -----------------------------------------------------

# If we aren't running under Jenkins, some variables will be unset so set them 
# to a reasonable value.

if [ -z "$NUGET_DIR" ]; then
  NUGET_DIR="$WORKSPACE/.nuget"
fi

if [ -z "$NUGET_EXE" ]; then
  NUGET_EXE="$NUGET_DIR/NuGet.exe"
fi

if [ -z "$MYGET_REPO_URL" ]; then
  MYGET_REPO_URL="http://www.myget.org/F/versionone/api/v2/"
fi

if [ -z "$Configuration" ]; then
  Configuration="Debug"
fi



# ---- Produce NuGet .nupkg file ----------------------------------------------------------

PROJECT_PATH=`winpath "$MAIN_DIR/$MAIN_CSPROJ"`
"$NUGET_EXE" pack "$PROJECT_PATH" -Symbols -prop Configuration=$Configuration



# ----- Publish Changes to Staging --------------------------------------------

cd $WORKSPACE/$MAIN_DIR
for PKG in "*[0-9].nupkg"; do
  echo "Pushing $PKG to MyGet.org"
  "$NUGET_EXE" push $PKG $MYGET_API_KEY -Source "$MYGET_REPO_URL"
done


