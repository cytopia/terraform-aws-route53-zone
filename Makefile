ifneq (,)
.error This Makefile requires GNU Make.
endif

CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TF_EXAMPLES = $(sort $(dir $(wildcard $(CURRENT_DIR)examples/*/)))


# -------------------------------------------------------------------------------------------------
# Image versions
# -------------------------------------------------------------------------------------------------
TF_VERSION      = 0.13.7
TFDOCS_VERSION  = 0.16.0-0.31
FL_VERSION      = 0.4


# -------------------------------------------------------------------------------------------------
# Image settings
# -------------------------------------------------------------------------------------------------
# Adjust your delimiter here or overwrite via make arguments
DELIM_START = <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
DELIM_CLOSE = <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# What arguments to append to terraform-docs command
TFDOCS_ARGS = --sort-by required

FL_IGNORE = .git/,.github/,*.terraform/

# -------------------------------------------------------------------------------------------------
# Default target
# -------------------------------------------------------------------------------------------------
help:
	@echo "gen        Generate terraform-docs output and replace in README.md's"
	@echo "lint       Static source code analysis"
	@echo "test       Integration tests"


# -------------------------------------------------------------------------------------------------
# Standard targets
# -------------------------------------------------------------------------------------------------
gen: _pull-tfdocs
	@echo "################################################################################"
	@echo "# Terraform-docs generate"
	@echo "################################################################################"
	@$(MAKE) --no-print-directory _gen-main
	@$(MAKE) --no-print-directory _gen-examples

lint:
	@# Lint all Terraform files
	@echo "################################################################################"
	@echo "# Linting"
	@echo "################################################################################"
	$(MAKE) --no-print-directory _lint-files
	$(MAKE) --no-print-directory _lint-fmt

test: _pull-tf
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="/t/examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "################################################################################"; \
		echo "# examples/$$( basename $${DOCKER_PATH} )"; \
		echo "################################################################################"; \
		echo; \
		echo "------------------------------------------------------------"; \
		echo "# Terraform init"; \
		echo "------------------------------------------------------------"; \
		if docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:$(TF_VERSION) \
			init \
				-upgrade=true \
				-reconfigure \
				-input=false \
				-get=true; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
			exit 1; \
		fi; \
		echo; \
		echo "------------------------------------------------------------"; \
		echo "# Terraform validate"; \
		echo "------------------------------------------------------------"; \
		if docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:$(TF_VERSION) \
			validate \
				.; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
			exit 1; \
		fi; \
	)


# -------------------------------------------------------------------------------------------------
# Helper Targets
# -------------------------------------------------------------------------------------------------
_gen-main:
	@echo "------------------------------------------------------------"
	@echo "# Main module"
	@echo "------------------------------------------------------------"
	@if docker run --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='$(DELIM_START)' \
		-e DELIM_CLOSE='$(DELIM_CLOSE)' \
		cytopia/terraform-docs:$(TFDOCS_VERSION) \
		terraform-docs-replace $(TFDOCS_ARGS) markdown README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi

_gen-examples:
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "------------------------------------------------------------"; \
		echo "# $${DOCKER_PATH}"; \
		echo "------------------------------------------------------------"; \
		if docker run --rm \
			-v $(CURRENT_DIR):/data \
			-e DELIM_START='$(DELIM_START)' \
			-e DELIM_CLOSE='$(DELIM_CLOSE)' \
			cytopia/terraform-docs:$(TFDOCS_VERSION) \
			terraform-docs-replace $(TFDOCS_ARGS) markdown $${DOCKER_PATH}/README.md; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			exit 1; \
		fi; \
	)

_lint-files: _pull-fl
	@# Basic file linting
	@echo "################################################################################"
	@echo "# File-lint"
	@echo "################################################################################"
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '$(FL_IGNORE)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '$(FL_IGNORE)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '$(FL_IGNORE)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '$(FL_IGNORE)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '$(FL_IGNORE)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '$(FL_IGNORE)' --path .

_lint-fmt: _pull-tf
	@# Lint all Terraform files
	@echo "################################################################################"
	@echo "# Terraform fmt"
	@echo "################################################################################"
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tf files"
	@echo "------------------------------------------------------------"
	@if docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t:ro" --workdir "/t" hashicorp/terraform:$(TF_VERSION) \
		fmt -check=true -diff=true -write=false -list=true .; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tfvars files"
	@echo "------------------------------------------------------------"
	@if docker run --rm --entrypoint=/bin/sh -v "$(CURRENT_DIR):/t:ro" --workdir "/t" hashicorp/terraform:$(TF_VERSION) \
		-c "find . -name '*.tfvars' -type f -print0 | xargs -0 -n1 terraform fmt -check=true -write=false -diff=true -list=true"; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo

_pull-tf:
	docker pull hashicorp/terraform:$(TF_VERSION)

_pull-tfdocs:
	docker pull cytopia/terraform-docs:$(TFDOCS_VERSION)

_pull-fl:
	docker pull cytopia/file-lint:$(FL_VERSION)
