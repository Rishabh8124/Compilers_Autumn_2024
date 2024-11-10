// NAME - S.RISHABH
// ROLL NUMBER - 22CS10058

#include "y.tab.c"
#include "lex.yy.c"

Symbol::Symbol(string id, int reg): id(id), current_register(reg), latest(1) { }

Quad::Quad(string op, string arg1, string arg2, string res): op(op), arg1(arg1), arg2(arg2), res(res), bl(0) { }

Symbol_table::Symbol_table() { this->symbols.resize(0); }

Symbol * Symbol_table::lookup(string id) {
    for(auto symbol: this->symbols) {
        if (symbol->id == id) return symbol;
    }

    Symbol * temp = new Symbol(id);
    this->symbols.push_back(temp);
    return temp;
}

string Symbol_table::gentemp() {
    string temp = "$"+int_to_string(temp_count++);
    return global_table.lookup(temp)->id;
}

string int_to_string(int num) {
    string a = "", temp1 = "0";
    int t = num<0;
    if (t) { num *= -1; a = "-"; }

    if (num == 0) return temp1;
    else {
        while(num) {
            string temp = " ";
            temp[0] = num%10+'0';
            a = temp + a;
            num /= 10;
        }

        return a;
    }
}

char * string_to_char(string s) {
    char * temp = (char *) malloc(s.size()+1);
    temp[s.size()] = '\0';

    strcpy(temp, s.c_str());

    return temp;
}

// Emit functions
void emit(Quad * quad) {
    quads.push_back(quad);
    instr_line++;
}

void emit_target(Quad * target) {
    target_code.push_back(target);
    target_code_number++;
}

// Target Code Generation

class Register {
    public:
        vector<Symbol *> vars;
        int score;

        Register(): score(0) { vars.resize(0); }
};

vector<Register> registers(5);

map<string, int> block_use_count;
map<int, int> update_line;

int getRegisterResult() {
    // Always the result is a temporary, hence it will be a new location

    // Method 2
    for (int i=0; i<5; i++) {
        if (registers[i].vars.size() == 0) return i;
    }

    // Method 3
    for (int i=0; i<5; i++) {
        if (registers[i].score != 0) continue;
        
        for (auto x: registers[i].vars) x->current_register = -1;

        registers[i].vars.clear();
        registers[i].score = 0;

        return i;
    }

    // Method 4
    // Dummy step

    // Method 5
    for(int i=0; i<5; i++) {
        int cond = 1;
        for (auto x: registers[i].vars) {
            if (x->id[0] != '$') { cond = 0; break; }
            if (block_use_count[x->id]) { cond = 0; break; }
        }

        if (cond) {
            registers[i].vars.clear();
            registers[i].score = 0;
            
            return i;
        }
    }

    // Method 6
    int min_register = 0;
    int min_score = registers[0].score;

    for (int i=0; i<5; i++) {
        if (registers[i].score < min_score) {
            min_score = registers[i].score;
            min_register = i;
        }
    }

    for (auto x: registers[min_register].vars) {
        if (x->latest == 0) emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
        x->current_register = -1;
    }

    registers[min_register].vars.clear();
    registers[min_register].score = 0;

    return min_register;
}

