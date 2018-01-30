%{
/* declare some standard headers to be used to import declarations
   and libraries into the parser. */

#include <stdio.h>
#include <stdlib.h>

/* make forward declarations to avoid compiler warnings */
int yylex (void);
void yyerror (char *);

typedef int bool;
		enum { false, true };
	
bool forloop = false;

/* 
   Some constants.
*/

  /* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

  enum ParseTreeNodeType { 	PROGRAM, BLOCK, DECLARATION, DECLARATION_BLOCK, T_TYPE_INTEGER, T_TYPE_CHARACTER,
							T_TYPE_REAL, STATEMENT_LIST, STATEMENT, STATEMENT_ASSIGNMENT, STATEMENT_IF, STATEMENT_DO,
							STATEMENT_WHILE, STATEMENT_FOR, STATEMENT_WRITE, STATEMENT_READ, ASSIGNMENT_STATEMENT,
							IF_STATEMENT, DO_STATEMENT, WHILE_STATEMENT, FOR_STATEMENT, WRITE_STATEMENT,
							READ_STATEMENT, OUTPUT_LIST, CONDITIONAL_BODY, CONDITIONAL, CONDITIONAL_NOT, CONDITIONAL_AND, 
							CONDITIONAL_OR, EQUALS_COMPARATOR, NOT_EQUAL_COMPARATOR, LESS_THAN_COMPARATOR, GREATER_THAN_COMPARATOR, 
							LESS_THAN_EQUALS_COMPARATOR, GREATER_THAN_EQUALS_COMPARATOR, EXPRESSION, EXPRESSION_PLUS, EXPRESSION_MINUS, 
							TERM, TERM_MULTIPLY, TERM_DIVIDE, VALUE_VAR_IDENTIFIER, VALUE_CONSTANT, VALUE_BRACKET, CONSTANT_CHARACTER, 
							CONSTANT_NUMBER, CHARACTER_CONSTANT, NUMBER_CONSTANT,DECIMAL_NUMBER_CONSTANT, MINUS_DECIMAL_NUMBER_CONSTANT,
							MINUS_NUMBER_CONSTANT } ;  
							
	char *NodeName[] = {	"PROGRAM", "BLOCK", "DECLARATION", "DECLARATION_BLOCK", "T_TYPE_INTEGER", "T_TYPE_CHARACTER",
							"T_TYPE_REAL", "STATEMENT_LIST", "STATEMENT", "STATEMENT_ASSIGNMENT", "STATEMENT_IF", "STATEMENT_DO",
							"STATEMENT_WHILE", "STATEMENT_FOR", "STATEMENT_WRITE", "STATEMENT_READ", "ASSIGNMENT_STATEMENT",
							"IF_STATEMENT", "DO_STATEMENT", "WHILE_STATEMENT", "FOR_STATEMENT", "WRITE_STATEMENT",
							"READ_STATEMENT", "OUTPUT_LIST", "CONDITIONAL_BODY", "CONDITIONAL", "CONDITIONAL_NOT", "CONDITIONAL_AND", 
							"CONDITIONAL_OR", "EQUALS_COMPARATOR", "NOT_EQUAL_COMPARATOR", "LESS_THAN_COMPARATOR", "GREATER_THAN_COMPARATOR", 
							"LESS_THAN_EQUALS_COMPARATOR", "GREATER_THAN_EQUALS_COMPARATOR", "EXPRESSION", "EXPRESSION_PLUS", "EXPRESSION_MINUS", 
							"TERM", "TERM_MULTIPLY", "TERM_DIVIDE", "VALUE_VAR_IDENTIFIER", "VALUE_CONSTANT", 
							"VALUE_BRACKET", "CONSTANT_CHARACTER", "CONSTANT_NUMBER", "CHARACTER_CONSTANT", "NUMBER_CONSTANT",
							"DECIMAL_NUMBER_CONSTANT", "MINUS_DECIMAL_NUMBER_CONSTANT", "MINUS_NUMBER_CONSTANT" } ;  

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE        *TERNARY_TREE;

/* ------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);

#ifdef DEBUG
	void PrintTree(TERNARY_TREE,int);
#endif

void WriteCode(TERNARY_TREE);

/* ------------- symbol table definition --------------------------- */

struct symTabNode {
    char identifier[IDLENGTH];
	char var_type;
	bool declared;
	bool initialised;
};

typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;

%}

/****************/
/* Start symbol */
/****************/

%start  program

/**********************/
/* Action value types */
/**********************/

%union {
    int iVal;
    TERNARY_TREE  tVal;
}

