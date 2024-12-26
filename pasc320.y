%{
#include <sys/types.h>
#include <unistd.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashtbl.h"
#define MAX_STR_CONST 	200
#define MAX_LINE_SIZE	200
#define MAX_ERRORS		5


HASHTBL *hashtbl;
int scope=0;

extern int yylex();
extern char *yytext;
extern FILE *yyin;

extern void yyterminate(), error_string();
void yyerror(char *message);

/*Pointer we use to access the file and store the line which we found an error*/
FILE *yyin1;
/*Flag = 0 when yyin1 find eof. Flag = 1 otherwise*/
int flag=1;
/*error_count :# of errors encountered in flex*/
int error_count = 0;
/*lineno: # of lines in the program*/
extern int lineno;
char linestream[MAX_LINE_SIZE];
/*in string_buf we store the strings encountered in the program*/ 
extern char string_buf[MAX_STR_CONST];
extern char *string_buf_ptr;

%}

%union{
	int intval;
	double doubleval;
	char *strval;
}
 
%start program
%token <strval> T_PROGRAM T_CONST T_TYPE T_ARRAY T_SET T_OF T_RECORD T_VAR T_FORWARD T_FUNCTION T_PROCEDURE T_INTEGER T_REAL 
%token <strval> T_BOOLEAN T_CHAR T_BEGIN T_END T_IF T_THEN T_ELSE T_WHILE T_DO T_FOR T_DOWNTO T_TO T_WITH T_READ T_WRITE
%token <strval> T_BCONST T_OROP T_MULDIVANDOP T_NOTOP T_INOP T_ID T_CCONST T_RELOP T_ADDOP T_LPAREN T_RPAREN T_SEMI
%token <strval> T_DOT T_COMMA T_EQU T_COLON T_LBRACK T_RBRACK T_ASSIGN T_DOTDOT T_EOF T_STRING
%token <doubleval> T_RCONST 
%token <intval> T_ICONST 
%type <strval> program header declarations constdefs constant_defs expression variable expressions constant 
%type <strval> elexpression elexpressions type_def type_defs typedefs dims limit limits typename standard_type
%type <strval> fields identifiers vardefs variable_defs subprogram subprograms sub_header formal_parameters 
%type <strval> parameter_list pass comp_statement statements statement if_statement if_tail while_statement 
%type <strval> for_statement iter_space with_statement io_statement read_list write_list write_item field
%type <strval> setexpression expression1 expression2 expression3

%nonassoc IFX
%nonassoc T_ELSE
%nonassoc EXP1
%nonassoc EXP2
%nonassoc EXP3

%left T_OROP T_ADDOP
%left T_MULDIVANDOP
%left T_RELOP T_EQU T_INOP



%%

program			 :header declarations subprograms 								{scope++;}
				  comp_statement 												{hashtbl_get(hashtbl, scope); scope--;}
				  T_DOT 														{hashtbl_get(hashtbl, scope);
																				 printf("\t\tprogram -> header declarations subprograms comp_statement DOT\n");
																				 printf("--- NUMBER OF ERRORS = %d ---\n", error_count);}
				 ;
	   
header			 :T_PROGRAM T_ID T_SEMI											{hashtbl_insert(hashtbl,$2, NULL ,scope); printf("\t\theader -> T_PROGRAM T_ID T_SEMI\n");}
				 |T_PROGRAM T_ID												{hashtbl_insert(hashtbl,$2, NULL ,scope); printf("\t\theader -> T_PROGRAM T_ID\n"); }
				  error															{printf("\tT_SEMI missing\n");}
				 ;
	  
declarations	 :constdefs typedefs vardefs									{printf("\t\tdeclarations -> constdefs typedefs vardefs\n");}
				 ;
		    
constdefs:		 T_CONST constant_defs T_SEMI									{printf("\t\tconstdefs -> T_CONST constant_defs T_SEMI\n");}
				 |T_CONST constant_defs error									{printf("\t\tconstdefs -> T_CONST constant_defs\n");
																				 printf("\tT_SEMI missing\n");}
				 |/* å */														{printf("\t\tconstdefs -> å\n");}
				 ;
		 
