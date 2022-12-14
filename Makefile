.PHONY: view build show-input-files pre post aux spellcheck full clean
.DEFAULT_GOAL: view

SRC_FILES = $(wildcard src/*.tex)
BIB_FILES = $(wildcard src/*.bib)
IMG_FILES = $(wildcard src/img/*) $(wildcard src/img/*/*)

PDFLATEX_EXIT = -interaction=nonstopmode -halt-on-error

# Build and view the PDF
view: build
	open build/main.pdf

# Build the PDF
build: build/main.pdf

# Run pdflatex with prettified (less verbose) output
# Requires texfot (which I believe is installed by default with most distros)
build/main.pdf: $(SRC_FILES) $(BIB_FILES) $(IMG_FILES)
	cp -R src/ build/
	cd build \
	&& pdflatex $(PDFLATEX_EXIT) main.tex > /dev/null \
	&& bibtex --terse main.aux | sed 's_^_    _' \
	&& pdflatex main.tex > /dev/null \
	&& texfot pdflatex main.tex | sed 's_^_    _'

# Show all sources picked up by the Makefile (useful for debugging)
show-input-files:
	@echo "=== tex sources ==="
	@echo $(SRC_FILES)
	@echo "=== bib ==="
	@echo $(BIB_FILES)
	@echo "=== images and figures ==="
	@echo $(IMG_FILES)

# Auxiliary data from pre-build .tex/.bib files
pre:
	scripts/update_totals.sh
	scripts/update_wordclouds.sh

# Auxiliary data from post-build .pdf/.aux files
post: build
	scripts/update_bibstats.sh || true
	scripts/update_fonts.sh

# Build all auxiliary data and stats
aux: pre post

# Run aspell (with input file of whitelisted words)
spellcheck:
	scripts/spellcheck.sh

# Build final version for publishing
full: clean spellcheck pre build post

# Clean up
# Separating out build/ simplifies cleanup considerably.
# Notice we don't have to enumerate a long list of TeX-related files, like:
# rm -f *.aux *.toc *.out *.log *.bbl *.blg *.pdf *.temp *.lof *.lot
clean:
	rm -rf build/
	rm -f data/*.temp