vector<int> getRegisterOperand(Symbol * S1, Symbol * S2) {

    vector<int> regs(2);

    if (S1 != NULL) regs[0] = S1->current_register;
    else regs[0] = 5;

    if (S2 != NULL) regs[1] = S2->current_register;
    else regs[1] = 5;

    int blocked;
    int free;

    // Method 1
    if (regs[0] != -1 && regs[1] != -1) return regs;
    else if (regs[0] != -1) { blocked = regs[0]; free = 1; }
    else if (regs[1] != -1) { blocked = regs[1]; free = 0; }
    else { blocked = -1; free = 2; }

    if (S1 != NULL && S2 != NULL && S1->id == S2->id) {
        regs[0] = getRegisterResult();
        regs[1] = regs[0];
        return regs;
    }

    // Method 2
    for (int i=0; i<5; i++) {
        if (i == blocked) continue;
        if (registers[i].vars.size()) continue;
        if (free < 2) {
            regs[free] = i;
            return regs;
        } else {
            regs[0] = i;
            free = 1;
            blocked = i;
        }
    }

    // Method 3
    for (int i=0; i<5; i++) {
        if (i == blocked) continue;
        if (registers[i].score != 0) continue;
        
        for (auto x: registers[i].vars) x->current_register = -1;

        registers[i].vars.clear();
        registers[i].score = 0;

        if (free < 2) {
            regs[free] = i;
            return regs;
        } else {
            regs[0] = i;
            free = 1;
            blocked = i;
        }
    }

    // Method 4
    // Dummy case, T is always new and is never equal to A and B (atleast in this grammar)

    // Method 5
    for(int i=0; i<5; i++) {
        if (i == blocked) continue;
        
        int cond = 1;
        for (auto x: registers[i].vars) {
            if (x->id[0] != '$') { cond = 0; break; }
            if (block_use_count[x->id]) { cond = 0; break; }
        }

        if (cond) {
            registers[i].vars.clear();
            registers[i].score = 0;

            if (free < 2) {
                regs[free] = i;
                return regs;
            } else {
                regs[0] = i;
                free = 1;
                blocked = i;
            }
        }
    }

    // Method 6
    int min_register;
    int min_score;

    if (blocked == 0) {
        min_register = 1;
        min_score = registers[1].score;
    } else {
        min_register = 0;
        min_score = registers[0].score;
    }

    for (int i=0; i<5; i++) {
        if (i == blocked) continue;
        if (registers[i].score < min_score) {
            min_score = registers[i].score;
            min_register = i;
        }
    }

    for (auto x: registers[min_register].vars) {
        if (x->latest == 0) emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
        x->current_register = -1;
    }

    registers[min_register].vars.clear();
    registers[min_register].score = 0;

    if (free < 2) {
        regs[free] = min_register;
        return regs;
    } else {
        regs[0] = min_register;
        free = 1;
        blocked = min_register;
    }

    if (blocked == 0) {
        min_register = 1;
        min_score = registers[1].score;
    } else {
        min_register = 0;
        min_score = registers[0].score;
    }

    for (int i=0; i<5; i++) {
        if (i == blocked) continue;
        if (registers[i].score < min_score) {
            min_score = registers[i].score;
            min_register = i;
        }
    }

    for (auto x: registers[min_register].vars) {
        if (x->latest == 0) emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
        x->current_register = -1;
    }

    registers[min_register].vars.clear();
    registers[min_register].score = 0;
    
    regs[free] = min_register;
    return regs;
}

void end_of_block(int cond = 0) {
    for (auto x: global_table.symbols) {
        if (x->current_register != -1 && x->id[0] != '$') {
            if (x->latest == 0) {
                emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
                x->latest = 1;
            }
            x->current_register = -1;
        }
    }

    for (int i=0; i<5; i++) {
        registers[i].vars.clear();
        registers[i].score = 0;
    }
}

