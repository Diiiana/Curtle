%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "math.h"
#include "cueue.c"
#include "XML2C.c"

extern int yylex();
void yyerror(char* s);
void curtle_knowledge();

int start = 0, is_set1 = 0, is_set2 = 0;
int testQuestion = 0, testing = 0, score = 0, printed = 0;
int* set1;
int* set2;
int* indice;
int set1_size = 0, set2_size = 0;
char *currentlyTeaching = NULL;

struct Queue *curtleQueue;
struct XML_nodeList *knowledge;
struct XML_test *test;

void welcome();
void bye();
void teach_me(char *subj);
void practice();
void reunion();
void intersect();
void exclude();
void cartesian();
void about_set();
void free_sets();
void searchResponse(char* givenResponse);
void explain();
void tell_me(char* subj);
int prime_number(int val);
void set_indices();

%}

%union {
            int n;
            int value;
            char* operatie;
            char* subject;
            char* answer;
       }

%token FORWARD BACKWARD SAY MY_VALUES SPACE EXPLAIN PRACTICE START END TEST

%token<operatie> ADD SUBTRACT MULTIPLY DIVIDE MODULO SQRT

%type<value> math_result
%token<value> VALUE
%token<n> FLOATN

%token<subject> TEACH 
%token<subject> TELLME
%token<answer> ANSWER
%token<answer> TEST_RESPONSE
%nonassoc SQRT
%left ADD SUBTRACT
%left MULTIPLY DIVIDE MODULO
%left '(' ')'

%%
program: program input
       | /*empty*/
       ;

input: '\n' { printf("\n"); }
     | statement
     ;

statement: FORWARD                {
                                    start = 1;  
                                    welcome();
                                   }
         | inbetween              {
                                if(!start){
                                    yyerror("\n      > You did not call curtle!\n");
                                }
                            }
         | BACKWARD          { 
                                start = 0;
                                printf("Curtle leaves!\n");
                                bye();   
                             }
         ;

inbetween: SAY math_result    { 
                                if(start){
                                    printf(" ___   _\n");
                                    printf("/___\\/_'|..result is: |_%d_|\n", $2);
                                    printf("() ()\n\n");
                                }
                             }
         | FLOATN '\n' numbers   { if(start){
                                       printf("     > cast up %d values\n", $1);
                                   }
                                 }
         | teaching
         | MY_VALUES            {
                                    if(start){
                                        print(curtleQueue);
                                    }
                                }   
         | TELLME               {
                                    if(start){
                                        tell_me($1);
                                    }
                                }
         | set_operation '\n'
         | test                {
                                    if(start){
                                        if(testQuestion < 5 && testing){
                                            printf("        >%s\n", test->questions[indice[testQuestion]]->text);
                                            testQuestion++;
                                        }else{
                                            testQuestion = 0;
                                            score = 0;
                                            testing = 0;
                                        }
                                    }
                                }
         ;

test: TEST '\n'               {   
                                if(start){
                                    if(testQuestion > 0){
                                        free(indice);
                                    }
                                    set_indices();
                                    testing = 1;
                                    testQuestion = 0;
                                    printf("                        > TEST <                \n");
                                    printf("        >%s\n", test->questions[indice[testQuestion]]->text);
                                    testQuestion++;
                                }
                              }
    | test TEST_RESPONSE '\n' {
                                    if(start){
                                        if(strcmp($2, test->questions[indice[testQuestion-1]]->correct) == 0){
                                            score += 20;
                                        }
                                        if(testQuestion < 5){
                                            printf("        >%s\n", test->questions[indice[testQuestion]]->text);
                                            testQuestion++;
                                        }else{
                                            printf("        > final score is %d/100\n", score);
                                            testQuestion = 0;
                                            score = 0;
                                            testing = 0;
                                        }
                                    }
                                }
    | test ANSWER '\n'          {  
                                    if(start){
                                        if(strcmp($2, test->questions[testQuestion-1]->correct) == 0){
                                            score += 20;
                                        }
                                        if(testQuestion < 5){
                                            printf("        >%s\n", test->questions[testQuestion]->text);
                                            testQuestion++;
                                        }else{
                                            printf("        > final score is %d/100\n", score);
                                            testQuestion = 0;
                                            score = 0;
                                            testing = 0;
                                        }
                                    }
                                }
    ;