constant_defs	 :constant_defs T_SEMI T_ID										{hashtbl_insert(hashtbl,$3,NULL ,scope);}
				  T_EQU expression												{printf("\t\tconstant_defs -> constant_defs SEMI ID EQU expression\n");}
				 |constant_defs error											{printf("\tT_SEMI missing\n");}
				  T_ID															{hashtbl_insert(hashtbl,$4,NULL ,scope);}
				  T_EQU expression												{printf("\t\tconstant_defs -> constant_defs ID EQU expression\n");}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope);}
				  T_EQU expression												{printf("\t\tconstant_defs -> ID EQU expression\n");}
				 ;

expression		 :expression T_RELOP expression1		%prec EXP1				{printf("\t\texpression -> expression RELOP expression\n");} 
				 |expression T_EQU expression1			%prec EXP1				{printf("\t\texpression -> expression T_EQU expression\n");}
				 |expression T_INOP expression1			%prec EXP1				{printf("\t\texpression -> expression T_INOP expression\n");}
				 |expression1							%prec EXP1				{printf("\t\texpression -> expression1\n");}
				 ;
		
expression1		 :expression1 T_ADDOP expression2		%prec EXP2				{printf("\t\texpression1 -> expression T_ADDOP expression\n");}
				 |expression1 T_OROP expression2		%prec EXP2				{printf("\t\texpression1 -> expression T_OROP expression\n");}
				 |expression2							%prec EXP2				{printf("\t\texpression1 -> expression2\n");}
				 ;
			
expression2 	 :expression2 T_MULDIVANDOP expression3							{printf("\t\texpression2 -> expression T_MULDIVANDOP expression\n");}
				 |expression3													{printf("\t\texpression2 -> expression3\n");}
				 ;
			
expression3   	 :T_ADDOP expression					%prec EXP3				{printf("\t\texpression3 -> T_ADDOP expression\n");}
				 |T_NOTOP expression					%prec EXP3				{printf("\t\texpression3 -> T_NOTOP expression\n");}
				 |variable														{printf("\t\texpression3 -> variable\n");}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope);}
				  T_LPAREN expressions T_RPAREN									{printf("\t\texpression3 -> T_LPAREN expressions T_RPAREN\n");}
				 |constant														{printf("\t\texpression3 -> constant\n");}
				 |T_LPAREN expression T_RPAREN									{printf("\t\texpression3 -> T_LPAREN expression T_RPAREN\n");}
				 |setexpression													{printf("\t\texpression3 -> setexpression\n");}
				 ;
			
variable		 :T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope); printf("\t\tvariable -> T_ID\n");}
				 |variable T_DOT T_ID											{hashtbl_insert(hashtbl,$3,NULL ,scope); printf("\t\tvariable -> variable T_DOT T_ID\n");}
				 |variable T_LBRACK expressions T_RBRACK 						{printf("\t\tvariable -> variable T_LBRACK expressions T_RBRACK\n");}
				 ;
		
expressions		 :expressions T_COMMA expression								{printf("\t\texpressions -> expressions T_COMMA expression\n");}
				 |expression													{printf("\t\texpressions -> expression\n");}
				 ;
		   
constant		 :T_ICONST														{printf("\t\tconstant -> T_ICONST\n");}
				 |T_RCONST														{printf("\t\tconstant -> T_RCONST\n");}
				 |T_BCONST														{printf("\t\tconstant -> T_BCONST\n");}
				 |T_CCONST														{printf("\t\tconstant -> T_CCONST\n");}
				 ;
		
setexpression	 :T_LBRACK elexpressions T_RBRACK								{printf("\t\tsetexpression -> T_LBRACK elexpressions T_RBRACK\n");}
				 |T_LBRACK T_RBRACK												{printf("\t\tsetexpression -> T_LBRACK T_RBRACK\n");}
				 ;
			 
elexpressions	 :elexpressions T_COMMA elexpression							{printf("\t\telexpressions -> elexpressions T_COMMA elexpression\n");}
				 |elexpression													{printf("\t\telexpressions -> elexpression\n");}
				 ;
			 
elexpression	 :expression T_DOTDOT expression								{printf("\t\telexpression -> expression T_DOTDOT expression\n");}
				 |expression													{printf("\t\telexpression -> expression\n");}
				 ;
			
typedefs		 :T_TYPE type_defs T_SEMI										{printf("\t\ttypedefs -> T_TYPE type_defs T_SEMI\n");}
				 |T_TYPE type_defs error										{printf("\tT_SEMI missing\n"); printf("\t\ttypedefs -> T_TYPE type_defs\n");}
				 |/* å */														{printf("\t\ttypedefs -> å\n");}
				 ;
		
