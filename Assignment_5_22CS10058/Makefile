YACC_FILE = "expr.y"
LEX_FILE = "expr.l"
C_FILE = "intcodegen.c"

all:
	yacc -d ${YACC_FILE}
	lex ${LEX_FILE}
	gcc ${C_FILE} -o icgen

run:
	./icgen < sample.txt
	gcc intcode.c -o ic
	./ic

clean:
	rm -f icgen lex.yy.c y.tab.h y.tab.c intcode.c ic a.out