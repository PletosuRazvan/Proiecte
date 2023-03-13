%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include<math.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
///#include "f.h"

int global =0; // 0- global 1- main 2 - scope functii

// tabel simboluri

struct simboluri {
	char nume[100];//NUME
	char typ[50];//TIP
	int global;//LOCATIE_VAR  
	int costant;//CONSTANT
	int init;// daca variabila are valoare
	int intVal; //VALOARE
	float floatVal;//VALOARE
	char charVal[256];//VALOARE
	char stingVal[256];//VALOARE
	int vectorIntVal[100];//VALOARE
	float vectorFloatVal[100];//VALOARE
} Simb[256];

union value {
     int intVal;
     float floatVal;
     char strVal[101];
     char charVal;
	 int boolVal;
};

struct node {
	int type;
	union value var;
	struct node *left;
	struct node *right;
};

struct node* buildAST(union value root,struct node* left,struct node* right,int type){
    if(type == 7)
	{
		int i = verifdecl(root.strVal);
		if(i == -1)
		{
			char msg[100];
			sprintf(msg,"Variable \'%s\' not found",root.strVal);
			yyerror(msg);
			return NULL;
		} else 
			root.intVal = 0;
	}
	struct node*  AST = malloc(sizeof(struct node));
	AST->var = root;
  	AST->type = type;
  	AST->left = left;
 	AST->right = right;
 	return AST;
}

int evalAST(struct node* AST){
    
	int leftval = 0;
	int rightval = 0;
	if(AST->left != NULL)
		leftval = evalAST(AST->left);
	if(AST->right != NULL)
		rightval = evalAST(AST->right);
	switch(AST->type)
	{
		case 1:
			return leftval + rightval;
		break;
		case 2:
			return leftval - rightval;
		break;
		case 3:
			return leftval * rightval;
		break;
		case 4:
			return leftval / rightval;
		break;
		// case 5:
		// 	return pow(leftval, rightval);
		// break;
		case 6:
			return AST->var.intVal;
		break;
		case 7:
			return Simb[verifdecl(AST->var.strVal)].intVal;
		default :
			return 0;
	}
}

int nrSimb=0;// variabila va nr cate simboluri au fost declarate
char* typeOfff(char n[])
{printf("   numele:  %s   ", n);
    for(int i=1;i<=nrSimb;i++)
    {
        if(strcmp(Simb[i].nume,n)==0)
        return Simb[i].typ;
    }
}
struct param{
	char nume[100];
	char tip[50];
}p[50];

int nrparametrii[50]={0};
int nrf=0 ;// pe asocierea parametrilor

struct functii{
	char nume[100];
	char tip_return[100];
	//param p[50];// o functie poate avea pana la 50 de parametri	
}Funct[256];



int nrFun=0; // nr de functii descrise

//declarare functie 

void declarareFun(char fnume[], char ftyp[] )
{
    nrFun++;
    strcpy(Funct[nrFun].nume,fnume);
    strcpy(Funct[nrFun].tip_return, ftyp);
}
// varificam daca o variabila a fost declarata
int verifdeclFun(char x[]) {
    for (int i = 0; i <= nrFun; i++) {
         if (strcmp(x, Funct[i].nume) == 0) {
             //printf("ajunge in verifdecl \n");
             return i;
         }
    }
    return -1;
}

FILE* tabel2;

void tabel_fun () {
    int i;
    tabel2 = fopen("symbol_table_functions.txt", "a");

}
void clear_table2(){

     tabel2=fopen("symbol_table_functions.txt","w");
}



//declararii sim

void declarare(char dnume[], char dtyp[], int dglobal, int dconstant)
{
    nrSimb++;
    strcpy(Simb[nrSimb].nume, dnume);
    strcpy(Simb[nrSimb].typ, dtyp);
    Simb[nrSimb].global= dglobal;
    Simb[nrSimb].costant=dconstant;
    Simb[nrSimb].init=0;
    Simb[nrSimb].intVal=-1;
    Simb[nrSimb].floatVal= -1;
    strcpy(Simb[nrSimb].charVal, "");
    strcpy(Simb[nrSimb].stingVal , "");
}

// varificam daca o variabila a fost declarata
int verifdecl(char x[]) {
    for (int i = 0; i <= nrSimb; i++) {
         if (strcmp(x, Simb[i].nume) == 0) {
             //printf("ajunge in verifdecl \n");
             return i;
         }
    }
    return -1;
}
// verificam daca o variabila a fost initializata
int verifinit(char x[]) {
    int i;
    for (i = 0; i <= nrSimb; i++) {
         if (strcmp(x, Simb[i].nume) == 0) {
              if (Simb[i].init == 0)
                 return -1;
              else 
                 return 1;
         }
    }
    return -1;
}

//verificam daca o variabila este constanta
int verifconst(char x[]) {
    int i;
    for (i = 0; i <= nrSimb; i++) {
         if (Simb[i].costant == 1) {
             if (Simb[i].init == 0)
                 return -1;
             else
                 return 1;
         }
    }
    return -1;
}



// initializari

void initializareINT(char nume[], int val)
{
    int k=verifdecl(nume);
    if(k!=-1)
    {
        Simb[k].init=1;
        Simb[k].intVal=val;
    }
}

void initializareFLOAT(char nume[], float val)
{
    int k=verifdecl(nume);
    if(k!=-1)
    {
        Simb[k].init=1;
        Simb[k].floatVal=val;
    }
}

void initializareCHAR(char nume[], char val[])
{
    int k=verifdecl(nume);
    if(k!=-1)
    {
        Simb[k].init=1;
        strcpy(Simb[k].charVal,val);
    }
}

void initializareSTRING(char nume[], char val[])
{
    int k=verifdecl(nume);
    if(k!=-1)
    {
        Simb[k].init=1;
        strcpy(Simb[k].stingVal,val);
    }
}

void getTyp(char nume[], char get[])
{
    int k=verifdecl(nume);
    strcpy(get, Simb[k].typ);
}

void copyVal(char nume1[], char nume2[])
{
    int nr1=verifdecl(nume1);// pozitia variabilei care primeste valarea
    int nr2=verifdecl(nume2);// pozitia variabilei care ofera valoare
    char tip[30];
    getTyp(nume2,tip);
    if(strcmp(tip,"typ_int")==0)
    {
        Simb[nr1].intVal=Simb[nr2].intVal;
        Simb[nr1].init=1;
    }
    else{
        if(strcmp(tip,"typ_float")==0)
        {
            Simb[nr1].floatVal=Simb[nr2].floatVal;
            Simb[nr1].init=1;
        }
        else{
            if(strcmp(tip,"typ_char")==0)
            {
                strcpy(Simb[nr1].charVal,Simb[nr2].charVal);
                Simb[nr1].init=1;
            }
            else{
                if(strcmp(tip,"typ_string")==0)
                {
                    strcpy(Simb[nr1].stingVal,Simb[nr2].stingVal);
                    Simb[nr1].init=1;
                }
            }
        }

    }
}


FILE* tabel;

void tabel_sim () {
    int i;
   
     tabel = fopen("symbol_table.txt", "a");

    for (i = 1; i <= nrSimb; i++) {
    

    	fprintf(tabel, "%s  %s  %s  %s ", "Nume: ", Simb[i].nume, " | Tip: ", Simb[i].typ);
      
        
        if(Simb[i].global == 0) {

            fprintf(tabel, " %s  %s "," | Scope: ", "GLOBAL");

	    }
	    else {
            if(Simb[i].global == 1) {

                fprintf(tabel, " %s  %s "," | Scope: ", "MAIN");

	        }else{
                fprintf(tabel, " %s  %s "," | Scope: ", "FUNCTION");
            }
	    }

        if (Simb[i].costant == 1) {
            fprintf(tabel, " %s ", " | Const: 1 ");
	    }
	    else {
            fprintf(tabel, " %s ", " | Const: 0 ");
	       
	    }
        if (Simb[i].init == 1) {

            fprintf(tabel, " %s ", " | Valoare: ");

            if (strcmp(Simb[i].typ, "typ_int") == 0 || strcmp(Simb[i].typ, "bool") == 0) {

                fprintf(tabel, " %d ", Simb[i].intVal);
               
            
            }
            
            if (strcmp(Simb[i].typ, "typ_float") == 0) {

                fprintf(tabel, " %f ", Simb[i].floatVal);
            }
            
            if (strcmp(Simb[i].typ, "typ_string") == 0) {

                fprintf(tabel, " %s ",Simb[i].stingVal );
            }
            
            if (strcmp(Simb[i].typ, "typ_char") == 0) {
                fprintf(tabel, " %s ", Simb[i].charVal);         
            }
        }
        else {
                fprintf(tabel, " %s ", " | Neinitializata");
                
            }
    fprintf(tabel, " %s " , "\n");
     
    }
}
void clear_table(){

     tabel=fopen("symbol_table.txt","w");
}


%}



%union {
  int intTyp;
  float floatTyp;
  char* charTyp;
  char* stringTyp;
  char* dataTyp; // IDENTIF
  char* arrayTyp;
  char* tip_val;
  struct node *astval;
  char charval;


}

%token  CONSTANT EVAL STRUCTURE CLASS TYPEOF TREQQ CLASS_TYP BGIN END IF ELSE WHILE FOR DO RETURN ASSIGN LESS LESSEQ GRT GRTEQ EQ NOT AND OR PLUS MINUS DIV MULTIP MOD LBRACES RBRACES LPAR RPAR LBRACKET RBRACKET POINT SINGLE_QUOTES COMMA SEMI_COLLON PRINT PRIVAT PUBLIC PROTECTED 

%token <intTyp> INT_NUM

%token <floatTyp> REAL_NUM

%token <charTyp> CHAR_VAL

%token <stringTyp> STRING_VAL

%token <dataTyp> IDENTIF

%token <arrayTyp> ARRAY_IDENTIF

%token <dataTyp> VOID INT FLOAT CHAR STRING BOOL

%left '+' '-'
%left '*' '/' '%'
%left '{' '}' '[' ']' '(' ')' 

%start PROGRAM // simbolul de start a gramaticii
 
%type <intTyp> adunare 
%type <intTyp> EXPRESIE EXPRESII
%type <astval> EXPRESIE_EVAL
%type <dataTyp> vartype


%%
PROGRAM: DECLARATII FUNCTII BGIN BLOC END 
	| CLASE DECLARATII FUNCTII BGIN BLOC END 
	| STRUCTURI DECLARATII FUNCTII BGIN BLOC END 
	| CLASE STRUCTURI DECLARATII FUNCTII BGIN BLOC END 
	| STRUCTURI FUNCTII BGIN BLOC END 
	| CLASE STRUCTURI FUNCTII BGIN BLOC END 
	| STRUCTURI FUNCTII DECLARATII BGIN BLOC END 
	| CLASE STRUCTURI FUNCTII DECLARATII BGIN BLOC END 
	;
	
STRUCTURI: STRUCTURA ';'
	 | STRUCTURI STRUCTURA ';'
	 ;
	 
STRUCTURA: STRUCTURE IDENTIF '{' DECLARATII '}' 
	 | STRUCTURE IDENTIF '{' DECLARATII '}' IDENTIF 
	 ;
	 
CLASE: CLASA ';'
     | CLASE CLASA ';'
     ;

CLASA: CLASS IDENTIF '{' CLASABLOC '}'
     ;

CLASABLOC: PUBLIC':' varpub PRIVAT':' varpriv METODA
         ;

varpub: DECLARATII  
      ;

varpriv: DECLARATII 
       ;

METODA: FUNCTIE
	|METODA FUNCTIE 
	;

FUNCTII: FUNCTIE 
       | FUNCTII FUNCTIE 
       ;

FUNCTIE: '['vartype']' IDENTIF '(' ARGUMENTE ')' '{' BLOC2 '}' { if(verifdeclFun($4)==-1){declarareFun($4,$2);tabel2 = fopen("symbol_table_functions.txt", "a");fprintf(tabel2, "%s  %s  %s  %s ", "Nume: ", $4, " | Tip: ", $2);  fprintf(tabel2, " %s " , "\n");}else{printf("Functia a fost deja declarata. Eroare la linia: %d\n",yylineno);yyerror();}}
	| '['VOID']' IDENTIF '(' ARGUMENTE ')' '{' BLOC2 '}' {if(verifdeclFun($4)==-1){declarareFun($4,"void");tabel2 = fopen("symbol_table_functions.txt", "a");fprintf(tabel2, "%s  %s  %s  %s ", "Nume: ", $4, " | Tip: ", $2);  fprintf(tabel2, " %s " , "\n");}else{printf("Functia a fost deja declarata. Eroare la linia: %d",yylineno);yyerror();}} 
        ;
	
APEL_FUNCTIE: IDENTIF '(' VARARG ')' 
	    ;
	
ARGUMENTE: vartype IDENTIF  {tabel2 = fopen("symbol_table_functions.txt", "a");fprintf(tabel2, " %s  %s  %s  %s", "Nume_param: ",$2, " | Tip_param: ", $1);fprintf(tabel2, " %s " , "\n");global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
         | vartype IDENTIF ',' ARGUMENTE { tabel2 = fopen("symbol_table_functions.txt", "a");fprintf(tabel2, " %s  %s  %s  %s", "Nume_param: ",$2, " | Tip_param: ", $1);fprintf(tabel2, " %s " , "\n"); global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();}global=0;}
         | vartype ARRAY_IDENTIF  { tabel2 = fopen("symbol_table_functions.txt", "a");fprintf(tabel2, " %s  %s  %s  %s", "Nume_param: ",$2, " | Tip_param: ", $1);fprintf(tabel2, " %s " , "\n");global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();}global=0;}
         | vartype ARRAY_IDENTIF ',' ARGUMENTE { tabel2 = fopen("symbol_table_functions.txt", "a");fprintf(tabel2, " %s  %s  %s  %s", "Nume_param: ",$2, " | Tip_param: ", $1);fprintf(tabel2, " %s " , "\n");global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();}global=0;}
         |/*null*/
         ;
         
VARARG: INT_NUM
      | REAL_NUM
      | CHAR_VAL
      | STRING_VAL
      | BOOL
      | IDENTIF {if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
      | ARRAY_IDENTIF {if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
      | APEL_FUNCTIE 
      | VARARG ',' INT_NUM
      | VARARG ',' REAL_NUM
      | VARARG ',' CHAR_VAL
      | VARARG ',' STRING_VAL
      | VARARG ',' IDENTIF {if(verifdecl($3)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
      | VARARG ',' ARRAY_IDENTIF {if(verifdecl($3)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
      | VARARG ',' APEL_FUNCTIE 
      |/*null*/
      ;

	
DECLARATII : DECLARATIE ';' 
| DECLARATII DECLARATIE ';'
;

DECLARATIE: vartype IDENTIF {if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();}}

| vartype ARRAY_IDENTIF {if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, " vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();}}

| vartype IDENTIF ASSIGN INT_NUM {if(verifdecl($2)== -1){declarare($2, $1,global,0); initializareINT($2,$4);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype IDENTIF ASSIGN REAL_NUM {if(verifdecl($2)== -1){declarare($2, $1,global,0); initializareFLOAT($2,$4);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype IDENTIF ASSIGN CHAR_VAL {if(verifdecl($2)== -1){declarare($2, $1,global,0);initializareCHAR($2,$4);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype IDENTIF ASSIGN STRING_VAL {if(verifdecl($2)== -1){declarare($2, $1,global,0);initializareSTRING($2,$4);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype CONSTANT IDENTIF ASSIGN INT_NUM {if(verifdecl($3)== -1){declarare($3, $1,global,1);initializareINT($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype CONSTANT IDENTIF ASSIGN REAL_NUM {if(verifdecl($3)== -1){declarare($3, $1,global,1);initializareFLOAT($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype CONSTANT IDENTIF ASSIGN CHAR_VAL {if(verifdecl($3)== -1){declarare($3, $1,global,1);initializareCHAR($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype CONSTANT IDENTIF ASSIGN STRING_VAL {if(verifdecl($3)== -1){declarare($3, $1,global,1); initializareSTRING($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype IDENTIF ASSIGN IDENTIF {if(verifdecl($2)== -1){ declarare($2,$1,global, 0); if(verifdecl($2)!=-1 && verifdecl($4)!=-1){if(verifinit($4)== 1){copyVal($2,$4);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
| vartype IDENTIF ASSIGN ARRAY_IDENTIF {if(verifdecl($2)== -1){declarare($2,$1,global, 0); if(verifdecl($2)!=-1 && verifdecl($4)!=-1){if(verifinit($4)== 1){copyVal($2,$4);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
| vartype CONSTANT IDENTIF ASSIGN IDENTIF {if(verifdecl($3)== -1){declarare($3,$1,global, 0); if(verifdecl($3)!=-1 && verifdecl($5)!=-1){if(verifinit($5)== 1){copyVal($3,$5);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;} 
|  TYPEOF '(' IDENTIF ')' {printf("\n Variabila este de tipul : %s \n",typeOfff($3));}
| vartype CONSTANT IDENTIF ASSIGN ARRAY_IDENTIF {if(verifdecl($3)== -1){declarare($3,$1,global, 0); if(verifdecl($3)!=-1 && verifdecl($5)!=-1){if(verifinit($5)== 1){copyVal($3,$5);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}

| vartype IDENTIF ASSIGN APEL_FUNCTIE {declarare($2,$1,global, 0);}

| vartype CONSTANT IDENTIF ASSIGN APEL_FUNCTIE {declarare($3,$1,global, 1);}

| '#' IDENTIF IDENTIF

| '#' '#' IDENTIF IDENTIF
| APEL_FUNCTIE
| evaluare
;
/*IDENTIFICATORI: IDENTIF 
	      | IDENTIFICATORI ',' IDENTIF 
	      ;	**/
	      
vartype: INT
       | CHAR
       | FLOAT
       | BOOL
       | STRING
       ;
 
/*value: INT_NUM
| REAL_NUM
| CHAR_VAL
| STRING_VAL
| IDENTIF
| ARRAY_IDENTIF
| APEL_FUNCTIE 
;*/

// bloc == main body of a funtion 
BLOC: INSTRUCTIUNI
    ;
INSTRUCTIUNI: INSTRUCTIUNE ';'
	    | INSTRUCTIUNI INSTRUCTIUNE ';'
	    ;
	    
INSTRUCTIUNE:vartype IDENTIF { 
                                global=1;
                                if(verifdecl($2)== -1)
                                {
                                    declarare($2, $1,global,0);
                                } 
                                else 
                                {
                                    printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);
                                    yyerror();
                                } 
                                global=0;
                                }

	    | vartype ARRAY_IDENTIF {
                                    global=1; 
                                    if(verifdecl($2)== -1)
                                    {
                                        declarare($2, $1,global,0);
                                    } 
                                    else 
                                    {
                                        printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);
                                        yyerror();
                                    } 
                                    global=0;
                                }

	    | vartype IDENTIF ASSIGN INT_NUM {
                                            global=1; 
                                            if(verifdecl($2)== -1)
                                            {
                                                declarare($2, $1,global,0); 
                                                initializareINT($2,$4);
                                            } 
                                            else 
                                            {
                                                printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);
                                                yyerror();
                                            }
                                            global=0;
                                        }
	    
            | vartype IDENTIF ASSIGN REAL_NUM {global=1; if(verifdecl($2)== -1){declarare($2, $1,global,0);initializareFLOAT($2,$4);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype IDENTIF ASSIGN CHAR_VAL {global=1; if(verifdecl($2)== -1){declarare($2, $1,global,0);initializareCHAR($2,$4);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype IDENTIF ASSIGN STRING_VAL {global=1; if(verifdecl($2)== -1){declarare($2, $1,global,0);initializareSTRING($2,$4);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
	    | vartype CONSTANT IDENTIF ASSIGN INT_NUM {global=1; if(verifdecl($3)== -1){declarare($3, $1,global,1);initializareINT($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; }
	    
            | vartype CONSTANT IDENTIF ASSIGN REAL_NUM {global=1; if(verifdecl($3)== -1){declarare($3, $1,global,1);initializareFLOAT($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN CHAR_VAL {global=1; if(verifdecl($3)== -1){declarare($3, $1,global,1);initializareCHAR($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN STRING_VAL {global=1; if(verifdecl($3)== -1){declarare($3, $1,global,1);initializareSTRING($3,$5);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype IDENTIF ASSIGN IDENTIF {if(verifdecl($2)== -1){ declarare($2,$1,global, 0); if(verifdecl($2)!=-1 && verifdecl($4)!=-1){if(verifinit($4)== 1){copyVal($2,$4);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype IDENTIF ASSIGN ARRAY_IDENTIF {if(verifdecl($2)== -1){declarare($2,$1,global, 0); if(verifdecl($2)!=-1 && verifdecl($4)!=-1){if(verifinit($4)== 1){copyVal($2,$4);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$4,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN IDENTIF {if(verifdecl($3)== -1){global=1; declarare($3,$1,global, 0); if(verifdecl($3)!=-1 && verifdecl($5)!=-1){if(verifinit($5)== 1){copyVal($3,$5);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN ARRAY_IDENTIF {if(verifdecl($3)== -1){global=1; declarare($3,$1,global, 0); if(verifdecl($3)!=-1 && verifdecl($5)!=-1){if(verifinit($5)== 1){copyVal($3,$5);}else{printf("Variabila %s nu a fost initializata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila %s nu a fost declarata. Eroare la linia :%d\n",$5,yylineno);yyerror();}}else{printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | IDENTIF ASSIGN CHAR_VAL {global=1; if(verifdecl($1)!=-1){initializareCHAR($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | IDENTIF ASSIGN STRING_VAL {global=1; if(verifdecl($1)!=-1){initializareSTRING($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | IDENTIF ASSIGN EXPRESII  {if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}

    	    | ARRAY_IDENTIF ASSIGN CHAR_VAL {global=1; if(verifdecl($1)!=-1){initializareCHAR($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
    	    
            | ARRAY_IDENTIF ASSIGN STRING_VAL {global=1; if(verifdecl($1)!=-1){initializareSTRING($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
    	    | ARRAY_IDENTIF ASSIGN EXPRESII {if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
    	    
            | vartype IDENTIF ASSIGN APEL_FUNCTIE {declarare($2,$1,global, 0);}

            | vartype CONSTANT IDENTIF ASSIGN APEL_FUNCTIE  {declarare($3,$1,global, 1);}

            | vartype IDENTIF'[' IDENTIF ']' { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}

            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN INT_NUM { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN REAL_NUM { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN CHAR_VAL { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN STRING_VAL { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN IDENTIF { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN ARRAY_IDENTIF { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN APEL_FUNCTIE { global=1; if(verifdecl($2)== -1){char ceva[100]; ceva[0] = '\0'; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            |  IDENTIF'[' IDENTIF ']'  ASSIGN CHAR_VAL {  if(verifdecl($3)== -1){printf("Variabila %s nu a fost declarataEroare la linia :%d \n",$3,yylineno);yyerror();}}
            
            |  IDENTIF'[' IDENTIF ']'  ASSIGN STRING_VAL {  if(verifdecl($3)== -1){printf("Variabila %s nu a fost declarataEroare la linia :%d \n",$3,yylineno);yyerror();}} 
    	    
            |  IDENTIF'[' IDENTIF ']'  ASSIGN EXPRESII {  if(verifdecl($3)== -1){printf("Variabila %s nu a fost declarataEroare la linia :%d \n",$3,yylineno);yyerror();}}        
	    | APEL_FUNCTIE  
    	    | RETURN INT_NUM
            | RETURN REAL_NUM
            | RETURN CHAR_VAL
            | RETURN STRING_VAL
            | RETURN IDENTIF
            | RETURN ARRAY_IDENTIF
            | RETURN APEL_FUNCTIE
    	    | INIT_STRUCT
    	    | instrIF ';'
            | instrWHILE ';'
            | instrFOR ';'
            | PRINT '(' STRING_VAL ',' EXPRESII ')' 
            |  TYPEOF '(' IDENTIF ')' {printf("\n Variabila este de tipul : %s \n",typeOfff($3));}
            | evaluare
    	    ;

// bloc2 ==  body of a funtion 
BLOC2: INSTRUCTIUNI2
    ;
INSTRUCTIUNI2: INSTRUCTIUNE2';'
	    | INSTRUCTIUNI2 INSTRUCTIUNE2 ';'
	    ;
/// INSTRUCITUNILE PT CORPUL FUNCTIILOR 

INSTRUCTIUNE2:vartype IDENTIF { global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
	    
            | vartype ARRAY_IDENTIF {global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
	    
            | vartype IDENTIF ASSIGN INT_NUM {global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($2)!=-1){initializareINT($2,$4);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype IDENTIF ASSIGN REAL_NUM {global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($2)!=-1){initializareFLOAT($2,$4);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype IDENTIF ASSIGN CHAR_VAL {global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($2)!=-1){initializareCHAR($2,$4);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype IDENTIF ASSIGN STRING_VAL {global=2; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($2)!=-1){ initializareSTRING($2,$4); } else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
    
            | vartype IDENTIF ASSIGN IDENTIF {global=2; declarare($2,$1,global, 0); if(verifdecl($2)!=-1 && verifdecl($4)!=-1){if(verifinit($4)== 1){copyVal($2,$4);}else{printf("Variabila %s nu a fost initializara. Eroare la linia :%d\n",$4,yylineno);yyerror();}} global=0;}
            
            | vartype IDENTIF ASSIGN ARRAY_IDENTIF {global=2;declarare($2,$1,global, 0); if(verifdecl($2)!=-1 && verifdecl($4)!=-1){if(verifinit($4)== 1){copyVal($2,$4);}else{printf("Variabila %s nu a fost initializara. Eroare la linia :%d\n",$4,yylineno);yyerror();}}global=0;}
            
            | vartype IDENTIF ASSIGN APEL_FUNCTIE {declarare($2,$1,global, 0);}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN INT_NUM { global=2; if(verifdecl($2)== -1){char ceva[100]; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN REAL_NUM { global=2; if(verifdecl($2)== -1){char ceva[100]; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN CHAR_VAL { global=2; if(verifdecl($2)== -1){char ceva[100]; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN STRING_VAL { global=2; if(verifdecl($2)== -1){char ceva[100]; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN IDENTIF { global=2; if(verifdecl($2)== -1){char ceva[100]; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN ARRAY_IDENTIF { global=2; if(verifdecl($2)== -1){char ceva[100]; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype IDENTIF'[' IDENTIF ']'  ASSIGN APEL_FUNCTIE { global=1; if(verifdecl($2)== -1){char ceva[100]; strcat(ceva,$1); strcat(ceva, "  vector"); declarare($2, ceva,global,0);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} if(verifdecl($2)== -1){printf("Variabila %s nu a fost declarata",$4);}global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN INT_NUM {global=2; if(verifdecl($3)== -1){declarare($3, $1,global,1);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($3)!=-1){ initializareINT($3,$5); } else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN REAL_NUM {global=2; if(verifdecl($3)== -1){declarare($3, $1,global,1);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($3)!=-1){ initializareFLOAT($3,$5); } else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN CHAR_VAL {global=2; if(verifdecl($3)== -1){declarare($3, $1,global,1);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($3)!=-1){ initializareCHAR($3,$5); } else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN STRING_VAL {global=2; if(verifdecl($3)== -1){declarare($3, $1,global,1);} else {printf("Variabila a fost deja declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0; if(verifdecl($3)!=-1){ initializareSTRING($3,$5); } else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN IDENTIF {global=2; declarare($3,$1,global, 0); if(verifdecl($3)!=-1 && verifdecl($5)!=-1){if(verifinit($5)== 1){copyVal($3,$5);}else{printf("Variabila %s nu a fost initializara. Eroare la linia :%d\n",$5,yylineno);yyerror();}}global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN ARRAY_IDENTIF {global=2; declarare($3,$1,global, 0); if(verifdecl($3)!=-1 && verifdecl($5)!=-1){if(verifinit($5)== 1){copyVal($3,$5);}else{printf("Variabila %s nu a fost initializara. Eroare la linia :%d\n",$5,yylineno);yyerror();}}global=0;}
            
            | vartype CONSTANT IDENTIF ASSIGN APEL_FUNCTIE  {declarare($3,$1,global, 1);}
	    
            | IDENTIF ASSIGN CHAR_VAL { if(verifdecl($1)!=-1){initializareCHAR($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} }
            
            | IDENTIF ASSIGN STRING_VAL { if(verifdecl($1)!=-1){initializareSTRING($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} }
    	    
            | ARRAY_IDENTIF ASSIGN CHAR_VAL {if(verifdecl($1)!=-1){initializareCHAR($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();} }
            
            | ARRAY_IDENTIF ASSIGN STRING_VAL { if(verifdecl($1)!=-1){initializareSTRING($1,$3);} else{printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
            
            |  IDENTIF'[' IDENTIF ']'  ASSIGN CHAR_VAL {  if(verifdecl($3)== -1){printf("Variabila %s nu a fost declarataEroare la linia :%d \n",$3,yylineno);yyerror();}}
            
            |  IDENTIF'[' IDENTIF ']'  ASSIGN STRING_VAL {  if(verifdecl($3)== -1){printf("Variabila %s nu a fost declarataEroare la linia :%d \n",$3,yylineno);yyerror();}}
            
            | IDENTIF ASSIGN EXPRESII  {if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
    	    
            | ARRAY_IDENTIF ASSIGN EXPRESII {if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
    	    
            |  IDENTIF'[' IDENTIF ']'  ASSIGN EXPRESII {  if(verifdecl($3)== -1){printf("Variabila %s nu a fost declarataEroare la linia :%d \n",$3,yylineno);yyerror();}} 
            | APEL_FUNCTIE  
            | RETURN INT_NUM
            | RETURN REAL_NUM
            | RETURN CHAR_VAL
            | RETURN STRING_VAL
            | RETURN IDENTIF
            | RETURN ARRAY_IDENTIF
            | RETURN APEL_FUNCTIE
            | INIT_STRUCT
            | instrIF ';'
            | instrWHILE ';'
            | instrFOR ';'
            | PRINT '(' STRING_VAL ',' EXPRESII ')' 
            |  TYPEOF '(' IDENTIF ')' {printf("\n Variabila este de tipul : %s \n",typeOfff($3));}
            | evaluare
    	    ;

// INITIALIZARE CLASS/ STRUCTURA
INIT_STRUCT: IDENTIF '.' ARRAY_IDENTIF ASSIGN EXPRESII //{global=1; if(verifdecl($2)== -1){declarare($2, $1,global,0);} else {printf("Variabila a fost deja declarata\n");} global=0; if(verifdecl($2)!=-1){initializareINT($2,$4);} else{printf("Variabila nu a fost declarata\n");} global=0;}
	   | IDENTIF '.' IDENTIF ASSIGN EXPRESII // INITIALIZARE CLASS/ STRUCTURA
	   | ARRAY_IDENTIF '.' IDENTIF ASSIGN EXPRESII // INITIALIZARE CLASS/ STRUCTURA
	   | ARRAY_IDENTIF '.' ARRAY_IDENTIF ASSIGN EXPRESII // INITIALIZARE CLASS/ STRUCTURA
    	   ;
    	   
instrFOR: FOR '(' exprFOR1 ',' exprFOR2 ',' exprFOR3 ')'  DO '{' BLOC '}'
        ;

exprFOR1: IDENTIF ASSIGN INT_NUM
        | IDENTIF ASSIGN REAL_NUM
        | IDENTIF ASSIGN CHAR_VAL
        | IDENTIF ASSIGN STRING_VAL
        | IDENTIF ASSIGN IDENTIF
        | IDENTIF ASSIGN ARRAY_IDENTIF
        | IDENTIF ASSIGN APEL_FUNCTIE
        ;

exprFOR2: EXPRESII  GRT  EXPRESII 
        | EXPRESII  LESS  EXPRESII 
        | EXPRESII  GRTEQ EXPRESII
        | EXPRESII  LESSEQ  EXPRESII
        ;

exprFOR3: IDENTIF ASSIGN  EXPRESII
        ;

instrIF: IF '(' listaexprIF ')' DO '{' BLOC'}' 
       | IF '(' listaexprIF ')' DO '{' BLOC '}' ELSE '{' BLOC '}'
       ;

listaexprIF: expresieIF AND listaexprIF
           | expresieIF OR listaexprIF
           | expresieIF
           ;

expresieIF: EXPRESII  EQ  EXPRESII
          | EXPRESII  GRT  EXPRESII
          |EXPRESII  LESS  EXPRESII
          | EXPRESII  GRTEQ  EXPRESII 
          | EXPRESII  NOT EQ  EXPRESII 
          | EXPRESII  LESSEQ  EXPRESII 
          ;

instrWHILE: WHILE '(' listaexprWHILE ')' DO '{' BLOC '}'
          ;
         
listaexprWHILE: expresieWHILE AND listaexprWHILE
              | expresieWHILE OR listaexprWHILE
              | expresieWHILE 
              ;

expresieWHILE: EXPRESII   EQ  EXPRESII
          | EXPRESII   GRT  EXPRESII 
          | EXPRESII   LESS  EXPRESII 
          | EXPRESII   GRTEQ  EXPRESII 
          | EXPRESII   NOT EQ EXPRESII 
          | EXPRESII   LESSEQ  EXPRESII 
          ;

EXPRESIE : EXPRESIE  '+' EXPRESIE  {$<intTyp>$ = $1 + $3;}
	  | EXPRESIE  '-' EXPRESIE {$$ = $1 - $3;}
	  | EXPRESIE '*' EXPRESIE  {$$ = $1 * $3;}
	  | EXPRESIE  '/' EXPRESIE {$$ = $1 / $3;}
          | EXPRESIE  '%' EXPRESIE {$$ = $1 % $3;}
	   |'(' EXPRESIE ')' {$$ = $2; }
          | INT_NUM {$<intTyp>$ = $1;}
          | REAL_NUM {$$ = $1;}
          | IDENTIF {$$ = $1;if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}} 
          | ARRAY_IDENTIF {$$ = $1;if(verifdecl($1)==-1){printf("Variabila nu a fost declarata. Eroare la linia :%d \n", yylineno);yyerror();}}
          | IDENTIF'[' IDENTIF ']' {  if(verifdecl($3)== -1){printf("Variabila %s nu a fost declarata. Eroare la linia :%d \n",$3,yylineno);yyerror();}}
        ;

evaluare: EVAL '(' EXPRESIE_EVAL ')' {printf("Expresia trimisa la linia %d are valoarea: %d\n",yylineno, evalAST($3));}


EXPRESIE_EVAL : '(' EXPRESIE_EVAL ')'  		 {$$ = $2;}
	| EXPRESIE_EVAL '+' EXPRESIE_EVAL   	 {union value x; x.charVal = $<charval>2; $$ = buildAST(x,$1,$3,1); printf("adaugat nodul interior: +\n");}
    | EXPRESIE_EVAL '-' EXPRESIE_EVAL   	 {union value x; x.charVal = $<charval>2; $$ = buildAST(x,$1,$3,2); printf("adaugat nodul interior: -\n");}
    | EXPRESIE_EVAL '*' EXPRESIE_EVAL  		 {union value x; x.charVal = $<charval>2; $$ = buildAST(x,$1,$3,3); printf("adaugat nodul interior: *\n");}
    | EXPRESIE_EVAL '/' EXPRESIE_EVAL   	 {union value x; x.charVal = $<charval>2; $$ = buildAST(x,$1,$3,4); printf("adaugat nodul interior: /\n");}
    /* | EXPRESIE_EVAL '^' EXPRESIE_EVAL     	 {union value x; x.charVal = $<charval>2; $$ = buildAST(x,$1,$3,5); printf("adaugat noduri: %s, ^, %s\n", $1, $3);} */
    | INT_NUM				 {union value x; x.intVal = $1; $$ = buildAST(x,NULL,NULL,6); printf("am bagat frunza %d\n", $1);}
	| IDENTIF				 {union value x; strcpy(x.strVal, $1); $$ = buildAST(x,NULL,NULL,7);printf("am bagat frunza %s\n", $1);}


adunare: adunare '+' adunare {$$=$3;}
        | INT_NUM {$$=$1;}
        ; 


EXPRESII: EXPRESIE    
| EXPRESII EXPRESIE    
;



%%

int errors_occurred = 0;

int yyerror(char * s) {
    errors_occurred++;   
    printf("%s %d %s %d\n","Syntax ERROR:", errors_occurred, " errors occurred! Current error at line: ", yylineno);
   // printf("%s\n", s);
}

int main(int argc, char** argv) {

    yyin=fopen(argv[1],"r");

    yyparse();
    clear_table();
    tabel_sim();
    clear_table2();
    tabel_fun();
    
    if (errors_occurred == 0) {
        printf("-------------------------------------------------------------------------\n"); 
        printf("\n\nNo errors occurred !!! :D \n\n\n"); 
        printf("-------------------------------------------------------------------------\n"); 
    }
}

