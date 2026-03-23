#!/usr/bin/env python3
"""Generate sitemap.xml for blog posts."""

from pathlib import Path
import re
from datetime import datetime
from xml.etree import ElementTree as ET

BASE_URL = "https://blog.mistivia.com"
BLOG_DIR = Path("blog")
OUTPUT_FILE = BLOG_DIR / "sitemap.xml"


def parse_post_date(dirname: str) -> str:
    """Extract date from directory name like '2025-09-27-ezlive'."""
    match = re.match(r'^(\d{4}-\d{2}-\d{2})-', dirname)
    if match:
        # Return date in W3C format (YYYY-MM-DD)
        return match.group(1)
    return datetime.now().strftime("%Y-%m-%d")


def collect_urls():
    """Collect all post URLs from posts and enposts directories."""
    urls = []
    
    for section in ["posts", "enposts"]:
        section_path = BLOG_DIR / section
        if not section_path.exists():
            continue
            
        # Add the section index page
        urls.append({
            'loc': f"{BASE_URL}/{section}/",
            'lastmod': datetime.now().strftime("%Y-%m-%d")
        })
        
        # Add individual posts
        for post_dir in sorted(section_path.iterdir()):
            if not post_dir.is_dir():
                continue
            # Skip special directories
            if post_dir.name.startswith('.') or post_dir.name.startswith('_'):
                continue
            
            date_str = parse_post_date(post_dir.name)
            urls.append({
                'loc': f"{BASE_URL}/{section}/{post_dir.name}/",
                'lastmod': date_str
            })
    
    # Add main pages
    urls.insert(0, {
        'loc': f"{BASE_URL}/",
        'lastmod': datetime.now().strftime("%Y-%m-%d")
    })
    
    return urls


def generate_sitemap(urls):
    """Generate sitemap XML content."""
    urlset = ET.Element('urlset')
    urlset.set('xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9')
    
    for url_info in urls:
        url_elem = ET.SubElement(urlset, 'url')
        
        loc = ET.SubElement(url_elem, 'loc')
        loc.text = url_info['loc']
        
        lastmod = ET.SubElement(url_elem, 'lastmod')
        lastmod.text = url_info['lastmod']
        
        # Set priority based on page type
        priority = ET.SubElement(url_elem, 'priority')
        if url_info['loc'] == f"{BASE_URL}/":
            priority.text = "1.0"
        elif url_info['loc'].endswith('/posts/') or url_info['loc'].endswith('/enposts/'):
            priority.text = "0.8"
        else:
            priority.text = "0.6"
    
    # Convert to string with pretty printing
    ET.indent(urlset, space='  ')
    xml_declaration = '<?xml version="1.0" encoding="UTF-8"?>\n'
    return xml_declaration + ET.tostring(urlset, encoding='unicode')


def main():
    urls = collect_urls()
    sitemap_content = generate_sitemap(urls)
    
    OUTPUT_FILE.write_text(sitemap_content, encoding='utf-8')
    print(f"Generated sitemap with {len(urls)} URLs: {OUTPUT_FILE}")


if __name__ == '__main__':
    main()
