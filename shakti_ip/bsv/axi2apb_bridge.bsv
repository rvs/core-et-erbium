/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-02-05
 Description: A brief description of the file's purpose.
*/

import axi2apb::*;
(*synthesize*)
module axi2apb_64(Ifc_axi2apb#(9,32,64,32,64,0));
	let t<- mkaxi2apb();
	return t;
endmodule
