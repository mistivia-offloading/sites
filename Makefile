rss: blog/index.xml blog/enposts/index.xml

blog/index.xml: blog/posts/index.md scripts/genrss.py
	sed -n '6,13p' $< | python scripts/genrss.py > $@

blog/enposts/index.xml: blog/enposts/index.md scripts/genrss.py
	sed -n '6,13p' $< | python scripts/genrss.py > $@

.PHONY: rss