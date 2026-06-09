#!/usr/bin/env bash
# =============================================================================
# run_slurm.sh — submit the ring_osc cocotb testbench to SLURM
#
# Usage:
#   ./run_slurm.sh            # run with VCS (default)
#   ./run_slurm.sh verilator  # run with Verilator
#   ./run_slurm.sh vcs        # explicit VCS
#
# The job runs 'make SIM=<sim>' inside the verification directory and writes
# stdout/stderr to slurm_<sim>_<jobid>.log alongside this script.
# =============================================================================

set -euo pipefail

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #
SIM="${1:-vcs}"                      # first arg selects simulator, default vcs
PARTITION="prod"                      # SLURM partition (adjust if needed)
NCPUS=4                               # CPUs for the compile step
MEM="8G"
TIME="02:00:00"                       # wall-clock limit (hh:mm:ss)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
VERIF_DIR="$GIT_ROOT/ring_osc/verification"

LOG_PREFIX="$VERIF_DIR/slurm_${SIM}"

# --------------------------------------------------------------------------- #
# Submit
# --------------------------------------------------------------------------- #
JOB_ID=$(sbatch \
    --parsable \
    --partition="$PARTITION" \
    --job-name="ring_osc_${SIM}" \
    --cpus-per-task="$NCPUS" \
    --mem="$MEM" \
    --time="$TIME" \
    --output="${LOG_PREFIX}_%j.log" \
    --error="${LOG_PREFIX}_%j.log" \
    <<EOF
#!/usr/bin/env bash
set -euo pipefail

# ---- Restore the tool PATH seen during interactive sessions ----------------
# VCS
export VCS_HOME=/tools/synopsys/vcs/W-2024.09-1
export PATH="\$VCS_HOME/bin:\$PATH"

# Verilator
export PATH="/tools/opt/verilator/latest/bin:\$PATH"

# Python 3.10
export PATH="/usr/bin:\$PATH"

# ---- Run -------------------------------------------------------------------
echo "=== ring_osc cocotb run (SIM=${SIM}) ==="
echo "Node    : \$(hostname)"
echo "Date    : \$(date)"
echo "Git root: $GIT_ROOT"
echo ""

cd "$VERIF_DIR"
make SIM=${SIM}

echo ""
echo "=== Simulation complete (SIM=${SIM}) ==="
echo "Results: $VERIF_DIR/results.xml"
EOF
)

echo "Submitted job ${JOB_ID} (SIM=${SIM})"
echo "Log: ${LOG_PREFIX}_${JOB_ID}.log"
echo ""
echo "Monitor with:"
echo "  squeue -j ${JOB_ID}"
echo "  tail -f ${LOG_PREFIX}_${JOB_ID}.log"
