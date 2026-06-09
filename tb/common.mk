# Common makefile for configs common between VCS and Verilator

# SYSEMU is only used for the build system - exposing it here
export SYSEMU=$(HDLET_ROOT)/ip/et-platform/sw-sysemu

ET_MONITORS=$(HDLET_ROOT)/ip/cpu_subsystem/dv/arch_monitors

# CoSim's link step hard-codes -lzstd: the toolchain's libbfd was built with
# zstd support and references ZSTD_compress/decompress/isError, so libcosim.so
# cannot link without it. Many hosts ship only the runtime libzstd.so.1 and not
# the unversioned libzstd.so that -lzstd resolves against, so we discover any
# libzstd present (versioned or not) and symlink it as libzstd.so into the cosim
# objdir, which is on the link's -L path. The probe runs wherever the build runs
# (e.g. under srun on the compute node), not on the login host. Override with
# ZSTD_LIB=/path/to/libzstd.so[.1] in any environment.
ifndef ZSTD_LIB
ZSTD_LIB := $(strip $(shell \
	for c in \
		"$$(/sbin/ldconfig -p 2>/dev/null | awk '/libzstd\.so(\.[0-9]+)* \(libc6,x86-64\)/{print $$NF; exit}')" \
		"$$(g++-13 -print-file-name=libzstd.so 2>/dev/null)" \
		"$$(g++-13 -print-file-name=libzstd.so.1 2>/dev/null)" \
		$(RISCV)/x86_64-pc-linux-gnu/riscv64-unknown-elf/lib/libzstd.so* \
		/usr/lib64/libzstd.so* /usr/lib/x86_64-linux-gnu/libzstd.so* ; do \
		if [ -e "$$c" ]; then echo "$$c"; break; fi ; \
	done))
endif

cosim_OBJDIR=$(SIM_BUILD)/csrc
libfpu_OBJDIR=$(SIM_BUILD)/csrc
MONITORS_OBJDIR=$(SIM_BUILD)/csrc

ERBIUM=1
MONITORS_DEFINES+= -DCOCOTB_TEST_END -DET_SIMULATION
MAX_PARALLEL_JOBS=8
# Add Cosim and monitors
include $(ET_MONITORS)/common/cosim.mk
include $(ET_MONITORS)/common/monitors.mk

# cosim.mk's $(cosim_OBJDIR)/libcosim.so recipe runs the recursive cosim build,
# which links with `-L$(cosim_OBJDIR) -lzstd`. Make the libzstd.so compat symlink
# (see ZSTD_LIB above) a prerequisite so it exists before that link runs. This
# wiring is what Ying's original $(cosim_OBJDIR) rule lacked, so it never fired.
$(cosim_OBJDIR)/libcosim.so: $(cosim_OBJDIR)/libzstd.so

$(cosim_OBJDIR)/libzstd.so:
	@mkdir -p $(@D)
	@if [ -z "$(ZSTD_LIB)" ] || [ ! -e "$(ZSTD_LIB)" ]; then \
		echo "ERROR: libzstd not found for the cosim -lzstd link step." >&2; \
		echo "       Install libzstd (libzstd-dev / libzstd-devel) or set" >&2; \
		echo "       ZSTD_LIB=/path/to/libzstd.so[.1] (see tb/common.mk)." >&2; \
		exit 1; \
	fi
	ln -sf "$(ZSTD_LIB)" $@

CUSTOM_COMPILE_DEPS += $(COSIM_DEPENDENCIES) $(MONITORS_DEPENDENCIES)

COMPILE_ARGS += -LDFLAGS "$(COSIM_LDFLAGS)" -CFLAGS "$(COSIM_CXXINC) $(MONITORS_CXXINC) $(MONITORS_DEFINES)" $(MONITORS_OBJS)