%token COLON FULLSTOP COMMA SEMICOLON 
		ARROW BRA KET EQUALS NOT_EQUAL LESS_THAN GREATER_THAN 
		LESS_THAN_EQUALS GREATER_THAN_EQUALS PLUS MINUS MULTIPLY 
		DIVIDE APOSTROPHE ENDP DECLARATIONS CODE OF T_TYPE CHARACTER 
		INTEGER REAL IF THEN ENDIF ELSE DO WHILE ENDDO ENDWHILE
		FOR IS BY TO ENDFOR WRITE NEWLINE READ AND OR NOT
		
%token<iVal> VAR_IDENTIFIER NUMBER CHAR_CONSTANT

%type<tVal> program block declaration_block declaration type statement_list 
			statement assignment_statement if_statement do_statement
			while_statement for_statement write_statement read_statement 
			output_list conditional_body conditional comparator expression
			term value constant character_constant number_constant

%%
program : VAR_IDENTIFIER COLON block ENDP VAR_IDENTIFIER FULLSTOP
              { 
				TERNARY_TREE ParseTree;
				ParseTree = create_node(NOTHING,PROGRAM,$3,NULL,NULL);
				
				#ifdef DEBUG
					PrintTree (ParseTree, 0);			  
				#endif
								
				WriteCode (ParseTree);
			  }
	;
block :  DECLARATIONS declaration_block CODE statement_list
			{ 
				$$ = create_node(NOTHING, BLOCK, $2, $4, NULL ) ;
			}
		| CODE statement_list
			{  
				$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL ) ;
			}
	;

declaration_block : declaration OF T_TYPE type SEMICOLON 
						{  
							$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL ) ;
						}
					| declaration OF T_TYPE type SEMICOLON declaration_block
						{  
							$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6 ) ;
						}
	;
	
declaration : VAR_IDENTIFIER 
				{  
					$$ = create_node($1, DECLARATION, NULL, NULL, NULL ) ;
				}
			| VAR_IDENTIFIER COMMA declaration
				{  
					$$ = create_node($1, DECLARATION, $3, NULL, NULL ) ;
				}
	;
	
type : CHARACTER
		{			
			$$ = create_node(NOTHING, T_TYPE_CHARACTER, NULL, NULL, NULL ) ;
		}
	| INTEGER
		{  
			
			$$ = create_node(NOTHING, T_TYPE_INTEGER, NULL, NULL, NULL ) ;
		}
	| REAL
		{  
			
			$$ = create_node(NOTHING, T_TYPE_REAL, NULL, NULL, NULL ) ;
		}
		
	;
statement_list : statement 
					{  
						$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL ) ;
					}
				|statement SEMICOLON statement_list
					{  
						$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL ) ;
					}
	;
statement : assignment_statement
				{  
					$$ = create_node(NOTHING, STATEMENT_ASSIGNMENT, $1, NULL, NULL ) ;
				}
			| if_statement 
				{  
					$$ = create_node(NOTHING, STATEMENT_IF, $1, NULL, NULL ) ;
				}
			| do_statement 
				{  
					$$ = create_node(NOTHING, STATEMENT_DO, $1, NULL, NULL ) ;
				}
			| while_statement 
				{  
					$$ = create_node(NOTHING, STATEMENT_WHILE, $1, NULL, NULL ) ;
				}
			| for_statement 
				{  
					$$ = create_node(NOTHING, STATEMENT_FOR, $1, NULL, NULL ) ;
				}
			| write_statement 
				{  
					$$ = create_node(NOTHING, STATEMENT_WRITE, $1, NULL, NULL ) ;
				}
			| read_statement
				{  
					$$ = create_node(NOTHING, STATEMENT_READ, $1, NULL, NULL ) ;
				}
	;
assignment_statement : expression ARROW VAR_IDENTIFIER
						{  
							$$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL ) ;
						}
	;
if_statement : IF conditional THEN statement_list ENDIF
				{  
					$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL ) ;
				}
			| IF conditional THEN statement_list ELSE statement_list ENDIF
				{  
					$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6 ) ;
				}
	;
do_statement : DO statement_list WHILE conditional ENDDO
				{  
					$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL ) ;
				}
	;
while_statement : WHILE conditional DO statement_list ENDWHILE
				{  
					$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL ) ;
				}
	;
for_statement : FOR VAR_IDENTIFIER IS expression BY expression TO expression
				DO statement_list ENDFOR
					{  
						$$ = create_node($2, FOR_STATEMENT, (create_node(NOTHING, FOR_STATEMENT, $4, $6, NULL)), $8, $10 ) ;
					}				 
	;