void tcg() {
    int i = 0;
    for (auto x: quads) {
        i++;
        if (x->bl) {
            end_of_block();
            block_use_count.clear();

            int temp = i;
            block_use_count[x->arg1]++;
            block_use_count[x->arg2]++;

            while(temp<quads.size() && quads[temp]->bl == 0) {
                block_use_count[quads[temp]->arg1]++;
                block_use_count[quads[temp]->arg2]++;
                temp++;
            }
        }

        int ql = target_code.size();
        update_line[i] = ql+1;
        
        if (x->op == "+" || x->op == "-" || x->op == "/" || x->op == "*" || x->op == "%") {
            Symbol * temp1, * temp2;
            string arg1 = x->arg1;
            if (arg1[0] > '9' || arg1[0] < '0') {
                temp1 = global_table.lookup(arg1);
            } else {
                temp1 = NULL;
            }

            string arg2 = x->arg2;
            if (arg2[0] > '9' || arg2[0] < '0') {
                temp2 = global_table.lookup(arg2);
            } else {
                temp2 = NULL;
            }

            vector<int> regs = getRegisterOperand(temp1, temp2);

            if (temp1 != NULL && temp1->current_register == -1) {
                arg1 = "R"+int_to_string(regs[0]+1);
                registers[regs[0]].vars.push_back(temp1);
                temp1->current_register = regs[0];
                emit_target(new Quad("LD", temp1->id, "", arg1));
            } else if (temp1 != NULL) {
                arg1 = "R"+int_to_string(regs[0]+1);
            }

            if (temp2 != NULL && temp2->current_register == -1) {
                arg2 = "R"+int_to_string(regs[1]+1);
                registers[regs[1]].vars.push_back(temp2);
                temp2->current_register = regs[1];
                emit_target(new Quad("LD", temp2->id, "", arg2));
            } else if (temp2 != NULL) {
                arg2 = "R"+int_to_string(regs[1]+1);
            }

            block_use_count[x->arg1]--;
            if (block_use_count[x->arg1] == 0 && x->arg1[0] == '$') {
                int index = 0;
                for(auto y: registers[temp1->current_register].vars) {
                    if (y->id == x->res) {
                        registers[temp1->current_register].vars.erase(registers[temp1->current_register].vars.begin()+index);
                        registers[temp1->current_register].score--;
                        break;
                    }
                    index++;
                }
            }

            block_use_count[x->arg2]--;
            if (block_use_count[x->arg2] == 0 && x->arg2[0] == '$') {
                int index = 0;
                for(auto y: registers[temp2->current_register].vars) {
                    if (y->id == x->res) {
                        registers[temp2->current_register].vars.erase(registers[temp2->current_register].vars.begin()+index);
                        registers[temp2->current_register].score--;
                        break;
                    }
                    index++;
                }
            }

            int target_reg = getRegisterResult();
            string result_arg = x->res;
            string result = "R"+int_to_string(target_reg+1);
            Symbol * result_temp = global_table.lookup(result_arg);
            result_temp->current_register = target_reg;

            registers[target_reg].vars.push_back(result_temp);
            registers[target_reg].score = 1;
            result_temp->latest = 0;

            if (x->op == "+") emit_target(new Quad("ADD", arg1, arg2, result));
            if (x->op == "-") emit_target(new Quad("SUB", arg1, arg2, result));
            if (x->op == "*") emit_target(new Quad("MUL", arg1, arg2, result));
            if (x->op == "/") emit_target(new Quad("DIV", arg1, arg2, result));
            if (x->op == "%") emit_target(new Quad("REM", arg1, arg2, result));
        } else if (x->op == ":=") {
            string arg = x->arg1;

            if (arg[0]>='0' && arg[0] <= '9') {
                int target_reg = getRegisterResult();
                string result = "R"+int_to_string(target_reg+1);
                emit_target(new Quad("LDI", arg, "", result));

                Symbol * result_temp = global_table.lookup(x->res);

                if (result_temp->current_register != -1) {
                    int index = 0;
                    for(auto y: registers[result_temp->current_register].vars) {
                        if (y->id == x->res) {
                            registers[result_temp->current_register].vars.erase(registers[result_temp->current_register].vars.begin()+index);
                            if (result_temp->latest == 0) registers[result_temp->current_register].score--;
                            break;
                        }
                        index++;
                    }
                }

                result_temp->current_register = target_reg;
                result_temp->latest = 0;

                registers[target_reg].vars.push_back(result_temp);
                registers[target_reg].score = 1;
            } else if (arg[0] == '$') {
                Symbol * arg = global_table.lookup(x->arg1);
                Symbol * result_temp = global_table.lookup(x->res);

                block_use_count[x->arg1]--;
                if (block_use_count[x->arg1] == 0 && x->arg1[0] == '$') {
                    int index = 0;
                    for(auto y: registers[result_temp->current_register].vars) {
                        if (y->id == x->res) {
                            registers[result_temp->current_register].vars.erase(registers[result_temp->current_register].vars.begin()+index);
                            registers[result_temp->current_register].score--;
                            break;
                        }
                        index++;
                    }
                }

                if (result_temp->current_register != -1) {
                    int index = 0;
                    for(auto y: registers[result_temp->current_register].vars) {
                        if (y->id == x->res) {
                            registers[result_temp->current_register].vars.erase(registers[result_temp->current_register].vars.begin()+index);
                            if (result_temp->latest == 0) registers[result_temp->current_register].score--;
                            break;
                        }

                        index++;
                    }
                }

                result_temp->current_register = arg->current_register;
                result_temp->latest = 0;
                registers[arg->current_register].vars.push_back(result_temp);
                registers[arg->current_register].score++;
            } else {
                Symbol * arg = global_table.lookup(x->arg1);
                vector<int> regs = getRegisterOperand(arg, NULL);

                if (arg->current_register == -1) {
                    string arg1 = "R"+int_to_string(regs[0]+1);
                    registers[regs[0]].vars.push_back(arg);
                    arg->current_register = regs[0];
                    emit_target(new Quad("LD", arg->id, "", arg1));
                }

                Symbol * result_temp = global_table.lookup(x->res);

                if (result_temp->current_register != regs[0]) {
                    if (result_temp->current_register != -1) {
                        int index = 0;
                        for(auto y: registers[result_temp->current_register].vars) {
                            if (y->id == x->res) {
                                registers[result_temp->current_register].vars.erase(registers[result_temp->current_register].vars.begin()+index);
                                if (result_temp->latest == 0) registers[result_temp->current_register].score--;
                                break;
                            }

                            index++;
                        }
                    }

                    result_temp->current_register = regs[0];
                    result_temp->latest = 0;

                    registers[regs[0]].vars.push_back(result_temp);
                    registers[regs[0]].score++;
                }
            }
        } else if (x->op == "goto") {
            end_of_block(1);
            emit_target(new Quad("JMP", "", "", x->res));
        } else if (x->op == "=" || x->op == "/=" || x->op == "<" || x->op == ">" || x->op == "<=" || x->op == ">=") {
            Symbol * temp1, * temp2;
            string arg1 = x->arg1;
            if (arg1[0] > '9' || arg1[0] < '0') {
                temp1 = global_table.lookup(arg1);
            } else {
                temp1 = NULL;
            }

            string arg2 = x->arg2;
            if (arg2[0] > '9' || arg2[0] < '0') {
                temp2 = global_table.lookup(arg2);
            } else {
                temp2 = NULL;
            }

            vector<int> regs = getRegisterOperand(temp1, temp2);

            if (temp1 != NULL && temp1->current_register == -1) {
                arg1 = "R"+int_to_string(regs[0]+1);
                registers[regs[0]].vars.push_back(temp1);
                temp1->current_register = regs[0];
                emit_target(new Quad("LD", temp1->id, "", arg1));
            } else if (temp1 != NULL) {
                arg1 = "R"+int_to_string(regs[0]+1);
            }

            if (temp2 != NULL && temp2->current_register == -1) {
                arg2 = "R"+int_to_string(regs[1]+1);
                registers[regs[1]].vars.push_back(temp2);
                temp2->current_register = regs[1];
                emit_target(new Quad("LD", temp2->id, "", arg2));
            } else if (temp2 != NULL) {
                arg2 = "R"+int_to_string(regs[1]+1);
            }

            block_use_count[x->arg1]--;
            if (block_use_count[x->arg1] == 0 && x->arg1[0] == '$') {
                int index = 0;
                for(auto y: registers[temp1->current_register].vars) {
                    if (y->id == x->res) {
                        registers[temp1->current_register].vars.erase(registers[temp1->current_register].vars.begin()+index);
                        registers[temp1->current_register].score--;
                        break;
                    }
                    index++;
                }
            }

            block_use_count[x->arg2]--;
            if (block_use_count[x->arg2] == 0 && x->arg2[0] == '$') {
                int index = 0;
                for(auto y: registers[temp2->current_register].vars) {
                    if (y->id == x->res) {
                        registers[temp2->current_register].vars.erase(registers[temp2->current_register].vars.begin()+index);
                        registers[temp2->current_register].score--;
                        break;
                    }
                    index++;
                }
            }

            Quad * temp;
            if (x->op == "=")  temp = new Quad("JNE", arg1, arg2, x->res);
            if (x->op == "/=") temp = new Quad("JEQ", arg1, arg2, x->res);
            if (x->op == "<")  temp = new Quad("JGE", arg1, arg2, x->res);
            if (x->op == ">")  temp = new Quad("JLE", arg1, arg2, x->res);
            if (x->op == "<=") temp = new Quad("JGT", arg1, arg2, x->res);
            if (x->op == ">=") temp = new Quad("JLT", arg1, arg2, x->res);

            end_of_block();
            emit_target(temp);
        } else {
            cout << "Hello" << endl;
            emit_target(new Quad("end"));
        }

        if (x->bl) target_code[ql]->bl = 1;
    }
}

