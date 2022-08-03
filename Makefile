SHELL := bash
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := default
.DELETE_ON_ERROR:
.SUFFIXES:

PROFILES_DIR=$(abspath .profiles)

$(PROFILES_DIR):
	mkdir -p $(PROFILES_DIR)

.PHONY: default
default: test lint

.PHONY: clean
clean:
	rm -f $(PROFILES_DIR)/profile-*.log
	rm -f .coverage_covimerage*
	rm -f .coverage
	rm -rf htmlcov/*
	rm -f lcov.info

.PHONY: test
test: $(PROFILES_DIR)
	if [ -n "$$(find test -type f -name '*.vader')" ]; then
		VADER_PROFILE="$(PROFILES_DIR)/profile-vader-vim.log" \
			vim -E -s -N -U None -u test/.vaderrc -c 'Vader! test/**/*.vader'
	fi
	if [ -n "$$(find test -type f -name '*.vim')" ]; then
		THEMIS_VIM=vim THEMIS_PROFILE="$(PROFILES_DIR)/profile-themis-vim.log" \
			themis --recursive --reporter tap
	fi


.PHONY: test-nvim
test-nvim: $(PROFILES_DIR)
	if [ -n "$$(find test -type f -name '*.vader')" ]; then
		VADER_PROFILE="$(PROFILES_DIR)/profile-vader-nvim.log" \
	 		nvim -E -s -N -U None -u test/.vaderrc -c 'Vader! test/**/*.vader'
	fi
	if [ -n "$$(find test -type f -name '*.vim')" ]; then
		THEMIS_VIM=nvim THEMIS_PROFILE="$(PROFILES_DIR)/profile-themis-nvim.log" \
			themis --recursive --reporter tap
	fi

.PHONY: lint
lint:
	poetry run vint --style-problem .
	poetry run vint --style-problem --enable-neovim .


.PHONY: lint_github_actions
lint_github_actions:
	actionlint -verbose -color .github/workflows/ci.yml

COVERAGE_DATA_FILE=.coverage
COVERAGE_HTML_DIR?=htmlcov
LCOV_DATA_FILE=lcov.info

.PHONY: coverage-gen
coverage-gen:
	for profile_file in $(PROFILES_DIR)/profile-*.log; do
		echo $$profile_file
		poetry run covimerage write_coverage --append $$profile_file
	done
	poetry run coverage report -m | tee $(COVERAGE_DATA_FILE)
	coverage2lcov $(COVERAGE_DATA_FILE) > $(LCOV_DATA_FILE)

.PHONY: coverage-html
coverage-html:
	poetry run coverage html -d $(COVERAGE_HTML_DIR)

.PHONY: all
all: clean test test-nvim lint lint_github_actions coverage-gen coverage-html
