.PHONY: test syntax audit-dry install

syntax:
	bash -n scripts/shield.sh
	bash -n modules/audit.sh
	bash -n modules/harden.sh
	bash -n modules/integrations.sh

test: syntax
	bash tests/test_audit.sh

audit-dry:
	bash scripts/shield.sh audit

install:
	sudo bash install.sh
