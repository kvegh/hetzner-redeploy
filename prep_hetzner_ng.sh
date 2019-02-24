#!/bin/bash
. env
ansible-playbook -i hosts reset_hetzner_server.yml 
ansible-playbook -i hosts hetzner_physusers.yml
ansible-playbook -i hosts hetzner_physkeys.yml
ansible-playbook -i hosts hetzner_sudo.yml
ansible-playbook -b -i hosts hetzner_sshserver.yml 
ansible-playbook -l hetzner -b -i inventory_hetzner/dynamic_custom_inventory.sh rhel_subscriptions.yml 
ansible-playbook -b -i hosts hetzner_pkgs.yml
ansible-playbook -b -i hosts -l hetzner hetzner_update.yml
ansible-playbook -b -i hosts hetzner_virtualization.yml
ansible-playbook -b -i hosts hetzner_images.yml
ansible-playbook -l hetzner -b -i inventory_hetzner/dynamic_custom_inventory.sh -e host_name=ansible-h rhel_vmcreate_hostname.yml 
ansible-playbook -l hetzner -b -i inventory_hetzner/dynamic_custom_inventory.sh -e host_name=satellite-h rhel_vmcreate_hostname.yml 
ansible-playbook -b -i hosts hetzner_dns.yml 
ansible-playbook -b -i hosts hetzner_iputils.yml 
cd /home/ansible/projects/AutomATa
ansible-playbook -b -l hetzner -i inventory_hetzner/dynamic_custom_inventory.sh rhel_webserversetup.yml
ansible-playbook -i inventory_hetzner/dynamic_custom_inventory.sh -e host_name=ansible-h rhel_sshkeyssetup_hostname_bastion.yml
ansible-playbook -i inventory_hetzner/dynamic_custom_inventory.sh -e host_name=satellite-h rhel_sshkeyssetup_hostname_bastion.yml
ansible-playbook -l gatewayed -b --vault-password-file=vpf -i inventory_hetzner/dynamic_custom_inventory.sh rhel_subscriptions.yml 
ansible-playbook -b -l gatewayed -i inventory_hetzner/dynamic_custom_inventory.sh rhel_update.yml 
ansible-playbook -l gatewayed -b -i inventory_hetzner/dynamic_custom_inventory.sh rhel_fixip_hetzner.yml
ansible-playbook -l hetzner -b -i inventory_hetzner/dynamic_custom_inventory.sh hosts_and_networks_hetzner.yml
ansible-playbook -l ansible-h -b -i inventory_hetzner/dynamic_custom_inventory.sh tower_install.yml
ansible-playbook -b -i inventory_hetzner/dynamic_custom_inventory.sh -l hetzner hetzner_ssl_command.yml
ansible-playbook -b -i inventory_hetzner/dynamic_custom_inventory.sh sslproxy.yml
ansible-playbook -b -i inventory_hetzner/hosts tower_licence.yml 
ssh ansible-h -o ProxyCommand="ssh -W %h:%p -q ansible@hetzner" ssh-keygen -f /home/ansible/.ssh/id_rsa -N \'\' 
cd /home/ansible/projects/ansible-hetzner/
ssh ansible-h -o ProxyCommand="ssh -W %h:%p -q ansible@hetzner" sudo -u awx mkdir /var/lib/awx/.ssh
ssh ansible-h -o ProxyCommand="ssh -W %h:%p -q ansible@hetzner" sudo -u awx ssh-keygen -f /var/lib/awx/.ssh/id_rsa -N \'\'
ansible-playbook -b -i hosts create_and_deploy_ssh_pubkeys.yml
ansible-playbook -b -i hosts tower-cli-install.yml 
ansible-playbook -b --vault-password-file=vpf -i hosts tower_populate.yml
