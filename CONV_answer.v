
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

reg busy_nxt;
reg [11:0] iaddr_nxt;
reg crd_nxt;
reg [11:0] caddr_rd_nxt;
reg cwr_nxt;
reg [19:0] cdata_wr_nxt;
reg [11:0] caddr_wr_nxt;
reg [2:0] csel_nxt;
reg [19:0] buffer [0:8];      reg [0:19] buffer_nxt [0:8];
reg [3:0] count;              reg [3:0] count_nxt;
reg [11:0] count_row;         reg [11:0] count_row_nxt;
reg [5:0] count_col;          reg [5:0] count_col_nxt;
reg [2:0] state;              reg [2:0] state_nxt;
reg [39:0] mul;               reg [39:0] mul_nxt;
reg [11:0] current_addr;      reg [11:0] current_addr_nxt;
reg [9:0] layer1_addr;        reg [9:0] layer1_addr_nxt;
reg [1:0] switch_state;       reg [1:0] switch_state_nxt;
reg [19:0] layer1 [0:3];      reg [19:0] layer1_nxt [0:3];
wire [19:0] max1, max2, max3;
assign max1 = (layer1[0]>=layer1[1])? layer1[0]:layer1[1]; 
assign max2 = (layer1[2]>=layer1[3])? layer1[2]:layer1[3];
assign max3 = (max1>=max2)? max1:max2;

parameter [39:0] k0={20'd0,20'h0A89E}, 
k1={20'd0,20'h092D5}, 
k2={20'd0,20'h06D43},
k3={20'd0,20'h01004}, 
k4={20'hfffff,20'hF8F71}, 
k5={20'hfffff,20'hF6E54}, 
k6={20'hfffff,20'hFA6D7}, 
k7={20'hfffff,20'hFC834}, 
k8={20'hfffff,20'hFAC19};

                 
integer i;
always@(posedge clk or posedge reset) begin
  if(reset) begin
    busy <= 1'b0;
    csel <= 3'd0;
    iaddr <= 12'd0;
    crd <= 1'b0;
    caddr_rd <= 12'd0;
    cwr <= 1'b0;
    cdata_wr <= 20'd0;
    caddr_wr <= 12'd0;
    count_row <= 6'd0;
    count <= 4'd0;
    state <= 3'd0;
    count_col <= 6'd0;
    mul <= 40'd0;
    current_addr <= 12'd0;
    layer1_addr <= 10'd0; 
    switch_state <= 2'd0;
    for(i=0;i<9;i=i+1)
      buffer[i] <= 20'd0;
    for(i=0;i<4;i=i+1)
      layer1[i] <= 20'd0;
  end
  else begin
    busy <= busy_nxt;
    iaddr <= iaddr_nxt;
    crd <= crd_nxt;
    caddr_rd <= caddr_rd_nxt;
    cwr <= cwr_nxt;
    cdata_wr <= cdata_wr_nxt;
    caddr_wr <= caddr_wr_nxt;
    csel <= csel_nxt;
    count_row <= count_row_nxt;
    count <= count_nxt;
    state <= state_nxt;
    count_col <= count_col_nxt;
    mul <= mul_nxt;
    current_addr <= current_addr_nxt;
    layer1_addr <= layer1_addr_nxt;
    switch_state <= switch_state_nxt;
    for(i=0;i<9;i=i+1)
      buffer[i] <= buffer_nxt[i];
    for(i=0;i<4;i=i+1)
      layer1[i] <= layer1_nxt[i];
  end
end

