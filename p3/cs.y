%{
#include <stdio.h>
//#define printf(a, ...) 

struct op_s
{
	int brf;	// Function open brace on same line
	int blf;	// Function open brace on new line
	
	int brs;	// Struct open brace on same line
	int bls;	// Struct open brace on new line
	
	int br;		// Statement open brace on same line
	int bl;		// Statement open brace on new line
} op;

%}
%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start S
%%

primary_expression
        : IDENTIFIER
        | CONSTANT
        | STRING_LITERAL
        | '(' expression ')'
        ;

postfix_expression
        : primary_expression
        | postfix_expression '[' expression ']'
        | postfix_expression '(' ')'
        | postfix_expression '(' argument_expression_list ')'
        | postfix_expression '.' IDENTIFIER
        | postfix_expression PTR_OP IDENTIFIER
        | postfix_expression INC_OP
        | postfix_expression DEC_OP
        ;

argument_expression_list
        : assignment_expression
        | argument_expression_list ',' assignment_expression
        ;

unary_expression
        : postfix_expression
        | INC_OP unary_expression
        | DEC_OP unary_expression
        | unary_operator cast_expression
        | SIZEOF unary_expression
        | SIZEOF '(' type_name ')'
        ;

unary_operator
        : '&'
        | '*'
        | '+'
        | '-'
        | '~'
        | '!'
        ;

cast_expression
        : unary_expression
        | '(' type_name ')' cast_expression
        ;

multiplicative_expression
        : cast_expression
        | multiplicative_expression '*' cast_expression
        | multiplicative_expression '/' cast_expression
        | multiplicative_expression '%' cast_expression
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression
        | additive_expression '-' multiplicative_expression
        ;

shift_expression
        : additive_expression
        | shift_expression LEFT_OP additive_expression
        | shift_expression RIGHT_OP additive_expression
        ;

relational_expression
        : shift_expression
        | relational_expression '<' shift_expression
        | relational_expression '>' shift_expression
        | relational_expression LE_OP shift_expression
        | relational_expression GE_OP shift_expression
        ;

equality_expression
        : relational_expression
        | equality_expression EQ_OP relational_expression
        | equality_expression NE_OP relational_expression
        ;

and_expression
        : equality_expression
        | and_expression '&' equality_expression
        ;

exclusive_or_expression
        : and_expression
        | exclusive_or_expression '^' and_expression
        ;

inclusive_or_expression
        : exclusive_or_expression
        | inclusive_or_expression '|' exclusive_or_expression
        ;

logical_and_expression
        : inclusive_or_expression
        | logical_and_expression AND_OP inclusive_or_expression
        ;

logical_or_expression
        : logical_and_expression
        | logical_or_expression OR_OP logical_and_expression
        ;

conditional_expression
        : logical_or_expression
        | logical_or_expression '?' expression ':' conditional_expression
        ;

assignment_expression
        : conditional_expression
        | unary_expression assignment_operator assignment_expression
        ;

assignment_operator
        : '='
        | MUL_ASSIGN
        | DIV_ASSIGN
        | MOD_ASSIGN
        | ADD_ASSIGN
        | SUB_ASSIGN
        | LEFT_ASSIGN
        | RIGHT_ASSIGN
        | AND_ASSIGN
        | XOR_ASSIGN
        | OR_ASSIGN
        ;

expression
        : assignment_expression
        | expression ',' assignment_expression
        ;

constant_expression
        : conditional_expression
        ;

declaration
        : declaration_specifiers ';' declaration_separator
        | declaration_specifiers init_declarator_list ';' declaration_separator
        ;

declaration_separator
	:
	| '\n'

declaration_specifiers
        : storage_class_specifier
        | storage_class_specifier declaration_specifiers
        | type_specifier
        | type_specifier declaration_specifiers
        | type_qualifier
        | type_qualifier declaration_specifiers
        ;

init_declarator_list
        : init_declarator
        | init_declarator_list ',' init_declarator
        ;

init_declarator
        : declarator
        | declarator '=' initializer
        ;

storage_class_specifier
        : TYPEDEF
        | EXTERN
        | STATIC
        | AUTO
        | REGISTER
        ;

type_specifier
        : VOID
        | CHAR
        | SHORT
        | INT
        | LONG
        | FLOAT
        | DOUBLE
        | SIGNED
        | UNSIGNED
        | struct_or_union_specifier
        | enum_specifier
        | TYPE_NAME
        ;

