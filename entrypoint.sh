#!/bin/sh
set -e

# Move godot templates already installed from the docker image to home
mkdir -v -p ~/.local/share/godot/export_templates
cp -n -a /root/.local/share/godot/export_templates/. ~/.local/share/godot/export_templates/


if [ "$3" != "" ]
then
    SubDirectoryLocation="$3/"
fi

mode="export-release"
if [ "$6" = "true" ]
then
    echo "Exporting in debug mode!"
    mode="export-debug"
fi

# Export for project
echo "Building $1 for $2"
mkdir -p $GITHUB_WORKSPACE/build/${SubDirectoryLocation:-""}
cd "$GITHUB_WORKSPACE/$5"

# if addons/godot-jolt exists, preload the extension by creating a .godot/extension_list.cfg
# and add "res://addons/godot-jolt/godot-jolt.gdextension"
if [ -d "addons/godot-jolt" ]; then
    mkdir -p .godot
    echo "res://addons/godot-jolt/godot-jolt.gdextension" > .godot/extension_list.cfg
fi

godot --headless --${mode} "$2" $GITHUB_WORKSPACE/build/${SubDirectoryLocation:-""}$1 --verbos
echo "Build Done"

echo ::set-output name=build::build/${SubDirectoryLocation:-""}


if [ "$4" = "true" ]
then
    echo "Packing Build"
    mkdir -p $GITHUB_WORKSPACE/package
    cd $GITHUB_WORKSPACE/build
    zip $GITHUB_WORKSPACE/package/artifact.zip ${SubDirectoryLocation:-"."} -r
    echo ::set-output name=artifact::package/artifact.zip
    echo "Done"
fi
