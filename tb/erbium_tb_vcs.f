
// CPU subsystem monitor and testend monitors requires a path
+define+SOC_MONITOR=tb.et.erbium_digital.cpu_ss.cpu_subsystem_monitor

// Erbium RTL + models
-F $HDLET_ROOT/erbium_digital/verilog/rtl.f

// Includes related to cpu subsystem TB
+incdir+$HDLET_ROOT/ip/cpu_subsystem

// Arch monitors
-f $HDLET_ROOT/ip/cpu_subsystem/dv/arch_monitors/common/soc_monitors.f
