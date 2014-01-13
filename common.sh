#!/usr/bin/env bash
set -x # echo commands and their arguments during execution

# fix for jenkins inserting the windows-style path in $WORKSPACE
cd "$WORKSPACE"
export WORKSPACE=`pwd`



# ----- Utility functions -----------------------------------------------------

function winpath() {
  # Convert gitbash style path '/c/Users/Big John/Development' to 'c:\Users\Big John\Development',
  # via dumb substitution. Handles drive letters; incurs process creation penalty for sed.
  if [ -e /etc/bash.bashrc ] ; then
    # Cygwin specific settings
    echo `cygpath -w $1`
  else
    # Msysgit specific settings
    echo "$1" | sed -e 's|^/\(\w\)/|\1:\\|g;s|/|\\|g'
  fi
}

function bashpath() {
  # Convert windows style path 'c:\Users\Big John\Development' to '/c/Users/Big John/Development'
  # via dumb substitution. Handles drive letters; incurs process creation penalty for sed.
  if [ -e /etc/bash.bashrc ] ; then
    # Cygwin specific settings
    echo `cygpath $1`
  else
    # Msysgit specific settings
    echo "$1" | sed -e 's|\(\w\):|/\1|g;s|\\|/|g'
  fi
}

function parentwith() {  # used to find $WORKSPACE, below.
  # Starting at the current dir and progressing up the ancestors,
  # retuns the first dir containing $1. If not found returns pwd.
  SEARCHTERM="$1"
  DIR=`pwd`
  while [ ! -e "$DIR/$SEARCHTERM" ]; do
    NEWDIR=`dirname "$DIR"`
    if [ "$NEWDIR" = "$DIR" ]; then
      pwd
      return
    fi
    DIR="$NEWDIR"
  done
  echo "$DIR"
  }

function findmsbuildin() {  # used to find MS Build, below.
  # Checking subdirs of the parameter, returns the last dir containing MS Build.
  # If not found returns pwd.
  # Requires changing the default separator (IFS) to handle spaces in names.
  SAVEIFS=$IFS
  IFS=$(echo -en "\n\b")
  DIR=`pwd`
  for D in `bashpath "$1"`/*; do
    if [ -e "$D/MSBuild.exe" ]; then
      DIR="$D"
    fi
    if [ -e "$D/Bin/MSBuild.exe" ]; then
      DIR="$D/Bin"
    fi
  done
  IFS=$SAVEIFS
  echo "$DIR"
  }



# ----- Variable Defaults -----------------------------------------------------

# If we aren't running under Jenkins, some variables will be unset.
# So set them to a reasonable value.

if [ -z "$WORKSPACE" ]; then
  export WORKSPACE=`parentwith .git`;
fi

TOOLSDIRS="."
for D in $TOOLSDIRS; do
  if [ -d "$D/bin" ]; then
    export BUILDTOOLS_PATH="$D/bin"
  fi
done

if [ -z "$NUGET_DIR" ]; then
  NUGET_DIR="$WORKSPACE/.nuget"
fi

if [ ! -e "$NUGET_DIR" ]; then
  mkdir -p "$NUGET_DIR"
fi

if [ -z "$NUGET_EXE" ]; then
  NUGET_EXE="$NUGET_DIR/nuget.exe"
fi

if [ ! -e "$NUGET_EXE" ]; then
  # Get the latest nuget.exe
  echo "Build is downloading the latest nuget.exe"
  curl --location -o "$NUGET_EXE" http://nuget.org/nuget.exe
fi

if [ -z "$MSBUILD_DIR" ]; then
  # As of .NET 4.5.1 and VS2013, MS Build is now separate. Use it if available.
  MSBUILD_DIR=`findmsbuildin "$PROGRAMFILES\\MSBuild"`
  # If not found, fall back to MS Build packaged with earlier .NET.
  if [ `pwd` = "$MSBUILD_DIR" ]; then
    MSBUILD_DIR=`findmsbuildin "$SYSTEMROOT\\Microsoft.NET\\Framework"`
  fi
fi

if [ -z "$MSBUILD_EXE" ]; then
  MSBUILD_EXE="$MSBUILD_DIR/MSBuild.exe"
fi

export PATH="$PATH:$MSBUILD_DIR"

if [ -z "$SIGNING_KEY_DIR" ]; then
  export SIGNING_KEY_DIR=`pwd`;
fi

export SIGNING_KEY="$SIGNING_KEY_DIR/VersionOne.snk"

if [ -f "$SIGNING_KEY" ]; then 
  export SIGN_ASSEMBLY="true"
else
  export SIGN_ASSEMBLY="false"
  echo "Please place VersionOne.snk in `pwd` or $SIGNING_KEY_DIR to enable signing.";
fi

if [ -z "$VERSION_NUMBER" ]; then
  export VERSION_NUMBER="0.0.0"
fi

if [ -z "$BUILD_NUMBER" ]; then
  # presume local workstation, use date-based build number
  export BUILD_NUMBER=`date +%H%M`  # hour + minute
fi



# ----- NuGet functions -------------------------------------------------------

function nuget_packages_restore() {
  echo "Build is restoring NuGet packages"
  "$NUGET_EXE" restore $SOLUTION_FILE -Source $NUGET_FETCH_URL
}

function nuget_packages_update() {
  echo "Build is updating NuGet packages to latest compatible versions"
  "$NUGET_EXE" update $SOLUTION_FILE -Source $NUGET_FETCH_URL
}

function nuget_packages_refresh() {
  nuget_packages_restore
  nuget_packages_update
}
