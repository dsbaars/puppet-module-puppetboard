# == Class: puppetboard::nginx::vhost
#
# Sets up an nginx::vhost to run PuppetBoard,
# and writes an appropriate wsgi.py from template.
#
# === Parameters
#
# Document parameters here.
#
# [*vhost_name*]
#   (string) The vhost ServerName.
#   No default.
#
# [*wsgi_alias*]
#   (string) WSGI script alias source
#   Default: '/'
#
# [*port*]
#   (int) Port for the vhost to listen on.
#   Defaults to 80.
#s
#
# [*user*]
#   (string) WSGI daemon process user, and daemon process name
#   Defaults to 'puppetboard' ($::puppetboard::params::user)
#
# [*group*]
#   (int) WSGI daemon process group owner, and daemon process group
#   Defaults to 'puppetboard' ($::puppetboard::params::group)
#
# [*basedir*]
#   (string) Base directory where to build puppetboard vcsrepo and python virtualenv.
#   Defaults to '/srv/puppetboard' ($::puppetboard::params::basedir)
#
# === Authors
#
# 2015 Djuri Baars
#
class puppetboard::nginx::vhost (
    $vhost_name,
    $wsgi_alias    = '/',
    $port          = 80,
    $wsgi_threads  = 5,
    $wsgi_user     = $::puppetboard::params::user,
    $wsgi_group    = $::puppetboard::params::group,
    $basedir       = $::puppetboard::params::basedir,
    $uwsgi_port    = 9090
) inherits ::puppetboard::params {

    $docroot = "${basedir}/puppetboard"

    $wsgi_script_aliases = {
        "${wsgi_alias}" => "${docroot}/wsgi.py",
    }

    $uwsgiPkgs = ['build-essential']

    ensure_packages($uwsgiPkgs)

    ::python::pip { 'uwsgi':
        ensure => present
    }

    # Template Uses:
    # - $basedir
    #
    file { "${docroot}/wsgi.py":
        ensure  => present,
        content => template('puppetboard/wsgi.py.erb'),
        owner   => $wsgi_user,
        group   => $wsgi_group,
        require => User[$wsgi_user],
    }

    file { '/etc/init/uwsgi-puppetboard.conf':
        ensure  => present,
        content => template('puppetboard/upstart/uwsgi-puppetboard.erb'),
        owner   => $wsgi_user,
        group   => $wsgi_group,
        require => User[$wsgi_user],
    }
    ~>
    service { 'uwsgi-puppetboard':
        provider => 'upstart',
    }

    # ::python::gunicorn { "${vhost_name}_gunicorn" :
    #     ensure      => present,
    #     virtualenv  => "${basedir}/virtenv-puppetboard",
    #     mode        => 'wsgi',
    #     dir         => "${basedir}/puppetboard",
    #     bind        => "unix:${uwsgi_socket}",
    #     appmodule   => 'puppetboard.app:app',
    #     timeout     => 30,
    #     template    => 'python/gunicorn.erb',
    #     environment => "PUPPETBOARD_SETTINGS=\"${basedir}/puppetboard/settings.py\""
    # }

    ::nginx::resource::vhost { $vhost_name:
        listen_port          => $port,
        www_root             => $docroot,
        use_default_location => false,
        require              => File["${docroot}/wsgi.py"],
    }

    ::nginx::resource::location { "${vhost_name}_uwsgi":
        ensure              => present,
        location            => $wsgi_alias,
        vhost               => $vhost_name,
        location_custom_cfg => {
            'uwsgi_pass' => "localhost:${uwsgi_port}",
            'include'    => '/etc/nginx/uwsgi_params'
        }
    }

    ::nginx::resource::location { "${vhost_name}_static":
        ensure         => present,
        location_alias => "${basedir}/puppetboard/puppetboard/static",
        vhost          => $vhost_name,

    }
}