set_operation: set ADD set  {
                                if(start){
                                    reunion();
                                }
                            }
             | set '|' set  {
                                    if(start){
                                        intersect();
                                    }
                                }
             | set DIVIDE set  {
                                    if(start){
                                        exclude();
                                    }
                                }
             | set 'x' set      {
                                    if(start){
                                        cartesian();
                                    }
                                }
             | set              {
                                    if(start){
                                        if(!testing){
                                            about_set();
                                        }
                                    }
                                }
             ;

set: START END
   | START set END      {   
                            is_set2 = 1;
                            is_set1 = 1;
                            if(set2_size == 0){
                                set2 = (int*)malloc(100*sizeof(int));
                            }
                        }
   | VALUE ',' set      {
                            if(is_set1 == 0){                    
                                set1[set1_size] = $1;
                                set1_size++;
                            }else{
                                if(is_set2 == 1){
                                    set2[set2_size] = $1;
                                    set2_size++;
                                }
                            }
                        }
   | VALUE              {
                            if(is_set1 == 0){
                                if(set1_size == 0){
                                    set1 = (int*)malloc(100*sizeof(int));
                                }
                                set1[set1_size] = $1;
                                set1_size++;
                            }else{
                                if(is_set2 == 1){
                                    set2[set2_size] = $1;
                                    set2_size++;
                                }
                            }
                        }
   ;

        
teaching: TEACH '\n'           {
                                if(start){
                                    char* s = strdup($1);
                                    currentlyTeaching = (char*)malloc((sizeof(s)+1)*sizeof(char));
                                    strcpy(currentlyTeaching, s);
                                    teach_me($1);
                                }else{
                                    yyerror("\n      > You did not call curtle!\n");
                                }
                            }
        | teaching PRACTICE '\n' {   if(start){
                                        printf("        > %s\n", currentlyTeaching);
                                        if(strlen(currentlyTeaching) < 1 || currentlyTeaching == NULL){
                                            printf("      > but what are we learning?\n");
                                        }else{
                                            practice();
                                        }
                                     }
                                }
        | teaching ANSWER '\n' {
                                    if(start){
                                        searchResponse($2);
                                    }
                                }
        | teaching EXPLAIN '\n' {
                                    if(start){
                                        if(strlen(currentlyTeaching) < 1){
                                            printf("      > but what are we learning?\n");
                                        }else{
                                            explain();
                                        }
                                    }
                                }
        ;

math_result: math_result ADD math_result   { 
                                                if(start){
                                                    $$ = $1 + $3; 
                                                }  
                                            }
           | math_result SUBTRACT math_result   { 
                                                if(start){
                                                    $$ = $1 - $3; 
                                                }  
                                            }
           | math_result MULTIPLY math_result   { 
                                                if(start){
                                                    $$ = $1 * $3; 
                                                }  
                                            }
           | math_result DIVIDE math_result   { 
                                                if(start){
                                                    $$ = $1 / $3; 
                                                }  
                                            }
           | math_result MODULO math_result   { 
                                                if(start){
                                                    $$ = $1 % $3; 
                                                }  
                                            }
           | SQRT math_result               { 
                                                if(start){
                                                    $$ = sqrt($2); 
                                                }  
                                            }
           | '(' math_result ')'            { 
                                                if(start){
                                                    $$ = $2; 
                                                }  
                                            }
           | VALUE                          { 
                                                if(start){
                                                    $$ = $1; 
                                                }  
                                            }
           ;

numbers: VALUE                 {
                                    if(start){
                                        enqueue(curtleQueue, $1);
                                    }
                               }
       | VALUE SPACE numbers   {    
                                   if(start){
                                       enqueue(curtleQueue, $1);
                                    }
                                }
       ;
      
%%

void welcome(){
    printf("Welcome to Curtle!\n");
    printf("                      _____     ____\n");
    printf("                     /     \\  |  o |\n"); 
    printf("                    |        |/___\\| how can I help?\n"); 
    printf("                    |_________/\n");     
    printf("                    |_|_| |_|_|\n"); 
}

void bye(){
    printf("                         ___\n");
    printf("                     ,,//   \\\\\n");
    printf("                    (_.\\/ \\_/ \\\n");
    printf("                Bye!  \\ \\_/_\\_/ >\n");
    printf("                       /_/  /_/\n");
}

void teach_me(char* subj){
    for(int i = 0; i < knowledge->size; i++){
        if(strcmp(knowledge->data[i]->about, subj) == 0){
            printf("        > %s\n", knowledge->data[i]->about);
            printf("%s\n", knowledge->data[i]->definition);
            break;
        }
    }
}

