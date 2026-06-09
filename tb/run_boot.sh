#!/usr/bin/bash

#RUN_DIR=BOOT_TEST
RUN_DIR=BOOT_MAJORITY_TEST

WFI_ENDS_TEST=1
RTL_COSIM=0

BOOTROM_ELF=$REPOROOT/romram/tb/bootROM_self_contained_majority_of_5/ErbiumROM.elf
ZEPHYR=$REPOROOT/romram/tb/bootROM_self_contained_majority_of_5/zephyr.elf

# TEST 1 - Normal cold boot
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test1 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST
sleep 3
mv $RUN_DIR/test/boot_only $RUN_DIR/test/boot_test_1

# TEST 2 - Firmware update skip → payload
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test2 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST TEST_ELF=$ZEPHYR
sleep 3
mv $RUN_DIR/test/zephyr.elf $RUN_DIR/test/boot_test_2_zephyr

# TEST 3 - Firmware update jump → payload
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test3 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST
sleep 3
mv $RUN_DIR/test/boot_only $RUN_DIR/test/boot_test_3_wfi

# TEST 4 - Payload mode → payload
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test4 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST TEST_ELF=$ZEPHYR
sleep 3
mv $RUN_DIR/test/zephyr.elf $RUN_DIR/test/boot_test_4_zephyr

# TEST 5 - Early jump SRAM → payload
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test5 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST
sleep 3
mv $RUN_DIR/test/boot_only $RUN_DIR/test/boot_test_5_wfi

# TEST 6 - Early jump MRAM → payload
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test6 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST TEST_ELF=$ZEPHYR
sleep 3
mv $RUN_DIR/test/zephyr.elf $RUN_DIR/test/boot_test_6_zephyr

# TEST 7 - Payload with 1 corrupt OTP_CFGR copy
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test7 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST TEST_ELF=$ZEPHYR
sleep 3
mv $RUN_DIR/test/zephyr.elf $RUN_DIR/test/boot_test_7_zephyr

# TEST 8 - Payload with 2 corrupt OTP_CFGR copies
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test8 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST TEST_ELF=$ZEPHYR
sleep 3
mv $RUN_DIR/test/zephyr.elf $RUN_DIR/test/boot_test_8_zephyr

# TEST 9 - FWUP with 1 corrupt OTP_FWUP copy
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test9 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST
sleep 3
mv $RUN_DIR/test/boot_only $RUN_DIR/test/boot_test_9_wfi

# TEST 10 - FWUP with 1 corrupt OTP_FWUP copy
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test10 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST
sleep 3
mv $RUN_DIR/test/boot_only $RUN_DIR/test/boot_test_10_wfi

 TEST 11 - Payload with 3 corrupt OTP_CFGR
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test11 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST
sleep 3
mv $RUN_DIR/test/boot_only $RUN_DIR/test/boot_test_11

# TEST 12 - Firmware update skip → deep sleep
make -f Makefile.elf COCOTB_MODULE=test_bootrom COCOTB_TESTCASE=bootrom_test12 BOOTROM=$BOOTROM_ELF ELF_RUN_ROOT=$RUN_DIR RTL_COSIM=$RTL_COSIM WFI_ENDS_TEST=$WFI_ENDS_TEST
sleep 3
mv $RUN_DIR/test/boot_only $RUN_DIR/test/boot_test_12
