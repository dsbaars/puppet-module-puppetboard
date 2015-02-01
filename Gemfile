source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.3']
group :development, :test do
    gem 'puppet', puppetversion
    gem 'puppetlabs_spec_helper', '>= 0.1.0'
    gem "puppet-lint", :git => 'https://github.com/rodjek/puppet-lint.git'
    gem 'facter', '>= 1.7.0'
    gem 'librarian-puppet', '>= 2.0.1'
    gem 'rspec', '< 3.0.0'
    gem 'yamllint', '~> 0.0.3'
    gem 'metadata-json-lint', '>= 0.0.6'
    gem 'beaker',
        :git => 'https://github.com/dsbaars/beaker-parallels',
        :branch =>  'vagrant_parallels_hypervisor'
    gem 'beaker-rspec',           :require => false
    gem 'serverspec',             :require => false
    gem 'pry',                    :require => false
end
