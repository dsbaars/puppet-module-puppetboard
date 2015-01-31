require 'beaker-rspec'

hosts.each do |host|
  # Broken in "original" module, ruby gems should be already installed
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'puppetboard')
    hosts.each do |host|
        on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module','install','jfryman-nginx'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module','install','puppetlabs-apache'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module','install','stankevich-python'), { :acceptable_exit_codes => [0,1] }
        on host, puppet('module','install','puppetlabs-vcsrepo'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
