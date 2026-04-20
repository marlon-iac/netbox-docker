Vagrant.configure("2") do |config|
  # Utilizando a box centos9
  # config.vm.box = "generic/centos9s"
  config.vm.box = "generic/ubuntu2204"

  config.vm.define "netbox" do |netbox| 
    netbox.vm.hostname = "netbox"
    netbox.vm.network "public_network", type: "dhcp"

    # Pastas Sincronizadas
    netbox.vm.synced_folder ".", "/home/vagrant/shared"

    # Provisionamento usando um script shell
    netbox.vm.provision :shell, path: "scripts/provisioning_ubuntu.sh"

    netbox.vm.provider "vmware_desktop" do |v|
      v.gui = true # opcional: para ver a janela da VM
      v.memory = "8192"
      v.cpus = 2
      v.linked_clone = false
    end
  end
end
