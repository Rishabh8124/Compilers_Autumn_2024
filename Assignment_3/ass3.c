/*
Name - S.Rishabh
Roll number - 22CS10058
Name - Sadda Suchith Reddy
Roll number - 22CS10063
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lex.yy.c"

typedef struct node {
   char * name;                        // Name of the token
   int count;                          // Count of the token
   struct node *next;

} node;

typedef node * count_map;              // Linked list type structure to store count of each token

count_map addtbl ( count_map T, char * id ) {
   
   count_map prev = T, new_node;

   while (prev != NULL) {
      if (!strcmp(prev->name,id)) {    // Existence of token
         prev->count++;
         return T;
      }
      prev = prev -> next;
   }

   new_node = (node *)malloc(sizeof(node));
   new_node->name = (char *)malloc((strlen(id)+1) * sizeof(char));
   new_node->next = NULL;
   strcpy(new_node->name, id);
   new_node->count = 1;

   if (T != NULL) {
      prev = T;
      while(prev->next) prev = prev->next;
      prev->next = new_node;
      return T;
   } else {
      return new_node;
   }

}

int main(int argc, char* argv[]) {

   count_map Keyword = NULL, Identifier = NULL, Constant = NULL, String = NULL , Punctuator = NULL;
   int token;                                               // New token

   while(token = yylex()) {
      switch(token) {
         case MULTI_LINE_COMMENT:
            printf("<MULTI_LINE_COMMENT>\n");
            break;
         case SINGLE_LINE_COMMENT:
            printf("<SINGLE_LINE_COMMENT>\n");
            break;
         case KEYWORD:
            printf("<KEYWORD, %s>\n", yytext);
            Keyword = addtbl(Keyword,yytext);
            break;
         case IDENTIFIER:
            printf("<IDENTIFIER, %s>\n", yytext);
            Identifier = addtbl(Identifier,yytext);
            break;
         case INTEGER_CONSTANT:
            printf("<INTEGER_CONSTANT, %s>\n", yytext);
            Constant = addtbl(Constant,yytext);
            break;
         case FLOATING_CONSTANT:
            printf("<FLOATING_CONSTANT, %s>\n", yytext);
            Constant = addtbl(Constant,yytext);
            break;
         case CHARACTER_CONSTANT:
            printf("<CHARACTER_CONSTANT, %s>\n", yytext);
            Constant = addtbl(Constant,yytext);
            break;
         case STRING_LITERAL:
            printf("<STRING_LITERAL, %s>\n", yytext);
            String = addtbl(String,yytext);
            break;
         case PUNCTUATOR:
            printf("<PUNCTUATOR, %s>\n", yytext);
            Punctuator = addtbl(Punctuator,yytext);
            break;
         default:
            printf("Invalid Token! - %s\n", yytext);
            exit(0);
            break;
      }
   }

   printf("\nKEYWORDS\n");
   count_map temp = Keyword;
   while(temp) {
      printf("\t%s (%d)\n", temp->name, temp->count);
      temp = temp->next;
   }
   printf("\nIDENTIFIERS\n");
   temp = Identifier;
   while(temp) {
      printf("\t%s (%d)\n", temp->name, temp->count);
      temp = temp->next;
   }
   printf("\nCONSTANTS\n");
   temp = Constant;
   while(temp) {
      printf("\t%s (%d)\n", temp->name, temp->count);
      temp = temp->next;
   }
   printf("\nSTRINGS\n");
   temp = String;
   while(temp) {
      printf("\t%s (%d)\n", temp->name, temp->count);
      temp = temp->next;
   }

   printf("\nPUNCTUATORS\n");
   temp = Punctuator;
   while(temp) {
      printf("\t%s (%d)\n", temp->name, temp->count);
      temp = temp->next;
   }

//    printf("\nENVIRONMENTS\n");
//    temp = environments;
//    while(temp) {
//       printf("\t%s (%d)\n", temp->name, temp->count);
//       temp = temp->next;
//    }

//    printf("\n");

//    math_equations /= 2;                         // start and end counted twice
//    displayed_equations /= 2;                    // start and end counted twice

//    printf("%d math equations found\n", math_equations);
//    printf("%d displayed equations found\n", displayed_equations);

   return 0;
}