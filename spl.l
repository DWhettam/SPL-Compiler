%{
#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#define ID_TOKEN(t) printf("ID %s Token: " #t "\n", yytext);
#define NUMBER_TOKEN(t) printf("Number %d Token: " #t "\n", atoi(yytext));
#define CHAR_TOKEN(t) printf("Character %s Token: " #t "\n", yytext);
#else
#define TOKEN(t) return (t);
#define ID_TOKEN(t) yylval.iVal = installId(yytext); return (t);
#define NUMBER_TOKEN(t) yylval.iVal = atoi(yytext); return (t);
#define CHAR_TOKEN(t) yylval.iVal = installId(yytext); return (t);

/* Declare Symbol Table Type and Array as imported types */

#include <string.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
int installId(char *);
#endif
%}

delim       			[ \t\r\n]
ws          			{delim}+
digit       			[0-9]
number      			{digit}+
letter					[a-zA-Z]
identifier				{letter}+({letter}|{digit})*
char_constant			'{letter}'
	
%%
":"						TOKEN(COLON)
"."						TOKEN(FULLSTOP)
","						TOKEN(COMMA)
";"						TOKEN(SEMICOLON)
"->"					TOKEN(ARROW)
"("						TOKEN(BRA)
")"						TOKEN(KET)


"="						TOKEN(EQUALS)
"<>"					TOKEN(NOT_EQUAL)
"<"						TOKEN(LESS_THAN)
">"						TOKEN(GREATER_THAN)
"<="	 				TOKEN(LESS_THAN_EQUALS)
">="					TOKEN(GREATER_THAN_EQUALS)
"+"						TOKEN(PLUS)
"-"						TOKEN(MINUS)
"*"						TOKEN(MULTIPLY)
"/"						TOKEN(DIVIDE)
"'"						TOKEN(APOSTROPHE)


ENDP					TOKEN(ENDP)
DECLARATIONS			TOKEN(DECLARATIONS)
CODE					TOKEN(CODE)
OF						TOKEN(OF)
TYPE					TOKEN(T_TYPE)
CHARACTER				TOKEN(CHARACTER)
INTEGER					TOKEN(INTEGER)
REAL					TOKEN(REAL)


IF						TOKEN(IF)
THEN					TOKEN(THEN)
ENDIF					TOKEN(ENDIF)
ELSE					TOKEN(ELSE)
DO						TOKEN(DO)
WHILE					TOKEN(WHILE)
ENDDO					TOKEN(ENDDO)
ENDWHILE				TOKEN(ENDWHILE)
FOR						TOKEN(FOR)
IS						TOKEN(IS)
BY						TOKEN(BY)
TO						TOKEN(TO)
ENDFOR					TOKEN(ENDFOR)
WRITE					TOKEN(WRITE)
NEWLINE					TOKEN(NEWLINE)
READ					TOKEN(READ)
AND						TOKEN(AND)
OR						TOKEN(OR)
NOT						TOKEN(NOT)

{ws}            ; /* Do Nothing */
{char_constant}			CHAR_TOKEN(CHAR_CONSTANT)
{number}				NUMBER_TOKEN(NUMBER)
{identifier}			ID_TOKEN(VAR_IDENTIFIER)
.						printf("Error: Unrecognised symbol: %s (%d)	\n", yytext, yytext[0]);
%%
#ifndef PRINT
/* Here is the code for the library of symbol table routines */

/* code for a simple symbol table, which is an array of pointers to
   structs, each of which contains an identifier.
*/

;
SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}

/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/

int installId(char *id) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);
    }
    else 
       if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       return(currentSymTabSize++);
    }
}
#endif
