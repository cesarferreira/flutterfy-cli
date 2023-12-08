#!/bin/bash

# Define color codes
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

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

    # Form new version string
    local new_version="$major.$minor.$patch+$new_build_number"

    # Update the version in the pubspec.yaml
    sed -i '' "s/$version_line/version: $new_version/" "$PUBSPEC_PATH"

    # Print the old and new version
    echo -e "\nfrom: ${YELLOW}$version+$build_number${RESET}"
    echo -e "to:   ${GREEN}$new_version${RESET}"
}

# Bump the version
bump_version
