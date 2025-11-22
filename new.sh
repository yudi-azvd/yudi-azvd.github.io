#!/usr/bin/env bash

set -e

filename="$1"

_date=$(date '+%F')
year=$(date '+%Y')

finalpath=content/posts/${year}/"${_date}-${filename}"

mkdir -p content/posts/${year}/

hugo new content content/posts/${year}/${filename}

# TODO: Arranjar um jeito (script quem sabe) de verifificar ou até interromper
# quando houver "WARN: Duplicate target paths"
mv content/posts/${year}/${filename} ${finalpath}
echo "Moved to ${finalpath}"
