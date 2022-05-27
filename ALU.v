module alu(instruction, regA, regB, result, flags);

output signed[31:0] result;
output signed[2:0] flags;
// 0 : zero flag;
// 1 : negative flag;
// 2 : overflow flag;

input signed[31:0] instruction, regA, regB;
// the address of reg1 is 00000, the address of reg2 is 00001

reg signed[31:0] reg1, reg2;

reg[5:0] opcode, func;

reg signed[31:0] reg_A, reg_B, reg_C;

reg [31:0] regu_A, regu_B;

reg signed[32:0] overflow;

reg signed[2:0] flag;

reg [15:0] imm;

parameter gr0 = 32'h0000_0000;

//----------------------------------------

always @({instruction,regA,regB})
begin

opcode = instruction[31:26];
func = instruction[5:0];

reg1 = regA;
reg2 = regB;

//immediate
imm = instruction[15:0];

// R Type ----------------------------------------------------------
case(opcode)
6'b000000:
begin

    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    imm = 16'bxxxx_xxxx_xxxx_xxxx;

    //add ----------------------------------------------------------
    case(func)
    6'b100000:
    begin
        
        reg_A = reg1;
        reg_B = reg2;
        reg_C = reg_A + reg_B;
        overflow = reg_A + reg_B;

        if(reg1[31]==1 & reg2[31]==0)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = -reg_A + reg_B;
            overflow = -reg_A + reg_B;
        end

        if(reg1[31]==0 & reg2[31]==1)
        begin
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = reg_A - reg_B;
            overflow = reg_A - reg_B;
        end

        if(reg1[31]==1 & reg2[31]==1)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = - (reg_A + reg_B);
            overflow = - (reg_A + reg_B);
        end

        if(reg1[31]==reg2[31])
        begin
            if(reg1[31]!=reg_C[31])
            flag[2] = 1'b1;
        end
    end
    endcase
    //--------------------------------------------------------------

    //addu (add unsigned)-------------------------------------------
    case(func)
    6'b100001:
    begin
        reg_A = reg1;
        reg_B = reg2;
        reg_C = reg_A + reg_B;

        if(reg1[31]==1 & reg2[31]==0)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = -reg_A + reg_B;
        end

        if(reg1[31]==0 & reg2[31]==1)
        begin
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = reg_A - reg_B;
        end

        if(reg1[31]==1 & reg2[31]==1)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = - (reg_A + reg_B);
        end
    end
    endcase
    //--------------------------------------------------------------

    //sub ----------------------------------------------------------
    case(func)
    6'b100010:
    begin
        
        reg_A = reg1;
        reg_B = reg2;
        reg_C = reg_A - reg_B;
        overflow = reg_A - reg_B;

        if(reg1[31]==1 & reg2[31]==0)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = -reg_A - reg_B;
            overflow = -reg_A - reg_B;
        end

        if(reg1[31]==0 & reg2[31]==1)
        begin
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = reg_A + reg_B;
            overflow = reg_A + reg_B;
        end

        if(reg1[31]==1 & reg2[31]==1)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = - (reg_A - reg_B);
            overflow = - (reg_A - reg_B);
        end
        
        if(reg1[31]!=reg2[31])
        begin
            if(reg1[31]!=reg_C[31])
            flag[2] = 1'b1;
        end
    end
    endcase
    //--------------------------------------------------------------

    //subu (sub unsigned)-------------------------------------------
    case(func)
    6'b100011:
    begin
        
        reg_A = reg1;
        reg_B = reg2;
        reg_C = reg_A - reg_B;

        if(reg1[31]==1 & reg2[31]==0)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = -reg_A - reg_B;
        end

        if(reg1[31]==0 & reg2[31]==1)
        begin
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = reg_A + reg_B;
        end

        if(reg1[31]==0 & reg2[31]==1)
        begin
            reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_B = ~reg2 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            reg_C = - (reg_A - reg_B);
        end
    end
    endcase
    //--------------------------------------------------------------

    //and ----------------------------------------------------------
    case(func)
    6'b100100:
    begin
        reg_A = reg1;
        reg_B = reg2;
        reg_C = reg_A & reg_B;
    end
    endcase
    //--------------------------------------------------------------

    //nor ----------------------------------------------------------
    case(func)
    6'b100111:
    begin
        reg_A = reg1;
        reg_B = reg2;
        reg_C = ~(reg_A | reg_B);
    end
    endcase
    //--------------------------------------------------------------

    //or -----------------------------------------------------------
    case(func)
    6'b100101:
    begin
        reg_A = reg1;
        reg_B = reg2;
        reg_C = reg_A | reg_B;
    end
    endcase
    //--------------------------------------------------------------

    //xor -----------------------------------------------------------
    case(func)
    6'b100110:
    begin
        reg_A = reg1;
        reg_B = reg2;
        reg_C = reg_A ^ reg_B;
    end
    endcase
    //--------------------------------------------------------------

    //slt (Set on Less Than)----------------------------------------
    case(func)
    6'b101010:
    begin
        reg_A = reg1;
        reg_B = reg2;
        reg_C = 0000_0000_0000_0000_0000_0000_0000_0000;

        // 1. negative flag

        if(reg_A < reg_B)
            begin
            flag[1] = 1'b1;
            reg_C = 0000_0000_0000_0000_0000_0000_0000_0001;
            end
    end
    endcase    
    //--------------------------------------------------------------

    //sltu (slt unsigned)----------------------------------------
    case(func)
    6'b101011:
    begin
        regu_A = reg1;
        regu_B = reg2;
        reg_C = 0000_0000_0000_0000_0000_0000_0000_0000;

        // 1. negative flag
        
        if(regu_A < regu_B)
            begin
            flag[1] = 1'b1;
            reg_C = 0000_0000_0000_0000_0000_0000_0000_0001;
            end
    end
    endcase    
    //--------------------------------------------------------------

    //sll (Shift Left Logical) -------------------------------------
    case(func)
    6'b000000:
    begin
        reg_B = reg2;
        reg_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000 + instruction[10:6];
        reg_C = reg_B << reg_A;
    end
    endcase
    //--------------------------------------------------------------

    //sllv (Shift Left Logical Variable) ---------------------------
    case(func)
    6'b000100:
    begin
        reg_B = reg2;
        reg_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000 + reg1;
        reg_C = reg_B << reg_A;
    end
    endcase
    //--------------------------------------------------------------

    //srl (Shift Right Logical) ------------------------------------
    case(func)
    6'b000010:
    begin
        reg_B = reg2;
        reg_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000 + instruction[10:6];
        reg_C = reg_B >> reg_A;
    end
    endcase
    //--------------------------------------------------------------

    //srlv (Shift Right Logical Variable) --------------------------
    case(func)
    6'b000110:
    begin
        reg_B = reg2;
        reg_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000 + reg1;
        reg_C = reg_B >> reg_A;
    end
    endcase
    //--------------------------------------------------------------

    //sra (Shift Right Arithmetic) ---------------------------------
    case(func)
    6'b000011:
    begin
        reg_B = reg2;
        reg_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000 +instruction[10:6];
        reg_C = reg_B >>> reg_A;
    end
    endcase
    //--------------------------------------------------------------

    //srav (Shift Right Arithmetic Variable) -----------------------
    case(func)
    6'b000111:
    begin
        reg_B = reg2;
        reg_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000 + reg1;
        reg_C = reg_B >>> reg_A;
    end
    endcase
    //--------------------------------------------------------------

