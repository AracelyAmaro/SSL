#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

struct NodoErrorLexico{
char *cadenaError;
struct NodoErrorLexico *sig;
};

struct NodoErrorSintactico{
  
  struct NodoErrorSintactico *sig;
};

struct NodoErrorLexico *listaErroresLexicos = NULL;
struct NodoErrorSintactico *listaErroresSintacticos =NULL;



//Agrega errores lexicos encontrados
struct NodoErrorLexico *agregarErrorLexico(struct NodoErrorLexico*puntero, char *cadNoReconocida){
  struct NodoErrorLexico *nuevaLista;
  nuevaLista= (struct NodoErrorLexico*)malloc(sizeof(struct NodoErrorLexico));
  nuevaLista->cadenaError = cadNoReconocida;
  
    nuevaLista->sig=NULL;
     if (puntero != NULL)
     {
          struct NodoErrorLexico *aux = puntero;
          while (aux->sig != NULL)
          {
               aux = aux->sig;
          }
          aux->sig = nuevaLista;
     }
     else
     {
          puntero = nuevaLista;
     }
     return puntero;
}

//Agrega errores sintacticos encontrados
struct NodoErrorSintactico* agregarErrorSintactico(struct NodoErrorSintactico*puntero ){
  struct NodoErrorSintactico *nuevaLista;
  nuevaLista= (struct NodoErrorSintactico*)malloc(sizeof(struct NodoErrorSintactico));

    nuevaLista->sig=NULL;
     if (puntero != NULL)
     {
          struct NodoErrorSintactico *aux = puntero;
          while (aux->sig != NULL)
          {
               aux = aux->sig;
          }
          aux->sig = nuevaLista;
     }
     else
     {
          puntero = nuevaLista;
     }
     return puntero;
}


void mostrarListaErroresLexicos(struct NodoErrorLexico *puntero)
{
     struct NodoErrorLexico *aux = puntero;
     while (aux != NULL)
     {
          printf("Se encontro el error lexico %s  \n", aux->cadenaError);
          aux = aux->sig;
     }
}

void mostrarListaErroresSintacticos(struct NodoErrorSintactico *puntero)
{
     struct NodoErrorSintactico *aux = puntero;
     while (aux != NULL)
     {
          printf("Se encontro el error Sintactico. Imposible emparejar por alguna produccion.\n");
          aux = aux->sig;
     }
}


