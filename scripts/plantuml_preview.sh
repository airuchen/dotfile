#!/bin/bash

# Plantuml to png with reused feh instance for previewing

set -e
set -o pipefail

if [ $# -lt 1 ]; then
  echo "Need a filename"
  echo "Usage: plantuml_preview.sh diagram.puml"
  exit 1
fi

# Rewrites the errors to contain the full path so quickfix jumping works
output_file="/tmp/plantuml_preview.png"
plantuml -p -stdrpt:2 -tpng < "${1}" 2> >(sed -e "s=^string=${1}=" >&2) > "${output_file}"

# Check whether preview is already running
pgrep --full '^feh .*plantuml_preview' > /dev/null && exit 0
# Detached
feh --class plantuml_preview -B '#303030' "${output_file}"&
