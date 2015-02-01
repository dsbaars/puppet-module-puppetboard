require 'spec_helper'

describe 'puppetboard::apache::vhost' do
    let :pre_condition do
        [
            'include ::apache',
        ]
    end
    let (:params) { { :vhost_name => 'www.rspec.example.com' } }

    let :facts do {
        :kernel                 => 'Linux',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '14.04',
        :architecture           => 'amd64',
        :lsbdistid              => 'Ubuntu',
        :lsbdistcodename        => 'trusty',
        :concat_basedir         => '/foo',
        }
    end
    context 'with defaults for all parameters' do
        it { should contain_class('apache') }
    end
end