struct_or_union_specifier
        : struct_or_union IDENTIFIER struct_or_union_separator '{' '\n'  struct_declaration_list '}'
        | struct_or_union struct_or_union_separator '{' '\n' struct_declaration_list '}'
        | struct_or_union IDENTIFIER
        ;

struct_or_union_separator
	: {op.brs++;}
	| '\n' {op.bls++;}

struct_or_union
        : STRUCT
        | UNION
        ;

struct_declaration_list
        : struct_declaration
        | struct_declaration_list struct_declaration
        ;

struct_declaration
        : specifier_qualifier_list struct_declarator_list ';' '\n'
        ;

specifier_qualifier_list
        : type_specifier specifier_qualifier_list
        | type_specifier
        | type_qualifier specifier_qualifier_list
        | type_qualifier
        ;

struct_declarator_list
        : struct_declarator
        | struct_declarator_list ',' struct_declarator
        ;

struct_declarator
        : declarator
        | ':' constant_expression
        | declarator ':' constant_expression
        ;

enum_specifier
        : ENUM '{' enumerator_list '}'
        | ENUM IDENTIFIER '{' enumerator_list '}'
        | ENUM IDENTIFIER
        ;

enumerator_list
        : enumerator
        | enumerator_list ',' enumerator
        ;

enumerator
        : IDENTIFIER
        | IDENTIFIER '=' constant_expression
        ;

type_qualifier
        : CONST
        | VOLATILE
        ;

declarator
        : pointer direct_declarator
        | direct_declarator
        ;

direct_declarator
        : IDENTIFIER
        | '(' declarator ')'
        | direct_declarator '[' constant_expression ']'
        | direct_declarator '[' ']'
        | direct_declarator '(' parameter_type_list ')'
        | direct_declarator '(' identifier_list ')'
        | direct_declarator '(' ')'
        ;

pointer
        : '*'
        | '*' type_qualifier_list
        | '*' pointer
        | '*' type_qualifier_list pointer
        ;

type_qualifier_list
        : type_qualifier
        | type_qualifier_list type_qualifier
        ;


parameter_type_list
        : parameter_list
        | parameter_list ',' ELLIPSIS
        ;

parameter_list
        : parameter_declaration
        | parameter_list ',' parameter_declaration
        ;

parameter_declaration
        : declaration_specifiers declarator
        | declaration_specifiers abstract_declarator
        | declaration_specifiers
        ;

identifier_list
        : IDENTIFIER
        | identifier_list ',' IDENTIFIER
        ;

type_name
        : specifier_qualifier_list
        | specifier_qualifier_list abstract_declarator
        ;

abstract_declarator
        : pointer
        | direct_abstract_declarator
        | pointer direct_abstract_declarator
        ;

direct_abstract_declarator
        : '(' abstract_declarator ')'
        | '[' ']'
        | '[' constant_expression ']'
        | direct_abstract_declarator '[' ']'
        | direct_abstract_declarator '[' constant_expression ']'
        | '(' ')'
        | '(' parameter_type_list ')'
        | direct_abstract_declarator '(' ')'
        | direct_abstract_declarator '(' parameter_type_list ')'
        ;

initializer
        : assignment_expression
        | '{' initializer_list '}'
        | '{' initializer_list ',' '}'
        ;

initializer_list
        : initializer
        | initializer_list ',' initializer
        ;

statement
	: statement_single single_statement_separator


single_statement_separator
	:
	| '\n'

statement_single
        : labeled_statement
        | compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement
        ;

labeled_statement
        : IDENTIFIER ':' statement
        | CASE constant_expression ':' statement
        | DEFAULT ':' statement
        ;

compound_statement
	: '{' real_statement '}' { /*op.br++;*/}
	| '{' '\n' real_statement '}' { /*op.bl++;*/}
	| '{' '\n' real_statement '\n' '}' { /*op.bl++;*/}


real_statement
        : 
        | statement_list
        | declaration_list
        | declaration_list statement_list
        ;

declaration_list
        : declaration
        | declaration_list declaration
        ;

statement_list
        : statement
        | statement_list statement
        ;

expression_statement
        : ';' '\n'
        | ';'
        | expression ';' '\n'
        | expression ';'
        ;

selection_statement
        : IF '(' expression ')' statement_separator statement
        | IF '(' expression ')' statement_separator statement ELSE statement
        | SWITCH '(' expression ')' statement_separator statement
        ;

iteration_statement
        : WHILE '(' expression ')' statement_separator statement
        | DO statement_separator statement WHILE '(' expression ')' ';'
        | FOR '(' expression_statement expression_statement ')' statement_separator statement
        | FOR '(' expression_statement expression_statement expression ')' statement_separator statement
        ;

