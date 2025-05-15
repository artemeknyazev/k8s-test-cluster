.ssh-key:
	@mkdir -p .ssh
	@ssh-keygen -q -t ed25519 -f ./.ssh/id_ed25519 -N '' -C "vagrant"

init: .ssh-key
	@vagrant up

destroy:
	@vagrant halt -f
	@vagrant destroy -f
	@rm -rf .vagrant .ssh

.PHONY: .ssh-key init destroy

