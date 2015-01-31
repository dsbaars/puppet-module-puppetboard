require 'spec_helper_acceptance'
require 'pry'

describe 'puppetboard class' do

  context 'default parameters' do
    hosts.each do |host|
      if fact('osfamily') == 'RedHat'
        if fact('architecture') == 'amd64'
          on host, "wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm; rpm -ivh epel-release-6-8.noarch.rpm"
        else
          on host, "wget http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm; rpm -ivh epel-release-6-8.noarch.rpm"
        end
      end
#      on host, "puppet module install puppetlabs/apache"
      install_package host, 'python-virtualenv'
      install_package host, 'git'
    end

    it 'should work with no errors' do
      pp = " class { 'puppetboard': } "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # TODO: get this working
    #it 'should not answer to localhost' do
    #  shell("/usr/bin/curl localhost:80", :acceptable_exit_codes => 7) do |r|
    #    r.exit_code.should == 7 # curl (7): Couldn't connect to host
    #  end
    #end

  end
end