type_defs		 :type_defs T_SEMI T_ID											{hashtbl_insert(hashtbl,$3,NULL ,scope);}
				  T_EQU type_def												{printf("\t\ttype_defs -> type_defs T_SEMI T_ID T_EQU type_def\n");}
				 |type_defs error											 	{printf("\tT_SEMI missing\n");}
				  T_ID															{hashtbl_insert(hashtbl,$4,NULL ,scope);}
				  T_EQU type_def												{printf("\t\ttype_defs -> type_defs T_ID T_EQU type_def\n");}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope);}
				  T_EQU type_def												{printf("\t\ttype_defs -> T_ID T_EQU type_def\n");}
				 ;
		 
type_def		 :T_ARRAY T_LBRACK dims T_RBRACK T_OF typename					{printf("\t\ttype_def -> T_ARRAY T_LBRACK dims T_RBRACK T_OF typename\n");}
				 |T_ARRAY T_LBRACK dims                                         
				 error  														{printf("\tT_LBRACK missing\n");}
				 T_OF typename					              					{printf("\t\ttype_def -> T_ARRAY T_LBRACK dims T_OF typename\n");}
				 |T_SET T_OF typename											{printf("\t\ttype_def -> T_SET T_OF typename\n");}
				 |T_RECORD fields T_END											{printf("\t\ttype_def -> T_RECORD fields T_END\n");}
				 |T_LPAREN identifiers T_RPAREN									{printf("\t\ttype_def -> T_LPAREN identifiers T_RPAREN\n");}
				 |limit T_DOTDOT limit											{printf("\t\ttype_def -> limit T_DOTDOT limit\n");}
				 ;
		
dims			 :dims T_COMMA limits											{printf("\t\tdims -> dims T_COMMA limits\n");}
				 |limits														{printf("\t\tdims -> limits\n");}	
				 ;
	
limits			 :limit T_DOTDOT limit											{printf("\t\tlimits -> limit T_DOTDOT limit\n");}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope); printf("\t\tlimits -> T_ID\n");}
				 ;
	  
limit			 :T_ADDOP T_ICONST												{printf("\t\tlimit -> T_ADDOP T_ICONST\n");}
				 |T_ADDOP T_ID													{hashtbl_insert(hashtbl,$2,NULL ,scope); printf("\t\tlimit -> T_ADDOP T_ID\n");}
				 |T_ICONST														{printf("\t\tlimit -> T_ICONST\n");}
				 |T_CCONST														{printf("\t\tlimit -> T_CCONST\n");}
				 |T_BCONST														{printf("\t\tlimit -> T_BCONST\n");}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope); printf("\t\tlimit -> T_ID\n");}
				 ;
	 
typename		 :standard_type													{printf("\t\ttypename -> standard_type\n");}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope); printf("\t\ttypename -> T_ID\n");}
				 ;
		
standard_type	 :T_INTEGER 													{printf("\t\tstandard_type -> T_INTEGER\n");}
				 |T_REAL														{printf("\t\tstandard_type -> T_REAL\n");}
				 |T_BOOLEAN														{printf("\t\tstandard_type -> T_BOOLEAN\n");}
				 |T_CHAR														{printf("\t\tstandard_type -> T_CHAR\n");}
				 ;
			 
fields			 :fields T_SEMI field											{printf("\t\tfields -> fields T_SEMI field\n");}
				 |fields error 													{printf("\tT_SEMI missing\n");}
				  field															{printf("\t\tfields -> fields field\n");}
				 |field															{printf("\t\tfields -> field\n");}
				 ;
	  
field			 :identifiers T_COLON typename									{printf("\t\tfield -> dentifiers T_COLON typename\n");}
				 ;
	 
identifiers		 :identifiers T_COMMA T_ID										{hashtbl_insert(hashtbl,$3,NULL ,scope);printf("\t\tidentifiers -> identifiers T_COMMA T_ID\n");}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope); printf("\t\tidentifiers ->T_ID\n");}
				 ;
		   
vardefs			 :T_VAR variable_defs T_SEMI									{printf("\t\tvardefs -> T_VAR variable_defs T_SEMI\n");}
				 |T_VAR variable_defs error										{printf("\tT_SEMI missing\n"); printf("\t\tvardefs -> T_VAR variable_defs\n");}
				 |/* å */														{printf("\t\tvardefs -> å\n");}
				 ;

