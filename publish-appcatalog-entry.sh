#!/usr/bin/env bash
set -ex
## x = exit immediately if a pipeline returns a non-zero status.
## e = print a trace of commands and their arguments during execution.
## See: http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin



# ----- Workspace -------------------------------------------------------------
## Should be set by Jenkins or a previous script.
## Need a default value for testing.
if [ -z "$WORKSPACE" ]; then
  export WORKSPACE=`pwd`;
fi



# ----- Environment Variables -------------------------------------------------
## Bundler will need to know where the Gemfile is.
export BUNDLE_GEMFILE=$WORKSPACE/../VersionOne.AppCatalog.Scripts/Gemfile
## Scripts directory includes configuration files for AppCatalog services.
export CATALOG_CONFIGS=$WORKSPACE/../VersionOne.AppCatalog.Scripts/



# ----- Prepare AppCatalog Scripts --------------------------------------------
if [ -d $WORKSPACE/../VersionOne.AppCatalog.Scripts ]; then
  ## When script directory already exists, just update when there are changes.
  cd $WORKSPACE/../VersionOne.AppCatalog.Scripts
  git fetch && git stash
  if ! git log HEAD..origin/master --oneline --quiet; then
    git pull
    bundle install
  fi
  cd $WORKSPACE
else
  ## When script directory does not exist, clone and prep.
  git clone git@github.com:versionone/VersionOne.AppCatalog.Scripts.git $WORKSPACE/../VersionOne.AppCatalog.Scripts
  cd $WORKSPACE/../VersionOne.AppCatalog.Scripts
  bundle install
  cd $WORKSPACE
fi



# ----- Publish Changes to Staging --------------------------------------------
bundle exec ruby $WORKSPACE/../VersionOne.AppCatalog.Scripts/catalog.rb upload



# ----- Clean Up --------------------------------------------------------------
unset CATALOG_CONFIGS
unset BUNDLE_GEMFILE


