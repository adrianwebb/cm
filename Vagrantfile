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
    gem_path = "/usr/local/rvm/gems/rbx-2.5.2/gems"
    cm_home = '/vagrant'
    cm_version = File.read('VERSION')

    # One directional pushes
    node.vm.synced_folder 'vagrant/home', "/home/vagrant", {
      :type          => 'rsync',
      :owner         => 'vagrant',
      :group         => 'vagrant',
      :rsync__auto   => true,
      :rsync__chown  => true,
      :rsync__args   => [ '--verbose', '--archive', '-z' ],
      :create        => true
    }

    # Basic VM settings and shares
    node.vm.provider :virtualbox do |provider, override|
      provider.memory = 4096
      provider.cpus = 2
      provider.customize ['modifyvm', :id, '--cpuexecutioncap', '50']

      override.vm.box = 'ubuntu/trusty64'
      override.vm.network :private_network, :ip => '172.100.100.100'

      # Bi-directional synchronization
      override.vm.synced_folder Dir.pwd, cm_home
      override.vm.synced_folder 'vagrant/config', '/etc/cm'
    end

    # CM bootstrap
    node.vm.provision :shell do |shell|
      shell.path = 'bootstrap/bootstrap.sh'
      shell.upload_path = "#{cm_home}/bootstrap/bootstrap.sh"
      shell.privileged = true
      shell.env = {
        'GEM_CM_DEV' => '1',
        'GEM_CM_DIRECTORY' => cm_home,
        'CM_CMD_VERSION' => cm_version
      }
    end
    node.vm.provision :shell do |shell|
      shell.path = 'vagrant/link.sh'
      shell.privileged = true
      shell.env = {
        'RUBY_GEM_PATH' => gem_path,
        'GEM_CM_VERSION' => cm_version,
        'GEM_CM_DIRECTORY' => cm_home
      }
    end

    # Gem toolset
    node.vm.provision :shell do |shell|
      shell.path = 'toolbox/install'
      shell.upload_path = "#{cm_home}/toolbox/install"
      shell.privileged = true
      shell.args = '--test'
    end

    # Dockerfile generation
    docker_file = File.read('Dockerfile')
      .gsub(/\# VERSION\s+\d+\.\d+\.\d+/, "# VERSION         #{cm_version}")
      .gsub(/CM_CMD_VERSION\=\d+\.\d+\.\d+/, "CM_CMD_VERSION=#{cm_version}")

    File.write('Dockerfile', docker_file)

    # Docker installation and image building
    node.vm.provision :docker do |provisioner|
      provisioner.build_image cm_home, args: '-t awebb/cm'
    end
  end
end