variable_defs	 :variable_defs T_SEMI identifiers T_COLON typename				{printf("\t\tvariable_defs -> variable_defs T_SEMI identifiers T_COLON typename\n");}
				 |variable_defs error 											{printf("\tT_SEMI missing\n");}
				  identifiers T_COLON typename									{printf("\t\tvariable_defs -> variable_defs identifiers T_COLON typename\n");}
				 |identifiers T_COLON typename									{printf("\t\tvariable_defs -> identifiers T_COLON typename\n");}
				 ;
			 
subprograms		 :subprograms subprogram T_SEMI									{printf("\t\tsubprograms -> subprograms subprogram T_SEMI\n");}
				 |subprograms subprogram error									{printf("\t\tsubprograms -> subprograms subprogram\n");}
				 |/* å */														{printf("\t\tsubprograms -> å\n");}
				 ;

subprogram		 :sub_header T_SEMI T_FORWARD									{printf("\t\tsubprogram -> sub_header T_SEMI T_FORWARD\n");}
				 |sub_header error T_FORWARD									{printf("\tT_SEMI missing\n"); printf("\t\tsubprogram -> sub_header T_FORWARD\n");}
				 |sub_header T_SEMI declarations subprograms comp_statement		{hashtbl_get(hashtbl, scope); printf("\t\tsubprogram -> sub_header T_SEMI declarations subprograms comp_statement\n"); scope--;}
				 |sub_header error declarations subprograms comp_statement		{printf("\tT_SEMI missing\n"); hashtbl_get(hashtbl, scope); printf("\t\tsubprogram -> sub_header T_SEMI declarations subprograms comp_statement\n"); scope--;}
				 ;
		  
sub_header		 :T_FUNCTION T_ID 												{scope++; hashtbl_insert(hashtbl,$2,NULL ,scope);}
				  formal_parameters T_COLON standard_type						{printf("\t\tsub_header -> T_FUNCTION T_ID formal_parameters T_COLON standard_type\n");}
				 |T_PROCEDURE T_ID												{scope++; hashtbl_insert(hashtbl,$2,NULL ,scope);}
				  formal_parameters												{printf("\t\tsub_header -> T_PROCEDURE T_ID formal_parameters\n");}
				 |T_FUNCTION T_ID												{hashtbl_insert(hashtbl,$2,NULL ,scope); printf("\t\tsub_header -> T_FORWARD T_ID\n");}
				 ;
		  
formal_parameters:T_LPAREN parameter_list T_RPAREN								{printf("\t\tformal_parameters -> T_LPAREN parameter_list T_RPAREN\n");}
				 |/* å */														{printf("\t\tformal_parameters -> å\n");}
				 ;
				 
parameter_list	 :parameter_list T_SEMI pass identifiers T_COLON typename		{printf("\t\tparameter_list -> parameter_list T_SEMI pass identifiers T_COLON typename\n");}
				 |parameter_list error      									{printf("\tT_SEMI missing\n");}
				 pass identifiers T_COLON typename		 						{printf("\t\tparameter_list -> parameter_list pass identifiers T_COLON typename\n");}
				 |pass identifiers T_COLON typename								{printf("\t\tparameter_list -> pass identifiers T_COLON typename\n");}
				 ;
			  
pass      		 :T_VAR															{printf("\t\tpass -> T_VAR\n");}
				 |/* å */														{printf("\t\tpass -> å\n");}
				 ;

comp_statement	 :T_BEGIN statements T_END										{printf("\t\tcomp_statement -> T_BEGIN statements T_END\n");}
				 ;
			  
statements		 :statements T_SEMI statement									{printf("\t\tstatements -> statements T_SEMI statement\n");}
				 |statement														{printf("\t\tstatements -> statement\n");}
				 ;
		  
statement		 :assignment													{printf("\t\tstatement -> assignment\n");}
				 |if_statement													{printf("\t\tstatement -> if_statement\n");}
				 |while_statement												{printf("\t\tstatement -> while_statement\n");}
				 |for_statement													{printf("\t\tstatement -> for_statement\n");}
				 |with_statement												{printf("\t\tstatement -> with_statement\n");}
				 |subprogram_call												{printf("\t\tstatement -> subprogram_call\n");}
				 |io_statement													{printf("\t\tstatement -> io_statement\n");}
				 |comp_statement												{printf("\t\tstatement -> comp_statement\n");}
				 |/* å */														{printf("\t\tstatement -> å\n");}
				 ;

