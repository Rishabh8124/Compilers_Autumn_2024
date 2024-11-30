shell = /bin/sh

lex:
	lex latex.l
	gcc procltx.c
	./a.out < A1.tex

clean:
	rm -f lex.yy.c a.out