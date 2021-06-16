%{
#include "y.tab.h"

%}

%%

"curtle, come!"                     {
                                      return FORWARD;
                                    }
"curtle, go!"                       {
                                      return BACKWARD;
                                    }
"curtle, say "                      {
                                      return SAY;
                                    }
"curtle, float "[1-9]+[0-9]*        {
                                      char s[100];
                                      strcpy(s, yytext + 14);
                                      yylval.n = atoi(s);
                                      return FLOATN;
                                    }
"curtle, tell me "[a-z]*[A-Z]*           {
                                            char s[100] = "";
                                            strcpy(s, yytext + 8);
                                            yylval.subject = strdup(s);
                                            return TELLME;
                                          }
"curtle, teach me "[a-z]*[A-Z]*[ ]*[a-z]*[A-Z]*   {
                                                    char s[100];
                                                    strcpy(s, yytext+17);
                                                    yylval.subject = strdup(s);
                                                    return TEACH;
                                                  }
"my values"                     {
                                  return MY_VALUES;
                                }
"explain"                       {
                                  return EXPLAIN;
                                }
"practice"                      {
                                  return PRACTICE;
                                }
"yes"                           {
                                  yylval.answer = strdup(yytext);
                                  return ANSWER;
                                }
"no"                            {
                                  yylval.answer = strdup(yytext);
                                  return ANSWER;
                                }
"curtle, test me"               {
                                  return TEST;
                                }
sqrt                            {
                                  return SQRT;
                                }
[a-z]*[A-Z]*                    {
                                   yylval.subject = strdup(yytext);
                                   return TEST_RESPONSE;
                                }       
"{"                             { 
                                  return START; 
                                }
"}"                             { 
                                  return END; 
                                }
" "                             {
                                  return SPACE;
                                }
"-"                             {
                                  return SUBTRACT;
                                }        
"+"                             {
                                  return ADD;
                                }  
"/"                             {
                                  return DIVIDE;
                                }  
"*"                             {
                                  return MULTIPLY;
                                }  
"%"                             {
                                  return MODULO;
                                }
[1-9]+[0-9]*                    {
                                  yylval.value = atoi(yytext);
                                  return VALUE;
                                }
\n                  {
                        return *yytext;
                    }
.                   {
                        return *yytext;
                    }
%%