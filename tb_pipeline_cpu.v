//`timescale 1ns / 1ps

//module tb_pipeline_cpu;
//    reg clk;
//    reg reset;

//    // 实例�? DUT
//    pipeline_cpu uut (
//        .clk(clk),
//        .reset(reset)
//    );

//    // 时钟生成�?10ns 周期（推荐写法）
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk;
//    end

//    // 初始化复位�?�辑
//    initial begin
//        reset = 1;
//        #20;
//        reset = 0;

//        // 仿真运行时间
//        #1000;
//        $finish;
//    end

//    // 可�?�：打印仿真状�??
//    initial begin
//        $monitor("Time = %t ns, clk = %b, reset = %b", $time, clk, reset);
//    end
//endmodule
