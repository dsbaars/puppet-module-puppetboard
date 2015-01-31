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
class puppetboard::nginx::vhost (
  $vhost_name,
  $wsgi_alias    = '/',
  $port          = 80,
  $threads       = 5,
  $user          = $::puppetboard::params::user,
  $group         = $::puppetboard::params::group,
  $basedir       = $::puppetboard::params::basedir,
  $uwsgi_socket  = '/tmp/puppetboard.sock'
) inherits ::puppetboard::params {

    $docroot = "${basedir}/puppetboard"

    $wsgi_script_aliases = {
        "${wsgi_alias}" => "${docroot}/wsgi.py",
    }

    $wsgi_daemon_process_options = {
        threads => $threads,
        group   => $group,
        user    => $user,
    }

    # Template Uses:
    # - $basedir
    #
    file { "${docroot}/wsgi.py":
        ensure  => present,
        content => template('puppetboard/wsgi.py.erb'),
        owner   => $user,
        group   => $group,
        require => User[$user],
    }

    ::nginx::resource::vhost { $vhost_name:
        port                        => $port,
        www_root                    => $docroot,
        use_default_location        => false,
        require                     => File["${docroot}/wsgi.py"],
    }

    ::nginx::resource::location { "${vhost_name}_uwsgi":
       ensure              => present,
       location            => $wsgi_alias,
       vhost               => $vhost_name,
       location_custom_cfg => {
           "uwsgi_pass" => "unix://${uwsgi_socket}"
       }
   }
}
