module hazard_unit(
    input wire PCSrcE,             // EX�׶�ȷ��������תʱ���ź�
    input wire RegWriteM,          // MEM�׶�ָ���д�Ĵ���
    input wire RegWriteW,          // WB�׶�ָ���д�Ĵ���
    input wire [4:0] Rs1D,
    input wire [4:0] Rs2D,         // ID�׶�ָ���Դ�Ĵ�����
    input wire [4:0] Rs1E,
    input wire [4:0] Rs2E,         // EX�׶�ָ���Դ�Ĵ�����
    input wire [4:0] RdE,          // EX�׶�ָ���Ŀ��Ĵ�����
    input wire [4:0] RdM,          // MEM�׶�ָ���Ŀ��Ĵ�����
    input wire [4:0] RdW,          // WB�׶�ָ���Ŀ��Ĵ�����
    input wire MemReadE,           // EX�׶�ָ���Ƿ�ΪLoad���Ӵ洢�������ݣ�
    output reg StallF,             // IF�׶���ͣ�ź�
    output reg StallD,             // ID�׶���ͣ�ź�
    output reg FlushD,             // ID�׶γ�ˢ�ź�
    output reg FlushE,             // EX�׶γ�ˢ�ź�
    output reg [1:0] ForwardAE,    // ת��ѡ����ƣ�ALU������A��
    output reg [1:0] ForwardBE     // ת��ѡ����ƣ�ALU������B��
);
    always @(*) begin
        // Ĭ������ͣ���޳�ˢ����ת��
        StallF = 0; StallD = 0; FlushD = 0; FlushE = 0;
        ForwardAE = 2'b00; ForwardBE = 2'b00;
        // ����ǰ�ݿ��ƣ�EX�׶�Դ����������һ����������ָ��Ŀ����ͬʱ����ת��
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E))
            ForwardAE = 2'b10;
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E))
            ForwardAE = 2'b01;
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E))
            ForwardBE = 2'b10;
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E))
            ForwardBE = 2'b01;
        // Load-Use����ð�ռ�⣺���EX�׶ε�ָ��ΪLoad����Ŀ��Ĵ���������ǰID�׶�ָ��ʹ�ã�����ͣ��ˮ��һ������
        if (MemReadE && ((RdE == Rs1D) || (RdE == Rs2D)) && (RdE != 5'b0)) begin
            StallF = 1;
            StallD = 1;
            FlushE = 1;  // ��EX�׶β�������
        end
        // ����ð�մ�����EX�׶�ȷ��������ת/��֧ʱ����ˢ����ȡ������һ��ָ��
        if (PCSrcE) begin
            FlushD = 1;
        end
    end
endmodule
