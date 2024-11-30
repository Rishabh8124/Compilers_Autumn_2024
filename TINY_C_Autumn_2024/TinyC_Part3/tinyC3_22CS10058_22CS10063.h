#ifndef _TRANSLATOR_h_
#define _TRANSLATOR_h_

#include <iostream>
#include <vector>
#include <stack>
#include <map>
#include <iomanip>
#include <string>

using namespace std;

#define INT_SIZE 4
#define FLOAT_SIZE 8
#define CHAR_SIZE 1
#define POINTER_SIZE 4
#define VOID_SIZE 0

class Array;
class Symbol;
class SymbolType;
class SymbolTableEntry;
class SymbolTable;
class Quad;

/*
Array class:
    symbol: Symbol pointer to the array
    temp: Symbol pointer to the temporary variable
    elem: SymbolType pointer to the element type of the array

Expression class:
    symbol: Symbol pointer to the expression
    type: int to store the type of the expression
    truelist: vector<int> pointer to store the truelist of the expression
    falselist: vector<int> pointer to store the falselist of the expression

SymbolType class:
    name: enum type_name to store the type of the symbol
    width: int to store the width of the symbol
    array_elem_type: SymbolType pointer to store the element type of the array

Symbol class:
    name: string to store the name of the symbol
    type: SymbolType pointer to store the type of the symbol
    init_val: string to store the initial value of the symbol
    size: int to store the size of the symbol
    offset: int to store the offset of the symbol
    nested: SymbolTable pointer to store the nested symbol table

SymbolTable class:
    name: string to store the name of the symbol table
    symbols: vector<Symbol *> to store the symbols in the symbol table
    symbol_instance: map<string, Symbol *> to store the instance of the symbols
    parent: SymbolTable pointer to store the parent symbol table

Quad class:
    op: string to store the operator of the quad
    arg1: string to store the first argument of the quad
    arg2: string to store the second argument of the quad
    result: string to store the result of the quad

QuadArray class:
    quads: vector<Quad> to store the quads

makelist(line number): function to create a new list with the given line number
merge(list1, list2): 
    list1 and list2 are two lists which have the same jump destination
    function to merge two lists
backpatch(list, line number): 
    list of quad indices to have the line number as the jump destination
    function to backpatch the given list with the given line number
    
getlineno: function to get the line number
int_to_string: function to convert an integer to a string
string_to_int: function to convert a string to an integer

*/

class Array {
    public:

        Symbol * symbol;
        Symbol * temp;
        SymbolType * elem;

        Array(Symbol * = NULL, Symbol * = NULL, SymbolType * = NULL);
};

class Expression {
    public:
        Symbol * symbol;
        int type;
        vector<int> * truelist, * falselist;

        void convert_to_bool();
        void convert_to_int();

        Expression(Symbol * = NULL, int = 0);
};

class SymbolType {
    public:
        enum type_name {TYPE_INT, TYPE_FLOAT, TYPE_CHAR, TYPE_STRING_LITERAL, TYPE_ARRAY, TYPE_POINTER, TYPE_VOID} name;
        int width;
        SymbolType * array_elem_type;

        SymbolType(type_name = TYPE_VOID, int = -1, SymbolType * = NULL);
        string print();
        int getsize();
};

class Symbol {
    public:
        string name;
        SymbolType * type;
        string init_val;
        int size;
        int offset;
        SymbolTable* nested;

        int getsize();
        Symbol(string = "", SymbolType * = NULL);
};

class SymbolTable {
    public:
        string name;
        vector<Symbol *> symbols;
        map<string, Symbol *> symbol_instance;
        SymbolTable * parent;

        SymbolTable(string = "", SymbolTable * = NULL);
        void update();
        void print();
        Symbol * lookup(string);
        Symbol * gentemp(SymbolType::type_name, int = -1);
};

class Quad {
    public:
        string op;
        string arg1;
        string arg2;
        string result;

        Quad(string="", string="", string="", string="");
};

class QuadArray {
    public:
        vector<Quad> quads;

        QuadArray();
        void emit(Quad);
        void print();
};

vector<int> * makelist(int);
vector<int> * merge(vector<int> *, vector<int> *);
void backpatch(vector<int> *, int);
int getlineno();
string int_to_string(int x);
int string_to_int(string s);

#endif