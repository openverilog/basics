
Intf_axi_D		axi_intf ();

t_reg_PERF_PERF_CFG_s               reg_PERF_PERFCNT_CFG;
t_reg_PERF_PERF_CNT_RUN_LO_s        reg_PERF_PERF_CNT_RUN_LO;
t_reg_PERF_PERF_CNT_RUN_HI_s        reg_PERF_PERF_CNT_RUN_HI;
t_reg_PERF_PERF_CNT_WR_TRANS_s      reg_PERF_PERF_CNT_WR_TRANS;
t_reg_PERF_PERF_CNT_RD_TRANS_s      reg_PERF_PERF_CNT_RD_TRANS;
t_reg_PERF_PERF_CNT_AW_CYCLES_s     reg_PERF_PERF_CNT_AW_CYCLES;
t_reg_PERF_PERF_CNT_W_CYCLES_s      reg_PERF_PERF_CNT_W_CYCLES;
t_reg_PERF_PERF_CNT_AR_CYCLES_s     reg_PERF_PERF_CNT_AR_CYCLES;
t_reg_PERF_PERF_CNT_B_CYCLES_s      reg_PERF_PERF_CNT_B_CYCLES;
t_reg_PERF_PERF_CNT_R_CYCLES_s      reg_PERF_PERF_CNT_R_CYCLES;


logic	[63:0]			run_cnt;

logic	[31:0]			wr_cnt;
logic	[31:0]			rd_cnt;
logic	[31:0]			aw_cycles, w_cycles, ar_cycles;
logic	[31:0]			b_cycles, r_cycles;

localparam			N_OSD	= 16;

logic	[$clog2(N_OSD)-1:0]	wptr, rptr;

logic		t_aw, t_w, t_ar, t_b, t_r;
logic		p_aw, p_w, p_ar;


always @(posedge clk)
if (rst) 
	run_cnt	<= 0;
else if (reg_PERF_PERFCNT_CFG.RESET) 
	run_cnt	<= 0;
else if (reg_PERF_PERFCNT_CFG.EN) 
	run_cnt	<= run_cnt + 1;
	

always @(posedge clk)
if (rst) begin 
	wr_cnt		<= 0;
	rd_cnt		<= 0;
	aw_cycles	<= 0;
	w_cycles	<= 0;
	ar_cycles	<= 0;
	b_cycles	<= 0;
	r_cycles	<= 0;
end
else if (reg_PERF_PERFCNT_CFG.RESET) begin 
	wr_cnt		<= 0;
	rd_cnt		<= 0;
	aw_cycles	<= 0;
	w_cycles	<= 0;
	ar_cycles	<= 0;
	b_cycles	<= 0;
	r_cycles	<= 0;
end
else if (reg_PERF_PERFCNT_CFG.EN)  begin 
	if (t_aw)	wr_cnt		<= wr_cnt + 1;
	if (t_ar)	rd_cnt		<= rd_cnt + 1;
	if (p_aw)	aw_cycles	<= aw_cycles + 1;
	if (p_w)	w_cycles	<= w_cycles + 1;
	if (p_ar)	ar_cycles	<= ar_cycles + 1;
	
	b_cycles	<= b_cycles + wptr;
	r_cycles	<= r_cycles + rptr;
end

always @(posedge clk)
if (rst) 
	wptr	<= 0;
else if (reg_PERF_PERFCNT_CFG.EN) 
  if (t_aw ^ t_b) 
	wptr	<= wptr + t_aw - t_b;

always @(posedge clk)
if (rst) 
	rptr	<= 0;
else if (reg_PERF_PERFCNT_CFG.EN) 
  if (t_ar ^ t_r) 
	rptr	<= rptr + t_ar - t_r;


assign t_aw	= axi_intf.AWVALID	& axi_intf.AWREADY;
assign t_w	= axi_intf.WVALID	& axi_intf.WREADY;
assign t_ar	= axi_intf.ARVALID	& axi_intf.ARREADY;
assign t_b	= axi_intf.BVALID	& axi_intf.BREADY;
assign t_r	= axi_intf.RVALID	& axi_intf.RREADY;
assign p_aw	= axi_intf.AWVALID	& ~axi_intf.AWREADY;
assign p_w	= axi_intf.WVALID	& ~axi_intf.WREADY;
assign p_ar	= axi_intf.ARVALID	& ~axi_intf.ARREADY;

