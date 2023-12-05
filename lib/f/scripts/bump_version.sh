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

    local old_major=$major
    local old_minor=$minor
    local old_patch=$patch
    local old_build_number="${YELLOW}$build_number${RESET}"

    # Increment the build number
    local new_build_number=$((build_number + 1))

    # Initialize new version parts for coloring
    local new_major=$major
    local new_minor=$minor
    local new_patch=$patch

    # Determine which part to update and apply color
    case $UPDATE_TYPE in
        major)
            major=$((major + 1))
            old_major="${YELLOW}$old_major${RESET}"
            new_major="${GREEN}$major${RESET}"
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            old_minor="${YELLOW}$old_minor${RESET}"
            new_minor="${GREEN}$minor${RESET}"
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            old_patch="${YELLOW}$old_patch${RESET}"
            new_patch="${GREEN}$patch${RESET}"
            ;;
        build)
            # Only build number will be incremented
            new_build_number="${GREEN}$new_build_number${RESET}"
            ;;
        *)
            echo "Invalid update type: $UPDATE_TYPE"
            echo "Please use 'major', 'minor', 'patch', or 'build'"
            exit 1
            ;;
    esac

    # Print the old and new version with highlights
    echo -e "\nfrom: $old_major.$old_minor.$old_patch+$old_build_number"
    echo -e "to:   $new_major.$new_minor.$new_patch+$new_build_number"
}

# Bump the version
bump_version
