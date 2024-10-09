%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<ctype.h>

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;

    void yyerror (char *s) 
    {
        fprintf (stdout, "%s\n", s);
    }

    struct table
    {
        char name[10];
        int val;
    } syms[53];

    int SIZE_OF_ID_TABLE = 0;

    typedef struct
    {
        char str[1024];
        int number;
    } YYSTYPE;
    #define YYSTYPE YYSTYPE

%}

%token ID NUMBER STRING PROGRAM END_PROGRAM VAR END_VAR IF END_IF ELSIF ELSE THEN REPEAT UNTIL END_REPEAT WHILE END_WHILE FOR END_FOR INT NOTEQUAL ASSIGN TO BY DO

%type<str> ID NUMBER STRING OPERATIONS OPERATION_TYPE1 OPERATION_TYPE2 OPERATION EXPRESSION EXPRESSION_TYPE1 EXPRESSION_TYPE2 TERM VALUE PROG DECLARATION ASSIGNMENT

%start PROG

%%

PROG: PROGRAM OPERATIONS END_PROGRAM                                        		{ printf("PROG\n"); fprintf(yyout, "%s", $2); }
;

OPERATIONS:                                                                 		{ printf("memo."); } 
|       OPERATION                                                           		{ printf("OPERATION\t | %s\n", $1); strcpy($$, $1); }
|       OPERATIONS OPERATION                                                		{ printf("OPERATIONS OPERATION\t | %s /// %s\n", $1, $2); strcpy($$,$1); strcat($$,$2); }
;

OPERATION_BASIC:                                           
|       ASSIGN                                                          			{ printf("ASSIGNMEN\t | %s\n", $1); strcpy($$, $1); }
|       EXPRESSION ';'                                                      		{ printf("EXPRESSION ';'\t | %s\n", $1); strcpy($$, $1); strcat($$, ";\n"); }
|       IF EXPRESSION THEN OPERATION_BASIC ELSE OPERATION_BASIC END_IF ';'  		{ printf("IF EXPRESSION THEN OPERATION_BASIC ELSE OPERATION_BASIC\t | if(%s) {%s} else {%s}\n",$2,$4,$6); strcpy($$, "if ("); strcat($$, $2); strcat($$, "){\n"); strcat($$, $4); strcat($$, "} else {\n"); strcat($$, $6); strcat($$, "}\n"); }
|       WHILE EXPRESSION OPERATION_BASIC END_WHILE                          		{ printf("WHILE EXPRESSION OPERATION_BASIC END_WHILE\t | while(%s) {%s}\n",$2,$3); strcpy($$, "while ("); strcat($$, $2); strcat($$, ") {\n"); strcat($$, $3); strcat($$, "}\n"); }
|       FOR ASSIGN TO EXPRESSION_TYPE2 BY EXPRESSION_TYPE2 DO OPERATION_BASIC   	{ printf("FOR\t | for(%s ; %s ; %s) {%s}\n",$2,$4,$6,$8); strcpy($$, "for ("); strcat($$, $2); strcat($$, "; "); strcat($$, $4); strcat($$, "; "); strcat($$, $6); strcat($$, ") {\n"); strcat($$, $8); strcat($$, "}\n"); }
|       REPEAT OPERATION_BASIC UNTIL EXPRESSION ';' END_REPEAT ';'          		{ printf("REPEAT\t | do{%s} while (%s)\n",$2,$4); strcpy($$, "do {\n");  strcat($$, $2); strcat($$, "} while ("); strcat($$, $4); strcat($$, ");\n"); }
;

