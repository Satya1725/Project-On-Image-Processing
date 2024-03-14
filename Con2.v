`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2024 10:09:05 PM
// Design Name: 
// Module Name: conv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module conv (
    input        i_clk,
    input [71:0] i_pixel_data,
    input        i_pixel_data_valid,
    output reg [7:0] o_convolved_data,
    output reg   o_convolved_data_valid
);

integer i; 
reg [7:0] kernel1 [8:0];
reg [7:0] kernel2 [8:0];
reg [7:0] kernel3 [8:0];
reg [7:0] kernel4 [8:0];
reg [10:0] multData1[8:0];
reg [10:0] multData2[8:0];
reg [10:0] multData3[8:0];
reg [10:0] multData4[8:0];
reg [10:0] sumDataInt1;
reg [10:0] sumDataInt2;
reg [10:0] sumDataInt3;
reg [10:0] sumDataInt4;
reg [10:0] sumData1;
reg [10:0] sumData2;
reg [10:0] sumData3;
reg [10:0] sumData4;
reg multDataValid;
reg sumDataValid;
reg convolved_data_valid;
reg [20:0] convolved_data_int1;
reg [20:0] convolved_data_int2;
reg [20:0] convolved_data_int3;
reg [20:0] convolved_data_int4;
wire [21:0] convolved_data_int;
reg convolved_data_int_valid;

initial begin
    // Sobel operator kernels
    kernel1[0] =  1; kernel1[1] =  0; kernel1[2] = -1;
    kernel1[3] =  2; kernel1[4] =  0; kernel1[5] = -2;
    kernel1[6] =  1; kernel1[7] =  0; kernel1[8] = -1;

    kernel2[0] =  1; kernel2[1] =  2; kernel2[2] =  1;
    kernel2[3] =  0; kernel2[4] =  0; kernel2[5] =  0;
    kernel2[6] = -1; kernel2[7] = -2; kernel2[8] = -1;
    
    // Prewitt operator kernels
    kernel3[0] =  1; kernel3[1] =  0; kernel3[2] = -1;
    kernel3[3] =  1; kernel3[4] =  0; kernel3[5] = -1;
    kernel3[6] =  1; kernel3[7] =  0; kernel3[8] = -1;

    kernel4[0] =  1; kernel4[1] =  1; kernel4[2] =  1;
    kernel4[3] =  0; kernel4[4] =  0; kernel4[5] =  0;
    kernel4[6] = -1; kernel4[7] = -1; kernel4[8] = -1;
end    
    
always @(posedge i_clk) begin
    for (i = 0; i < 9; i = i + 1) begin
        multData1[i] <= $signed(kernel1[i]) * $signed({1'b0, i_pixel_data[i*8 +: 8]});
        multData2[i] <= $signed(kernel2[i]) * $signed({1'b0, i_pixel_data[i*8 +: 8]});
        multData3[i] <= $signed(kernel3[i]) * $signed({1'b0, i_pixel_data[i*8 +: 8]});
        multData4[i] <= $signed(kernel4[i]) * $signed({1'b0, i_pixel_data[i*8 +: 8]});
    end
    multDataValid <= i_pixel_data_valid;
end

always @(*) begin
    sumDataInt1 = 0; sumDataInt2 = 0;
    sumDataInt3 = 0; sumDataInt4 = 0;
    for (i = 0; i < 9; i = i + 1) begin
        sumDataInt1 = $signed(sumDataInt1) + $signed(multData1[i]);
        sumDataInt2 = $signed(sumDataInt2) + $signed(multData2[i]);
        sumDataInt3 = $signed(sumDataInt3) + $signed(multData3[i]);
        sumDataInt4 = $signed(sumDataInt4) + $signed(multData4[i]);
    end
end

always @(posedge i_clk) begin
    sumData1 <= sumDataInt1; 
    sumData2 <= sumDataInt2;
    sumData3 <= sumDataInt3; 
    sumData4 <= sumDataInt4;
    sumDataValid <= multDataValid;
end

always @(posedge i_clk) begin
    convolved_data_int1 <= $signed(sumData1) * $signed(sumData1);
    convolved_data_int2 <= $signed(sumData2) * $signed(sumData2);
    convolved_data_int3 <= $signed(sumData3) * $signed(sumData3);
    convolved_data_int4 <= $signed(sumData4) * $signed(sumData4);
    convolved_data_int_valid <= sumDataValid;
end

assign convolved_data_int = convolved_data_int1 + convolved_data_int2 + convolved_data_int3 + convolved_data_int4;
    
always @(posedge i_clk) begin
    if (convolved_data_int > 4000)
        o_convolved_data <= 8'hff;
    else
        o_convolved_data <= 8'h00;
    o_convolved_data_valid <= convolved_data_int_valid;
end

endmodule
