#include "y.tab.c"
#include "lex.yy.c"
#include "tinyC3_22CS10058_22CS10063.h"

SymbolType::SymbolType(type_name name, int size, SymbolType * array_elem_type): name(name), width(size), array_elem_type(array_elem_type) {
    if (size == -1) {
        switch(name) {
            case SymbolType::TYPE_INT: 
                this->width = INT_SIZE;
                break;
            case SymbolType::TYPE_FLOAT: 
                this->width = FLOAT_SIZE;
                break;
            case SymbolType::TYPE_CHAR:
                this->width = CHAR_SIZE;
                break;
            case SymbolType::TYPE_POINTER:
                this->width = POINTER_SIZE;
                break;
        }
    }
}

Array::Array(Symbol * symbol, Symbol * temp, SymbolType * elem): symbol(symbol), temp(temp), elem(elem) { }

Symbol::Symbol(string name, SymbolType * type): name(name), type(type), nested(NULL) { }

SymbolTable::SymbolTable(string name, SymbolTable * parent): name(name), parent(parent) { this->symbols.resize(0); }

Quad::Quad(string op, string arg1, string arg2, string result): op(op), arg1(arg1), arg2(arg2), result(result) {}

QuadArray::QuadArray() { this->quads.resize(0); }

int getlineno() {
    return three_address_code.quads.size();
}

Expression::Expression(Symbol * symbol, int type): symbol(symbol), type(type), truelist(new vector<int>), falselist(new vector<int>) { }

Symbol * SymbolTable::lookup(string id) {
    for (auto symbol: symbols) {
        if (symbol->name == id) return symbol;
    }

    Symbol * temp = NULL;
    if (parent != NULL) temp = parent->lookup(id);

    if (temp == NULL && this->name == current_table->name) {
        temp = new Symbol(id);
        symbols.push_back(temp);
        symbol_instance[id] = temp;
    }
    return temp;
}

string int_to_string(int x) {
    string a = "", temp1 = "0";
    int t = x<0;
    if (t) { x *= -1; a = "-";}

    if (x == 0) return temp1;
    else {
        while(x) {
            string temp = " ";
            temp[0] = x%10+'0';
            a = temp + a;
            x /= 10;
        }

        return a;
    }
}

int string_to_int(string s) {
    int t = 0;
    if (s[0] == '-') {
        t = 1;
        s = s.substr(1, s.size()-1);
    }

    int ans = 0;
    for(auto i: s) ans = ans*10+(i-'0');
    if (t) ans *= -1;
    
    return ans;
}

void QuadArray::emit(Quad quad) {
    quads.push_back(quad);
}

Symbol * SymbolTable::gentemp(SymbolType::type_name type, int size) {
    string temp_var_name = "$";
    temp_var_name += int_to_string(temporary_count++);

    Symbol * temp = new Symbol(temp_var_name);
    temp->type = new SymbolType(type, size);
    symbols.push_back(temp);
    symbol_instance[temp_var_name] = temp;

    return temp;
}

string SymbolType::print() {
    switch (name) {
        case TYPE_INT: return "int";
        case TYPE_FLOAT: return "float";
        case TYPE_CHAR: return "char";
        case TYPE_STRING_LITERAL: return "string";
        case TYPE_POINTER: return ("pointer(" + this->array_elem_type->print() + ")");
        case TYPE_ARRAY: return ("array(" + to_string(this->width) + ", " + this->array_elem_type->print() + ")" );
        case TYPE_VOID: return"void";
    }
    return "";
}

void SymbolTable::update() {
    int last_var = this->symbols.size();

    for(int i=0; i<last_var; i++) {
        this->symbols[i]->size = (this->symbols[i]->nested == NULL)*this->symbols[i]->getsize();
        if (i) this->symbols[i]->offset = this->symbols[i-1]->offset + this->symbols[i-1]->size;
        else this->symbols[i]->offset = 0;
    }
}

void Expression::convert_to_bool() {
    if (this->type == 0) {
        this->type = 1;
        this->truelist = makelist(getlineno());
        three_address_code.emit(*(new Quad("==", this->symbol->name, "0", "")));
        this->falselist = makelist(getlineno());
        three_address_code.emit(*(new Quad("goto")));
    }
}

void Expression::convert_to_int() {
    if (this->type == 1) {
        this->type = 0;

        this->symbol = current_table->gentemp(SymbolType::TYPE_INT);
        backpatch(this->truelist, getlineno());
        three_address_code.emit(*(new Quad("=", "1", "", this->symbol->name)));
        three_address_code.emit(*(new Quad("goto", "", "", int_to_string(getlineno()+3))));
        backpatch(this->falselist, getlineno());
        three_address_code.emit(*(new Quad("=", "0", "", this->symbol->name)));
        three_address_code.emit(*(new Quad("goto", "", "", int_to_string(getlineno()+1))));
    }
}

int SymbolType::getsize() {
    if (this->name != SymbolType::TYPE_ARRAY) return width;
    else return width*(this->array_elem_type->getsize());
}

