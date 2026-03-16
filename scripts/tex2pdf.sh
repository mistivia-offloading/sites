#!/bin/bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path/to/file.tex>" >&2
  exit 1
fi

tex_in="$1"

if [ ! -f "$tex_in" ]; then
  echo "Error: input file not found: $tex_in" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
templates_dir="$project_root/templates"

tex_dir="$(cd "$(dirname "$tex_in")" && pwd)"
tex_file="$(basename "$tex_in")"

export TEXINPUTS="$templates_dir:${TEXINPUTS-}"

cd "$tex_dir"
echo "Compiling '$tex_file' in '$tex_dir'"
echo "Using TEXINPUTS='$TEXINPUTS'"
xetex -interaction=nonstopmode "$tex_file"
