box = ENV['box'] ? ENV['box'] : 'ubuntu/jammy64'
pubkey = ENV['pubkey'] ? ENV['pubkey'] : ''

Vagrant.configure('2') do |c|
  c.vm.box = box
  c.vm.box_check_update = false
  c.vm.hostname = "cache-server"
  
  ## !NOTE:
  ## in the task, it is specified that webserver has 2 NICs.
  ## public facing interface
  ## private/LAN interface
  c.vm.network "private_network", ip: "192.168.104.155" ## Private/LAN
  c.vm.network "public_network", bridge: 'enp2s0', ip: "192.168.1.139" ## Public/WAN
  
  c.vm.provider "vmware_desktop" do |p|
    p.vmx["memsize"] = 1024 * 4
    p.vmx["numvcpus"] = 2
  end

  c.vm.provision "shell", inline: <<-EOS
    sudo apt remove unattended-upgrades -y && \
      echo #{pubkey} >> ~vagrant/.ssh/authorized_keys
  EOS
end