assignment		 :variable T_ASSIGN expression									{printf("\t\tassignment -> variable T_ASSIGN expression\n");}
				 |variable T_ASSIGN T_STRING									{printf("\t\tassignment -> variable T_ASSIGN expression\n");}
				 ;
		  
if_statement	 :T_IF expression T_THEN statement if_tail						{printf("\t\tif_statement -> T_IF expression T_THEN statement if_tail\n");}
				 ;
			
if_tail			 :T_ELSE statement												{printf("\t\tif_tail -> T_ELSE statement\n");}
				 |/* å */%prec IFX												{printf("\t\tif_tail -> å\n");}
				 ;
				 
while_statement	 :T_WHILE expression T_DO statement								{printf("\t\twhile_statement -> T_WHILE expression T_DO statement\n");}
				 ;
			   
for_statement	 :T_FOR T_ID													{hashtbl_insert(hashtbl,$2,NULL ,scope);}
				  T_ASSIGN iter_space T_DO statement							{printf("\t\tfor_statement -> T_FOR T_ID T_ASSIGN iter_space T_DO statement\n");}
				 ;
			 
iter_space		 :expression T_TO expression									{printf("\t\titer_space -> expression T_TO expression\n");}
				 |expression T_DOWNTO expression								{printf("\t\titer_space -> expression T_DOWNTO expression\n");}
				 ;
		  
with_statement	 :T_WITH variable T_DO statement								{printf("\t\twith_statement -> T_WITH variable T_DO statement\n");}				 		 
				;
			  
subprogram_call	 :T_ID															{printf("\t\tsubprogram_call -> T_ID\n"); hashtbl_insert(hashtbl,$1,NULL ,scope);}
				 |T_ID															{hashtbl_insert(hashtbl,$1,NULL ,scope);}
				  T_LPAREN expressions T_RPAREN									{printf("\t\tsubprogram_call -> T_ID T_LPAREN expressions T_RPAREN\n");}
				 ;
			   
io_statement	 :T_READ T_LPAREN read_list T_RPAREN							{printf("\t\tio_statement -> T_READ T_LPAREN read_list T_RPAREN\n");}
				 |T_WRITE T_LPAREN write_list T_RPAREN							{printf("\t\tio_statement -> T_READ T_LPAREN write_list T_RPAREN\n");}
				 |T_WRITE T_LPAREN error T_RPAREN								{yyclearin;printf("\t\tio_statement -> T_WRITE T_LPAREN T_RPAREN\n");}
				 ;
			
read_list		 :read_list T_COMMA read_item									{printf("\t\tread_list-> read_list T_COMMA read_item\n");}
				 |read_item														{printf("\t\tread_list-> read_item\n");}
				 ;
		 
read_item		 :variable														{printf("\t\tread_item-> variable\n");}
				 ;
		 
write_list		 :write_list T_COMMA write_item									{printf("\t\twrite_list-> write_list T_COMMA write_item\n");}
				 |write_item													{printf("\t\twrite_list-> write_item\n");}
				 ;
		  
write_item		 :expression													{printf("\t\twrite_item-> expression\n");}
				 |T_STRING														{printf("\t\twrite_item-> T_STRING\n");}
				 ;


%%


int main(int argc, char *argv[]){
	

	if(!(hashtbl = hashtbl_create(10, NULL))) {
		fprintf(stderr, "ERROR: hashtbl_create() failed\n");
		exit(EXIT_FAILURE);
	}
	
	++argv; --argc;
	if( argc > 0){
		yyin = fopen(argv[0], "r");
		if (yyin == NULL){
			perror ("Error opening file"); return -1;
		}
		yyin1 = fopen(argv[0], "r");
		if (yyin1 == NULL){
			perror ("Error opening file"); return -1;
		}
	}
	yyparse();
	
	hashtbl_destroy(hashtbl);
	
	fclose(yyin);
	return(0);
}

void yyerror(char *message){
	error_count++; 
	printf("(%d)ERROR: \"%s\" | TOKEN: %s | LINE: %d | ->%s<-\n",
	error_count, message, yytext, lineno, linestream);
	if(MAX_ERRORS == error_count){
 		printf("ERRORS DETECTED IN PROGRAM: %d\nERRORS ACCEPTED: %d\nTermination...\n", error_count, MAX_ERRORS); 
 		exit(-1);
	}
}