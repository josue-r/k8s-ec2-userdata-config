#!/bin/bash
set -euo pipefail

# Find all directories containing Terraform config (main.tf, etc)
for dir in $(find . -type f -name '*.tf' -exec dirname {} \; | sort -u); do
  echo "Validating $dir"
  terraform -chdir="$dir" init -backend=false -input=false
  terraform -chdir="$dir" validate
done
