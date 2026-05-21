#!/bin/bash
# get-postgres-version.sh
# Usage: ./get-postgres-version.sh 18
# Returns: 18.x (latest minor version for PostgreSQL 18)

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <major_version>" >&2
    echo "Example: $0 18" >&2
    exit 1
fi

MAJOR_VERSION=$1

# Validate input is a number
if ! [[ "$MAJOR_VERSION" =~ ^[0-9]+$ ]]; then
    echo "Error: Major version must be a number" >&2
    exit 1
fi

echo "Fetching latest PostgreSQL $MAJOR_VERSION version..." >&2

# Use docker-library/postgres versions.json (same source as official image builds).
# Docker Hub's tags API is unreliable in CI (often returns 504 HTML/plain-text errors).
VERSIONS_URL="https://raw.githubusercontent.com/docker-library/postgres/master/versions.json"
RESPONSE=$(curl -fsSL "$VERSIONS_URL")

LATEST_VERSION=$(echo "$RESPONSE" | jq -r --arg major "$MAJOR_VERSION" '.[$major].version // empty')

if [ -z "$LATEST_VERSION" ]; then
  echo "Error: Could not find version for PostgreSQL $MAJOR_VERSION" >&2
  echo "Check $VERSIONS_URL for available major versions." >&2
  exit 1
fi

echo "Found latest version: $LATEST_VERSION" >&2
echo "$LATEST_VERSION"
