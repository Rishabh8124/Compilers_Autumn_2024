YACC_FILE = "expr.y"
LEX_FILE = "expr.l"
C_FILE = "expr.c"

all:
	yacc -d ${YACC_FILE}
	lex ${LEX_FILE}
	gcc ${C_FILE}

run :
	./a.out < test.txt

clean:
	rm -f lex.yy.c y.tab.c y.tab.h a.out