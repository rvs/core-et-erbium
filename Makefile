SHELL=/usr/bin/bash

##
## Parallel job configuration
## Override on the command line: make <target> VCS_JOBS=4 VERILATOR_JOBS=4
##
VCS_JOBS       ?= 1
VERILATOR_JOBS ?= 1

##
## Artifacts directory and job name — always set by the calling target.
## Left empty here so any accidental bare invocation produces a visible empty
## string rather than a misleading sentinel.
##
ARTIFACTS_DIR ?=
JOB_NAME      ?=

## ────────────────────────────────────────────────────────────────────────────
## Internal targets
## ────────────────────────────────────────────────────────────────────────────

## Print job configuration summary and starting message.
## Also creates the artifacts directory since it is only known at recipe time.
job-info:
	@mkdir -p $(ARTIFACTS_DIR)
	@printf '\n%s\n'          '━━━  Job config  ━━━'
	@printf '  %-28s %s\n'   'Job name:'                '$(JOB_NAME)'
	@printf '  %-28s %s\n'   'Artifacts directory:'      '$(ARTIFACTS_DIR)'
	@printf '  %-28s %s\n'   'VCS parallel jobs:'        '$(VCS_JOBS)'
	@printf '  %-28s %s\n'   'Verilator parallel jobs:'  '$(VERILATOR_JOBS)'
	@printf '  %-28s %s\n\n' 'Log:'                      '$(ARTIFACTS_DIR)/$(JOB_NAME).log'
	@printf '[%s] Starting\n' '$(JOB_NAME)'

## ────────────────────────────────────────────────────────────────────────────
## CI/CD targets
## To add a target: copy one of the blocks below, update the target name
## and ARTIFACTS_DIR.
## ────────────────────────────────────────────────────────────────────────────

install_uv:
	command -v uv || curl -LsSf https://astral.sh/uv/install.sh | sh

setup: install_uv
	uv sync
	# Submodules first: regblock gen includes cpu_subsystem RDL, and the cicd
	# mkdir below lives under REPOROOT (= ip/cpu_subsystem) — both need the
	# submodule present.
	GIT_SSH_COMMAND='ssh -v' git submodule update --init --recursive
	mkdir -p public tb/ralstruct $(REPOROOT)/cicd/$(CI_PIPELINE_ID)
	uv run make -C regblocks/systemrdl ral

build: setup
	source .venv/bin/activate && source .autoenv.zsh && $(MAKE) -C tb >&/dev/null || echo Regression Done

chiptopTest: ARTIFACTS_DIR := $(REPOROOT)/cicd/$(CI_PIPELINE_ID)
chiptopTest: JOB_NAME      := chiptopTest
chiptopTest: job-info
	# For some reason VCS does not detect file changes. need to do a clean for every rtl change.
	source .venv/bin/activate && source .autoenv.zsh && $(MAKE) -C tb WAVES=0 VERDI=0 regress >& $(ARTIFACTS_DIR)/$(JOB_NAME).log
	source .venv/bin/activate && source .autoenv.zsh && $(MAKE) -f tb/Makefile.elf VERBOSE=0 WAVES=0 ci -j 1>& $(ARTIFACTS_DIR)/elf_regression.log || echo ELF Regression Done
	python $(REPOROOT)/scripts/junit2html.py  --merge public/junit.xml tb/*results.xml tb/elf_run_*/test/*/*.xml
	python $(REPOROOT)/scripts/junit2html.py --report-matrix public/index.html public/junit.xml
	python $(REPOROOT)/scripts/junit2html.py  public/junit.xml public/details.html
	python $(REPOROOT)/scripts/junit2html.py --summary-matrix public/junit.xml --max-failures 10
	cp -r public $(ARTIFACTS_DIR)
	cp -r tb/*results.xml $(ARTIFACTS_DIR)/public/
	ls -al public
	echo "Regression Done"

nightly: ARTIFACTS_DIR := $(REPOROOT)/ci_nightly/$(CI_PIPELINE_ID)
nightly: JOB_NAME      := nightly
nightly: job-info
	source .autoenv.zsh
	source .venv/bin/activate
	cd tb
	make
	make -f Makefile.verilator
	#$(MAKE) -C erbium_digital/testbench MODULE=$@ >& $(ARTIFACTS_DIR)/$@.log

mtg_regress: ARTIFACTS_DIR := /scratch/contractors/ylin/gitlab/mtg_regress/$(CI_PIPELINE_ID)
mtg_regress: JOB_NAME      := mtg_regress
mtg_regress: setup job-info
	source .venv/bin/activate \
	  && source .autoenv.zsh \
	  && $(MAKE) -f tb/Makefile.elf SRUN= VERBOSE=0 WAVES=0 ELF_RUN_ROOT=$(ARTIFACTS_DIR) -j $(VCS_JOBS) $@ >"$(ARTIFACTS_DIR)/$(JOB_NAME).log" 2>&1 \
	  && printf '[%s] SUCCESS\n' '$(JOB_NAME)' \
	  || { printf '[%s] FAILED — see %s\n' '$(JOB_NAME)' '$(ARTIFACTS_DIR)/$(JOB_NAME).log' >&2; exit 1; }

diag_regress: ARTIFACTS_DIR := /scratch/contractors/ylin/gitlab/diag_regress/$(CI_PIPELINE_ID)
diag_regress: JOB_NAME      := diag_regress
diag_regress: setup job-info
	source .venv/bin/activate \
	  && source .autoenv.zsh \
	  && $(MAKE) -f tb/Makefile.elf SRUN= VERBOSE=0 WAVES=0 ELF_RUN_ROOT=$(ARTIFACTS_DIR) -j $(VCS_JOBS) $@ >"$(ARTIFACTS_DIR)/$(JOB_NAME).log" 2>&1 \
	  && printf '[%s] SUCCESS\n' '$(JOB_NAME)' \
	  || { printf '[%s] FAILED — see %s\n' '$(JOB_NAME)' '$(ARTIFACTS_DIR)/$(JOB_NAME).log' >&2; exit 1; }

#regression: $(TESTS)
.PHONY: all clean test regression job-info install_uv setup build chiptopTest nightly mtg_regress diag_regress
.ONESHELL:
