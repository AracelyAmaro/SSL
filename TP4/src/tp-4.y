%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "funciones.h"

int yylex ();
int yyerror (char*);
int yywrap(){
    return(1);
}



extern int yylineno;


FILE* yyin;
FILE* yyout;

%}

%type <ccval> variableSimple 


%union {
char ccval[20]; // cadenas
struct yylval_Tokens
  {
      int tipo;
      int ival;
      double dval;
  } estructura;
struct yylval_TokenError
  {
      char nomError[20];
  } errorLex;
}


%token <ival> CENTERO 
%token <dval> CREAL
%token <ccval> ID
%token <ccval> LCADENA
%token <ccval> CCARACTER
%token <ccval> OPASIG 
%token <ccval> OR 
%token <ccval> AND 
%token <ccval> OPIGUAL 
%token <ccval> OPREL 
%token <ccval> OPINCDEC
%token <ccval> T_DATO 
%token <ccval> TCLASE 
%token <ccval> FLECHA 
%token <ccval> OPDESIGUAL
%token <ccval> OPERADORUNARIO
%token <ccval> IF 
%token <ccval> ELSE 
%token <ccval> SIZEOF 
%token <ccval> SWITCH
%token <ccval> WHILE 
%token <ccval> DO 
%token <ccval> FOR 
%token <ccval> RETURN 
%token <ccval> CONTINUE 
%token <ccval> GOTO 
%token <ccval> BREAK 
%token <ccval> CASE 
%token <ccval>DEFAULT

%token <ccval> CNORECONOCIDO
%token <ccval> errorLexico


%% 

input:  /* vacio */
        | input line
;


line:   declaracion   
        | sentencia 
        | expresion 
        | errorLexico {
                char *cadena = (char *)malloc((strlen($<errorLex>1.nomError) + 1) * sizeof(char *));
                strcpy(cadena,$<errorLex>1.nomError); 
                listaErroresLexicos = agregarErrorLexico(listaErroresLexicos, cadena );

        }

        | error '\n' {listaErroresSintacticos=agregarErrorSintactico(listaErroresSintacticos);}
;


/* GRAMATICA DE EXPRESIONES */
expresion:    expresionAsignacion
;

expresionAsignacion:    expresionCondicional
                        | expresionUnaria OPASIG expresionAsignacion
;

expresionCondicional:    expresionOr
                        | expresionOr '?' expresion ':' expresionCondicional
;
expresionOr:  expresionAnd
            | expresionOr OR expresionAnd 
;
expresionAnd: expresionIgualdad
            | expresionAnd AND expresionIgualdad
;
expresionIgualdad:   expresionRelacional
            | expresionIgualdad OPIGUAL expresionRelacional 
;

expresionRelacional: expresionAditiva
                    |expresionRelacional OPREL expresionAditiva
;

expresionAditiva: expresionMultiplicativa 
        | expresionAditiva '+' expresionMultiplicativa 
        
        | expresionAditiva '-' expresionMultiplicativa
;
expresionMultiplicativa: expresionUnaria 
        | expresionMultiplicativa '*' expresionUnaria
        | expresionMultiplicativa '/' expresionUnaria
        | expresionMultiplicativa '%' expresionUnaria
;

;
expresionUnaria: expresionPostFijo 
        | OPINCDEC expresionUnaria
        | SIZEOF '(' T_DATO ')'
;


expresionPostFijo:   expresionPrimaria {

                    if($<estructura>1.tipo==1){
                    $<estructura>$.tipo=$<estructura>1.tipo;
                    $<estructura>$.ival=$<estructura>1.ival;
                    }else{
                        $<estructura>$.tipo=$<estructura>1.tipo;
                        $<estructura>$.dval=$<estructura>1.dval;
                        }
                                        }
            | expresionPostFijo '[' expresion ']'
            | ID '(' listaArgumentos ')' 
            | expresionPostFijo '.' ID
            | expresionPostFijo FLECHA ID
            | expresionPostFijo OPINCDEC

;
listaArgumentos:  /*vacio*/
            |expresionAsignacionBis 
            | listaArgumentos ',' expresionAsignacionBis
