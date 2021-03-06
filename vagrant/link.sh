#!/bin/bash
#-------------------------------------------------------------------------------

# Linking CM source directory
echo "*** Cleaning old CM gem definitions"
sudo rm -Rf "$RUBY_GEM_PATH"/cm-*

echo "*** Linking CM"
sudo ln -s "$GEM_CM_DIRECTORY" "$RUBY_GEM_PATH/cm-$GEM_CM_VERSION" || exit 210
