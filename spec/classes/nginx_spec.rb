require 'spec_helper'

describe 'puppetboard::nginx::vhost' do
    let :pre_condition do
        [
            'include ::nginx',
            'include ::python',
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
        it { should contain_class('nginx')}
        it {
            should contain_class('python')
            should contain_package('python-pip')
        }
        it { should contain_python__pip('uwsgi') }
    end
end
