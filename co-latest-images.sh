#!/bin/bash

REGISTRY=${REGISTRY:-'https://registry.hub.docker.com'}
OPERATOR_DIR=${OPERATOR_DIR:-'.'}

process () {
    # echo Processing $1
    local repository=$(yq e '.. | select(has("image")) | .image | select(has("repository")) | .repository' "$1" 2>/dev/null)
    local tag=$(yq e '.. | select(has("image")) | .image | select(has("tag")) | .tag' "$1" 2>/dev/null)
    if [ "$repository" != "null" ] && [ -n "$repository" ]; then
        # latest_version=$(curl -L -s "$REGISTRY/v2/repositories/$repository/tags?page_size=1024" | jq '."results"[]["name"]' | sort -r | egrep -e '\b([0-9]+\.[0-9]+\.[0-9]+)' | head -n 1 | tr -d '"')
        images+=( "$repository:$tag" )
    else
        # Maybe it's the 2.0/EA format
        # echo Processing $1
        local indexes=( $(yq -N e 'select(has("apiVersion")) | select(.apiVersion == "platform.confluent.io/v1beta1") | documentIndex' "$1" 2>/dev/null) )
        # echo $indexes
        # echo ${#indexes[@]}
        for i in $(seq 1 ${#indexes[@]}); do
            local index=${indexes[$i]}
            # echo $index
            local application=$(yq e "select(documentIndex == $i) | .spec.image.application" "$1" 2>/dev/null)
            local init=$(yq e "select(documentIndex == $i) | .spec.image.init" "$1" 2>/dev/null)
            # blah blah blah global variables
            images+=($application $init)
        done
    fi
}

# echo "Finding latest image versions for Confluent Operator in ${OPERATOR_DIR}"

# Make sure globstar is enabled
shopt -s globstar
images=()
for i in $OPERATOR_DIR/**/*.yaml; do # Whitespace-safe and recursive
    process $i
done
# Deduplicate and sort
declare -A dedup_images
for i in "${images[@]}"; do
    if [ -n "$i" ] && [ "$i" != "null" ]; then
        dedup_images["$i"]=1;
    fi
done
images=()
count=1
for i in "${!dedup_images[@]}"; do
    images[$((count++))]=$i
done
images=($(echo "${images[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
# printf "[%s]\n" "${images[@]}"

if [ ${#images[@]} -eq 0 ]; then
    echo "No image references found, are you sure this is a Confluent Operator directory?"
    exit 1
fi

# Process each image into a table of name|version|latest version
col1_size=0
col2_size=0
col3_size=0
col1=()
col2=()
col3=()
for i in "${images[@]}"; do
    image=$(echo "$i" | cut -d ':' -f 1)
    tag=$(echo "$i" | cut -d ':' -f 2)
    # echo "$REGISTRY/v2/repositories/$image/tags?page_size=1024"
    latest=$(curl -L -s "$REGISTRY/v2/repositories/$image/tags?page_size=1024" | jq '."results"[]["name"]' | sort --reverse --ignore-case --version-sort | egrep -e '\b([0-9]+\.[0-9]+\.[0-9]+)' | head -n 1 | tr -d '"')
    col1_size=$(( $col1_size > ${#image} ? $col1_size : ${#image} ))
    col2_size=$(( $col2_size > ${#tag} ? $col2_size : ${#tag} ))
    col3_size=$(( $col3_size > ${#latest} ? $col3_size : ${#latest} ))
    col1+=( $image )
    col2+=( $tag )
    col3+=( $latest )
done
printf -v header "%-${col1_size}s   %-${col2_size}s   %-${col3_size}s" "Image" "Tag" "Latest"
printf "%s\n" "$header"
printf "%${#header}s\n" ' ' | tr ' ' '-'
for i in $(seq 0 ${#col1[@]}); do
    printf "%-${col1_size}s   %-${col2_size}s   %-${col3_size}s\n" "${col1[$i]}" "${col2[$i]}" "${col3[$i]}"
done
