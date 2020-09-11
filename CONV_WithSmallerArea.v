`timescale 1ns/10ps

module  CONV(
            input		clk,
            input		reset,
            output	reg	busy,
            input		ready,

            output	reg [11:0]	iaddr,
            input	[19:0]	idata,

            output	reg 	cwr,
            output	reg [11:0] 	caddr_wr,
            output	reg [19:0] 	cdata_wr,

            output	reg 	crd,
            output	reg [11:0] 	caddr_rd,
            input	 [19:0]	cdata_rd,

            output	reg [2:0] 	csel
        );
reg signed [19:0] buffer[8:0];
reg [4:0] count;
reg [11:0] layerone_addr;
reg signed [39:0] mul;
reg [3:0] count_k;
reg start = 1;
reg beginning;
wire [19:0] com0, com1, max;
wire signed [19:0] k[8:0];
wire signed [19:0] bias;
assign com0 = (buffer[0] >= buffer[1])?buffer[0]:buffer[1];
assign com1 = (buffer[2] >= buffer[3])?buffer[2]:buffer[3];
assign max = (com0 >= com1)?com0:com1;
integer i;
assign bias = 20'h01310;
assign  k[0] = 20'h0a89e,
        k[1] = 20'h092d5,
        k[2] = 20'h06d43,
        k[3] = 20'h01004,
        k[4] = 20'hf8f71,
        k[5] = 20'hf6e54,
        k[6] = 20'hfa6d7,
        k[7] = 20'hfc834,
        k[8] = 20'hfac19;

/*---------------------------------------------*/
always@(posedge clk or posedge reset) begin
    if(reset) begin
        iaddr <= 1;
        cwr <= 0;
        caddr_wr <= 0;
        cdata_wr <= 0;
        crd <= 0;
        caddr_rd <= 0;
        csel <= 3'b001;
        count <= 0;
        layerone_addr <= 0;
        beginning <= 1;
        mul <= 0;
        count_k <= 0;
        for(i = 0; i < 9; i = i + 1)
            buffer[i] <= 0;
    end
    else begin
        case(count)
            /* layer 0 */
            0: begin
                if(beginning) begin
                    iaddr <= iaddr;
                    count <= 0;
                    beginning <= 0;
                end
                else begin
                    buffer[5] <= idata;
                    iaddr <= caddr_wr + 65;
                    if(caddr_wr[5:0] == 6'd0) begin
                        count <= 3;
                    end
                    else begin
                        buffer[0] <= buffer[1];
                        buffer[1] <= buffer[2];
                        buffer[3] <= buffer[4];
                        buffer[4] <= buffer[5];
                        buffer[6] <= buffer[7];
                        buffer[7] <= buffer[8];
                        if(caddr_wr[5:0] == 6'd63)
                            count <= 1;
                        else begin
                            count <= 10; // not first col and last col
                        end
                    end
                end
            end
            1: begin  //for last col
                buffer[2] <= 0;
                buffer[5] <= 0;
                buffer[8] <= 0;
                if(caddr_wr == 63)
                    count_k <= 3;
                else
                    count_k <= 0;
                count <= 2;
            end
            2: begin // for multiply
                mul <= mul + buffer[count_k] * k[count_k];
                if(caddr_wr[11:6] == 6'd63) begin  // last row
                    if(caddr_wr == 4095) begin
                        if(count_k == 1)
                            count_k <= 3;
                        else
                            count_k <= count_k + 1;
                        if(count_k == 4)
                            count <= 12;
                        else
                            count <= 2;
                    end
                    else begin
                        if(caddr_wr == 4032) begin
                            if(count_k == 2)
                                count_k <= 4;
                            else
                                count_k <= count_k + 1;
                        end
                        else begin
                            count_k <= count_k + 1;
                        end
                        if(count_k == 5)
                            count <= 12;
                        else
                            count <= 2;
                    end
                end
                else begin
                    if(caddr_wr[5:0] == 6'd63) begin
                        if(caddr_wr == 63) begin
                            if(count_k == 4)
                                count_k <= 6;
                            else
                                count_k <= count_k + 1;
                        end
                        else begin
                            if(count_k == 1)
                                count_k <= 3;
                            else if(count_k == 4)
                                count_k <= 6;
                            else
                                count_k <= count_k + 1;
                        end
                        if(count_k == 7)
                            count <= 12;
                        else
                            count <= 2;
                    end
                    else begin
                        count_k <= count_k + 1;
                        if(count_k == 8)
                            count <= 12;
                        else
                            count <= 2;
                    end
                end
            end
            3: begin // first col
                buffer[0] <= 0;
                buffer[3] <= 0;
                buffer[6] <= 0;
                iaddr <= caddr_wr;
                buffer[8] <= idata;
                count <= 4;
            end
            4: begin
                if(caddr_wr[11:6] == 6'd63) begin // last row
                    count <= 5;
                    iaddr <= caddr_wr - 63;
                end
                else begin  // not last row
                    count <= 6;
                    iaddr <= caddr_wr + 64;
                end
                buffer[4] <= idata;
            end
            5: begin // last row
                buffer[2] <= idata;
                buffer[7] <= 0;
                buffer[8] <= 0;
                iaddr <= caddr_wr - 64;
                count <= 7;
            end
            6: begin
                buffer[7] <= idata;
                iaddr <= caddr_wr - 63;
                count <= 8;
            end
            7: begin
                count <= 2;
                buffer[1] <= idata;
                buffer[0] <= 0;
                buffer[3] <= 0;
                buffer[6] <= 0;
                if(caddr_wr == 4032)
                    count_k <= 1;
                else
                    count_k <= 0;
            end
            8: begin
                if(caddr_wr == 0) begin  // pixel 0
                    buffer[1] <= 0;
                    buffer[2] <= 0;
                    count_k <= 4;
                    count <= 2;
                end
                else begin
                    count <= 9;
                    buffer[2] <= idata;
                    iaddr <= caddr_wr - 64;
                end
            end
            9: begin
                buffer[1] <= idata;
                count_k <= 1;
                count <= 2;
            end
            10: begin
                if(caddr_wr[11:6] == 6'd63) begin
                    buffer[8] <= 0;
                end
                else begin
                    buffer[8] <= idata;
                end
                iaddr <= caddr_wr - 63;
                count <= 11;
            end
            11: begin
                count <= 2;
                if(caddr_wr <= 62) begin
                    count_k <= 3;
                end
                else begin
                    count_k <= 0;
                    buffer[2] <= idata;
                end
            end
            /* layer 0 output */
            12: begin
                cdata_wr <= mul[35:16] + mul[15] + bias;
                iaddr <= caddr_wr + 2;
                mul <= 0;
                count <= 13;
            end
            13: begin
                cdata_wr <= (cdata_wr[19] == 1)?0:cdata_wr;
                cwr <= 1;
                count <= 14;
            end
            14: begin
                cwr <= 0;
                if(caddr_wr == 4095) begin
                    caddr_wr <= 0;
                    count <= 15;
                    crd <= 1;
                end
                else begin
                    caddr_wr <= caddr_wr + 1;
                    count <= 0;
                end
            end
            /*  layer 1 */
            15: begin
                buffer[0] <= cdata_rd;
                caddr_rd <= layerone_addr + 1;
                count <= 16;
            end
            16: begin
                buffer[1] <= cdata_rd;
                caddr_rd <= layerone_addr + 64;
                count <= 17;
            end
            17: begin
                buffer[2] <= cdata_rd;
                caddr_rd <= layerone_addr + 65;
                count <= 18;
            end
            18: begin
                buffer[3] <= cdata_rd;
                caddr_rd <= layerone_addr + 2;
                count <= 19;
            end
            19: begin
                cwr <= 1;
                csel <= 3'b011;
                cdata_wr <= max;
                count <= 20;
            end
            20: begin
                cwr <= 0;
                csel <= 3'b001;
                caddr_wr <= caddr_wr + 1;
                if(layerone_addr[5:0] == 6'd62) begin
                    if(layerone_addr == 4030) begin
                        layerone_addr <= 4031;
                    end
                    else begin
                        layerone_addr <= layerone_addr + 66;
                        count <= 15;
                    end
                end
                else begin
                    layerone_addr <= layerone_addr + 2;
                    count <= 15;
                end
            end           
            default: count <= count;
        endcase
    end
end
always@(reset or ready or start or count or layerone_addr) begin
    if(reset) begin
        busy = 0;
        start = 0;
    end
    else begin
        if(ready) begin
            busy = 1;
            start = 0;
        end
        else begin
            if(start) begin
                start = 0;
                busy = 0;
            end
            else begin
                start = 0;
                if(count == 20) begin
                    if(layerone_addr == 4031)
                        busy = 0;
                    else
                        busy = 1;
                end
                else
                    busy = 1;
            end
        end
    end
end
endmodule