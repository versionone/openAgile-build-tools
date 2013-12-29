#!/usr/bin/env bash
set -x # echo commands and their arguments during execution

CD $WORKSPACE

# ----- Prepare AppCatalog Scripts --------------------------------------------
if [ -d ../VersionOne.AppCatalog.Scripts ]; then
  cd ../VersionOne.AppCatalog.Scripts
  git fetch && git stash
  if git log HEAD..origin/master --oneline --quiet; then
  	git pull
    export BUNDLE_GEMFILE=../VersionOne.AppCatalog.Scripts/Gemfile
    export CATALOG_CONFIGS=../VersionOne.AppCatalog.Scripts/
    bundle
  fi  	
else
  git clone git@github.com:versionone/VersionOne.AppCatalog.Scripts.git ../VersionOne.AppCatalog.Scripts
  export BUNDLE_GEMFILE=../VersionOne.AppCatalog.Scripts/Gemfile
  export CATALOG_CONFIGS=../VersionOne.AppCatalog.Scripts/
  bundle
fi

# ----- Publish Changes to Staging --------------------------------------------
bundle exec ruby ../VersionOne.AppCatalog.Scripts/catalog.rb upload