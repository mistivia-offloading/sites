MD_SRC  = $(shell find . -name "*.md")
MD_TARGET  = $(MD_SRC:.md=.html)

all: rss $(MD_TARGET)

rss: blog/index.xml blog/enposts/index.xml

blog/index.xml: blog/posts/index.md scripts/genrss.py
	sed -n '6,13p' $< | python scripts/genrss.py > $@

blog/enposts/index.xml: blog/enposts/index.md scripts/genrss.py
	sed -n '6,13p' $< | python scripts/genrss.py > $@

$(MD_TARGET): %.html: %.md scripts/md.py
	python scripts/md.py $< > $@

.PHONY: rss