module FA 
(
    input A, B, C,
    output S, Cout
);
    xor x0 (D, A, B);
    xor x1 (S, D, C);
    and a0 (E, A, B);
    and a1 (F, G, C);
    or o1 (G, A, B);
    or o2 (Cout, E, F);
endmodule


module CSA 
(
    input [3:0] A, B, C,
    output [3:0] S,
    output [3:0] Cout
);
    genvar i;
    generate 
        for (i = 0; i < 4; i++) begin : CSA_FULL_ADDERS
            FA fa(A[i], B[i], C[i], S[i], Cout[i]);
        end
    endgenerate

endmodule

module CPA
(
    input [3:0] A, B,
    output [4:0] result
);
    wire [4:0] C;
    wire [3:0] G, P, S;

    genvar i;
    generate 
        for (i = 0; i < 4; i++) begin : CPA_FULL_ADDERS
            FA fa
            (
                .A(A[i]),
                .B(B[i]),
                .C(C[i]),
                .S(S[i]),
                .Cout()
            );
            assign G[i] = A[i] & B[i];
            assign P[i] = A[i] | B[i];
            assign C[i + 1] = G[i] | (P[i] & C[i]);
        end
    endgenerate

    assign C[0] = 1'b0;
    assign result = {C[4], S};
endmodule


module DREG #(parameter WIDTH = 4) 
(
    input reset, clk,
    input [WIDTH - 1: 0] D,
    output logic [WIDTH - 1: 0] Q
);
    always_ff @(posedge clk) begin
        if (reset)
            Q = {WIDTH{1'b0}};
        else
            Q <= D;
    end
endmodule

module IntegratorNeuron 
(
    input clk,
    input [3:0] w,
    input [3:0] x [4],
    output logic F

);
    logic [3:0] l_x [4];
    wire [3:0] sum1, sum2;
    wire [5:0] final_sum;
    wire [3:0] c1, c2;

    assign final_sum[0] = sum2[0];
    DREG x0_reg (~w[0], clk, x[0], l_x[0]);
    DREG x1_reg (~w[1], clk, x[1], l_x[1]);
    DREG x2_reg (~w[2], clk, x[2], l_x[2]);
    DREG x3_reg (~w[3], clk, x[3], l_x[3]);

    CSA csa_abc (l_x[0], l_x[1], l_x[2], sum1, c1);
    CSA csa_sum1_c1_d(sum1, l_x[3], {c1[2:0], 1'b0}, sum2, c2);
    CPA cpa({c1[3], sum2[3:1]}, c2, final_sum[5:1]);



    always_ff @(posedge clk) begin
        F <= final_sum[5] | final_sum[4];
    end

endmodule 
