require 'spec_helper'

describe 'puppetboard' do
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
        it { should contain_class('puppetboard') }
    end
end
