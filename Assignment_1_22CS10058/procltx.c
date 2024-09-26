/*
Name - S.Rishabh
Roll number - 22CS10058
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

   while (prev) {
      if (!strcmp(prev->name,id)) {    // Existence of token
         prev->count++;
         return T;
      }
      prev = prev -> next;
   }

   new_node = (node *)malloc(sizeof(node));
   new_node->name = (char *)malloc((strlen(id)+1) * sizeof(char));
   strcpy(new_node->name, id);
   new_node->count = 1;

   if (T) {
      prev = T;
      while(prev->next) prev = prev->next;
      prev->next = new_node;
      return T;
   } else {
      return new_node;
   }

}

int main(int argc, char* argv[]) {

   count_map commands = NULL, environments = NULL;
   int token;                                               // New token
   int math_equations = 0, displayed_equations = 0;         // Math equation count and Displayed equation count

   while(token = yylex()) {
      switch(token) {
         case 1:
         case 2:
            break;
         case 3:
            commands = addtbl(commands, yytext);
            break;
         case 4:
            token = yylex();                                // {
            if (strcmp(yytext, "{")) token = yylex();       // Space between \begin and {
            token = yylex();                                // Environment name
            environments = addtbl(environments, yytext);
            token = yylex();                                // }
            break;
         
         case 6:
            displayed_equations++;
            break;

         case 7:
            math_equations++;
            break;
      }
   }

   printf("\nCOMMANDS\n");
   count_map temp = commands;
   while(temp) {
      printf("\t%s (%d)\n", temp->name, temp->count);
      temp = temp->next;
   }

   printf("\nENVIRONMENTS\n");
   temp = environments;
   while(temp) {
      printf("\t%s (%d)\n", temp->name, temp->count);
      temp = temp->next;
   }

   printf("\n");

   math_equations /= 2;                         // start and end counted twice
   displayed_equations /= 2;                    // start and end counted twice

   printf("%d math equations found\n", math_equations);
   printf("%d displayed equations found\n", displayed_equations);

   return 0;
}