void practice(){
    for(int i = 0; i < knowledge->size; i++){
        if(strcmp(knowledge->data[i]->about, currentlyTeaching) == 0){
            printf("%s\n", knowledge->data[i]->test);
            break;
        }
    }
}

void reunion(){
    int reunion_size = 0;
    int *reunion = (int *)malloc((set1_size+set2_size+1)*sizeof(int));

    for(int i = set1_size-1; i>= 0; i--){
        reunion[reunion_size] = set1[i];
        reunion_size++;
    }
    reunion_size = set1_size;

    for(int i = set2_size-1; i>= 0; i--){
        int ok = 1;
        for(int j = 0; j < reunion_size; j++){
            if(reunion[j] == set2[i]){
                ok = 0;
            }
        }

        if(ok){
            reunion[reunion_size] = set2[i];
            reunion_size++;
        }
    }

    printf("        > Union is: {");
    for(int i = 0; i < reunion_size; i++){
        if(i != reunion_size-1){
            printf("%d,", reunion[i]);
        }else{
            printf("%d}\n", reunion[i]);
        }
    }
    free(reunion);
    free_sets();
}

void intersect(){
    int ints_size = 0;
    int *inters = (int *)malloc((set1_size+1)*sizeof(int));

    for(int i = set1_size-1; i>= 0; i--){
        for(int j = set2_size-1; j>= 0; j--){
            if(set1[i] == set2[j]){
                inters[ints_size] = set1[i];
                ints_size++;
            }
        }
    }

    printf("        > Intersection is: {");
    for(int i = 0; i < ints_size; i++){
        if(i != ints_size-1){
            printf("%d,", inters[i]);
        }else{
            printf("%d}\n", inters[i]);
        }
    }
    free(inters);
    free_sets();
}

void exclude(){

    int excl_size = 0;
    int *excl = (int *)malloc((set1_size+1)*sizeof(int));

    for(int i = set1_size-1; i>= 0; i--){
        int ok = 1;
        for(int j = set2_size-1; j>= 0; j--){
            if(set1[i] == set2[j]){
                ok = 0;
            }
        }
        if(ok){
            excl[excl_size] = set1[i];
            excl_size++;
        }
    }

    printf("        > Differention is: {");
    for(int i = 0; i < excl_size; i++){
        if(i != excl_size-1){
            printf("%d,", excl[i]);
        }else{
            printf("%d}\n", excl[i]);
        }
    }
    free(excl);
    free_sets();
}

void explain(){
    for(int i = 0; i < knowledge->size; i++){
        if(strcmp(knowledge->data[i]->about, currentlyTeaching) == 0){
            printf("%s\n", knowledge->data[i]->explain);
            break;
        }
    }
}

void cartesian()
{
    printf("        > cartesian product is:");
    for(int i = set1_size-1; i>= 0; i--){
        for(int j = set2_size-1; j>= 0; j--){
            if(!(i==0 && j==0)){
                printf("{%d, %d}, ", set1[i], set2[j]);
            }else{
                printf("{%d, %d}\n", set1[i], set2[j]);
            }
        }
    }
    printf("\n");
    free_sets();
}

void about_set(){
    if(set1_size == 0){
        printf("        > empty set\n");
    }else{
        if(set1_size == 1){
            printf("        > singleton set\n");
        }else{
            char* result = (char*)malloc((200 + curtleQueue->size)*sizeof(char));
            strcpy(result, "duplicates: ");
            for(int i = set1_size; i >= 0; i--){
                for(int j = i-1; j >= 0; j--){
                    if(set1[i] == set1[j]){
                        char *s = (char *)malloc(100*sizeof(char));
                        sprintf(s, "%d", set1[j]);
                        strncat(result, s, strlen(s));
                        free(s);
                    }
                }
            }
            if(strlen(result) > 12){
                printf("        > not a valid set\n");
                printf("            %s\n", result);
            }else{
                printf("        > valid set\n");
                printf("        > cardinality is |S| = %d\n", set1_size);
            }
            
        }
    }
    free_sets();
}

void free_sets(){
    if(set1_size != 0){
        set1_size = 0;
        free(set1);
    }
    if(set2_size != 0){
        set2_size = 0;
        free(set2);
    }
    is_set1 = 0;
    is_set2 = 0;
}

