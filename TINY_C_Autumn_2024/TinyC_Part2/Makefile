YACC_FILE = "tinyC2_22CS10058_22CS10063.y"
LEX_FILE = "tinyC2_22CS10058_22CS10063.l"
C_FILE = "tinyC2_22CS10058_22CS10063.c"
INPUT_FILE = "input_22CS10058_22CS10063.c"
OUTPUT_FILE = "output_22CS10058_22CS10063.txt"

all:
	yacc -d ${YACC_FILE}
	lex ${LEX_FILE}
	gcc ${C_FILE}

run:
	./a.out < ${INPUT_FILE} > ${OUTPUT_FILE}

clean:
	rm -f lex.yy.c y.tab.c y.tab.h a.out a.exe ${OUTPUT_FILE}