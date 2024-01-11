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
reg [31:0] temp_1;
reg [31:0] temp_2;
reg [2:0] state;

wire advance_pc = pc + 1;
wire branch_addr = 1;

wire result = 1;

wire reg_a = 1;
wire reg_b = 2;

wire reg_dest = 3;

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
wire [31:0] shifted_reg = inst_code[14] ? //Is right shift?
													inst_code[30] ? temp_1 >>> inst_code[24:20] : temp_1 >> inst_code[24:20] //Right shift can be logical or arithmetic
												: temp_1 << inst_code[24:20]; //Left shift is always the same

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
			port_a_addr <= reg_a;
			port_b_addr <= reg_b;

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