CI_DIAG_TESTS := \
    wait_for_credits \
    test_pass \
    sram_only \
    sram_fill \
    rom_only \
    mailbox \
    l1_only \
    fcc \
    esrs_rw_test \
    erbium_pmp \
    erbium_csr_warl \
    erbium_csr_illegal \
    erbium_clint_mtip \
    erbium_clint_msip \
    erbium_clint_esrs \
    erbium_cacheops_invalid_levels

    # TODO: not passing
    #xspi_only \
    #qspi_only \
    #memmap \
    #memmap_sanity_test \
    #plic_test \

print-ci-tests:
	@echo "Available CI Tests:"
	@for t in $(CI_DIAG_TESTS); do \
		echo "  - $$t"; \
	done

ci: $(CI_DIAG_TESTS)