OPERATION_COMPL:    IF EXPRESSION THEN OPERATION END_IF                     		{ printf("IF EXPRESSION THEN OPERATION\t | if(%s){%s}\n",$2,$4); strcpy($$, "if ("); strcat($$, $2); strcat($$, "){\n"); strcat($$, $4); strcat($$, "}\n"); }
|       IF EXPRESSION THEN OPERATION_BASIC ELSE OPERATION_COMPL END_IF ';'  		{ printf("IF EXPRESSION THEN OPERATION_BASIC ELSE OPERATION_COMPL\t | if(%s){%s} else {%s}\n",$2,$4,$6); strcpy($$, "if ("); strcat($$, $2); strcat($$, "){\n"); strcat($$, $4); strcat($$, "} else {\n"); strcat($$, $6); strcat($$, "}\n"); }
|       WHILE EXPRESSION DO OPERATION_COMPL END_WHILE                       		{ printf("WHILE EXPRESSION DO OPERATION_COMPL END_WHILE\t | while(%s){%s}\n",$2,$4); strcpy($$, "while ("); strcat($$, $2); strcat($$, "){\n"); strcat($$, $4); strcat($$, "}\n");}

;

OPERATION:     OPERATION_BASIC                                              		{ printf("OPERATION_BASIC\t | %s\n", $1); }
|       OPERATION_COMPL                                                    		 	{ printf("OPERATION_COMPL\t | %s\n", $1); }
|       VAR DECLARATION END_VAR                                             		{ printf("VAR DECLARATION END_VAR\t | %s\n", $2); strcpy($$, $2); }
;

DECLARATION: ID ':' INT ';'                                              			{ printf("ID ':' INT ';'\t | int %s;\n", $1); strcpy($$, "int "); strcat($$, $1); strcat($$, ";\n"); }
;

ASSIGN: ID ASSIGN EXPRESSION                                            			{ printf("ID ASSIGN EXPRESSION\t | %s = %s\n", $1, $3); strcpy($$, $1); strcat($$, "="); strcat($$, $3); }
;

EXPRESSION:   EXP_L                                              					{ printf("EXP_L\t | %s\n", $1);strcpy($$,$1); }
|       ASSIGN                                                          			{  printf("ASSIGN\t | %s\n", $1);strcpy($$, $1); }
|       ID '=' EXP_L                                             					{  printf("ID '=' EXP_L\t | %s = %s\n", $1, $3); strcpy($$, $1); strcat($$, "="); strcat($$, $3); }
;

EXP_L:  EXP_H                                         								{  printf("EXP_H\t | %s\n"); strcpy($$,$1); }
|       EXP_L NEQ EXP_H                          									{  printf("EXP_L NEQ EXP_H\t | %s != %s\n", $1, $3);strcpy($$,$1); strcat($$, "!="); strcat($$, $3); }
;

EXP_H:  TERM                                                     					{ printf("TERM\t | %s\n", $1); }
|       EXP_H '+' TERM                                           					{  printf("EXP_H '+' TERM\t | %s + %s\n", $1, $3);strcpy($$,$1); strcat($$, "+"); strcat($$, $3); }
|       EXP_H '-' TERM                                           					{ printf("EXP_H '-' TERM\t | %s - %s\n", $1, $3); strcpy($$,$1); strcat($$, "-"); strcat($$, $3); }
;

TERM:   VALUE                                 
|       TERM '*' VALUE                                                      		{ printf("TERM '*' VALUE\t | %s * %s\n", $1, $3); strcpy($$,$1); strcat($$, "*"); strcat($$, $3); }
|       TERM '/' VALUE                                                      		{ printf("TERM '/' VALUE\t | %s / %s\n", $1, $3); strcpy($$,$1); strcat($$, "/"); strcat($$, $3); }
;

VALUE:  NUM                                                              			{ printf("NUM\t | %s\n", $1); strcpy($$,$1); }
|       '-' VALUE                                                           		{ printf("'-' VALUE\t | -%s\n", $2); strcpy($$,"-"); strcat($$, $2); }
|       '(' EXPRESSION ')'                                                  		{ printf(" '(' EXPRESSION ')' \t | %s\n", $2); strcpy($$, $2); }
|       ID                                                                  		{ printf("ID \t | %s\n",$1); strcpy($$, $1); }
;

%%
int main() { 
    yyin = fopen("in.txt","r");
    yyout = fopen("out.txt","w");
	fprintf(yyout, "int main(){\n");
    yyparse();
	fprintf(yyout, "}");	
    fclose(yyin);
    fclose(yyout);  
    printf("file \"out.txt\" contains the final program.\n");
}