/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-01-05
 Description: A brief description of the file's purpose.
*/
import Vector::*;
import BuildVector::*;
import axi4_types::*;
import apb_types::*;

typedef enum {
	HB_DEFAULT,
	OSPI_DEFAULT,
	QSPI_DEFAULT,
	SPI_DEFAULT
} DefaultMode deriving(Bits, Eq, FShow);

interface XSPI;
	(*always_ready , always_enabled*)
	method Action dq(Bit#(8) in);
	(*always_ready , enable="rwds_in"*)
	method Action rwds();
	(*always_ready , enable="csn" *)
	method Action csn();

	(*ready="dq_out_enable" , always_enabled*)
	method Bit#(8) dq_out;
	(* always_enabled*)
	method Bool dq_out_ena;
	(*ready="rwds_out_enable" , always_enabled*)
	method Bool rwds_out;
	(* always_enabled*)
	method Bool rwds_out_ena;
endinterface
interface Xspi_config;
	(*always_enabled, always_ready*)
	method Action default_mode(DefaultMode m);
	(* always_ready*)
	method Bool deep_power_down();
	(* always_ready*)
	method Bool ultra_deep_power_down();
	(* always_ready*)
	method Bit#(3) drive_strength();
	(* always_ready*)
	method Bool use_xspi_clk();
	(* always_ready*)
	method Bool reset_device();
	(* always_ready*)
	method Bool interrupt();
endinterface

interface XSPI_Ifc;
	interface Ifc_axi4_master#(0,32,64,0) axi;
	interface Ifc_apb_slave#(32,64,0) apb;
	interface XSPI xspi;
	interface Xspi_config cfg;
endinterface
typedef enum {
	ReadSFDP=8'h5a,
	ReadRegister=8'h65,
	WriteRegister=8'h71,

	ReadMEM='h0B,
	WriteMEM='h02, //Program 

	ResetDevice='h99,
	ResetEnable='h66,
	EnterDeepSleep='hB9,
	ExitDeepSleep='hAB,
	SetRate='h52,
	OTPRead='h4b,
	OTPWrite='h42
	// ReadSR='H5,
	// ReadFSR='h70,
	// ReadCR='h85,
	// ReadGPR='h96,
	// WriteSR=1,
	// WriteCR='h81,
	// ClearFR='h50,
}Commands deriving(Bits, Eq, FShow);

typedef enum {None,A5, A4,A3} AddressBytes deriving(Bits,Eq,FShow);
typedef struct {
	Commands cmd;
	Bool extension;
	AddressBytes address;
	Bool latency;
	Bool isread;
	Bool iswrite;
}Format_st deriving(Bits, Eq, FShow);


typedef enum {S1,D1,S2,D2,S4,D4,S8,D8,HB} Rates deriving(Bits,Eq,FShow);
typedef enum {B1,B2,B4,B8} RateBits deriving(Bits,Eq,FShow);
typedef enum {Init,Cmd,Extension,Address,Latency,RData,WData} StateMachine deriving(Bits, Eq, FShow);
typedef struct {
	Bool isReadTxn;
	Bool isRegAccess;
	Bool isLinearBurst;
	//Bit#(5) reserved_1;
	Bit#(29) uca;
	Bit#(13) reserved0;
	Bit#(3) lca;
}HB_Cmd_st deriving(Bits, Eq, FShow);
Vector#(7,Format_st) command_table_s1=vec(
	Format_st{cmd:ReadSFDP      , extension:False , address:A3   , latency:True  , isread:True  , iswrite:False }, // 0E

	Format_st{cmd:ReadRegister  , extension:False , address:A3   , latency:True  , isread:True  , iswrite:False }, // 0E
	Format_st{cmd:WriteRegister , extension:False , address:A3   , latency:False , isread:False , iswrite:True  }, // 0J

	Format_st{cmd:ReadMEM       , extension:False , address:A4   , latency:True  , isread:True  , iswrite:False }, // 0F
	Format_st{cmd:WriteMEM      , extension:False , address:A4   , latency:False , isread:False , iswrite:True  }, // 0K

	Format_st{cmd:ResetDevice   , extension:False , address:None , latency:False , isread:False , iswrite:False }, //0A
	Format_st{cmd:SetRate       , extension:False , address:A3   , latency:False , isread:False , iswrite:False }  //0G
);
Vector#(7,Format_st) command_table_s8=vec(
	Format_st{cmd:ReadSFDP      , extension:True , address:A4   , latency:True  , isread:True  , iswrite:False }, // 1B

	Format_st{cmd:ReadRegister  , extension:True , address:A4   , latency:True  , isread:True  , iswrite:False }, //1B
	Format_st{cmd:WriteRegister , extension:True , address:A4   , latency:False , isread:False , iswrite:True  }, //1D

	Format_st{cmd:ReadMEM       , extension:True , address:A4   , latency:True  , isread:True  , iswrite:False }, //1B
	Format_st{cmd:WriteMEM      , extension:True , address:A4   , latency:False , isread:False , iswrite:True  }, //1D

	Format_st{cmd:ResetDevice   , extension:True , address:None , latency:False , isread:False , iswrite:False }, //1A
	Format_st{cmd:SetRate       , extension:True , address:A3   , latency:False , isread:False , iswrite:False }  //1G
);
function Rates toRate(Bit#(8) b);
	return unpack(b[3:0]);
endfunction
function Bit#(8) fromRate(Rates b);
	return zeroExtend(pack(b));
endfunction


function Bit#(4) init_count(Rates datarate);
	let rv = case(datarate)
		S1: return 7;
		D1: return 3;
		S4: return 1;
		default: return 0;
	endcase;
	return rv;
endfunction

function Bit#(16) demangle(Bit#(8) re, Bit#(8) fe,Rates datarate);
	let rv=case(datarate)
		S1: return {re,8'b0};
		D1: return {re[3],fe[3],re[2],fe[2],re[1],fe[1],re[0],fe[0],8'b0 };
		S4: return {re,8'b0};
		D4: return {re[3:0],fe[3:0],8'b0};
		D8: return  {re,fe};
		HB: return  {re,fe};
		default: return {re,8'b0};
	endcase;
	return  rv;
endfunction

function Bool match_cmd(Commands cmd,Format_st row);
	return cmd == row.cmd;
endfunction
function Tuple2#(RateBits,Bool) decode_rate(Rates r);
	let ddr= r == D1|| r == D2 || r ==D4 ||r==D8 ||r==HB;
	RateBits rate=case(r)
		S1: return B1;
		D1: return B1;
		S4: return B4;
		D4: return B4;
		S8: return B8;
		D8: return B8;
		HB: return B8;
	endcase;
		return tuple2(rate,ddr);
endfunction
function Bit#(8) fn_bytecnt2wstrb(Bit#(3) ctr);
	return case(ctr)
		0: return 0;
		1: return 1;
		2: return 3;
		3: return 7;
		4: return 'hf;
		5: return 'h1f;
		6: return 'h3f;
		7: return 'h7f;
	endcase;

endfunction