void searchResponse(char* givenResponse){
    for(int i = 0; i < knowledge->size; i++){
        if(strcmp(knowledge->data[i]->about, currentlyTeaching) == 0){
            if(knowledge->data[i]->solution[strlen(knowledge->data[i]->solution)-3]=='s' && strcmp(givenResponse, "yes") != 0){
                printf("        > that's not correct :(\n");
            }else{
                if(knowledge->data[i]->solution[strlen(knowledge->data[i]->solution)-3]=='o' && strcmp(givenResponse, "no") != 0){
                    printf("        > that's not correct :(\n");
                }else{
                    printf("        > you're right! congrats!\n");
                }
            }
            break;
        }
    }
}

int prime_number(int val){
    if(val == 1 || val == 0){
        return 0;
    }
    for(int i = 2; i <= val/2; i++){
        if(val%i == 0){
            return 0;
        }
    }
    return 1;
}

char* set_verification(){
    char* result = (char*)malloc((200 + curtleQueue->size)*sizeof(char));
    strcpy(result, "duplicates: ");
    for(int i = 0; i < curtleQueue->size - 1; i++){
        for(int j = i+1; j < curtleQueue->size; j++){
            if(curtleQueue->elements[i] == curtleQueue->elements[j]){
                char *s = (char *)malloc(100*sizeof(char));
                sprintf(s, "%d", curtleQueue->elements[i]);
                strncat(result, s, strlen(s));
                free(s);
            }
        }
    }
    return result;
}

void tell_me(char *subj){
    if(curtleQueue->size < 1){
        printf("        > no floating values :(\n");
    }else{
        if(strstr(subj, "prime") != NULL){
            printf("        > you have: ");
            int ok = 0;
            for(int i = curtleQueue->size-1; i >= 0; i--){
                if(prime_number(curtleQueue->elements[i])){
                    printf("%d ", curtleQueue->elements[i]);
                    ok = 1;
                }
            }
            if(!ok){
                printf("no prime numbers\n");
            }else{
                printf("as prime numbers\n");
            }
        }else{
            if(strstr(subj, "odd") != NULL){
                printf("        > you have: ");
                int ok = 0;
                for(int i = curtleQueue->size-1; i >= 0; i--){
                    if(curtleQueue->elements[i]% 2 !=0 ){
                        printf("%d ", curtleQueue->elements[i]);
                        ok = 1;
                    }
                }
                if(!ok){
                    printf("no odd numbers\n");
                }else{
                    printf(" as odd numbers\n");
                }
            }else{
                if(strstr(subj, "even") != NULL){
                    printf("        > you have: ");
                    int ok = 0;
                    for(int i = curtleQueue->size-1; i >= 0; i--){
                        if(curtleQueue->elements[i]% 2 == 0){
                            printf("%d ", curtleQueue->elements[i]);
                            ok = 1;
                        }
                    }
                    if(!ok){
                        printf("no even numbers\n");
                    }else{
                        printf(" as even numbers\n");
                    }
                }else{
                    if(strstr(subj, "set") != NULL){
                        char *str = set_verification();
                        if(strcmp(str, "duplicates: ") == 0){
                            printf("        > is set");
                        }else{
                            printf("        >%s\n", str);
                        }
                    }else{
                        int ok = 0;
                        printf("        > you have: ");
                        for(int i = curtleQueue->size-1; i >= 0; i--){
                            int cop = curtleQueue->elements[i];
                            int palindrome = 0;
                            while(cop > 0){
                                palindrome = cop%10;
                                cop /= 10;
                            }
                            if(palindrome == curtleQueue->elements[i]){
                                printf("%d ", curtleQueue->elements[i]);
                                ok = 1;
                            }
                        }
                        if(!ok){
                            printf("no palindrome numbers\n");
                        }else{
                            printf(" as palindrome numbers\n");
                        }
                    }
                }
            }
        }
    }
}

void set_indices(){
    srand(time(NULL));
    int cnt = 0;
    indice = (int*)calloc(10, sizeof(int));
    while(cnt < 5){
        int r = rand()%(test->count-1);
        int ok = 1;
        while(ok){
            ok = 0;
            for(int i = 0; i < cnt; i++){
                if(r == indice[i]){
                    ok = 1;
                }
            }
            if(ok){
                r = rand()%(test->count-1);
            }
        }
        indice[cnt] = r;
        cnt++;
    }
}

void yyerror(char *s)
{
    fprintf (stderr, "%s", s);
}

int main(void)
{
    curtleQueue = createQueue(0);
    char *file = read_file_xml("./knowledge.xml");
    char *file_test = read_file_xml("./knowledge.xml");
    knowledge = node_structure(file);
    test = build_test(file_test);
    return yyparse();
}