#!/bin/bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path/to/file.typ>" >&2
  exit 1
fi

typ_in="$1"

if [ ! -f "$typ_in" ]; then
  echo "Error: input file not found: $typ_in" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
templates_dir="$project_root/templates"

typ_in_abs="$(cd "$(dirname "$typ_in")" && pwd)/$(basename "$typ_in")"
typ_in_rel="${typ_in_abs#$project_root/}"
typ_dir="$(dirname "$typ_in_abs")"
typ_base="$(basename "$typ_in_abs" .typ)"
pdf_out="$typ_dir/$typ_base.pdf"

if [ "$typ_in_rel" = "$typ_in_abs" ]; then
  echo "Error: input file must be inside project root: $project_root" >&2
  exit 1
fi

created_links=()
cleanup() {
  for p in "${created_links[@]}"; do
    rm -f "$p"
  done
}
trap cleanup EXIT

for name in template.typ template-en.typ; do
  target="$project_root/$name"
  source_file="$templates_dir/$name"
  if [ -e "$target" ]; then
    continue
  fi
  ln -s "$source_file" "$target"
  created_links+=("$target")
done

echo "Compiling '$typ_in_abs' -> '$pdf_out'"
echo "Using typst root '$project_root'"

typst compile --root "$project_root" "$typ_in_rel" "$pdf_out"
