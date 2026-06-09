#!/bin/bash

# List of testcases
# test_uart
# TESTCASES=(
#     test_01_reset
#     test_02_smoke_tx_rx
#     test_03_register_access
#     test_04b_standard_baud_rates
#     test_05_tx_functional
#     test_06_rx_functional
#     test_07_parity_modes
#     test_08_stop_bits
#     test_09_fifo_boundary
#     test_10_interrupt
#     test_11_error_injection
#     test_12_stress_random
# )

#test_memory_map
TESTCASES=(
    test_01_rom_functional_read
    test_02_rom_write_rejection
    test_03_sram_functional_rw
    test_04_boundary_conditions
    test_05_address_decoding_aliasing
    test_06_corner_case_patterns
    test_07_random_stress
    test_08_cpu_block_boundaries
    test_09_error_handling
    test_10_region_switching_burst
    test_11_cpu_u_neigh
    test_12_cpu_u_cpu
    test_13_cpu_s_cpu
    test_14_cpu_d_hart_esr
    test_15_cpu_d_neigh
    test_16_cpu_d_cpu
    test_17_cpu_m_neigh
    test_18_cpu_m_cpu
    test_19_cpu_cross_region
)

#test_qspi
# TESTCASES=(
# test_01_reset_defaults
# test_02_register_rw
# test_03_sr_read_only
# test_04_fcr_w1c
# test_05_enable_disable
# test_06_prescaler_sweep
# test_07_dcr_fields
# test_08_ccr_field_encoding
# test_09_indirect_write
# test_10_indirect_read
# test_11_back_to_back_writes
# test_12_back_to_back_reads
# test_13_fifo_level_tracking
# test_14_fifo_threshold_interrupt
# test_15_transfer_complete_interrupt
# test_16_transfer_error_flag
# test_17_auto_polling_smf
# test_18_timeout_lptr
# test_19_abort
# test_20_ddr_mode
# test_21_sioo
# test_22_alternate_bytes
# test_23_dummy_cycles
# test_24_ckmode
# test_25_csht_sweep
# test_26_dlr_boundary
# test_27_write_read_integrity
# test_28_memory_mapped_config
# test_29_dual_flash_fsel
# test_30_random_stress
# )

# Directory for logs
LOG_DIR=logs
SUMMARY_LOG=memory_map_summary.log

mkdir -p $LOG_DIR
> $SUMMARY_LOG   # clear summary file

# Add global timestamp
echo "====================================" >> $SUMMARY_LOG
echo "Test Run Started at: $(date)" >> $SUMMARY_LOG
echo "====================================" >> $SUMMARY_LOG
echo "" >> $SUMMARY_LOG

for tc in "${TESTCASES[@]}"; do
    echo "===================================="
    echo "Running $tc"
    echo "===================================="

    LOG_FILE="$LOG_DIR/${tc}.log"

    # Run test and save full log
    make MODULE=test_memory_map TESTCASE=$tc > $LOG_FILE 2>&1

    echo "------------------------------------" >> $SUMMARY_LOG
    echo "Testcase: $tc" >> $SUMMARY_LOG
    echo "Timestamp: $(date)" >> $SUMMARY_LOG

    # PASS/FAIL detection
    if grep -q "FAIL=1" $LOG_FILE; then
        RESULT="FAIL"
    else
        RESULT="PASS"
    fi

    echo "Result: $RESULT" >> $SUMMARY_LOG
    echo "" >> $SUMMARY_LOG

    echo "----- Last 30 lines -----" >> $SUMMARY_LOG
    tail -n 30 $LOG_FILE >> $SUMMARY_LOG
    echo -e "\n" >> $SUMMARY_LOG
done

echo "====================================" >> $SUMMARY_LOG
echo "Test Run Completed at: $(date)" >> $SUMMARY_LOG
echo "====================================" >> $SUMMARY_LOG

echo "All tests completed."
echo "Summary stored in $SUMMARY_LOG"