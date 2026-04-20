vagrant up para subir a máquina virtual com o Netbox.
vagrant ssh para conectar na máquina virtual.
execute o comando abaixo para criar o superuser
docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser

# Quick Setup

- https://netboxlabs.com/blog/getting-started-with-network-automation-netbox-ansible/