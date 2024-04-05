SHELL := /usr/bin/bash

## Vagrant
vagrant-up:
	@vagrant validate
	@vagrant up --provision


vagrant-down:
	@vagrant destroy -f

## Ansible
ansible-deploy: ansible-check
	@ansible-playbook -e @sample-vars.yaml cache-server.yaml

ansible-check:
	command -v  netaddr &> /dev/null || pip3 install netaddr
	yamllint .
	ansible-lint *yaml
	ansible-playbook --syntax-check cache-server.yaml