;
expresionAsignacionBis: expresionAsignacion 
;
expresionPrimaria:     ID  {strcpy($<ccval>$,$<ccval>1);}
            | CENTERO {$<estructura>$.ival=$<estructura>1.ival; $<estructura>$.tipo=$<estructura>1.tipo;}
            | CREAL {$<estructura>$.dval=$<estructura>1.dval; $<estructura>$.tipo=$<estructura>1.tipo;}
            | LCADENA 
            | '(' expresion ')'
;


/* GRAMATICA DE DECLARACIONES */

declaracion: '\n' 
        | declaracionDeVariables 
        |declaracionDeFunciones 
        |definicionDeFuncion 
        
;

declaracionDeVariables: T_DATO declaracionDeVariablesPuntero
;

declaracionDeVariablesPuntero: listaVariablesSimples ';' {strcpy($<ccval>$, "");}
        | '*' listaVariablesSimples ';' {strcpy($<ccval>$, "*");}
        |  ID listaArreglos ';'  
;
listaArreglos: arreglo 
                | listaArreglos arreglo
;

arreglo: '[' expresion ']'
;

listaVariablesSimples: variableSimple
                        |listaVariablesSimples ',' variableSimple  
;

variableSimple: ID inicializador                    
;

inicializador: /* vacio */
              |OPASIG   expresionCondicional
;


declaracionDeFunciones: T_DATO  ID '(' opcionArgumentos ')' ';'   
                                        
        
                         |T_DATO '*' ID '(' opcionArgumentos ')' ';' 
;

opcionArgumentos: /*vacio*/
                | argumentoSimple
                | argumentoSimple ',' opcionArgumentos

;

argumentoSimple: T_DATO referencia ID 
                |T_DATO '*' referencia ID 
;


referencia: /*vacio*/
        | '&'
;

definicionDeFuncion: T_DATO ID '(' opcionArgumentos ')' sentencia  
;


/*GRAMATICA DE SENTENCIAS*/

sentencia:		
        sentenciaExpresion '\n'
        | sentenciaCompuesta 
        | sentenciaSeleccion 
        | sentenciaIteracion 
        | sentenciaSalto  
        | sentenciaEtiqueta  
;

sentenciaExpresion: ';'
                    | expresion ';' 
;

sentenciaCompuesta:	'{' listaDeclaracionesOpcional '\n' listaSentenciasOpcional '}' '\n'    
                        | '{' listaDeclaracionesOpcional  listaSentenciasOpcional '}' '\n'    
;

listaDeclaracionesOpcional: /*vacio*/
                        | declaracion 
                        | listaDeclaracionesOpcional declaracion
;

listaSentenciasOpcional: /*vacio*/
                        | sentencia
                        | listaSentencias sentencia 
;

listaSentencias: sentencia 
                | listaSentencias sentencia
;

sentenciaSeleccion:	IF '(' expresion ')' sentencia elseSent                     
                        | SWITCH '(' expresion ')' sentencia                            
;

elseSent: 	/* vacio */
			| ELSE sentencia                                                
;

sentenciaIteracion:	WHILE '(' expresion ')' sentencia                                               
                        | DO sentencia WHILE '(' expresion ')' ';'                                      
                        | FOR '('expresionOpc ';' expresionOpc ';' expresionOpc ')' sentencia         
;

sentenciaSalto:  RETURN expresionOpc ';'                                                  
                        | CONTINUE ';'                                                  
                        | BREAK ';'                                                      
                        | GOTO ID ';'                                                    
;

sentenciaEtiqueta:   CASE expresionCondicional ':' sentencia                          
                        | DEFAULT ':' sentencia                                          
                        | ID ':' sentencia                                       
;       

expresionOpc: /*vacio*/
                        |expresion

;

%%


int yyerror (char *mensajeError){ 
        fprintf(yyout, "Se encontraron errores sintacticos en el archivo analizado.\n", mensajeError);
}

int main (){

yyin = fopen("Entrada.c","r");
yyout= fopen("Salida.txt", "w");
printf("-------------------------------------------------------------------------\n\n");
yyparse();
printf("\nERRORES LEXICOS:\n\n");
mostrarListaErroresLexicos(listaErroresLexicos);
printf("\n\n              ---------------------------------------               \n");
printf("\nERRORES SINTACTICOS:\n\n");
mostrarListaErroresSintacticos(listaErroresSintacticos);
printf("\n\n              ---------------------------------------               \n");
}