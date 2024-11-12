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
void emit(Quad * quad) {                    // Emit intermediate code
    quads.push_back(quad);
    instr_line++;
}

void emit_target(Quad * target) {           // Emit target code
    target_code.push_back(target);
    target_code_number++;
}

// Target Code Generation

class Register {                            // Data structure to store and process information related to registers
    public: 
        vector<Symbol *> vars;              // Set of variables pointing to the value stored in this register
        int score;                          // Number of variables which are pointing here and do not have their value in sync with memory

        Register(): score(0) { vars.resize(0); }
};

int n;                                      // Number of registers (overwritten through command-line argument)
vector<Register> registers(5);

map<string, int> block_use_count;           // Count of variables being used in a single block (Computed at the start of a block)
map<int, int> update_line;                  // Used for updating goto lines in target code

int getRegisterResult() {
    // Always the result is a temporary, hence it will be a new location

    // Method 1
    // Since the result is always a new temporary it will not be stored in old register

    // Method 2
    // Free registers
    // If T = A op B and if A and B are not used later in the block the same register of A or B can be used

    for (int i=0; i<n; i++) {
        if (registers[i].vars.size() == 0) return i;
    }

    // Method 3
    // All values are in sync with memory
    // Score = 0 means all the variable pointing to this register are in sync with the memory
    for (int i=0; i<n; i++) {
        if (registers[i].score != 0) continue;
        
        for (auto x: registers[i].vars) x->current_register = -1;

        registers[i].vars.clear();
        registers[i].score = 0;

        return i;
    }

    // Method 4
    // Since T is always a new temporary it will never be equal to A and B

    // Method 5
    // Temporaries are not used below further in that block

    for(int i=0; i<n; i++) {
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
    // Choosing register with the minimum score
    // Recalculating score because temporaries with no use below should not be stored and hence should not be included in calculation of score
    int scores[n];
    for (int i=0; i<n; i++) {
        scores[i] = registers[i].score;
        for(auto x: registers[i].vars) {
            if (x->id[0] == '$' && block_use_count[x->id] == 0) scores[i]--;
        }
    }
    int min_register = 0;
    int min_score = scores[0];

    for (int i=0; i<n; i++) {
        if (scores[i] < min_score) {
            min_score = scores[i];
            min_register = i;
        }
    }

    for (auto x: registers[min_register].vars) {
        if ((x->id[0]!='$' && x->latest == 0) || (x->id[0] == '$' && block_use_count[x->id])) {
            emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
            x->latest = 1;
        }
        x->current_register = -1;
    }

    registers[min_register].vars.clear();
    registers[min_register].score = 0;

    return min_register;
}

vector<int> getRegisterOperand(Symbol * S1, Symbol * S2) {

    // Both the operands are searched together to prevent the register used for one operand from being used for the other one
    // If the input parameter is NULL, it means it is a numerical value

    vector<int> regs(2);

    if (S1 != NULL) regs[0] = S1->current_register;
    else regs[0] = n;

    if (S2 != NULL) regs[1] = S2->current_register;
    else regs[1] = n;

    int blocked;        // Tells which register is blocked by the operand whose register has 
    int free;

    // Method 1
    // If the variable being searched is already present in a register, use it
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
    // Free registers
    for (int i=0; i<n; i++) {
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
    // All the variables in the register are in sync with the memory
    for (int i=0; i<n; i++) {
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
    // Temporaries not being used below
    for(int i=0; i<n; i++) {
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
    // Register with the minimum score
    // Recalculation of score (to remove the temporary contributing to the existing score if it is not used below)

    int scores[n];
    for (int i=0; i<n; i++) {
        scores[i] = registers[i].score;
        for(auto x: registers[i].vars) {
            if (x->id[0] == '$' && block_use_count[x->id] == 0) scores[i]--;
        }
    }
    
    int min_register;
    int min_score;

    if (blocked == 0) {
        min_register = 1;
        min_score = scores[1];
    } else {
        min_register = 0;
        min_score = scores[0];
    }

    for (int i=0; i<n; i++) {
        if (i == blocked) continue;
        if (scores[i] < min_score) {
            min_score = scores[i];
            min_register = i;
        }
    }

    for (auto x: registers[min_register].vars) {
        if ((x->id[0]!='$' && x->latest == 0) || (x->id[0] == '$' && block_use_count[x->id])) {
            emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
            x->latest = 1;
        }
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
        min_score = scores[1];
    } else {
        min_register = 0;
        min_score = scores[0];
    }

    for (int i=0; i<n; i++) {
        if (i == blocked) continue;
        if (scores[i] < min_score) {
            min_score = scores[i];
            min_register = i;
        }
    }

    for (auto x: registers[min_register].vars) {
        if ((x->id[0]!='$' && x->latest == 0) || (x->id[0] == '$' && block_use_count[x->id])) {
            emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
            x->latest = 1;
        }
        x->current_register = -1;
    }

    registers[min_register].vars.clear();
    registers[min_register].score = 0;
    
    regs[free] = min_register;
    return regs;
}

void end_of_block() {   // Store variables not in sync with memory at the end of block
    for (auto x: global_table.symbols) {
        if (x->current_register != -1 && x->id[0] != '$') {
            if (x->latest == 0) {
                emit_target(new Quad("ST", "R"+int_to_string(x->current_register+1), "", x->id));
                x->latest = 1;
            }
            x->current_register = -1;
        }
    }

    for (int i=0; i<n; i++) {
        registers[i].vars.clear();
        registers[i].score = 0;
    }
}

void tcg() {
    int i = 0;
    for (auto x: quads) {
        i++;

        // Pre processing block, for usage count of operands
        if (x->bl) {
            end_of_block();
            block_use_count.clear();

            block_use_count[x->arg1]++;
            block_use_count[x->arg2]++;

            int temp = i;
            while(temp<quads.size() && quads[temp]->bl == 0) {
                block_use_count[quads[temp]->arg1]++;
                block_use_count[quads[temp]->arg2]++;
                temp++;
            }
        }

        // Map intermediate code line to target code line (used for jmp target in target code)
        int ql = target_code.size();
        update_line[i] = ql+1;
        

        // Conversion to target code casewise
        if (x->op == "+" || x->op == "-" || x->op == "/" || x->op == "*" || x->op == "%") { // Arithmetic operations

            // Argument 1 and Argument 2 smbol reference from symbol table
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

            // Fetching register for operands
            vector<int> regs = getRegisterOperand(temp1, temp2);

            if (temp1 != NULL && temp1->current_register == -1) {   // Variable not found in register and has to be loaded
                arg1 = "R"+int_to_string(regs[0]+1);
                registers[regs[0]].vars.push_back(temp1);
                temp1->current_register = regs[0];
                emit_target(new Quad("LD", temp1->id, "", arg1));
            } else if (temp1 != NULL) {                             // Variable found in register
                arg1 = "R"+int_to_string(regs[0]+1);
            }

            if (temp2 != NULL && temp2->current_register == -1) {   // Variable not found in register and has to be loaded
                arg2 = "R"+int_to_string(regs[1]+1);
                registers[regs[1]].vars.push_back(temp2);
                temp2->current_register = regs[1];
                emit_target(new Quad("LD", temp2->id, "", arg2));
            } else if (temp2 != NULL) {                             // Variable found in register
                arg2 = "R"+int_to_string(regs[1]+1);
            }

            block_use_count[x->arg1]--;
            block_use_count[x->arg2]--;

            // Fetching register for result
            // Result is always a new temporary, hence it wil not be found in register and the register being assigned will be new (cleaned/empty) before assigned

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

        } else if (x->op == ":=") { // Assignment operations
            // All assignment operations will be variable = ()
            // There is no occasion where a temporary is assigned a value directly, it is only if it is computing a result

            string arg = x->arg1;

            if (arg[0]>='0' && arg[0] <= '9') {
                // Load the integer value in a register and assign it to the variable

                int target_reg = getRegisterResult();
                string result = "R"+int_to_string(target_reg+1);
                emit_target(new Quad("LDI", arg, "", result));

                Symbol * result_temp = global_table.lookup(x->res);

                if (result_temp->current_register != -1) {  // Th resultant variable was initially present in a register and has to be removed from there
                    int index = 0;
                    for(auto y: registers[result_temp->current_register].vars) {
                        if (y->id == x->res) {
                            registers[result_temp->current_register].vars.erase(registers[result_temp->current_register].vars.begin()+index);

                            // If the variable stored before was not in sync with the memory, the score of the register will be reduced on storing removing this variable from that register
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
                // This condition is reached during operation (set variable expr)
                // The last calculation of expr is done in a register and will be available for sure in a register
                // Hence there is no need to fetch a register for the temporarily manually, the information is directly available in the symbol table

                Symbol * arg = global_table.lookup(x->arg1);
                Symbol * result_temp = global_table.lookup(x->res);

                block_use_count[x->arg1]--;

                if (result_temp->current_register != -1) {
                    int index = 0;
                    for(auto y: registers[result_temp->current_register].vars) {    // Updating the old register
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
                // variable = variable

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
            end_of_block();
            emit_target(new Quad("JMP", "", "", x->res));
        } else if (x->op == "=" || x->op == "/=" || x->op == "<" || x->op == ">" || x->op == "<=" || x->op == ">=") {
            // Boolean statements
            // Conditional jumps
            
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
            block_use_count[x->arg2]--;

            Quad * temp;
            if (x->op == "=")  temp = new Quad("JNE", arg1, arg2, x->res);
            if (x->op == "/=") temp = new Quad("JEQ", arg1, arg2, x->res);
            if (x->op == "<")  temp = new Quad("JGE", arg1, arg2, x->res);
            if (x->op == ">")  temp = new Quad("JLE", arg1, arg2, x->res);
            if (x->op == "<=") temp = new Quad("JGT", arg1, arg2, x->res);
            if (x->op == ">=") temp = new Quad("JLT", arg1, arg2, x->res);
            
            // Storing variables should be done before the jmp statement
            end_of_block();
            emit_target(temp);
        } else {
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

    target_file << endl;

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

int main(int argc, char * argv[]) {

    if (argc > 1) {
        n = atoi(argv[1]);
        if (n<2) n = 5;
        registers.resize(n);
    } else {
        n = 5;
    }

    yyparse();
    
    if (error_bool == 0) {
        print_quad();
        tcg();
        print_target();
    } else {
        ofstream target_file("Intermediate_code.txt");
        target_file << "\nIntermediate code not generated due to syntax error\n" << endl;
        target_file.close();

        ofstream target_file_1("Target_code.txt");
        target_file_1 << "\nTarget code not generated due to syntax error\n" << endl;
        target_file_1.close();

    }
    return 0;
}