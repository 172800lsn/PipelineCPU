module alu(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [1:0] ALUOp,
    output reg [31:0] result
);
    always @(*) begin
        case(ALUOp)
            2'b00: result = A + B;
            2'b01: result = A - B;
            2'b10: result = A | B;
            default: result = A + B;
        endcase
    end
endmodule
