#!/bin/bash

# Get the path to pubspec.yaml and the update type
PUBSPEC_PATH=$1
UPDATE_TYPE=$2

# Function to increment version parts
function bump_version() {
    # Extract the line containing the version and build number
    local version_line=$(grep 'version: ' "$PUBSPEC_PATH")
    local version=$(echo "$version_line" | sed -E 's/version: ([0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+/\1/')
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)
    local patch=$(echo "$version" | cut -d. -f3)
    local build_number=$(echo "$version_line" | sed -E 's/version: [0-9]+\.[0-9]+\.[0-9]+\+([0-9]+)/\1/')

    # Store the old version for the final message
    local old_version="$version+$build_number"

    # Increment the build number
    local new_build_number=$((build_number + 1))

    # Determine which part to update
    case $UPDATE_TYPE in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        build)
            # Only build number will be incremented
            ;;
        *)
            echo "Invalid update type: $UPDATE_TYPE"
            echo "Please use 'major', 'minor', 'patch', or 'build'"
            exit 1
            ;;
    esac

    # Construct the new version line
    local new_version_line="version: $major.$minor.$patch+$new_build_number"

    # Replace the old version line with the new version line in pubspec.yaml
    # The '' after -i is necessary for macOS compatibility
    sed -i '' "s/$version_line/$new_version_line/" "$PUBSPEC_PATH"

    # Print the old and new version
    echo -e "\033[0;32mIt was version $old_version and now is $major.$minor.$patch+$new_build_number\033[0m"
}

# Bump the version
bump_version
