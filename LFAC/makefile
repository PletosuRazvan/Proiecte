all:
	rm -f lex.yy.c
	rm -f y.tab.c
	yacc -d X.y
	flex X.l
	gcc  lex.yy.c y.tab.c -o X
