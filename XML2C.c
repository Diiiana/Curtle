#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct XML_node {
    char* about;
    char* definition;
    char* test;
    char* solution;
    char* explain;
};

struct XML_nodeList {
    struct XML_node **data;
    int size;
};

struct XML_question {
    char* text;
    char* correct;
};

struct XML_test {
    struct XML_question **questions;
    int count;
};

char *read_file_xml(const char *path){
    FILE* file = fopen(path, "r");
    if(!file){
        printf("Error loading file %s\n", path);
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    int size = ftell(file);
    fseek(file, 0, SEEK_SET);

    char *buffer = (char*)malloc(sizeof(char)*(size+1));
    fread(buffer, sizeof(char), size, file);
    fclose(file);

    buffer[size] = '\0';
    return buffer;
}

struct XML_nodeList* node_structure(char *content){
    struct XML_nodeList* nodes = (struct XML_nodeList*)malloc(100*sizeof(struct XML_nodeList));
    nodes->data = (struct XML_node**)malloc(100*sizeof(sizeof(struct XML_node*)));
    nodes->size = 0;
    while (strstr(content, "<note>") != NULL)
     {
         /*                  ABOUT                      */
         char* start_about = strstr(content, "<about>");
         char* end_about = strstr(content, "</about>");

         int s = strlen(content) - strlen(start_about) + 7;
         int e = strlen(content) - strlen(end_about);
         int fe = e - s;
         
         struct XML_node* nod = (struct XML_node*)malloc(sizeof(struct XML_node));
         nod->about = (char *)malloc(sizeof(char)*(fe+10));
        
         strncpy(nod->about, start_about + 7, fe);
         nod->about[fe] = '\0';
         /*                  DEFINITION              */
         char* start_defi = strstr(content, "<definition>");
         char* end_defi = strstr(content, "</definition>");

         int sd = strlen(content) - strlen(start_defi);
         int ed = strlen(content) - strlen(end_defi);
         int fed = ed - sd - 12;

         nod->definition = (char *)malloc(sizeof(char)*(fed + 1));
  
         strncpy(nod->definition, start_defi + 12, fed);
         nod->definition[fed] = '\0';

         strcpy(content, end_defi + 12);

        /*                  TEST              */
         char* start_test = strstr(content, "<test>");
         char* end_test = strstr(content, "</test>");

         int st = strlen(content) - strlen(start_test);
         int et = strlen(content) - strlen(end_test);
         int fst = et - st - 6;

         nod->test = (char *)malloc(sizeof(char)*(fst + 1));
  
         strncpy(nod->test, start_test + 6, fst);
         nod->test[fst] = '\0';

         strcpy(content, end_test + 6);

        /*                  SOLUTION              */
          char* start_sol = strstr(content, "<solution>");
          char* end_sol = strstr(content, "</solution>");

          int ss = strlen(content) - strlen(start_sol);
          int es = strlen(content) - strlen(end_sol);
          int fss = es - ss - 10;

          nod->solution = (char *)malloc(sizeof(char)*(fss + 1));
  
          strncpy(nod->solution, start_sol + 10, fss);
          nod->solution[fss] = '\0';

          strcpy(content, end_sol + 10);
        
        /*                  EXPLAIN              */
          char* start_expl = strstr(content, "<explain>");
          char* end_expl = strstr(content, "</explain>");

          int se2 = strlen(content) - strlen(start_expl);
          int ee2 = strlen(content) - strlen(end_expl);
          int fe2 = ee2 - se2 - 9;

          nod->explain = (char *)malloc(sizeof(char)*(fe2 + 1));
  
          strncpy(nod->explain, start_expl + 9, fe2);
          nod->explain[fe2] = '\0';

          strcpy(content, end_expl + 9);

         nodes->data[nodes->size] = nod;
         nodes->size++;
     }
    
    return nodes;
}

struct XML_test* build_test(char *content){
    struct XML_test* nodes = (struct XML_test*)malloc(100*sizeof(struct XML_test));
    nodes->questions = (struct XML_question**)malloc(100*sizeof(struct XML_question*));
    nodes->count = 0;
    
    while (strstr(content, "<question>") != NULL)
     {
         /*                    QUESTION                      */
         char* start_question = strstr(content, "<text>");
         char* end_question = strstr(content, "</text>");

         int s = strlen(content) - strlen(start_question);
         int e = strlen(content) - strlen(end_question);
         int fe = e - s - 6;

         struct XML_question* nod = (struct XML_question*)malloc(sizeof(struct XML_question));
         nod->text = (char *)malloc(sizeof(char)*(fe + 6));
         
         strncpy(nod->text, start_question + 6, fe);
         nod->text[fe] = '\0';
         

         /*                  CORRECT ANSWER              */
         char* start_correct = strstr(content, "<correct>");
         char* end_correct = strstr(content, "</correct>");

         int sd = strlen(content) - strlen(start_correct);
         int ed = strlen(content) - strlen(end_correct);
         int fed = ed - sd - 9;

         nod->correct = (char *)malloc(sizeof(char)*(fed + 1));
  
         strncpy(nod->correct, start_correct + 9, fed);
         nod->correct[fed] = '\0';
         strcpy(content, end_correct + 9);

          nodes->questions[nodes->count] = nod;
          nodes->count++;
      }
    
    return nodes;
}

// int main(){
//        char *file = read_file_xml("./knowledge.xml");
//        struct XML_nodeList *result = node_structure(file);
//        for(int i = 0; i < result->size; i++){
//              printf("%s\n", result->data[i]->about);
//              printf("%s\n", result->data[i]->definition);
//              printf("%s\n", result->data[i]->test);
//              printf("%s\n", result->data[i]->solution);
//              printf("%s\n", result->data[i]->explain);
//              printf("\n\n\n");
//        }
//     struct XML_test *test = build_test(file);
//     for(int i = 0; i < test->count; i++){
//              printf("%s\n", test->questions[i]->text);
//              printf("%s\n", test->questions[i]->correct);
//              printf("\n\n\n");
//        }
//        return 0;
// }