statement_separator
	: {op.br++;}
	| '\n' {op.bl++;}

jump_statement
        : GOTO IDENTIFIER ';'
        | CONTINUE ';'
        | BREAK ';'
        | RETURN ';'
        | RETURN expression ';'
        ;

translation_unit
        : external_declaration
        | translation_unit external_declaration
        ;

external_declaration
        : function_definition
        | declaration
        ;

function_definition
        : declaration_specifiers declarator declaration_list function_separator compound_statement
        | declaration_specifiers declarator function_separator compound_statement
        | declarator declaration_list function_separator compound_statement
        | declarator function_separator compound_statement
        ;

function_separator
	: 	{op.brf++;}
	| '\n'	{op.blf++;}

S
	:
	| translation_unit {fprintf(stderr, "OK\n");}
	| translation_unit '\n' {fprintf(stderr, "OK\n");}
	| S translation_unit {fprintf(stderr, "OK\n");}
	| S translation_unit '\n' {fprintf(stderr, "OK\n");}
	

%%
#include <stdio.h>

extern char yytext[];
extern int column;
extern int spaces_count[80];
extern int tabs_count[80];

yyerror(s)
char *s;
{
        fflush(stdout);
        fprintf(stdout, "\n%*s\n%*s\n", column, "^", column, s);
}

void print_spaces()
{
	int i;
	fprintf(stderr, "Spaces stats:\n");
	for(i = 0; i<80; i++)
	{
		if(spaces_count[i])
			fprintf(stderr, "%d: %d\n", i, spaces_count[i]);
	}
	fprintf(stderr, "Tabs stats:\n");
	for(i = 0; i<80; i++)
	{
		if(tabs_count[i])
			fprintf(stderr, "%d: %d\n", i, tabs_count[i]);
	}
}

int gcd(int a, int b)
{
	int c;
	while(a != 0)
	{
		c = a;
		a = b%a;
		b = c;
	}
	return b;
}

void calculate_indentation_space()
{
	int i, j;
	int max_spaces = 0;
	int diferent_spaces = 0;
	int indentation_max = 0;
	int indentation = 0;
	int gcd_table[80] = {0};
	int gcd_table2[80] = {0};
	
	for(i = 79; i >= 0; i--)
	{
		if(spaces_count[i])
		{
			max_spaces = i;
			break;
		}
	}

	for(i = max_spaces; i > 0; i--)
	{
		for(j = 1; j<80; j++)
		{
			if(!spaces_count[j]) continue;
			if(gcd(j, i) == i)
			{
				gcd_table2[i] += spaces_count[j];
				gcd_table[i]++;
			}
		}
		//if(gcd_table[i] && spaces_count[i]) printf("gcd %d = %d -> %d\n", i, gcd_table[i], gcd_table2[i]);
	}

	for(i = 1; i<=max_spaces; i++)
	{
		if((indentation_max < gcd_table2[i]) && spaces_count[i])
		{
			indentation = i;
			indentation_max = gcd_table2[i];
		}
	}
	//printf("La indentacion estimada es: %d espacios\n", indentation);
	printf(" -i%d", indentation);
	
}

void calculate_indentation()
{
	int i;
	int tabs = 0, spaces = 0;
	int use_tabs = 1;
	for(i = 1; i<79; i++)
	{
		if(spaces_count[i]) spaces += spaces_count[i];
		if(tabs_count[i]) tabs += tabs_count[i];

	}
	if(tabs < spaces)
	{
		use_tabs = 0;
		printf(" -nut");
		calculate_indentation_space();
	}
	else
	{
		printf(" -ut -ts8");
	}
	
}

extern int sai, nsai;
extern int saf, nsaf;
extern int saw, nsaw;

int main(int argc, char *argv)
{
	yyparse();

	printf("-linux -bli0");
	
	if(op.bl > op.br) printf(" -bl");
	else printf(" -br");

	if(op.blf > op.brf) printf(" -blf");
	else printf(" -brf");
	
	if(op.bls > op.brs) printf(" -bls");
	else printf(" -brs");

	if(sai >= nsai) printf(" -sai");
	else printf(" -nsai");

	if(saf >= nsaf) printf(" -saf");
	else printf(" -nsaf");

	if(saw >= nsaw) printf(" -saw");
	else printf(" -nsaw");

	print_spaces();
	calculate_indentation();
	printf("\n");

	return 0;
}
