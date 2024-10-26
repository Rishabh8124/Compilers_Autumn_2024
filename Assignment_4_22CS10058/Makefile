YACC_FILE = "poly.y"
LEX_FILE = "poly.l"
C_FILE = "polyutils.c"

all:
	yacc -d ${YACC_FILE}
	lex ${LEX_FILE}
	gcc ${C_FILE}

run:
	./a.out < sample.txt

clean:
	rm -f a.out lex.yy.c y.tab.h y.tab.c