// Printing functions

void print_quad() {
    ofstream target_file("Intermediate_code.txt");

    target_file << "\nBLOCKS OF INTERMEDIATE CODE:-" << endl;
    int i = 1;
    int block_number = 1;
    for (auto x: quads) {
        if (x->bl == 1) {
            target_file << "\nBLOCK " << block_number++ << ":" << endl;
        }

        if (x->op == "goto") {
            target_file << "    " << i++ << " : " <<  x->op << " " << x->res << endl;
        } else if (x->op == "<" || x->op == ">" || x->op == "<=" || x->op == ">=") {
            target_file << "    " << i++ << " : iffalse ( " << x->arg1 << " "  <<  x->op  << " " << x->arg2 << " ) goto " << x->res << endl;
        } else if (x->op == "/=") {
            target_file << "    " << i++ << " : iffalse ( " << x->arg1 << " != " << x->arg2 << " ) goto " << x->res << endl;
        } else if (x->op == "=") {
            target_file << "    " << i++ << " : iffalse ( " << x->arg1 << " == " << x->arg2 << " ) goto " << x->res << endl;
        } else if (x->op == ":=") {
            target_file << "    " << i++ << " : " << x->res << " = " << x->arg1 << endl;
        } else if (x->op == "end") {
            target_file << "    " << i++ << " : " << x->op << endl;
        } else {
            target_file << "    " << i++ << " : " << x->res << " = " << x->arg1 << " " <<  x->op << " " << x->arg2 << endl;
        }
    }

    cout << endl;

    target_file.close();
}

