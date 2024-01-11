module cpu(
	input clk,
	input rst,
	input [31:0] mem_data,
	output reg [31:0] mem_addr,
	inout [31:0] port_a,
	inout [31:0] port_b,
	output reg [7:0] port_a_addr,
	output reg [7:0] port_b_addr
);

reg [27:0] pc;
reg [31:0] inst_code;
reg [2:0] state;

reg [31:0] temp_1;
reg [31:0] temp_2;
wire signed [31:0] temp_1_s = temp_1;
wire signed [31:0] temp_2_s = temp_2;

wire advance_pc = pc + 1;
wire branch_addr = 1;

//// Instruction decode logic

//Does the arithmetic instruction use the immediate register format?
wire op_is_imm = !inst_code[5];
wire [2:0] funct3 = inst_code[14:12];

//Register fields from instruction 
wire [5:0] rd = inst_code[11:7];
wire [5:0] rs1 = inst_code[19:15];
wire [5:0] rs2 = inst_code[24:20];

//Decode different immediate value encodings
wire [31:0] Iimmediate = {{20{inst_code[31]}}, inst_code[31:20]};
wire [31:0] Simmediate = {{20{inst_code[31]}}, inst_code[31:25], inst_code[11:7]}; //Used by store instructions
wire [31:0] Bimmediate = {{19{inst_code[31]}}, inst_code[31], inst_code[7], inst_code[30:25], inst_code[11:8], {1'b0}}; //Used by conditional branch instructions
wire [31:0] Uimmediate = {inst_code[31:12], {12{1'b0}}};
wire [31:0] Jimmediate = {{12{inst_code[31]}}, inst_code[31], inst_code[19:12], inst_code[20], inst_code[30:21], {1'b0}}; //Used by jump instructions

//Shift instructions use specialized encoding
wire [4:0] shift_amount = op_is_imm ? temp_2[4:0] : inst_code[24:20];

wire [31:0] shifted_value = funct3[2] ? //Is right shift?
													inst_code[30] ? temp_1 >>> shift_amount : temp_1 >> shift_amount //Right shift can be logical or arithmetic
												: temp_1 << shift_amount; //Left shift is always the same

//Arithmetic operations other than bitwise shifts
wire [31:0] alu_out = 
	//Only subtract in the case of a register-register operation with bit inst_code[30] set
	funct3 == 0 ? (op_is_imm || !inst_code[30]) ? temp_1 + temp_2 : temp_1 - temp_2 :
	funct3 == 1 ? shifted_value :
	funct3 == 2 ? temp_1_s < temp_2_s :
	funct3 == 3 ? temp_1 < temp_2 :
	funct3 == 4 ? temp_1 ^ temp_2 :
	funct3 == 5 ? shifted_value :
	funct3 == 6 ? temp_1 | temp_2 :
	funct3 == 7 ? temp_1 & temp_2 : 0;

always @(posedge clk) begin
	if(rst) begin
		state <= 0;
		pc <= 0;
	end
	else begin
		case (state)
		0 : begin 
			//Fetch instruction
			inst_code <= mem_data;
			//Save result from previous instruction
		end

		1 : begin
			//Instruction has been fetched and decoded by the combinational logic
			//Output reg file addresses

			//Output memory address from instruction
			//mem_addr <= decoded;
		end

		2 : begin
			//In case of a load instruction, save value read from main memory into temp reg
			//Else, save operand values from registers into temp regs

			//Update PC
		end
		
		endcase
	end
end



endmodule