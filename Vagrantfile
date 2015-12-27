#
# CM Vagrant development environment
#-------------------------------------------------------------------------------

Vagrant.configure('2') do |config|
  #
  # Default CM development machine
  #
  # - should work on any platform Vagrant supports
  #
  config.vm.define :cm do |node|
    # One directional pushes
    node.vm.synced_folder '.', "/usr/local/rvm/gems/rbx-2.5.2/gems/cm-#{File.read('VERSION')}", {
      :type           => 'rsync',
      :owner          => 'root',
      :group          => 'root',
      :rsync__exclude => [ '.git/', 'vagrant/', 'pkg/' ],
      :rsync__auto    => true,
      :rsync__chown   => true,
      :rsync__args    => [ '--verbose', "--rsync-path='sudo rsync'", '--archive', '--delete', '-z' ],
      :create         => true
    }
    node.vm.synced_folder 'vagrant/home', "/home/vagrant", {
      :type          => 'rsync',
      :owner         => 'vagrant',
      :group         => 'vagrant',
      :rsync__auto   => true,
      :rsync__chown  => true,
      :rsync__args   => [ '--verbose', '--archive', '-z' ],
      :create        => true
    }

    node.vm.provider :virtualbox do |provider, override|
      override.vm.box = 'ubuntu/trusty64'

      override.vm.network :private_network, :ip => '172.100.100.100'

      # Bi-directional synchronization
      override.vm.synced_folder '.', '/vagrant'
      override.vm.synced_folder 'vagrant/config', '/etc/cm'
    end

    # Provisioning

    # Docker installation and image building
    node.vm.provision :docker do |provisioner|
      provisioner.build_image '/vagrant', args: '-t awebb/cm'
    end

    # CM bootstrap
    node.vm.provision :shell do |shell|
      shell.path = 'bootstrap/bootstrap.sh'
      shell.upload_path = '/vagrant/bootstrap/bootstrap.sh'
      shell.privileged = true
      shell.env = {
        'GEM_CM_DEV' => '1',
        'GEM_CM_DIRECTORY' => '/vagrant',
        'CM_CMD_VERSION' => File.read('VERSION')
      }
    end
  end
end
