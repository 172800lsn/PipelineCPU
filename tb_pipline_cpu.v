`timescale 1ns / 1ps

module tb_pipeline_cpu;
    reg clk;
    reg reset;

    // ʵ���� DUT
    pipeline_cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // ʱ�����ɣ�10ns ���ڣ��Ƽ�д����
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ��ʼ����λ�߼�
    initial begin
        reset = 1;
        #10;
        reset = 0;

        // ��������ʱ��
        #1000;
        $finish;
    end

    // ��ѡ����ӡ����״̬
    initial begin
        $monitor("Time = %t ns, clk = %b, reset = %b", $time, clk, reset);
    end
endmodule