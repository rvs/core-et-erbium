# RISC-V toolchain selection for the DV flows. Sourced from .autoenv.zsh.
#
# This used to live in the cpu_subsystem repo, which is now the open-source
# core-et submodule and no longer carries it; keep it here so the selection is
# self-contained and works against the public submodule.
#
# The default path matches the historical layout (/tools/aifoundry/riscv/<ver>).
# To use a toolchain built/installed in an arbitrary path, pre-export RISCV (a
# full path) before sourcing — it is respected as-is. RISCV_TOOLS_DIR and
# RISCV_TOOLS_VERSION override just the base directory or the version. Setting
# FORCE_RISCV_VERSION=1 also leaves an already-set RISCV untouched.
if [ "$FORCE_RISCV_VERSION" != "1" ] && [ -z "$RISCV" ]; then
    : "${RISCV_TOOLS_DIR:=/tools/aifoundry/riscv}"
    : "${RISCV_TOOLS_VERSION:=20251103}"
    export RISCV="$RISCV_TOOLS_DIR/$RISCV_TOOLS_VERSION"
fi

# Put the toolchain on PATH — the DV makefiles call `riscv64-unknown-elf-gcc`
# bare, so exporting RISCV alone isn't enough on a clean environment (CI node,
# fresh VM) that doesn't already have it. Probe the common bin layouts
# ($RISCV/bin and $RISCV/<triple>/bin) and prepend the one that has gcc.
for _rvbin in "$RISCV/bin" "$RISCV"/*/bin; do
    if [ -x "$_rvbin/riscv64-unknown-elf-gcc" ]; then
        case ":$PATH:" in
            *":$_rvbin:"*) : ;;
            *) export PATH="$_rvbin:$PATH" ;;
        esac
        break
    fi
done
unset _rvbin
