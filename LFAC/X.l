%{
#include <stdio.h>
#include "y.tab.h" // generat de yacc - defineste lista de token-uri folosite
%}

space [ \t ]

%option noyywrap
%%
"typeof" {return TYPEOF;}
"eval" {return EVAL;}
"typ_void" {yylval.dataTyp=strdup(yytext); return VOID;}
"typ_int" {yylval.dataTyp=strdup(yytext); return INT;}
"typ_float" {yylval.dataTyp=strdup(yytext); return FLOAT;}
"typ_char" {yylval.dataTyp=strdup(yytext); return CHAR;}
"typ_string" {yylval.dataTyp=strdup(yytext); return STRING;}
"typ_bool" {yylval.dataTyp=strdup(yytext); return BOOL;}

"constant" {return CONSTANT;}

"structure" {return STRUCTURE;}

"class" {return CLASS;} 

"private" {return PRIVAT;}
"protected" {return PROTECTED;}
"public" {return PUBLIC;} 

"if" {return IF;}

"else" {return ELSE;}

"while" {return WHILE;}
	
"for" {return FOR;}

"do" {return DO;}

"true" | "false" {yylval.boolTyp = strdup(yytext); return BOOL;}

"print" {return PRINT;}

"begin_program" {return BGIN;}

"end_program"   {return END;}

"return" {return RETURN;}

"<-" {return ASSIGN;}

"<" {return LESS;}
"<=" {return LESSEQ;}
">" {return GRT;}
">=" {return GRTEQ;}
"==" {return EQ;}
"!" {return NOT;}

"&&" {return AND;}
"||" {return OR;}



[-+]?0|[-+]?([1-9][0-9]*) {yylval.intTyp = atoi(yytext); return INT_NUM;}

[-+]?0|[-+]?([1-9][0-9]*)"."[0-9]* {yylval.floatTyp = atof(yytext); return REAL_NUM;} 

'[a-zA-Z]'  {yylval.charTyp = strdup(yytext); return CHAR_VAL;} 

\"[^"]*\" {yylval.stringTyp = strdup(yytext); return STRING_VAL;}

[a-zA-Z][_a-zA-Z0-9]* {yylval.dataTyp = strdup(yytext); return IDENTIF;}

[a-zA-Z][_a-zA-Z0-9]*(\[[0-9a-z]+\])+ {yylval.arrayTyp = strdup(yytext); return ARRAY_IDENTIF;}

 {space} ;

\n {yylineno++;} 
. {return yytext[0];}
%%
