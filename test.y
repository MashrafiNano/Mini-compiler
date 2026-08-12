%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(char *s);

// Structure to store symbol information
typedef struct Symbol {
    char* name;
    int value;
} Symbol;

// Symbol table
#define MAX_SYMBOLS 100
Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

int findSymbolIndex(char* name);
void addSymbol(char* name, int value);
int getSymbolValue(char* name);
void displaySymbolTable(void);
%}


%union {
    char* str;  // Used for variable names
    int num;    // Used for numeric values
}

%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS  // For unary minus

%token MYTYPE SHOW INPUT  SYMBOLS
%token <str> IDENTIFIER
%token <num> NUMBER
%token PLUS MINUS TIMES DIVIDE
//comparison operator develop korsi
%token GT LT GE LE EQ NE
%token IF ELSE
%type <num> expression comparison
%%

program:
    statements
    ;

statements:
    statements statement
    | statement
    ;


//update korechi
statement:
     MYTYPE IDENTIFIER ';'{ 
        if(findSymbolIndex($2) !=-1){
            printf("Error: Variable '%s' is already delcared!\n",$2);
        }
        else{
            addSymbol($2,0);
            printf("Declared %s\n",$2);
        }
     }
     | IF '(' comparison ')' SHOW '(' IDENTIFIER ')' ';'
  ELSE SHOW '(' IDENTIFIER ')' ';' {
    if ($3) {
        printf("Displaying value of %s: %d\n", $7, getSymbolValue($7));
    } else {
        printf("Displaying value of %s: %d\n", $13, getSymbolValue($13));
    }
}
    | SHOW '(' IDENTIFIER ')' ';'      { 
        printf("Displaying value of %s: %d\n", $3, getSymbolValue($3)); 
     }
    | INPUT '(' IDENTIFIER ')' ';' {
    int value;

    if (findSymbolIndex($3) == -1) {
        printf("Error: Variable '%s' is not declared!\n", $3);
    } else {
        printf("Enter value for %s: ", $3);
        scanf("%d", &value);
        addSymbol($3, value);
        printf("Input stored successfully.\n");
    }
}
     | SYMBOLS ';' {
    displaySymbolTable();
}
    | IDENTIFIER '=' expression ';'   { 
       if(findSymbolIndex($1) == -1){
        printf("Error: Variable '%s' is not declared!\n",$1);
       }
       else{
        addSymbol($1,$3);
        printf("Assigned %d to variable %s\n",$3,$1);
       }
     }
     | comparison ';' {
    printf("Comparison result: %d\n", $1);
}
    | expression ';' { 
        printf("Expression result: %d\n", $1); 
     }
    ;
comparison:
      expression GT expression   { $$ = $1 > $3; }
    | expression LT expression   { $$ = $1 < $3; }
    | expression GE expression   { $$ = $1 >= $3; }
    | expression LE expression   { $$ = $1 <= $3; }
    | expression EQ expression   { $$ = $1 == $3; }
    | expression NE expression   { $$ = $1 != $3; }
;
expression:
    expression PLUS expression  { $$ = $1 + $3; }
    | MINUS expression %prec UMINUS {
    $$ = -$2;
}
    | expression MINUS expression  { $$ = $1 - $3; }
    | expression TIMES expression  { $$ = $1 * $3; }
    | expression DIVIDE expression  { 
        if ($3 == 0) {
            yyerror("Division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3; 
        }
    }
    | NUMBER  { $$ = $1; }
    | IDENTIFIER { $$ = getSymbolValue($1); }
    | '(' expression ')' { $$ = $2; }
    ;

%%

int yyerror(char *s) {
    printf("Error: %s\n", s);
    return 0;
}

int main() {
    yyparse();
    return 0;
}

// Helper function to find a symbol in the table
int findSymbolIndex(char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return i;  // Return index of symbol
        }
    }
    return -1;  // Symbol not found
}

// Helper function to add a symbol to the table
void addSymbol(char* name, int value) {
    int index = findSymbolIndex(name);
    if (index == -1) {
        if (symbolCount < MAX_SYMBOLS) {
            symbolTable[symbolCount].name = strdup(name);
            symbolTable[symbolCount].value = value;
            symbolCount++;
        } else {
            printf("Symbol table full!\n");
        }
    } else {
        symbolTable[index].value = value;  // Update existing symbol's value
    }
}

// Helper function to get the value of a symbol
int getSymbolValue(char* name) {
    int index = findSymbolIndex(name);
    if (index != -1) {
        return symbolTable[index].value;
    } else {
        printf("Error: Symbol %s not found!\n", name);
        return 0;  // Error value
    }
}
void displaySymbolTable(void) {
    printf("\n----- Symbol Table -----\n");
    printf("%-15s %s\n", "Name", "Value");
    printf("------------------------\n");

    for (int i = 0; i < symbolCount; i++) {
        printf("%-15s %d\n",
               symbolTable[i].name,
               symbolTable[i].value);
    }

    printf("------------------------\n");
}