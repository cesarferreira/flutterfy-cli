#!/bin/bash

# Get the path to pubspec.yaml as an argument
PUBSPEC_PATH=$1

# Function to increment a build number
function bump_build_number() {
    # Extract the line containing the version and build number
    local version_line=$(grep 'version: ' $PUBSPEC_PATH)

    # Extract the version and build number
    local version=$(echo $version_line | sed -E 's/version: ([0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+/\1/')
    local build_number=$(echo $version_line | sed -E 's/version: [0-9]+\.[0-9]+\.[0-9]+\+([0-9]+)/\1/')

    # Increment the build number
    local new_build_number=$((build_number + 1))

    # Construct the new version line
    local new_version_line="version: $version+$new_build_number"

    # Replace the old version line with the new version line in pubspec.yaml
    # The '' after -i is necessary for macOS compatibility
    sed -i '' "s/$version_line/$new_version_line/" $PUBSPEC_PATH

    # Print the new version line
    echo "Updated $new_version_line"
}

# Bump the build number
bump_build_number
