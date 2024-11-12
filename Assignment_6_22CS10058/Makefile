YACC_FILE = "prog.y"
LEX_FILE = "prog.l"
C_FILE = "codegen.cpp"

all:
	yacc -d ${YACC_FILE}
	lex ${LEX_FILE}
	g++ ${C_FILE} -o codegen

run:
	@read -p "Enter number of registers (less than 2 will run with default value 5): " regCount; \
	./codegen $$regCount < sample.txt
	cat Intermediate_code.txt
	cat Target_code.txt

clean:
	rm -f codegen Intermediate_code.txt Target_code.txt lex.yy.c y.tab.h y.tab.c a.out