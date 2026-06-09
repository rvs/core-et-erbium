// Copyright (c) 2014-2023 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Authors:
// - Thomas Benz <tbenz@iis.ee.ethz.ch>

// Macros to add AXI ports

`ifndef AXI_PORT_SVH_
`define AXI_PORT_SVH_

////////////////////////////////////////////////////////////////////////////////////////////////////
// Macros creating flat AXI ports
// `AXI_M_PORT(__name, __addr_t, __data_t, __strb_t, __id_t, __aw_user_t, __w_user_t, __b_user_t, __ar_user_t, __r_user_t)
`define AXI_M_PORT(__name, __addr_t, __data_t, __strb_t, __id_t, __aw_user_t, __w_user_t, __b_user_t, __ar_user_t, __r_user_t) \
  output logic             m_axi_``__name``_awvalid,   \
  output __id_t            m_axi_``__name``_awid,      \
  output __addr_t          m_axi_``__name``_awaddr,    \
  output erbium_noc_axi_pkg::len_t    m_axi_``__name``_awlen,     \
  output erbium_noc_axi_pkg::size_t   m_axi_``__name``_awsize,    \
  output erbium_noc_axi_pkg::burst_t  m_axi_``__name``_awburst,   \
  output logic             m_axi_``__name``_awlock,    \
  output erbium_noc_axi_pkg::cache_t  m_axi_``__name``_awcache,   \
  output erbium_noc_axi_pkg::prot_t   m_axi_``__name``_awprot,    \
  output erbium_noc_axi_pkg::qos_t    m_axi_``__name``_awqos,     \
  output erbium_noc_axi_pkg::region_t m_axi_``__name``_awregion,  \
  output __aw_user_t       m_axi_``__name``_awuser,    \
  output logic             m_axi_``__name``_wvalid,    \
  output __data_t          m_axi_``__name``_wdata,     \
  output __strb_t          m_axi_``__name``_wstrb,     \
  output logic             m_axi_``__name``_wlast,     \
  output __w_user_t        m_axi_``__name``_wuser,     \
  output logic             m_axi_``__name``_bready,    \
  output logic             m_axi_``__name``_arvalid,   \
  output __id_t            m_axi_``__name``_arid,      \
  output __addr_t          m_axi_``__name``_araddr,    \
  output erbium_noc_axi_pkg::len_t    m_axi_``__name``_arlen,     \
  output erbium_noc_axi_pkg::size_t   m_axi_``__name``_arsize,    \
  output erbium_noc_axi_pkg::burst_t  m_axi_``__name``_arburst,   \
  output logic             m_axi_``__name``_arlock,    \
  output erbium_noc_axi_pkg::cache_t  m_axi_``__name``_arcache,   \
  output erbium_noc_axi_pkg::prot_t   m_axi_``__name``_arprot,    \
  output erbium_noc_axi_pkg::qos_t    m_axi_``__name``_arqos,     \
  output erbium_noc_axi_pkg::region_t m_axi_``__name``_arregion,  \
  output __ar_user_t       m_axi_``__name``_aruser,    \
  output logic             m_axi_``__name``_rready,    \
  input  logic             m_axi_``__name``_awready,   \
  input  logic             m_axi_``__name``_arready,   \
  input  logic             m_axi_``__name``_wready,    \
  input  logic             m_axi_``__name``_bvalid,    \
  input  __id_t            m_axi_``__name``_bid,       \
  input  erbium_noc_axi_pkg::resp_t   m_axi_``__name``_bresp,     \
  input  __b_user_t        m_axi_``__name``_buser,     \
  input  logic             m_axi_``__name``_rvalid,    \
  input  __id_t            m_axi_``__name``_rid,       \
  input  __data_t          m_axi_``__name``_rdata,     \
  input  erbium_noc_axi_pkg::resp_t   m_axi_``__name``_rresp,     \
  input  logic             m_axi_``__name``_rlast,     \
  input  __r_user_t        m_axi_``__name``_ruser,     \
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Macros creating flat AXI ports
// `AXI_S_PORT(__name, __addr_t, __data_t, __strb_t, __id_t, __aw_user_t, __w_user_t, __b_user_t, __ar_user_t, __r_user_t)
`define AXI_S_PORT(__name, __addr_t, __data_t, __strb_t, __id_t, __aw_user_t, __w_user_t, __b_user_t, __ar_user_t, __r_user_t) \
  input  logic             s_axi_``__name``_awvalid,   \
  input  __id_t            s_axi_``__name``_awid,      \
  input  __addr_t          s_axi_``__name``_awaddr,    \
  input  erbium_noc_axi_pkg::len_t    s_axi_``__name``_awlen,     \
  input  erbium_noc_axi_pkg::size_t   s_axi_``__name``_awsize,    \
  input  erbium_noc_axi_pkg::burst_t  s_axi_``__name``_awburst,   \
  input  logic             s_axi_``__name``_awlock,    \
  input  erbium_noc_axi_pkg::cache_t  s_axi_``__name``_awcache,   \
  input  erbium_noc_axi_pkg::prot_t   s_axi_``__name``_awprot,    \
  input  erbium_noc_axi_pkg::qos_t    s_axi_``__name``_awqos,     \
  input  erbium_noc_axi_pkg::region_t s_axi_``__name``_awregion,  \
  input  __aw_user_t       s_axi_``__name``_awuser,    \
  input  logic             s_axi_``__name``_wvalid,    \
  input  __data_t          s_axi_``__name``_wdata,     \
  input  __strb_t          s_axi_``__name``_wstrb,     \
  input  logic             s_axi_``__name``_wlast,     \
  input  __w_user_t        s_axi_``__name``_wuser,     \
  input  logic             s_axi_``__name``_bready,    \
  input  logic             s_axi_``__name``_arvalid,   \
  input  __id_t            s_axi_``__name``_arid,      \
  input  __addr_t          s_axi_``__name``_araddr,    \
  input  erbium_noc_axi_pkg::len_t    s_axi_``__name``_arlen,     \
  input  erbium_noc_axi_pkg::size_t   s_axi_``__name``_arsize,    \
  input  erbium_noc_axi_pkg::burst_t  s_axi_``__name``_arburst,   \
  input  logic             s_axi_``__name``_arlock,    \
  input  erbium_noc_axi_pkg::cache_t  s_axi_``__name``_arcache,   \
  input  erbium_noc_axi_pkg::prot_t   s_axi_``__name``_arprot,    \
  input  erbium_noc_axi_pkg::qos_t    s_axi_``__name``_arqos,     \
  input  erbium_noc_axi_pkg::region_t s_axi_``__name``_arregion,  \
  input  __ar_user_t       s_axi_``__name``_aruser,    \
  input  logic             s_axi_``__name``_rready,    \
  output logic             s_axi_``__name``_awready,   \
  output logic             s_axi_``__name``_arready,   \
  output logic             s_axi_``__name``_wready,    \
  output logic             s_axi_``__name``_bvalid,    \
  output __id_t            s_axi_``__name``_bid,       \
  output erbium_noc_axi_pkg::resp_t   s_axi_``__name``_bresp,     \
  output __b_user_t        s_axi_``__name``_buser,     \
  output logic             s_axi_``__name``_rvalid,    \
  output __id_t            s_axi_``__name``_rid,       \
  output __data_t          s_axi_``__name``_rdata,     \
  output erbium_noc_axi_pkg::resp_t   s_axi_``__name``_rresp,     \
  output logic             s_axi_``__name``_rlast,     \
  output __r_user_t        s_axi_``__name``_ruser,     \
////////////////////////////////////////////////////////////////////////////////////////////////////

`endif
