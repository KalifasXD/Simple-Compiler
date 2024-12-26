#define T_PROGRAM		1
#define T_CONST			2	
#define T_TYPE			3
#define T_ARRAY			4	
#define T_SET			5
#define T_OF			6
#define T_RECORD		7
#define T_VAR			8
#define T_FORWARD		9
#define T_FUNCTION		10
#define T_PROCEDURE		11
#define T_INTEGER		12
#define T_REAL			13
#define T_BOOLEAN		14
#define T_CHAR			15
#define T_BEGIN			16
#define T_END			17
#define T_IF			18
#define T_THEN			19
#define T_ELSE			20
#define T_WHILE			21
#define T_DO			22
#define T_FOR			23
#define T_DOWNTO		24
#define T_TO			25
#define T_WITH			26
#define T_READ			27
#define T_WRITE			28

//Boolean keywords
#define T_BCONST		29

//ASCII characters 
#define T_CCONST		30

//Operators
#define T_RELOP			31
#define T_ADDOP			32
#define T_OROP			33
#define T_MULDIVANDOP	34
#define T_NOTOP			35
#define T_INOP			36

//Other tokens
#define T_LPAREN		37
#define T_RPAREN  		38
#define T_SEMI			39
#define T_DOT			40
#define T_COMMA			41
#define T_EQU			42
#define T_COLON			43
#define T_LBRACK		44
#define T_RBRACK		45
#define T_ASSIGN		46
#define T_DOTDOT		47
#define T_EOF			0

//Identifier
#define T_ID			49

//INTEGER CONSTANT
#define T_DECCONST		50
#define T_HEXCONST		51
#define T_BINCONST		52

//REAL CONSTANT
#define T_RDECCONST		53
#define T_RHEXCONST		54
#define T_RBINCONST		55

//STRING
#define T_STRING		56

#define MAX_STR_CONST 	200
#define MAX_LINE_SIZE	200
#define MAX_ERRORS		5