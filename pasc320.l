%{
#include <sys/types.h>
#include <unistd.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pasc320.tab.h"

#define MAX_STR_CONST 	200
#define MAX_LINE_SIZE	200
#define MAX_ERRORS		5


/*Function with which we store the line every time we find a new line character*/
void error_string(void);

/*Print error messages when errors found in code*/
extern void yyerror(char *message);

/*Functions that return the literal values in decimal format istead of a string one*/
int decIntHandle(char *str);
int hexIntHandle(char *str);
int binIntHandle(char *str);

/*Functions that return the literal values in real format istead of a string one*/
double decRealHandle(char *str);
double hexRealHandle(char *str);
double binRealHandle(char *str);

/*Pointer we use to access the file and store the line which we found an error*/
extern FILE *yyin1;
/*Flag = 0 when yyin1 find eof. Flag = 1 otherwise*/
extern int flag;
/*error_count :# of errors encountered in flex*/
// extern int error_count;
/*lineno: # of lines in the program*/
int lineno=1;
extern char linestream[MAX_LINE_SIZE];
/*in string_buf we store the strings encountered in the program*/ 
char string_buf[MAX_STR_CONST];
char *string_buf_ptr;

%}

%option nounput
%option noinput

/*option noyywrap:makes the scanner not call yywrap() upon an end-of-file, but simply assume that there are no more files to scan (until the user points yyin at a new file and calls yylex() again)*/
%option noyywrap
/*option case-insensitive:the case of letters given in the flex input.Patterns will be ignored  and tokens in the input will be matched regardless of case*/
%option case-insensitive
/*State of comments*/
%x COMMENT 
/*State of strings*/
%x STRING


WHITESPACE 														[ \t]*
NEWLINE 														[\n]
LETTER															[A-Za-z_]
DIGIT 															[0-9]
LETTERDIGIT 													({LETTER}|{DIGIT})
HEXDIGIT 														[0-9A-F]
EXPONENT 														E[+-]?(0|[1-9]{DIGIT}*)
/*UNSINT:unsigned integer */
UNSINT 															{DIGIT}+
ASCII 															[ !"#$%&')(*,-./:;<=>}{?@\^_`|~\[\]]
%%
 /* KEYWORDS */
"PROGRAM" 														{error_string(); printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_PROGRAM, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_PROGRAM;}
"CONST"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CONST;}
"TYPE"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_TYPE, lineno);
																	yylval.strval = strdup(yytext);
																	return T_TYPE;}
"ARRAY"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_ARRAY, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_ARRAY;}
"SET"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_SET, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_SET;}
"OF"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_OF, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_OF;}
"RECORD"														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_RECORD, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_RECORD;}
"VAR"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_VAR, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_VAR;}
"FORWARD"														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_FORWARD, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_FORWARD;}
"FUNCTION"														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_FUNCTION, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_FUNCTION;}
"PROCEDURE"														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_PROCEDURE, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_PROCEDURE;}
"INTEGER"														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_INTEGER, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_INTEGER;}
"REAL"				 											{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_REAL, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_REAL;}
"BOOLEAN"														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_BOOLEAN, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_BOOLEAN;}
"CHAR"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CHAR, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CHAR;}
"BEGIN"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_BEGIN, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_BEGIN;}
"END"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_END, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_END;}
"IF"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_IF, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_IF;}
"THEN"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_THEN, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_THEN;}
"ELSE"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_ELSE, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_ELSE;}
"WHILE"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_WHILE, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_WHILE;}
"DO"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_DO, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_DO;}
"FOR"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_FOR, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_FOR;}
"DOWNTO"														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_DOWNTO, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_DOWNTO;}
"TO"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_TO, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_TO;}
"WITH"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_WITH, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_WITH;}
"READ"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_READ, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_READ;}
"WRITE"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_WRITE, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_WRITE;}
 /* BOOLEAN KEYWORDS */
"TRUE"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_BCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_BCONST;}
"FALSE"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_BCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_BCONST;}
"OR"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_OROP, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_OROP;}
"*"|"/"|"DIV"|"MOD"|"AND" 										{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_MULDIVANDOP, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_MULDIVANDOP;}
"NOT"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_NOTOP, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_NOTOP;}
"IN"															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_INOP, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_INOP;}
 /* IDENTIFIER */