void print_target() {

    ofstream target_file("Target_code.txt");

    target_file << "\nTARGET CODE:-" << endl;
    int i = 1;
    int block_number = 1;
    for (auto x: target_code) {
        if (x->bl == 1) {
            target_file << "\nBLOCK " << block_number++ << ":" << endl;
        }

        if (x->op == "JMP") {
            target_file << "    " << i++ << " : " <<  x->op << " " << update_line[atoi(string_to_char(x->res))] << endl;
        } else if (x->op[0] == 'J') {
            target_file << "    " << i++ << " : " <<  x->op << " " << x->arg1 << " " << x->arg2 << " " << update_line[atoi(string_to_char(x->res))] << endl;
        } else if (x->op == "ST") {
            target_file << "    " << i++ << " : " <<  x->op << " " << x->res << " " << x->arg1 << endl;
        } else if (x->op == "LD" || x->op == "LDI") {
            target_file << "    " << i++ << " : " <<  x->op << " " << x->res << " " << x->arg1 << endl;
        } else {
            target_file << "    " << i++ << " : " <<  x->op << " " << x->res << " " << x->arg1 << " " << x->arg2 << endl;
        }
    }

    target_file.close();
}

int main() {
    yyparse();
    
    print_quad();

    tcg();

    print_target();

    return 0;
}