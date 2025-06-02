/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/



`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"



/*
 *	Description:
 *
 *		This module implements the ALU control unit
 */



module ALUControl(FuncCode, ALUCtl, Opcode);
	input [3:0]		FuncCode;
	input [6:0]		Opcode;
	output reg [6:0]	ALUCtl;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		ALUCtl = 7'b0;
	end

	always @(*) begin
		case (Opcode)
			/*
			 *	LUI, U-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_LUI:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AUIPC;

			/*
			 *	AUIPC, U-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_AUIPC:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AUIPC;

			/*
			 *	JAL, UJ-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_JAL:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;

			/*
			 *	JALR, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_JALR:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;

			/*
			 *	Branch, SB-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_BRANCH:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BEQ; //BEQ conditions
					3'b001:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BNE; //BNE conditions
					3'b100:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLT; //BLT conditions
					3'b101:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGE; //BGE conditions
					3'b110:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLTU; //BLTU conditions
					3'b111:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGEU; //BGEU conditions
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	Loads, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_LOAD:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LB; //LB
					3'b001:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LH; //LH
					3'b010:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LW; //LW
					3'b100:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LBU; //LBU
					3'b101:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LHU; //LHU
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	Stores, S-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_STORE:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SB; //SB
					3'b001:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SH; //SH
					3'b010:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SW; //SW
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	Immediate operations, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_IMMOP:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADDI; //ADDI
					3'b010:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTI; //SLTI
					3'b011:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTIU; //SLTIU
					3'b100:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XORI; //XORI
					3'b110:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ORI; //ORI
					3'b111:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ANDI; //ANDI
					3'b001:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLLI; //SLLI
					3'b101:
						case (FuncCode[3])
							1'b0:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRLI; //SRLI
							1'b1:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRAI; //SRAI
							default:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
						endcase
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	ADD SUB & logic shifts, R-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_ALUOP:
				case (FuncCode[2:0])
					3'b000:
						case(FuncCode[3])
							1'b0:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADD; //ADD
							1'b1:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SUB; //SUB
							default:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
						endcase
					3'b001:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLL; //SLL
					3'b010:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLT; //SLT
					3'b011:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTU; //SLTU
					3'b100:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XOR; //XOR
					3'b101:
						case(FuncCode[3])
							1'b0:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRL; //SRL
							1'b1:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRA; //SRA untested
							default:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
						endcase
					3'b110:
						ALUCtl = 	`kSAIL_MICROARCHITECTURE_ALUCTL_6to0_OR; //OR
					3'b111:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AND; //AND
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			default:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
		endcase
	end
endmodule
