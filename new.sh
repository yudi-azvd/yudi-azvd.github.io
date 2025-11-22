#!/usr/bin/env bash

set -e

filename="$1"

_date=$(date '+%F')
year=$(date '+%Y')

finalpath=content/posts/${year}/"${_date}-${filename}"

mkdir -p content/posts/${year}/

hugo new content content/posts/${year}/${filename}

mv content/posts/${year}/${filename} ${finalpath}
echo "Moved to ${finalpath}"
