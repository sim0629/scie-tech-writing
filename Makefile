PROLOGS = $(wildcard *.pl)

all: paper.pdf

clean:
	rm -f paper.pdf paper.aux paper.dvi paper.log paper.toc paper.toc.bak paper.ilg paper.ind paper.lof  paper.out  paper.pyg

paper.pdf: paper.tex $(PROLOGS)
	pdflatex -shell-escape $<
	makeindex $<
	pdflatex -shell-escape $<
