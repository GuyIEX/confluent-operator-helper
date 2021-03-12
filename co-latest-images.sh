#!/bin/bash

REGISTRY=${REGISTRY:-'https://registry.hub.docker.com'}
OPERATOR_DIR=${OPERATOR_DIR:-'.'}

process () {
    # repository=$(yq e '.image.repository' "$1" 2>/dev/null)
    repository=$(yq e '.. | select(has("repository")) | .repository' "$1" 2>/dev/null)
    if [ "$repository" != "null" ] && [ -n "$repository" ] && [[ $repository == confluentinc* ]]; then
        latest_version=$(curl -L -s "$REGISTRY/v2/repositories/$repository/tags?page_size=1024" | jq '."results"[]["name"]' | sort -r | egrep -e '\b([0-9]+\.[0-9]+\.[0-9]+)' | head -n 1 | tr -d '"')
        echo "$repository:$latest_version"
    fi
}

echo "Finding latest image versions for Confluent Operator in ${OPERATOR_DIR}"

# Make sure globstar is enabled
shopt -s globstar
for i in $OPERATOR_DIR/**/*.yaml; do # Whitespace-safe and recursive
    process $i
done

# Alternate to Bash globstar
# Not recommended, will break on whitespace
# for i in $(find -name \*.yaml); do
#    process $i
# done