end
endcase
//------------------------------------------------------------------

//addi - Add Immediate
case(opcode)
6'b001000:   
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;

    reg_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000 +instruction[15:0];
    if(reg_B[15] == 1'b1)
        reg_B[31:16] = 16'b1111_1111_1111_1111;

    reg_C = reg_A + reg_B;
    overflow = reg_A + reg_B;

    if(reg_A[31]==1 & reg_A[31]==0)
    begin
        reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_C = -reg_A + reg_B;
        overflow = -reg_A + reg_B;
    end

    if(reg_A[31]==0 & reg_B[31]==1)
    begin
        reg_B = ~reg_B + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_C = reg_A - reg_B;
        overflow = reg_A - reg_B;
    end

    if(reg_A[31]==1 & reg_B[31]==1)
    begin
        reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_B = ~reg_B + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_C = - (reg_A + reg_B);
        overflow = - (reg_A + reg_B);
    end

    if(reg_A[31]==reg_B[31])
    begin
        if(reg_A[31]!=reg_C[31])
        flag[2] = 1'b1;
    end
end
endcase

//addiu - Add Immediate Unsigned
case(opcode)
6'b001001:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;

    reg_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000 +instruction[15:0];
    if(reg_B[15] == 1'b1)
        reg_B[31:16] = 16'b1111_1111_1111_1111;

    reg_C = reg_A + reg_B;

    if(reg_A[31]==1 & reg_A[31]==0)
    begin
        reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_C = -reg_A + reg_B;
    end

    if(reg_A[31]==0 & reg_B[31]==1)
    begin
        reg_B = ~reg_B + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_C = reg_A - reg_B;
    end

    if(reg_A[31]==1 & reg_B[31]==1)
    begin
        reg_A = ~reg1 + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_B = ~reg_B + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        reg_C = - (reg_A + reg_B);
    end
end
endcase

//andi - And Immediate
case(opcode)
6'b001100:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000 +instruction[15:0];
    reg_C = reg_A & reg_B;
end
endcase

//ori - Or Immediate
case(opcode)
6'b001101:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000 +instruction[15:0];
    reg_C = reg_A | reg_B;
end
endcase

//xori - XOR Immediate
case(opcode)
6'b001110:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000 + instruction[15:0];
    reg_C = reg_A ^ reg_B;
end
endcase

//beq - Branch on Equal
case(opcode)
6'b000100:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = reg2;
    reg_C = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    // 0 : zero flag;
    if(reg_A==reg_B)
        begin
        flag[0] = 1'b1;
        reg_C= 32'b0000_0000_0000_0000_0000_0000_0000_0000 + instruction[15:0] + instruction[15:0] + instruction[15:0] + instruction[15:0];
        end

    if(reg_C[17] == 1'b1)
        reg_C[31:18] = 16'b1111_1111_1111_11;
end
endcase

//bne - Branch on Not Equal
case(opcode)
6'b000101:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = reg2;
    reg_C = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    // 0 : zero flag;
    if(reg_A!=reg_B)
        begin
        flag[0] = 1'b1;
        reg_C= 32'b0000_0000_0000_0000_0000_0000_0000_0000 + instruction[15:0] + instruction[15:0] + instruction[15:0] + instruction[15:0];
        end
        
    if(reg_C[17] == 1'b1)
        reg_C[31:18] = 16'b1111_1111_1111_11;
end
endcase

//lw - Load Word
case(opcode)
6'b100011:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = reg2;
    reg_C = 32'b00000000000000000000000000000000 + instruction[15:0];
    
    if(reg_C[15] == 1'b1)
        reg_C[31:16] = 16'b1111_1111_1111_1111;
        
    reg_C = reg_C + reg_A;
	//outputs address designated by immediate
end
endcase

//sw - Store Word
case(opcode)
6'b101011:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = reg2;
    reg_C = 32'b00000000000000000000000000000000 + instruction[15:0];
    
    if(reg_C[15] == 1'b1)
        reg_C[31:16] = 16'b1111_1111_1111_1111;

    reg_C = reg_C + reg_A;
	//outputs address designated by immediate
end
endcase

//slti - slt Immediate
case(opcode)
6'b001010:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    reg_A = reg1;
    reg_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000 +instruction[15:0];
    if(reg_B[15] == 1'b1)
        reg_B[31:16] = 16'b1111_1111_1111_1111;
    
    reg_C = 0000_0000_0000_0000_0000_0000_0000_0000;

    // 1. negative flag

    if(reg_A < reg_B)
        begin
        flag[1] = 1'b1;
        reg_C = 0000_0000_0000_0000_0000_0000_0000_0001;
        end
end
endcase    

//sltiu - slt Immediate Unsigned
case(opcode)
6'b001011:
begin
    flag[0] = 1'b0;
    flag[1] = 1'b0;
    flag[2] = 1'b0;
    func = 6'bxxxxxx;

    regu_A = reg1;
    reg_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000 +instruction[15:0];
    if(reg_B[15] == 1'b1)
        reg_B[31:16] = 16'b1111_1111_1111_1111;
    
    reg_C = 0000_0000_0000_0000_0000_0000_0000_0000;

        // 1. negative flag
        
    if(regu_A < regu_B)
        begin
        flag[1] = 1'b1;
        reg_C = 0000_0000_0000_0000_0000_0000_0000_0001;
        end
end
endcase 

//------------------------------------------------------------------

end
assign result = 32'b0000_0000_0000_0000_0000_0000_0000_0000 + reg_C;
assign flags = flag[2:0];

//----------------------------------------

endmodule
