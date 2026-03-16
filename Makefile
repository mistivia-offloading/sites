MD_SRC  = $(shell find . -name "*.md")
MD_TARGET  = $(MD_SRC:.md=.html)

TEX_SRC  = $(shell find . -name '*.tex' -not -path './templates/*')
TEX_PDF_TARGET  = $(TEX_SRC:.tex=.pdf)

TYP_SRC  = $(shell find . -name '*.typ' -not -path './templates/*')
TYP_PDF_TARGET  = $(TYP_SRC:.typ=.pdf)

PDF_SRC = $(TYP_PDF_TARGET) $(TEX_PDF_TARGET)
PDF_HTML_TARGET = $(PDF_SRC:.pdf=.html)

all: rss $(MD_TARGET) $(PDF_HTML_TARGET)

rss: blog/index.xml blog/enposts/index.xml

blog/index.xml: blog/posts/index.md scripts/genrss.py
	sed -n '6,13p' $< | python scripts/genrss.py > $@

blog/enposts/index.xml: blog/enposts/index.md scripts/genrss.py
	sed -n '6,13p' $< | python scripts/genrss.py > $@

$(MD_TARGET): %.html: %.md scripts/md.py
	python scripts/md.py $< > $@

$(TYP_PDF_TARGET): %.pdf: %.typ
	bash scripts/typ2pdf.sh $<

$(TEX_PDF_TARGET): %.pdf: %.tex
	bash scripts/tex2pdf.sh $<

$(PDF_HTML_TARGET): %.html: %.pdf scripts/pdf2html.py
	python scripts/pdf2html.py $< > $@

.PHONY: rss