write_statement : WRITE BRA output_list KET
					{  
						$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL ) ;
					}
				| NEWLINE
					{  
						$$ = create_node(NEWLINE, WRITE_STATEMENT, NULL, NULL, NULL ) ;
					}
	;
read_statement : READ BRA VAR_IDENTIFIER KET
					{  
						$$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL ) ;
					}
	;
output_list : value 
				{  
					$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL ) ;
				}
			| value COMMA output_list
				{  
					$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL ) ;
				}
	;
conditional_body :  expression comparator expression
						{  
							$$ = create_node(NOTHING, CONDITIONAL_BODY, $1, $2, $3 ) ;
						}
	;
conditional : conditional_body 
				{  
					$$ = create_node(NOTHING, CONDITIONAL, $1, NULL, NULL ) ;
				}
			| NOT conditional
				{  
					$$ = create_node(NOTHING, CONDITIONAL_NOT, $2, NULL, NULL ) ;
				}
			| conditional_body AND conditional
				{  
					$$ = create_node(NOTHING, CONDITIONAL_AND, $1, $3, NULL ) ;
				}
			| conditional_body OR conditional
				{  
					$$ = create_node(NOTHING, CONDITIONAL_OR, $1, $3, NULL ) ;
				}
	;
comparator : EQUALS 
				{  
					$$ = create_node(NOTHING, EQUALS_COMPARATOR, NULL, NULL, NULL ) ;
				}
			| NOT_EQUAL
				{  
					$$ = create_node(NOTHING, NOT_EQUAL_COMPARATOR, NULL, NULL, NULL ) ;
				}
			| LESS_THAN 
				{  
					$$ = create_node(NOTHING, LESS_THAN_COMPARATOR, NULL, NULL, NULL ) ;
				}
			| GREATER_THAN
				{  
					$$ = create_node(NOTHING, GREATER_THAN_COMPARATOR, NULL, NULL, NULL ) ;
				}
			| LESS_THAN_EQUALS
				{  
					$$ = create_node(NOTHING, LESS_THAN_EQUALS_COMPARATOR, NULL, NULL, NULL ) ;
				}
			| GREATER_THAN_EQUALS
				{  
					$$ = create_node(NOTHING, GREATER_THAN_EQUALS_COMPARATOR, NULL, NULL, NULL ) ;
				}
	;
expression : term
				{  
					$$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL ) ;
				}
			| expression PLUS term
				{  
					$$ = create_node(NOTHING, EXPRESSION_PLUS, $1, $3, NULL ) ;
				}
			| expression MINUS term
				{  
					$$ = create_node(NOTHING, EXPRESSION_MINUS, $1, $3, NULL ) ;
				}
	;
term : value 
		{  	
			$$ = create_node(NOTHING, TERM, $1, NULL, NULL ) ;
		}
	| term MULTIPLY value
		{  
			$$ = create_node(NOTHING, TERM_MULTIPLY, $1, $3, NULL ) ;
		}
	| term DIVIDE value
		{  
			$$ = create_node(NOTHING, TERM_DIVIDE, $1, $3, NULL ) ;
		}
	;
value : VAR_IDENTIFIER 
			{  
				$$ = create_node($1, VALUE_VAR_IDENTIFIER, NULL, NULL, NULL ) ;
			}
		| constant 
			{  
				$$ = create_node(NOTHING, VALUE_CONSTANT, $1, NULL, NULL ) ;
			}
		| BRA expression KET
			{  
				$$ = create_node(NOTHING, VALUE_BRACKET, $2, NULL, NULL ) ;
			}
	;
constant : number_constant 
			{  
				$$ = create_node(NOTHING, CONSTANT_NUMBER, $1, NULL, NULL ) ;
			}
		| character_constant
			{  
				$$ = create_node(NOTHING, CONSTANT_CHARACTER, $1, NULL, NULL ) ;
			}
	;
character_constant : CHAR_CONSTANT
						{  
							$$ = create_node($1, CHARACTER_CONSTANT, NULL, NULL, NULL ) ;
						}
	;
number_constant : NUMBER
					{  
						$$ = create_node($1, NUMBER_CONSTANT, NULL, NULL, NULL ) ;
					}
				| MINUS NUMBER 
					{  
						$$ = create_node($2, MINUS_NUMBER_CONSTANT, NULL, NULL, NULL ) ;
					}
				| MINUS NUMBER FULLSTOP NUMBER
					{  						
						$$ = create_node($2, MINUS_DECIMAL_NUMBER_CONSTANT, (create_node($4, MINUS_DECIMAL_NUMBER_CONSTANT, NULL, NULL, NULL)), NULL, NULL ) ;
					}
				| NUMBER FULLSTOP NUMBER
					{  
						$$ = create_node($1, DECIMAL_NUMBER_CONSTANT, (create_node($3, DECIMAL_NUMBER_CONSTANT, NULL, NULL, NULL)), NULL, NULL ) ;
					}
	;
	
