#!/usr/bin/env python3
import html
import sys
import subprocess
import tempfile
import os
import glob
from pathlib import Path

CSS_STYLES = """
"""

def get_project_root() -> Path:
    """Get the project root directory (where this script is located/..)"""
    script_path = Path(__file__).resolve()
    return script_path.parent.parent

def extract_title(src_path: Path) -> str:
    """Extract title from the first line of source file"""
    if not src_path.exists():
        return src_path.stem
    text = src_path.read_text(encoding="utf-8")
    first_line = text.splitlines()[0] if text.splitlines() else ""
    line = first_line.strip()
    if line.startswith("//"):
        return line[2:].strip() or src_path.stem
    if line.startswith("%"):
        return line.lstrip("%").strip() or src_path.stem
    return src_path.stem

def compile_typ_to_svgs(typ_path: Path, project_root: Path) -> list[Path]:
    """Compile typst file to multiple SVG files in a temp directory"""
    # Create temp directory for SVG output
    with tempfile.TemporaryDirectory() as tmpdir:
        # Calculate relative path from project root
        try:
            rel_path = typ_path.relative_to(project_root)
        except ValueError:
            rel_path = typ_path
        
        # Output pattern: page-01.svg, page-02.svg, etc.
        output_pattern = os.path.join(tmpdir, "page-{0p}.svg")
        
        # Run typst compile
        cmd = [
            "typst", "compile",
            "--root", str(project_root),
            str(rel_path),
            output_pattern
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error compiling typst: {result.stderr}", file=sys.stderr)
            raise SystemExit(1)
        
        # Collect generated SVG files
        svg_files = sorted(glob.glob(os.path.join(tmpdir, "page-*.svg")))
        if not svg_files:
            print("Error: No SVG files generated", file=sys.stderr)
            raise SystemExit(1)
        
        # Read SVG contents and return
        svg_contents = []
        for svg_file in svg_files:
            with open(svg_file, 'r', encoding='utf-8') as f:
                svg_contents.append(f.read())
        
        return svg_contents

def build_html(svg_contents: list[str], title: str, srctext: str = "") -> str:
    """Build HTML with inline SVGs"""
    # Wrap each SVG in a page div
    page_divs = []
    for svg in svg_contents:
        # Remove XML declaration if present
        if svg.startswith('<?xml'):
            svg = svg[svg.find('?>')+2:].strip()
        page_divs.append(f'<div class="ipadding"><div class="page">\n{svg}\n</div></div>')
    
    pages_html = '\n'.join(page_divs)
    
    return f"""<!DOCTYPE html>
<html>
<head>
<title>{title}</title>
<meta charset="utf-8">
<link rel="stylesheet" href="/style5.css">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<div class="ipadding">
<pre class="back"><a href="../">../</a></pre>
</div>
<pre style="position:absolute;left:-10000px;top:-10000px;opacity:0;width:1px;height:1px;overflow:hidden;">{srctext[:800]}</pre>
<div class="content">
{pages_html}
</div>
<div class="ipadding">
<hr>
<p id="email">Email: i (at) mistivia (dot) com</p>
</div>
<script>
var emailElement = document.getElementById('email');
var base64String = "RW1haWw6IGlAbWlzdGl2aWEuY29tCg==";
var decodedString = atob(base64String);
emailElement.innerHTML = decodedString;
</script>
</body>
</html>
"""

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python scripts/typ2html.py <path/to/file.typ>", file=sys.stderr)
        return 1

    typ_path = Path(sys.argv[1])
    if typ_path.suffix.lower() != ".typ":
        print(f"error: input is not a typst file: {typ_path}", file=sys.stderr)
        return 1

    if not typ_path.exists():
        print(f"error: file not found: {typ_path}", file=sys.stderr)
        return 1

    project_root = get_project_root()
    
    # Extract title and source text
    title = extract_title(typ_path)
    src_text = typ_path.read_text(encoding="utf-8")
    src_text_escaped = html.escape(src_text)
    
    # Compile to SVGs
    svg_contents = compile_typ_to_svgs(typ_path, project_root)
    
    # Build and output HTML
    html_output = build_html(svg_contents, title, src_text_escaped)
    print(html_output)
    
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
