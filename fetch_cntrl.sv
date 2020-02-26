module fetch_cntrl 
( 	
	input	logic				s0_vld, 
	input	[7:0]				s0_cnt, 
	output	logic				s0_rdy, 

	output	logic				s1_vld, 
	output	[31:0]				s1_pl, 
	input	logic				s1_rdy, 
	
	input	logic				clk, 
	input	logic				rst 
);


logic	[7:0]		s0_addr;

assign s0_addr	= s0_cnt;


logic	s0_rdy_int;

always @(posedge clk)
if (rst) 
	s0_rdy_int	<= 1;
else if (s0_vld & s0_rdy) 
	s0_rdy_int	<= 0;
else if (s1_rdy) 
	s0_rdy_int	<= 1;


assign s0_rdy = 
`ifdef PROP_RDY
				s1_rdy |
`endif
				s0_rdy_int ;

logic	s0_trans; assign s0_trans = s0_vld & s0_rdy;

logic	[31:0]		s0_dout;

ram_block_sdp #(
	.A_S		( 8 ), 
	.M_S		( 4 ), 			
	.D_S		( 32 )
) u_data_ram (
	.wea		( 'd0 ), 
	.reb		( s0_trans ), 
	.bea		( 'd0 ), 
	.addra		( 'd0 ), 
	.addrb		( s0_addr ), 
	.dina		( 'd0 ), 
	.doutb		( s0_dout ),
	.clk,  
	.rst 
); 
initial begin 
for (int i = 0; i < 256; i++) 
  u_data_ram.data[i] = 32'h4000_0000 + i;
end

`DFF_1D(s0_trans)
`DFF_1DN(s0_addr, 8)


assign s1_pl = s0_dout;
//assign s1_vld	= s0_trans_1d;
always @(posedge clk)
if (rst) 
	s1_vld	<= 0;
else if (s0_trans) 
	s1_vld	<= 1;
else if (~s0_trans & s1_rdy) 
	s1_vld	<= 0;


endmodule 