always@(*) begin
  {busy_nxt, csel_nxt, iaddr_nxt, crd_nxt, caddr_rd_nxt, cwr_nxt, cdata_wr_nxt, caddr_wr_nxt} = {busy, csel, iaddr, crd, caddr_rd, cwr, cdata_wr, caddr_wr};
  state_nxt = state;
  count_row_nxt = count_row;
  count_col_nxt = count_col;
  count_nxt = count;
  mul_nxt = mul;
  current_addr_nxt = current_addr;
  switch_state_nxt = switch_state;
  layer1_addr_nxt = layer1_addr;
  for(i=0;i<9;i=i+1)
    buffer_nxt[i] = buffer[i];
  for(i=0;i<4;i=i+1)
    layer1_nxt[i] = layer1[i];
  if(busy) begin
    case(switch_state)
    2'd0:begin
      case(state)
      3'd0:begin //input
        if(count_col==0) begin
          if(count_row==0) begin
            buffer_nxt[0] = 0; buffer_nxt[1] =0; buffer_nxt[2] = 0; buffer_nxt[3] =0; buffer_nxt[6] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr+1'b1;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[5] = idata;
              iaddr_nxt = iaddr+12'd63;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[7] = idata;
              iaddr_nxt = iaddr+1'b1;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd1;
              buffer_nxt[8] = idata;
              iaddr_nxt = iaddr-12'd64;
              count_nxt = 4'd0;
            end
            endcase
          end
          else if(count_row==6'd63) begin
            buffer_nxt[0] = 0; buffer_nxt[3] =0; buffer_nxt[6] = 0; buffer_nxt[7] =0; buffer_nxt[8] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr-12'd64;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[1] = idata;
              iaddr_nxt = iaddr+1'b1;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[2] = idata;
              iaddr_nxt = iaddr+12'd64;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd1;
              buffer_nxt[5] = idata;
              iaddr_nxt = iaddr;
              count_nxt = 4'd0;
            end
            endcase
          end
          else begin
            buffer_nxt[0] = 0; buffer_nxt[3] =0; buffer_nxt[6] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr-12'd64;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[1] = idata;
              iaddr_nxt = iaddr+12'd1;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[2] = idata;
              iaddr_nxt = iaddr+12'd64;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd0;
              buffer_nxt[5] = idata;
              iaddr_nxt = iaddr+12'd64;
              count_nxt = count+1'b1;
            end
            4'd4:begin
              state_nxt = 3'd0;
              buffer_nxt[8] = idata;
              iaddr_nxt = iaddr-12'd1;
              count_nxt = count+1'b1;
            end
            4'd5:begin
              state_nxt = 3'd1;
              buffer_nxt[7] = idata;
              iaddr_nxt = iaddr-12'd63;
              count_nxt = 4'd0;
            end
            endcase
          end
        end
        else if(count_col==6'd63) begin
          if(count_row==0) begin
            buffer_nxt[0] = 0; buffer_nxt[1] =0; buffer_nxt[2] = 0; buffer_nxt[5] =0; buffer_nxt[8] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr-1'b1;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[3] = idata;
              iaddr_nxt = iaddr+12'd64;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[6] = idata;
              iaddr_nxt = iaddr+1'b1;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd1;
              buffer_nxt[7] = idata;
              iaddr_nxt = iaddr-12'd63;
              count_nxt = 4'd0;
            end
            endcase
          end
          else if(count_row==6'd63) begin
            buffer_nxt[2] = 0; buffer_nxt[5] =0; buffer_nxt[6] = 0; buffer_nxt[7] =0; buffer_nxt[8] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr-12'd64;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[1] = idata;
              iaddr_nxt = iaddr-12'd1;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[0] = idata;
              iaddr_nxt = iaddr+12'd64;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd1;
              buffer_nxt[3] = idata;
              iaddr_nxt = 12'd0;
              count_nxt = 4'd0;
            end
            endcase
          end
          else begin
          buffer_nxt[2] = 0; buffer_nxt[5] =0; buffer_nxt[8] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr-12'd64;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[1] = idata;
              iaddr_nxt = iaddr-12'd1;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[0] = idata;
              iaddr_nxt = iaddr+12'd64;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd0;
              buffer_nxt[3] = idata;
              iaddr_nxt = iaddr + 12'd64;
              count_nxt = count + 1'b1;
            end
            4'd4:begin
              state_nxt = 3'd0;
              buffer_nxt[6] = idata;
              iaddr_nxt = iaddr + 12'd1;
              count_nxt = count + 1'b1;
            end
            4'd5:begin
              state_nxt = 3'd1;
              buffer_nxt[7] = idata;
              iaddr_nxt = iaddr -12'd63;
              count_nxt = 4'd0;
            end
            endcase
          end
        end
        else begin
          if(count_row==0) begin
          buffer_nxt[0] = 0; buffer_nxt[1] =0; buffer_nxt[2] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr-12'd1;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[3] = idata;
              iaddr_nxt = iaddr+12'd64;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[6] = idata;
              iaddr_nxt = iaddr+12'd1;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd0;
              buffer_nxt[7] = idata;
              iaddr_nxt = iaddr + 12'd1;
              count_nxt = count +4'd1;
            end
            4'd4:begin
              state_nxt = 3'd0;
              buffer_nxt[8] = idata;
              iaddr_nxt = iaddr - 12'd64;
              count_nxt = count+ 4'd1;
            end
            4'd5:begin
              state_nxt = 3'd1;
              buffer_nxt[5] = idata;
              iaddr_nxt = iaddr ;
              count_nxt = 4'd0;
            end
            endcase
          end
          else if(count_row==6'd63) begin
          buffer_nxt[6] = 0; buffer_nxt[7] =0; buffer_nxt[8] = 0;
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr-12'd1;
              count_nxt = count+1'b1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[3] = idata;
              iaddr_nxt = iaddr-12'd64;
              count_nxt = count+1'b1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[0] = idata;
              iaddr_nxt = iaddr+12'd1;
              count_nxt = count+1'b1;
            end
            4'd3:begin
              state_nxt = 3'd0;
              buffer_nxt[1] = idata;
              iaddr_nxt = iaddr + 12'd1;
              count_nxt = count +4'd1;
            end
            4'd4:begin
              state_nxt = 3'd0;
              buffer_nxt[2] = idata;
              iaddr_nxt = iaddr + 12'd64;
              count_nxt = count+ 4'd1;
            end
            4'd5:begin
              state_nxt = 3'd1;
              buffer_nxt[5] = idata;
              iaddr_nxt = iaddr ;
              count_nxt = 4'd0;
            end
            endcase
          end
          else begin
            case(count)
            4'd0:begin
              state_nxt = 3'd0;
              buffer_nxt[4] = idata;
              iaddr_nxt = iaddr - 12'd63;
              count_nxt = count +4'd1;
            end
            4'd1:begin
              state_nxt = 3'd0;
              buffer_nxt[2] = idata;
              iaddr_nxt = iaddr - 12'd1;
              count_nxt = count +4'd1;
            end
            4'd2:begin
              state_nxt = 3'd0;
              buffer_nxt[1] = idata;
              iaddr_nxt = iaddr - 12'd1;
              count_nxt = count +4'd1;
            end
            4'd3:begin
              state_nxt = 3'd0;
              buffer_nxt[0] = idata;
              iaddr_nxt = iaddr + 12'd64;
              count_nxt = count +4'd1;
            end
            4'd4:begin
              state_nxt = 3'd0;
              buffer_nxt[3] = idata;
              iaddr_nxt = iaddr + 12'd64;
              count_nxt = count +4'd1;
            end
            4'd5:begin
              state_nxt = 3'd0;
              buffer_nxt[6] = idata;
              iaddr_nxt = iaddr + 12'd1;
              count_nxt = count +4'd1;
            end
            4'd6:begin
              state_nxt = 3'd0;
              buffer_nxt[7] = idata;
              iaddr_nxt = iaddr + 12'd1;
              count_nxt = count +4'd1;
            end
            4'd7:begin
              state_nxt = 3'd0;
              buffer_nxt[8] = idata;
              iaddr_nxt = iaddr - 12'd64;
              count_nxt = count +4'd1;
            end
            4'd8:begin
              state_nxt = 3'd1;
              buffer_nxt[5] = idata;
              iaddr_nxt = iaddr ;
              count_nxt = 4'd0;
            end
            endcase
          end
        end
      end
      3'd1:begin //calculate
        //{{20{a[19]}},a}*
        mul_nxt = {{20{buffer[0][19]}},buffer[0]}*k0+{{20{buffer[1][19]}},buffer[1]}*k1+{{20{buffer[2][19]}},buffer[2]}*k2+{{20{buffer[3][19]}},buffer[3]}*k3+{{20{buffer[4][19]}},buffer[4]}*k4+{{20{buffer[5][19]}},buffer[5]}*k5+{{20{buffer[6][19]}},buffer[6]}*k6+{{20{buffer[7][19]}},buffer[7]}*k7+{{20{buffer[8][19]}},buffer[8]}*k8;
        caddr_wr_nxt = current_addr;
        state_nxt = 3'd2;
      end
      3'd2:begin 
        cdata_wr_nxt = mul[35:16]+20'h01310+mul[15];
        state_nxt = 3'd3;
      end
      3'd3:begin
        cdata_wr_nxt = (cdata_wr[19]==1'b1)? 1'b0:cdata_wr;
        cwr_nxt = 1'b1; 
        csel_nxt = 3'b001;
        state_nxt = 3'd4;
      end
      3'd4:begin
        cwr_nxt = 1'b0; 
        current_addr_nxt = (current_addr==12'd4095)? 12'd0:current_addr+1'b1;
        iaddr_nxt = current_addr+1'b1;
        if(count_col==6'd63) begin
          count_col_nxt = 6'd0;
          count_row_nxt = (count_row==6'd63)? 6'd0:count_row+1'b1;
          //busy_nxt = (count_row==6'd63)? 1'b0:1'b1;
          switch_state_nxt = (count_row==6'd63)? 1'b1:1'b0;
        end
        else begin
          count_col_nxt = count_col + 1'b1;
          count_row_nxt = count_row;
        end
        state_nxt = 3'd0;
      end
      endcase
    end
    2'd1:begin
        case(count)
        4'd0:begin
          crd_nxt = 1'b1;
          cwr_nxt = 1'b0;
          csel_nxt = 3'b001;
          caddr_rd_nxt = current_addr;
          count_nxt = 4'd1;
          caddr_wr_nxt = layer1_addr;
        end
        4'd1:begin
          crd_nxt = 1'b1;
          csel_nxt = 3'b001;
          caddr_rd_nxt = current_addr+1'b1;
          layer1_nxt[0] = cdata_rd;
          count_nxt = 4'd2;
        end
        4'd2:begin
          crd_nxt = 1'b1;
          csel_nxt = 3'b001;
          caddr_rd_nxt = current_addr+12'd64;
          layer1_nxt[1] = cdata_rd;
          count_nxt = 4'd3;
        end
        4'd3:begin
          crd_nxt = 1'b1;
          csel_nxt = 3'b001;
          caddr_rd_nxt = current_addr+12'd65;
          layer1_nxt[2] = cdata_rd;
          count_nxt = 4'd4;
        end
        4'd4:begin
          crd_nxt = 1'b0;
          csel_nxt = 3'b001;
          layer1_nxt[3] = cdata_rd;
          count_nxt = 4'd5;
        end
        4'd5:begin
          csel_nxt = 3'b011;
          cwr_nxt = 1'b1;
          cdata_wr_nxt = max3;
          caddr_wr_nxt = layer1_addr;
          count_nxt = 4'd0;
          layer1_addr_nxt = layer1_addr+1'b1;
          if(count_col==6'd62) begin
            if(current_addr==12'd4030) begin
              switch_state_nxt = 2'd2;
            end
            else begin
              current_addr_nxt = current_addr+12'd66;
              count_col_nxt = 6'd0;
              busy_nxt = 1'b1;
            end
          end
          else begin
            current_addr_nxt = current_addr+12'd2;
            count_col_nxt = count_col+6'd2;
          end
        end
        endcase
    end
    2'd2:begin
      busy_nxt = 1'b0;
    end
    endcase
  end
  else begin
    if(ready) begin
      busy_nxt = 1'b1;
      csel_nxt = 3'b001;
    end
    else begin
      busy_nxt = busy;
      csel_nxt = csel;
    end
  end
  
end

endmodule