int Symbol::getsize() {
    return this->type->getsize();
}

void SymbolTable::print() {
    cout << "============================================================================================================================================\n";
    cout << "Table Name: " << this->name << endl;;
    if (this->parent == NULL) cout << "Parent: None"<< endl;
    else cout << "Parent: " << this->parent->name << endl;
    cout << "============================================================================================================================================\n";
    cout << "Name                Type                                    Initial Value       Offset              Size                Child               \n";
    vector<SymbolTable *> nested_tables;

    for (auto x: this->symbols) {
        cout << std::left << setw(20) << x->name;
        cout << std::left << setw(40) << x->type->print();
        cout << std::left << setw(20) << x->init_val;
        cout << std::left << setw(20) << x->offset;
        cout << std::left << setw(20) << x->size;
        if(x->nested != NULL) cout << std::left << setw(20) << x->nested->name;
        cout << endl;
        if (x->nested != NULL) {nested_tables.push_back(x->nested);}
    }
    cout << "--------------------------------------------------------------------------------------------------------------------------------------------\n\n";
    for (auto x: nested_tables) {cout << endl; x->print();}
}

void QuadArray::print() {
    int i = 0;
    for (auto x: quads) {
        i++;
        // cout << i << " : " << x.op << " " << x.arg1 << " " << x.arg2 << " " << x.result << endl;
        cout << i << " : ";
        if(x.op == "=")
        {
            cout << "\t" << x.result << " = " << x.arg1 << endl;
        }
        else if(x.op == "goto")
        {
            cout << "\tgoto " << x.result << endl;
        }
        else if( x.op == "return")
        {
            cout << "\treturn " << x.result << endl;
        }
        else if( x.op == "call")
        {
            cout << "\t" << x.result << " = call " << x.arg1 << ", " << x.arg2 << endl;
        }
        else if(x.op == "param")
        {
            cout << "\t" << "param " << x.result << endl;
        }
        else if(x.op == "label")
        {
            cout << x.result << ':' << endl;
        }
        else if(x.op == "=[]")
        {
            cout << "\t" << x.result << " = " << x.arg1 << "[" << x.arg2 << "]" << endl;
        }
        else if (x.op == "[]=")
        {
            cout << "\t" << x.result << "[" << x.arg1 << "] = " << x.arg2 << endl;
        }

        else if (x.op == "+" || x.op == "-" || x.op == "*" || x.op == "/" || x.op == "%" || x.op == "|" || x.op == "^" || x.op == "&" || x.op == "<<" || x.op == ">>")
        {
            // binary_print();
            cout << "\t" << x.result << " = " << x.arg1 << " " << x.op << " " << x.arg2 << endl;
        }
        else if (x.op == "==" || x.op == "!=" || x.op == "<" || x.op == ">" || x.op == "<=" || x.op == ">=")
        {
            // relation_print();
            // cout << "what is going on = " << x.op << "  ";
            cout << "\tif " << x.arg1 << " " << x.op << " " << x.arg2 << " goto " << x.result << endl;
        }
        else if (x.op == "=&" || x.op == "=*")
        {
            // shift_print();
            cout << "\t" << x.result << " " << x.op[0] << " " << x.op[1] << x.arg1 << endl;
        }
        else if(x.op == "*=")
        {
            cout << "\t" << "*" << x.result << " = " << x.arg1 << endl;
        }
        else if (x.op == "=-")
        {
            // shift_print_("= -");
            cout << "\t" << x.result << " " << x.op[0] << " " << x.op[1] << x.arg1 << endl;
        }
        else if (x.op == "~")
        {
            // shift_print_("= ~");
            cout << "\t" << x.result << " = ~" << x.arg1 << endl;
        }
        else if (x.op == "!")
        {
            // shift_print_("= !");
            cout << "\t" << x.result << " = !" << x.arg1 << endl;
        }
        else
        {
            // if none of the above operators
            cout << x.op << "ll---" << x.arg1 << x.arg2 << "k" << x.result << endl;
            cout << "INVALID OPERATOR\n";
        }
    }
}

vector<int> * makelist(int line) {
    vector<int> * temp = new vector<int>;
    temp->push_back(line);
    return temp;
}

vector<int> * merge(vector<int> * list1, vector<int> * list2) {
    if (list1 == NULL && list2 == NULL) return NULL;
    vector<int> * temp = new vector<int>;
    if (list1 != NULL) for (auto x: *(list1)) temp->push_back(x);
    if (list2 != NULL) for (auto x: *(list2)) temp->push_back(x);

    return temp;
}

void backpatch(vector<int> * list1, int line) {
    if (list1 == NULL) return;
    for(auto x: *list1) {
        three_address_code.quads[x].result = int_to_string(line+1);
    }
    return;
}

int main() {
    three_address_code.emit(*(new Quad("label", "", "", "global")));
    yyparse();
    global_table->print();
    cout << endl;
    three_address_code.print();
    return 0;
}