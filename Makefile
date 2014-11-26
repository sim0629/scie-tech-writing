all: paper.pdf

clean:
	rm -f paper.pdf paper.aux paper.dvi paper.log paper.toc paper.toc.bak paper.ilg paper.ind

paper.pdf: paper.tex
	pdflatex -shell-escape $<
	makeindex $<
	pdflatex -shell-escape $<