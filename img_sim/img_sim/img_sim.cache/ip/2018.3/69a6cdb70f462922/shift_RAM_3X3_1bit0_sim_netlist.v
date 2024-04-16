// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Apr  3 11:22:11 2024
// Host        : DESKTOP12700 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ shift_RAM_3X3_1bit0_sim_netlist.v
// Design      : shift_RAM_3X3_1bit0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "shift_RAM_3X3_1bit0,c_shift_ram_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_shift_ram_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (D,
    CLK,
    SCLR,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 d_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME d_intf, LAYERED_METADATA undef" *) input [0:0]D;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:d_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA undef" *) output [0:0]Q;

  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  (* C_AINIT_VAL = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "640" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_shift_ram_v12_0_12 U0
       (.A({1'b0,1'b0,1'b0,1'b0}),
        .CE(1'b1),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

(* C_ADDR_WIDTH = "4" *) (* C_AINIT_VAL = "0" *) (* C_DEFAULT_DATA = "0" *) 
(* C_DEPTH = "640" *) (* C_ELABORATION_DIR = "./" *) (* C_HAS_A = "0" *) 
(* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_MEM_INIT_FILE = "no_coe_file_loaded" *) (* C_OPT_GOAL = "0" *) 
(* C_PARSER_TYPE = "0" *) (* C_READ_MIF = "0" *) (* C_REG_LAST_BIT = "1" *) 
(* C_SHIFT_TYPE = "0" *) (* C_SINIT_VAL = "0" *) (* C_SYNC_ENABLE = "0" *) 
(* C_SYNC_PRIORITY = "1" *) (* C_VERBOSITY = "0" *) (* C_WIDTH = "1" *) 
(* C_XDEVICEFAMILY = "zynq" *) (* downgradeipidentifiedwarnings = "yes" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_shift_ram_v12_0_12
   (A,
    D,
    CLK,
    CE,
    SCLR,
    SSET,
    SINIT,
    Q);
  input [3:0]A;
  input [0:0]D;
  input CLK;
  input CE;
  input SCLR;
  input SSET;
  input SINIT;
  output [0:0]Q;

  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  (* C_AINIT_VAL = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "640" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_shift_ram_v12_0_12_viv i_synth
       (.A({1'b0,1'b0,1'b0,1'b0}),
        .CE(1'b0),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
PkyhyBb59EPgq8kANKUgNUvJSxwVgcYTKLlfXroHeM6zPnPHm+ATuJPY2OmCojZnDY2A6SHiMUmx
ylnsx6jVAA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
XgKClVpS+h3z22aTgNZepCZW5Yffl4m6nNLRjY88G0b6Og6dF7wA3of30X3Vr2BKX5GVSe+jeu6a
q3D7Qa0T3sEnO1qnWdbom/P31G6nS7/pQCPaLh+suxznQX2imRfhfTkmY1B9wExxZtZBbss2GPfs
EFGX8a+efiUiZLAKaSE=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LYMHL9qwz9VPPAbHAyLFK1YM6t0YBJUbhdak6y3IQta7KscLfLakFo9QXv7rXKj3R5WEjx6Vg+9K
QUgoa/uCYy+n2t004DDpVeDamNuGIrJU3WXV9mo6tEi21Rm+kIG+CFgVuqLY9JSjwI3dhmEqYYtS
wC2GIO6hKaV0keq1ldvsRFBu71kLY+jczboTe6EddpUktWp3UM/RqnrSfHPMlZWhHp1k3YC0SDq9
gvcPn9DB3vIjXgn+xRbyzZOt/j+s8RfjF446i2RalkF5p/den9o/OMG5jmv4rZKHj9S1V3Z2UuL1
c2fxe26sNIvZ7tpz8RHVWRMloPfcPVakam2zhg==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BACIRg239ZSAZHpsLobWk7IZyWSAM1rsaZq5LesIgnba07iijhvT5s8WIOIIgHZs1XEDKelSnU1J
+5cyEbU9WgPZsja6FQEw6J0GuN3L/1QyrvmNIJKsNXINx7R+xaY/n0uby2eFsFE9luplvdOyrCEw
eK82BghXwPdasTT1ZUgKiycyGYtNsp5ZaPIWXI9ezN9oHowcWp7Mn6v2jrdDl4lzJuoHgqRtkZvG
7GqevJFheGfXkRPuQGkNK2Pk6XN9woSB1a9C+FUsQBM5MlIE7zrBQAjONIQj/nd82Hlp1H4PRxBW
1mmFP7PskMeNR2hH5xwkvg4Q3IfYBlw8gdzneg==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
vUWbACu3JL9XeVH21XChN1bLnACIM0U/dLRQNf2LGaDFNW9CL0o3SY9pOtV226o71+9Eal6i7P4l
ht62RU2AHTweJsgWkXtQBI0/jHIw4/gxbBebNbqZM6m3qjEE5blPsuzJ1njoX2JWCJElO3p9FfRu
uHpC+4hYoccdFayGku3vk1gwz9lLJ4FcYG9mi1vLIY+tzs0o83THQ8dLrg50Rr/r2n0Xf4hxWe4U
tJ6iUOYBQUYjeOwNQOOxfjv5PKfLIgGA2WC8sJb2GFe9MkTDoMAo40nBLK0Y8+klDIJTyx079Bx0
wdRg2JxUF3+TGlXW98+2/iWy94H1CPEVRm18FQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VX8rVAT0l4oniSvb1X0sblwaqcWh2XE0oCAZbC0SVv8fCy8dLmmtqBzFq3w2V/7nyMmJzWKNP/yV
0GW7ICEfrGaBejU3VpwaHA69xE56Y/8NSHGlZOhr390/5/UqELcFOknZEPJXMLpeKjUn2ijACn/u
O0myDIvGFiUyRGWWYKM=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
dlKAt52rb1rebbUvCxUw/pmWR03F+be3vApC1VuekYTvk7BFt7xopdHrqsvoU8rgaCBc2wuCudx5
nUcu7bKEyHKFc6bcbp6J84c2uG0ZckyqBn/OHRMbmq4Vbar8C3ERI2YmcbL0Q0fBLzMosVarF9eM
+c6VfE9hA5lx9qpwFJhgk5v/yx6kjgu+kEnG+xsdWrpKrj8LIxxh6gkrPOn+jQtKQSX3o7q35Rcv
W3vWLRYdH+pHsfJqCdT0wL4oBTLa7ozdsufX9l6UDgT4ECxLf7R1TtNj7XA1jaaefThL0F1AUCjF
5WuhMqBOotpDZUmvB91yVtbXLMm0r85tK9b/iA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YYkxpAWgjd9KIeI5aZR9wwBBIeAe9tsut9ngmB9rAYkm6s1jNmBipsoC0EvT3o8T5sazvGt+bdes
/bYk1/qda7CKLPsdlAXof2zN33HwODLe6LD9vYMw1a7hf2X04dmEMtXaGO2jaVIw7pAZZealR6XT
eMuX+FOsgj6H+3dF/mg1VOjKN6QGTbQFqgP2225FyD12c96YAfINw4G+ZATBSK10dEPHh71zDL6r
tipLbdhCXvSttkKQUT4eM/D76XWMbaSzMIbGelBKxg3gZxsUMp+2ExN6bjsr5BcuRh02owoV2Qo9
p4U0c9xVHHYkjXv8gFpWOlP00PeWCTPOdYZveA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
gxTaBiroyDMDC8wOevKPsFpkhCRGbLad9Y6Zje1aoz0v9dwzBW+TuVw7jaYsM0XmyK2I26OvvI2m
ZFVaw/0lm/xRS99bWU3MD5A7EjqBbyziGkx/LD3z2LJbMdXrXpW0bKrNO6LsVCqlMn16+08rPkvh
s+Xnwu64w4QYG9uvZ6f49x3/17LnBUoqbX2BCaDQ6Gcw0Z1CW92GO/IVRnq8wmt7bnWmsWvFdGSY
jIVe/w7/g43iL26rP6ZYEhHZwrw4BQaxTepOWBIvCPwffqo0vzztrcO0YlwbQE/cTW+7BT7MXCwW
dV3V7006hMrO4w2ABb2s8JJUoWjvdj+JOZ6z6g==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22320)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
