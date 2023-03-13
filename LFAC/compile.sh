#!/bin/bash
echo "compiling $1"
rm -f lex.yy.c
rm -f y.tab.c
yacc -d $1.y
flex $1.l
gcc  lex.yy.c y.tab.c -o $1
