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



# ----- Variable Defaults -----------------------------------------------------

# If we aren't running under Jenkins, some variables will be unset so set them 
# to a reasonable value.

if [ -z "$NUGET_DIR" ]; then
  NUGET_DIR="$WORKSPACE/.nuget"
fi

if [ -z "$NUGET_EXE" ]; then
  NUGET_EXE="$NUGET_DIR/NuGet.exe"
fi

if [ -z "$Configuration" ]; then
  Configuration="Debug"
fi



# ---- Produce NuGet .nupkg file ----------------------------------------------------------

PROJECT_PATH="$MAIN_DIR/$MAIN_CSPROJ"
"$NUGET_EXE" pack $PROJECT_PATH -Symbols -prop Configuration=$Configuration


