%{

   typedef struct
   {
      char data[1024];
   } string;

   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>

   #define YYSTYPE string
   void yyerror(char *s);
   #include "y.tab.h"
%}

%option yylineno

%%

"PROGRAM"          {    return PROGRAM;     	}
"END_PROGRAM"      {    return END_PROGRAM;     }
"VAR"              {    return VAR;    			}
"END_VAR"          {    return END_VAR;    		}
"IF"               {    return IF;     			}
"END_IF"           {    return END_IF;    		}
"ELSIF"            {    return ELSIF;    		}
"ELSE"             {    return ELSE;   			}
"THEN"             {    return THEN;   			}
"REPEAT"           {    return REPEAT;     		}
"UNTIL"            {    return UNTIL;     		}
"END_REPEAT"       {    return END_REPEAT;     	}
"WHILE"            {    return WHILE;     		}
"END_WHILE"        {    return END_WHILE;     	}
"FOR"              {    return FOR;     		}
"TO"               {    return TO; 				}
"BY"               {    return BY; 				}
"END_FOR"          {    return END_FOR;     	}
"INT"              {    return INT;    			}
"<>"               {    return NEQ; 			}
":="               {    return ASSIGN; 			}
[0-9]+             { 
					   strcpy(yylval.data, yytext);
					   return NUM;
                   }
[a-z]([a-z]|[0-9])*{ 
					   strcpy(yylval.data, yytext); 
					   return ID;
				   } 
[- + ; ( ) ! * / = < > { } % ? : .]    {  return *yytext;  }
[ \t\n]              ;
%%

int yywrap()
{
   return 1;
}
