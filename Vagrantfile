Vagrant.configure("2") do |config|
        config.vm.box = "centos/8"
        config.vm.provision "shell", path: "bootstrap.sh"
        config.vm.synced_folder ".", "/vagrant", type: "virtualbox", disabled: true
        #config.vm.disk :disk, size: "50GB", primary: true
        #config.disksize.size = "50GB"

        Master = 3 
        (1..Master).each do |i|
        
                config.vm.define "Kmaster#{i}" do |node|
                        node.vm.provider "virtualbox" do |vb|
                                vb.name = "mastervm0#{i}"
                                vb.memory = 2048
                                vb.cpus = 2
                                #vb.disk :disk, size: "50GB", primary: true
                        end
                        node.vm.hostname = "Kmaster#{i}"
                        node.vm.network :private_network, ip: "192.168.5.1#{i}"
                        node.vm.network "forwarded_port", guest: 22, host: "27#{i}5", id: "ssh"
                        node.vm.provision "setup-kubernetes", type: "shell", :path => "k8.sh"
                        #node.vm.provision "common-steps", type: "shell", :path => "setup.sh"
                end
        end
        
        Worker = 1
        (1..Worker).each do |i|
                config.vm.define "Kworker#{i}" do |node|
                        node.vm.provider "virtualbox" do |vb|
                                vb.name = "workervm0#{i}"
                                vb.memory = 2048
                                vb.cpus = 2
                                #vb.disk :disk, size: "50GB", primary: true
                        end
                        node.vm.hostname = "Kworker#{i}"
                        node.vm.network :private_network, ip: "192.168.5.2#{i}"
                        node.vm.network "forwarded_port", guest: 22, host: "273#{i}", id: "ssh"
                        node.vm.provision "setup-kubernetes", type: "shell", :path => "k8.sh"
                        #node.vm.provision "common-steps", type: "shell", :path => "setup.sh"
                end
        end

        Loadbalancer = 2
        (1..Loadbalancer).each do |i|
                config.vm.define "loadbalancer#{i}" do |node|
                        node.vm.provider "virtualbox" do |vb|
                                vb.name = "lbvm0#{i}"
                                vb.memory = 1024
                                vb.cpus = 2
                                #vb.disk :disk, size: "50GB", primary: true
                        end
                        node.vm.hostname = "loadbalancer#{i}"
                        node.vm.network :private_network, ip: "192.168.5.3#{i}"
                        node.vm.network "forwarded_port", guest: 22, host: "275#{i}", id: "ssh"
                        node.vm.provision "setup-loadbalancer", type: "shell", :path => "loadbalancer.sh"
                        #node.vm.provision "common-steps", type: "shell", :path => "setup.sh"
                end
        end
end