%%

/* Code for routines for managing the Parse Tree */

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    return (t);
}


/* Put other auxiliary functions here */
#ifdef DEBUG
void PrintTree(TERNARY_TREE t, int indent)
{
   int i;
   if (t == NULL) return;   
   for (i=indent; i; i--)
   {
		printf(" ");
   }
	if (t->nodeIdentifier == NUMBER_CONSTANT 
		|| t->nodeIdentifier == MINUS_NUMBER_CONSTANT 
		|| t->nodeIdentifier == MINUS_DECIMAL_NUMBER_CONSTANT 
		|| t->nodeIdentifier == DECIMAL_NUMBER_CONSTANT)
	{
		printf("Number: %d ", t->item);
	}
	else if (t->nodeIdentifier == CHARACTER_CONSTANT)	
	{
		if (t->item > 0 && t->item < SYMTABSIZE)
		{
			printf("Character: %s ", symTab[t->item]-> identifier);
		}	
		else printf("Unknown Identifier: %d ",t->item);
	}	
	else if (t->nodeIdentifier == VALUE_VAR_IDENTIFIER)	
	{
		if (t->item > 0 && t->item < SYMTABSIZE)
		{
			printf("Identifier: %s ", symTab[t->item]->identifier);
		}	
		else printf("Unknown Identifier: %d ",t->item);
	}
	else if (t->item != NOTHING) {
		printf("Item: %d ", t->item);
	}
   if	(t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
	printf("Unknown nodeIdentifier: %d\n",t->nodeIdentifier);
   else
	   printf("%s\n",NodeName[t->nodeIdentifier]);
	   PrintTree(t->first,indent+3);
	   PrintTree(t->second,indent+3);
	   PrintTree(t->third,indent+3);
}
#endif

void PrintError(char* errorMessage)
{
	#ifdef _WIN32
		system("cls");
	#else
		system("clear");
	#endif
	
	yyerror(errorMessage);
	exit(1);
}
void TypeAssign(TERNARY_TREE t, char setType)
{	
	if (t == NULL) return; 	
	switch(t->nodeIdentifier)
	{		
		case(DECLARATION_BLOCK):				
			if(t->second->nodeIdentifier == T_TYPE_CHARACTER)
			{				
				symTab[t->first->item]->var_type = 'c';	
				
				if (t->first->first != NULL)
				{
					TypeAssign(t->first, 'c');
					
				}
			}
			else if (t->second->nodeIdentifier == T_TYPE_INTEGER)
			{	
				symTab[t->first->item]->var_type = 'd';

				if (t->first->first != NULL)
				{
					TypeAssign(t->first, 'd');				
				}
			}
			else
			{
				symTab[t->first->item]->var_type = 'f';

				if (t->first->first != NULL)
				{
					TypeAssign(t->first, 'f');
				}
			}
		case(DECLARATION):
			if(setType == 'd')
			{
				symTab[t->item]->var_type = 'd';
				
				if (t->first != NULL)
				{
					TypeAssign(t->first, 'd');
				}
			}
			else if(setType == 'c')
			{
				symTab[t->item]->var_type = 'c';
				
				if (t->first != NULL)
				{
					TypeAssign(t->first, 'c');
				}
			}
			else if(setType == 'f')
			{
				symTab[t->item]->var_type = 'f';
				
				if (t->first != NULL)
				{
					TypeAssign(t->first, 'f');
				}
			}
			
	}
	
	TypeAssign(t->first, 'z');
	TypeAssign(t->second, 'z');
	TypeAssign(t->third, 'z');
}

char GetExpressionType(TERNARY_TREE t)
{	
	char rVal;
	if (t == NULL) return rVal; 
	switch(t->nodeIdentifier)
	{	
		case(EXPRESSION):			
			if (GetExpressionType(t->first) == 'f')
			{
				rVal = 'f';
			}
			else if (GetExpressionType(t->first) == 'd')
			{
				rVal = 'd';
			}	
			else if (GetExpressionType(t->first) == 'c')
			{
				rVal = 'c';
			}
			else 
			{
				rVal = 'e';
			}
			return rVal;
		case(EXPRESSION_PLUS):
			if (GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'f')
			{
				rVal = 'f';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'd';
			}	
			else if (GetExpressionType(t->first) == 'c' && GetExpressionType(t->second) == 'c')
			{
				rVal = 'c';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'f'
					|| GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'f';
			}
			else 
			{
				rVal = 'e';
			}
			return rVal;
		case(EXPRESSION_MINUS):	
			if (GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'f')
			{
				rVal = 'f';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'd';
			}	
			else if (GetExpressionType(t->first) == 'c' && GetExpressionType(t->second) == 'c')
			{
				rVal = 'c';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'f'
					|| GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'f';
			}
			else 
			{
				rVal = 'e';
			}
			return rVal;
		case(TERM):
			rVal = GetExpressionType(t->first);	
			return rVal;
		case(TERM_MULTIPLY):
			if (GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'f')
			{
				rVal = 'f';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'd';
			}	
			else if (GetExpressionType(t->first) == 'c' && GetExpressionType(t->second) == 'c')
			{
				rVal = 'c';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'f'
					|| GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'f';
			}
			else 
			{
				rVal = 'e';
			}
			return rVal;
		case(TERM_DIVIDE):
			if (GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'f')
			{
				rVal = 'f';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'd';
			}	
			else if (GetExpressionType(t->first) == 'c' && GetExpressionType(t->second) == 'c')
			{
				rVal = 'c';
			}
			else if (GetExpressionType(t->first) == 'd' && GetExpressionType(t->second) == 'f'
					|| GetExpressionType(t->first) == 'f' && GetExpressionType(t->second) == 'd')
			{
				rVal = 'f';
			}
			else 
			{
				rVal = 'e';
			}
			return rVal;
			return rVal;
		case(VALUE_VAR_IDENTIFIER):
			rVal = symTab[t->item]->var_type;	
			return rVal;
		case(VALUE_CONSTANT):
			rVal = GetExpressionType(t->first);		
			return rVal;
		case(VALUE_BRACKET):
			rVal = GetExpressionType(t->first);	
			return rVal;
		case(CONSTANT_NUMBER):
			rVal = GetExpressionType(t->first);	
			return rVal;
		case(CONSTANT_CHARACTER):
			rVal = GetExpressionType(t->first);		
			return rVal;
		case(CHARACTER_CONSTANT):
			rVal = 'c';	
			return rVal;
		case(NUMBER_CONSTANT):
			rVal = 'd';
			return rVal;
		case(MINUS_NUMBER_CONSTANT):
			rVal = 'd';
			return rVal;
		case(DECIMAL_NUMBER_CONSTANT):
			rVal = 'f';	
			return rVal;
		case(MINUS_DECIMAL_NUMBER_CONSTANT):
			rVal = 'f';	
			return rVal;
	}
	
	return rVal;
}

bool isValid = false;
bool ValidExpression(TERNARY_TREE t)
{
	
	if (t == NULL) return isValid; 
	switch(t->nodeIdentifier)
	{	
		case(EXPRESSION):
			isValid = ValidExpression(t->first);
			return isValid;
		case(EXPRESSION_PLUS):	
			isValid = ValidExpression(t->first);
			return isValid;
		case(EXPRESSION_MINUS):
			isValid = ValidExpression(t->first);
			return isValid;
		case(TERM):
			isValid = ValidExpression(t->first);
			return isValid;
		case(TERM_MULTIPLY):
			isValid = ValidExpression(t->first);
			return isValid;
		case(TERM_DIVIDE):
			isValid = ValidExpression(t->first);
			return isValid;
		case(VALUE_VAR_IDENTIFIER):
			if(symTab[t->item]->declared == true && symTab[t->item]->initialised == true)
			{	
				isValid = true;
			}
			else
			{
				isValid = false;
			}
			return isValid;
		case(VALUE_CONSTANT):			
			isValid = true;
			return isValid;
		case(VALUE_BRACKET):
			isValid = ValidExpression(t->first);
			return isValid;
	}	
	return isValid;		
}

void WriteCode(TERNARY_TREE t)
{	
	int MAX_INT = 2147483647;
	int MIN_INT = -2147483647;
	
	if (t == NULL) return; 
	TypeAssign(t, 'z');
	
	switch(t->nodeIdentifier)
	{
		case(PROGRAM):
			printf("#include <stdio.h>\n#include <stdlib.h>\n\nint main (void)\n{\n");
			WriteCode(t->first);
			printf("\n}\n");
			return;
		
		case(DECLARATION_BLOCK):
			WriteCode(t->second);
			WriteCode(t->first);			
			if (t->third != NULL)
			{				
				WriteCode(t->third);
			}
			printf("\n");
			return;
			
		case(DECLARATION):
			if(symTab[t->item] -> declared != true)
			{
				if (t->item >= 0 && t->item < SYMTABSIZE)
				{				
					printf("%s_v", symTab[t->item]->identifier);
					symTab[t->item]->declared = true;
				}	
				else printf("Unknown Identifier: %d ",t->item);		
				if(t->first != NULL)
				{
					printf(", ");
				}
			}
			else 
			{
				PrintError("Identifier previously declared");
			}
			if(t->first != NULL)
			{					
				WriteCode(t->first);
			}
			else printf(";\n");	
				
			return;
		
		case(T_TYPE_CHARACTER):
			printf("char ");			
			return;
			
		case(T_TYPE_INTEGER):
			printf("int ");
			return;
			
		case(T_TYPE_REAL):
			printf("float ");
			return;
			
		case(STATEMENT_LIST):
			WriteCode(t->first);
			if(t->second != NULL)
			{
				WriteCode(t->second);
			}
			return;
		
		case(ASSIGNMENT_STATEMENT):		
			if(symTab[t->item]->declared == true)
			{					
				if(t->first->nodeIdentifier == EXPRESSION
					|| t->first->nodeIdentifier == EXPRESSION_PLUS
					|| t->first->nodeIdentifier == EXPRESSION_MINUS)
				{		
					if(symTab[t->item]->var_type == GetExpressionType(t->first)
						|| symTab[t->item]->var_type == 'f' && GetExpressionType(t->first) == 'd')
					{
						if (t->item >= 0 && t->item < SYMTABSIZE)
						{				
							printf("%s_v", symTab[t->item]->identifier);
							symTab[t->item]->initialised = true;
						}	
						else printf("Unknown Identifier: %d ",t->item);
						
						printf(" = ");
						WriteCode(t->first);
						printf(";\n");	
						
					}
					else
					{
						PrintError("Cannot assign an identifier a type that is not its own");
					}															
				}	
			}
			else
			{
				PrintError("Identifier undeclared");
			}
			
			return;
			
		case(IF_STATEMENT):
			printf("if(");
			WriteCode(t->first);
			printf(")\n{\n");
			WriteCode(t->second);
			printf("}\n");
			if (t->third != NULL)
			{
				printf("else\n{\n");
				WriteCode(t->third);
				printf("}\n");
			}
			return;	
			
		case(DO_STATEMENT):
			printf("do\n{\n");
			WriteCode(t->first);
			printf("\n} while(");
			WriteCode(t->second);
			printf(");\n");
			return;
			
		case(WHILE_STATEMENT):
			printf("while (");
			WriteCode(t->first);
			printf(")\n{\n");
			WriteCode(t->second);
			printf("\n}\n");
			return;
			
		case(FOR_STATEMENT):
			if(symTab[t->item]->declared == true)
			{
				if(GetExpressionType(t->first->first) == 'd' 
					&& GetExpressionType(t->first->second) == 'd'
					&& GetExpressionType(t->second) == 'd')
				{
					if(forloop == false)
					{
						forloop = true;
						printf("register int _by, _sign;\n");
					}
							
					symTab[t->item]->initialised = true;
					
					printf("for(%s_v = ", symTab[t->item]->identifier);
					WriteCode(t->first->first);
					printf("; _by = ");
					WriteCode(t->first->second);
					printf(", _sign = (_by == 0 ? 1 : _by/abs(_by)), (%s_v - ", symTab[t->item]->identifier);
					WriteCode(t->second);
					printf(")*_sign <= 0 ; ");
					printf("%s_v += _by)\n{\n", symTab[t->item]->identifier);
					WriteCode(t->third);
					printf("\n}\n");		
					return;
				}
				else
				{
					PrintError("Must use Integers within FOR loop");
				}			
			}
			else
			{
				PrintError("Cannot implicitly declare variables within a FOR loop");
			}
			
			
		case(WRITE_STATEMENT):						
			if (t->first != NULL)
			{	
				WriteCode(t->first);
			}
			else
			{
				printf("printf(\"\\n\");\n");
			}			
			return;
			
		case(READ_STATEMENT):
			if(symTab[t->item]->declared == true)
			{
				if(symTab[t->item]->var_type == 'c')
				{
					printf("scanf(\" %%");
				}
				else
				{
					printf("scanf(\"%%");
				}
				printf("%c\", ", symTab[t->item]->var_type);
				printf("&%s_v);\n", symTab[t->item]->identifier);
				symTab[t->item]->initialised = true;
				return;
			}
			else
			{	
				PrintError("Cannot read undeclared identifier");
			}
			
		case(OUTPUT_LIST):
			if (t->first->nodeIdentifier == VALUE_VAR_IDENTIFIER)
			{	
				if(symTab[t->first->item]->declared != true)
				{
					PrintError("Cannot write undeclared identifier");
				}
				else if(symTab[t->first->item]->initialised == true)
				{
					printf("printf(\"%%");
					printf("%c", symTab[t->first->item]->var_type);
					printf("\", ");
					printf("%s_v", symTab[t->first->item]->identifier);
					printf(");\n");
				}
				else
				{	
					PrintError("Unitialised Identifier");
				}
				
			}
			else if(t->first->first->nodeIdentifier == CONSTANT_CHARACTER)
			{
				printf("printf(\"%%c\", ");
				WriteCode(t->first);					
				printf(");\n");
			}			

			else if(t->first->first->first->nodeIdentifier == NUMBER_CONSTANT 
				|| t->first->first->first->nodeIdentifier == MINUS_NUMBER_CONSTANT)
			{
				printf("printf(\"%%d\", ");
				WriteCode(t->first);					
				printf(");\n");
			}
			
			else if(t->first->first->first->nodeIdentifier == DECIMAL_NUMBER_CONSTANT 
				|| t->first->first->first->nodeIdentifier == MINUS_DECIMAL_NUMBER_CONSTANT)
			{
				printf("printf(\"%%f\", ");
				WriteCode(t->first);					
				printf(");\n");
			}
			
			else
			{				
				char type = GetExpressionType(t->first);
				if (type != 'e')
				{
					printf("printf(\"%%");
					printf("%c\", ", type);
					WriteCode(t->first);					
					printf(");\n");
				}
				else
				{
					PrintError("Cannot write mixed types");
				}
			}
									
			if(t->second != NULL)
			{
				WriteCode(t->second);
			}			
			return;
		
		case(CONDITIONAL_BODY):	
			if(ValidExpression(t->first) == false 
				|| ValidExpression(t->second) == false)
			{				
				PrintError("Cannot use an undeclared identifier within a conditional");
			}

			
			
			printf("(");
			WriteCode(t->first);
			WriteCode(t->second);
			WriteCode(t->third);
			printf(")");
			return;
		
		case(CONDITIONAL):		
			WriteCode(t->first);
			return;
			
		case(CONDITIONAL_NOT):
			printf("!");
			WriteCode(t->first);
			return;
			
		case(CONDITIONAL_AND):
			WriteCode(t->first);
			printf(" && ");
			WriteCode(t->second);
			return;
			
		case(CONDITIONAL_OR):
			WriteCode(t->first);
			printf(" || ");
			WriteCode(t->second);
			return;
			
		case(EQUALS_COMPARATOR):
			printf(" == ");
			return;
		
		case(NOT_EQUAL_COMPARATOR):
			printf(" != ");
			return;
			
		case(LESS_THAN_COMPARATOR):
			printf(" < ");
			return;
			
		case(GREATER_THAN_COMPARATOR):
			printf(" > ");
			return;
			
		case(LESS_THAN_EQUALS_COMPARATOR):
			printf(" <= ");
			return;
			
		case(GREATER_THAN_EQUALS_COMPARATOR):
			printf(" >= ");
			return;
		
		case(EXPRESSION):
			if(ValidExpression(t) == true)
			{
				WriteCode(t->first);
				return;
			}
			else
			{
				PrintError("Cannot use an undeclared or uninitialised identifier within an expression");
			}
		
		case(EXPRESSION_PLUS):
			if (ValidExpression(t) == true)
			{
				if(t->second->second == NULL && t->second->first->nodeIdentifier == VALUE_CONSTANT)
				{
					if(t->second->first->first->first->item == 0 )
					{
						WriteCode(t->first);
					}
					else 
					{
						WriteCode(t->first);
						printf("+");
						WriteCode(t->second);
					}
				}
				else
				{
					WriteCode(t->first);
					printf("+");
					WriteCode(t->second);
				}		
				return;
			}
			else
			{
				PrintError("Cannot use an undeclared or uninitialised identifier within an expression");
			}
			
		
		case(EXPRESSION_MINUS):
			if(ValidExpression(t) == true)
			{
				if(t->second->second == NULL && t->second->first->nodeIdentifier == VALUE_CONSTANT)
				{
					if(t->second->first->first->first->item == 0 )
					{
						WriteCode(t->first);
					}
					else 
					{
						WriteCode(t->first);
						printf("-");
						WriteCode(t->second);
					}
				}
				else
				{
					WriteCode(t->first);
					printf("-");
					WriteCode(t->second);
				}		
				return;
			}
			else
			{
				PrintError("Cannot use an undeclared or uninitialised identifier within an expression");
			}
			
			
		case(TERM):
			WriteCode(t->first);
			return;
		
		case(TERM_MULTIPLY):			
			if(t->first->first->nodeIdentifier == VALUE_CONSTANT)
			{					
				if(t->first->first->first->nodeIdentifier == CONSTANT_NUMBER)
				{							
					if(t->first->first->first->first->nodeIdentifier == NUMBER_CONSTANT)
					{
						if(t->first->first->first->first->item == 0)
						{
							printf("0");
							return;
						}	
						else if(t->first->first->first->first->item == 1)
						{
							WriteCode(t->second);
							return;
						}		
					}
				}
			}
			if(t->second->nodeIdentifier == VALUE_CONSTANT)
			{					
				if(t->second->first->nodeIdentifier == CONSTANT_NUMBER)
				{							
					if(t->second->first->first->nodeIdentifier == NUMBER_CONSTANT)
					{
						if(t->second->first->first->item == 0)
						{
							printf("0");
							return;
						}	
						else if(t->second->first->first->item == 1)
						{
							WriteCode(t->first);
							return;
						}	
					}
				}
			}
			
			WriteCode(t->first);
			printf("*");
			WriteCode(t->second);
			
			return;
			
		case(TERM_DIVIDE):
			if(t->first->first->nodeIdentifier == VALUE_CONSTANT)
			{
				if(t->first->first->first->nodeIdentifier == CONSTANT_NUMBER)
				{
					if(t->first->first->first->first->nodeIdentifier == NUMBER_CONSTANT)
					{
						if(t->first->first->first->first->item == 0)
						{	
							printf("0");
							return;
						}	
					}
				}
			}
			if(t->second->nodeIdentifier == VALUE_CONSTANT)
			{
				if(t->second->first->nodeIdentifier == CONSTANT_NUMBER)
				{
					if(t->second->first->first->nodeIdentifier == NUMBER_CONSTANT)
					{
						if(t->second->first->first->item == 1)
						{	
							WriteCode(t->first);
							return;
						}
						else if(t->second->first->first->item == 0)
						{
							PrintError("Divide by 0 error");
						}
					}
				}
			}
				
			WriteCode(t->first);
			printf("/");
			WriteCode(t->second);
			return;
		
		case(VALUE_VAR_IDENTIFIER):		
			if(symTab[t->item]->declared == true)
			{
				if (t->item >= 0 && t->item < SYMTABSIZE)
				{				
					printf("%s_v", symTab[t->item]->identifier);				
				}	
				else printf("Unknown Identifier: %d ",t->item);		
			}
			else
			{
				#ifdef _WIN32
						system("cls");
					#else
						system("clear");
					#endif
				
				yyerror("Identifier undeclared");
				exit(1);
			}
				
			return;
			
		case(VALUE_CONSTANT):
			WriteCode(t->first);
			return;						
		case(VALUE_BRACKET):
			printf("(");
			WriteCode(t->first);
			printf(")");
			return;
		
		case(CHARACTER_CONSTANT):
			if (t->item >= 0 && t->item < SYMTABSIZE)
			{
				printf("%s", symTab[t->item]->identifier);
			}	
			else printf("Unknown Identifier: %d ",t->item);
			return;
			
		case(NUMBER_CONSTANT):
			if(t->item <= MAX_INT && t->item >= MIN_INT) 
			{
				printf("%d", t->item);	
				
			}
			else
			{
				PrintError("Integer exceeds valid size");
			}
			return;
			
		case(MINUS_NUMBER_CONSTANT):	
			if(t->item <= MAX_INT && t->item >= MIN_INT)
			{
				printf("(-%d)", t->item);	
				
			}
			else
			{
				PrintError("Integer exceeds valid size");
			}
			return;
			
		case(DECIMAL_NUMBER_CONSTANT):
			if(t->item <= MAX_INT && t->item >= MIN_INT)
			{
				printf("%d.", t->item);
				printf("%d", t->first->item);	
			}
			else
			{
				PrintError("Integer exceeds valid size");
			}
				
			return;
		
		case(MINUS_DECIMAL_NUMBER_CONSTANT):
			if(t->item <= MAX_INT && t->item >= MIN_INT)
			{
				printf("(-");
				printf("%d.", t->item);
				printf("%d)", t->first->item);	
			}
			else
			{
				PrintError("Integer exceeds valid size");
			}
								
			return;
		}
					
	WriteCode(t->first);
	WriteCode(t->second);	
	WriteCode(t->third);	
}


#include "lex.yy.c"