(\_)?[a-zA-Z]({LETTERDIGIT}*[a-zA-Z0-9])*						{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_ID, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_ID;}
 /* REAL HEXADEMICAL CONSTANT */
(0H)([1-9A-F]{HEXDIGIT}*)?(\.)(0|0*[1-9A-F]{HEXDIGIT}*)			{printf("[TOKEN FOUND: %s = %lf | TOKEN NUMBER: %d | LINE: %d]\n",yytext, hexRealHandle(yytext), T_RCONST, lineno);
																	yylval.doubleval = hexRealHandle(yytext);
																	return T_RCONST;}
 /* REAL BINARY CONSTANT */
(0B)(0|1[01]*)?(\.)(0|0*1[01]*)									{printf("[TOKEN FOUND: %s = %lf | TOKEN NUMBER: %d | LINE: %d]\n",yytext, binRealHandle(yytext), T_RCONST, lineno); 
																	yylval.doubleval = binRealHandle(yytext);
																	return T_RCONST;}
 
 /* REAL DECIMAL CONSTANT */
(0|[1-9]{DIGIT}*)?(\.)(0|0*[1-9]{DIGIT}*)						{printf("[TOKEN FOUND: %s = %lf | TOKEN NUMBER: %d | LINE: %d]\n",yytext, decRealHandle(yytext), T_RCONST, lineno);
																	yylval.doubleval = decRealHandle(yytext);
																	return T_RCONST;}
(0|[1-9]{DIGIT}*){EXPONENT}										{printf("[TOKEN FOUND: %s = %lf | TOKEN NUMBER: %d | LINE: %d]\n",yytext, decRealHandle(yytext), T_RCONST, lineno);
																	yylval.doubleval = decRealHandle(yytext);
																	return T_RCONST;}
(0|[1-9]{DIGIT}*)?((\.)(0|0*[1-9]{DIGIT}*){EXPONENT})			{printf("[TOKEN FOUND: %s = %lf | TOKEN NUMBER: %d | LINE: %d]\n",yytext, decRealHandle(yytext), T_RCONST, lineno);
																	yylval.doubleval = decRealHandle(yytext);
																	return T_RCONST;} 
 /* HEXADEMICAL CONSTANT */
(0H)([1-9A-F])({HEXDIGIT}*)										{printf("[TOKEN FOUND: %s = %d | TOKEN NUMBER: %d | LINE: %d]\n",yytext, hexIntHandle(yytext), T_ICONST, lineno);
																	yylval.intval = hexIntHandle(yytext);
																	return T_ICONST;}
 /* BINARY CONSTANT */
(0B)1[01]*														{printf("[TOKEN FOUND: %s = %d | TOKEN NUMBER: %d | LINE: %d]\n",yytext, binIntHandle(yytext), T_ICONST, lineno);
																	yylval.intval = binIntHandle(yytext);
																	return T_ICONST;}
 /* INTEGER CONSTANT */
0|[1-9]{DIGIT}*													{printf("[TOKEN FOUND: %s = %d | TOKEN NUMBER: %d | LINE: %d]\n",yytext, decIntHandle(yytext), T_ICONST, lineno); 
																	yylval.intval = decIntHandle(yytext);
																	return T_ICONST;}
 /* CCONST */
(\'\\n\')														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, 		lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
(\'\\t\')														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
(\'\\f\')														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
(\'\\r\')														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
(\'\\b\')														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
(\'\\v\')														{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
('){ASCII}(')													{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
('){LETTER}(')													{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
('){DIGIT}(')													{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_CCONST, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_CCONST;}
 /*Operators*/																
">"|">="|"<"|"<="												{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_RELOP, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_RELOP;}
[+-]															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_ADDOP, lineno); 
																	yylval.strval = strdup(yytext);
																	/*yylval.charval=yytext[0];*/
																	return T_ADDOP;}
"("																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_LPAREN, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_LPAREN;}
")"																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_RPAREN, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_RPAREN;}
";"																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_SEMI, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_SEMI;}
"."																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_DOT, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_DOT;}
","																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_COMMA, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_COMMA;}
"="																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_EQU, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_EQU;}
":"																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_COLON, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_COLON;}
"["																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_LBRACK, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_LBRACK;}
"]"																{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_RBRACK, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_RBRACK;}
":="															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_ASSIGN, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_ASSIGN;}
".."															{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_DOTDOT, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_DOTDOT;}
 /*<INITIAL><<EOF>>												{printf("[TOKEN FOUND: %s | TOKEN NUMBER: %d | LINE: %d]\n", yytext, T_EOF, lineno); 
																	yylval.strval = strdup(yytext);
																	return T_EOF;}*/
 /* Comments */
