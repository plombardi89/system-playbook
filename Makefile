SHELL=/usr/bin/env bash
VENV=venv

.PHONY: apply \
		apply-novenv \
		venv \
		$(VENV)/bin/activate \
		clobber \
		smoke \
		test.ubuntu.image \
		test.ubuntu.shell \
		test.ubuntu \
		test.fedora.image \
		test.fedora.shell \
		test.fedora

SRC_DIR=/usr/local/src
DKR_RUN=docker run \
        --user=dev \
        --rm \
        -it \
        -v$(PWD):$(SRC_DIR)/playbook

all: apply smoke

apply-novenv:
	ansible-galaxy install -r galaxy.yaml
	ansible-playbook playbook.yaml --become

apply: venv
	$(VENV)/bin/ansible-galaxy install -r galaxy.yaml
	$(VENV)/bin/ansible-playbook playbook.yaml --become

clobber:
	rm -rf $(VENV)

smoke:
	test/smoke.sh

venv: $(VENV)/bin/activate

$(VENV)/bin/activate: requirements.txt
	test -d $(VENV) || virtualenv $(VENV) --python=python3
	$(VENV)/bin/pip install -Ur requirements.txt
	touch $(VENV)/bin/activate

test.ubuntu.image:
	docker build -t plombardi89/system-playbook:ubuntu -f Dockerfile.ubuntu .

test.ubuntu.shell: test.ubuntu.image
	$(DKR_RUN) plombardi89/system-playbook:ubuntu

test.ubuntu:
	$(DKR_RUN) \
	--workdir=$(SRC_DIR)/playbook \
	plombardi89/system-playbook:ubuntu sudo -s bash -c "cp -R $(SRC_DIR)/playbook /playbook && chown -R dev:dev /playbook && cd /playbook && rm -rf venv && make apply-novenv smoke"

test.fedora.image:
	docker build -t plombardi89/system-playbook:fedora -f Dockerfile.fedora .

test.fedora.shell: test.fedora.image
	$(DKR_RUN) plombardi89/system-playbook:fedora

test.fedora: test.fedora.image
	$(DKR_RUN) \
	--workdir=$(SRC_DIR)/playbook \
	plombardi89/system-playbook:fedora sudo -s bash -c "cp -R $(SRC_DIR)/playbook /playbook && chown -R dev:dev /playbook && cd /playbook && rm -rf venv && make apply-novenv smoke"