"{"																BEGIN(COMMENT);
<COMMENT>[^}\n]+												;
<COMMENT>\n														{if (flag) error_string(); lineno++;}
<COMMENT><<EOF>>												{yyerror("Unterminated comment"); yyterminate();}
<COMMENT>"}"													BEGIN(INITIAL);
 /* Strings */ 
\"																{string_buf_ptr = string_buf; BEGIN(STRING);}
<STRING>\"														{*string_buf_ptr = '\0';
																 printf("[STRING FOUND: \"%s\" | TOKEN NUMBER: %d | LINE: %d]\n" ,string_buf, T_STRING, lineno);
																 BEGIN(INITIAL);
																 return T_STRING;}

<STRING>\n														{yyerror("Illegal input in string");}
<STRING>\\n														{*string_buf_ptr++ = '\n';}
<STRING>\\t														{*string_buf_ptr++ = '\t';}
<STRING>\\r														{*string_buf_ptr++ = '\r';}
<STRING>\\b														{*string_buf_ptr++ = '\b';}
<STRING>\\v														{*string_buf_ptr++ = '\v';}
<STRING>\\f														{*string_buf_ptr++ = '\f';}
<STRING>\\\n													{if (flag) error_string(); lineno++;}
<STRING>\\(.)													{*string_buf_ptr++ = yytext[1];}
<STRING>[^\\\n\"]+												{char *yptr = yytext; 
																while ( *yptr ){ *string_buf_ptr++ = *yptr++;}}
<STRING><<EOF>>													{yyerror("Unterminated string"); yyterminate();}
{WHITESPACE}													;
{NEWLINE}														{if (flag) error_string(); lineno++;} 
.																yyerror("Illegal input");
%%
int decIntHandle(char *str){
    return atoi(str);
}
int hexIntHandle(char *str){
    int res;
    res = (int)strtol(&str[2], NULL, 16);
    return res;
}
int binIntHandle(char *str){
    int res;
    res = (int)strtol(&str[2], NULL, 2);
    return res;
}
double decRealHandle(char *str){
	return atof(str);
}
double hexRealHandle(char *str){
    double res;
    int i;
    int length_real;
    char *character;
    character = strchr(str, '.');
    length_real = strlen(character) - 1;
    res = (int)strtol(&str[2], &character, 16);
    for (i = 1; i <= length_real; i++){
		if ((character[i] == 'A') || (character[i] == 'B') || (character[i] == 'C') || (character[i] == 'D') || (character[i] == 'E') || (character[i] == 'F')){
			res = (character[i] - '7') * (1 / pow(16,i)) + res;
		}else{
			if ((character[i] == 'a') || (character[i] == 'b') || (character[i] == 'c') || (character[i] == 'd') || (character[i] == 'e') || (character[i] == 'f')){
				res = (character[i] - 'W') * (1 / pow(16,i)) + res;
			}else{
				res = (character[i] - '0') * (1 / pow(16,i)) + res;
			}
		}
	}
    return res;
}
double binRealHandle(char *str){
	double res;
	int i;
	int length_real;
	char *character;
	character = strchr(str, '.');
	length_real = strlen(character) - 1;    
	res = (int)strtol(&str[2], &character, 2);
	for (i = 1; i <= length_real; i++){
		res = (character[i] - '0') * (1 / pow(2,i)) + res;
	}
	return res;
}
void error_string(void){
	int k;
	char c;
	
	for(k = 0; k < MAX_LINE_SIZE; k++){
		linestream[k] = '\0';
	}
	
	k = 0;
	while(1){
		c = fgetc(yyin1);
		if( feof(yyin1) || c == '\n' ){ 
			break;
		}
		linestream[k] = c;
		k++;
	}
	if (feof(yyin1)){
		flag = 0;
	}
}