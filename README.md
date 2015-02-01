dsbaars-puppetboard
===========
[![Build Status](https://travis-ci.org/dsbaars/puppet-puppetboard.svg?branch=nginx)](https://travis-ci.org/dsbaars/puppet-puppetboard)

Puppetboard is a puppet dashboard
https://github.com/nedap/puppetboard

This is an improved puppetboard-module for puppet.
[Original by Spencer Krum](https://github.com/puppet-community/puppet-module-puppetboard)


This improved module also supports nginx as reverse-proxy. Unfortunately, it does not support RedHat/CentOS like the original module, because the use of upstart.

Also, I fixed the beaker acceptence tests, added spec tests, fixtures, librarian-puppet support, added a .editorconfig file


Installation
------------

`$ puppet module install dsbaars-puppetboard`


Dependencies
------------

Note that this module no longer explicitly requires the puppetlabs apache module. If you want to use the apache functionality of this module you will have to specify that the apache module is installed with:

`$ puppet module install puppetlabs-apache`

This module also requires the ``git`` and ``virtualenv`` packages. These can be enabled in the module by:


```puppet
class { 'puppetboard':
    manage_git        => true, # or latest
    manage_virtualenv => true, # or latest
}

```

Usage
-----

Declare the base puppetboard manifest:

```puppet
class { 'puppetboard':
    # By default, puppetboard displays only 10 reports. This number can be
    # controlled to set the number of repports to show.
    reports_count => 40
}
```

### Nginx

This version supports the use of nginx as reverse proxy.

```puppet
# Configure nginx
class { 'nginx': }

# Configure Puppetboard
class { 'puppetboard': }

# Access Puppetboard through pboard.example.com
class { 'puppetboard::nginx::vhost':
    vhost_name => 'pboard.example.com',
    port       => 80,
}
```

### Apache

If you want puppetboard accessible through Apache and you're able to use the
official `puppetlabs/apache` Puppet module, this module contains two classes
to help configuration.

The first, `puppetboard::apache::vhost`, will use the `apache::vhost`
defined-type to create a full virtual host. This is useful if you want
puppetboard to be available from http://pboard.example.com:

```puppet

# Configure Apache on this server
class { 'apache': }
class { 'apache::mod::wsgi': }

# Configure Puppetboard
class { 'puppetboard': }

# Access Puppetboard through pboard.example.com
class { 'puppetboard::apache::vhost':
    vhost_name => 'pboard.example.com',
    port       => 80,
}
```

The second, `puppetboard::apache::conf`, will create an entry in
`/etc/apache2/conf.d` (or `/etc/httpd/conf.d`, depending on your distribution).
This is useful if you simply want puppetboard accessible from
http://example.com/puppetboard:

```puppet
# Configure Apache
# Ensure it does *not* purge configuration files
class { 'apache':
    purge_configs => false,
    mpm_module    => 'prefork',
    default_vhost => true,
    default_mods  => false,
}

class { 'apache::mod::wsgi': }

# Configure Puppetboard
class { 'puppetboard': }

# Access Puppetboard from example.com/puppetboard
class { 'puppetboard::apache::conf': }
```

#### Apache (with Reverse Proxy)

You can also relocate puppetboard to a sub-URI of a Virtual Host. This is
useful if you want to reverse-proxy puppetboard, but are not planning on
dedicating a domain just for puppetboard:

```puppet
class { 'puppetboard::apache::vhost':
    vhost_name => 'dashes.acme',
    wsgi_alias => '/pboard'
}
```

In this case puppetboard will be available (on the default) on
http://dashes.acme:5000/pboard. You can then reverse-proxy to it like so:

```apache
Redirect /pboard /pboard/
ReverseProxy /pboard/ http://dashes.acme:5000/pboard/
ProxyPassReverse /pboard/ http://dashes.acme:5000/pboard/
```

### Using SSL to the PuppetDB host

If you would like to use certificate auth into the PuppetDB service you must configure puppetboard to use a client certificate and private key.

You have two options for the source of the client certificate & key:

1. Generate a new certificate, signed by the puppetmaster CA
2. Use the existing puppet client certificate

If you choose option 1, generate the new certificates on the CA puppet master as follows:

`$ puppet cert generate puppetboard.example.com`

Note: this name cannot conflict with an existing certificate name.

The new certificate and private key can be found in $certdir/<NAME>.pem and $privatekeydir/<NAME>.pem on the CA puppet master. If you are not running puppetboard on the CA puppet master you will need to copy the certificate and key to the node runing puppetboard.

Here's an example, using new certificates:
```puppet
$ssl_dir = '/var/lib/puppetboard/ssl'
$puppetboard_certname = 'puppetboard.example.com'
class { 'puppetboard':
    manage_virtualenv => true,
    puppetdb_host     => 'puppetdb.example.com',
    puppetdb_port     => '8081',
    puppetdb_key      => "${ssl_dir}/private_keys/${puppetboard_certname}.pem",
    puppetdb_ssl      => 'True',
    puppetdb_cert     => "${ssl_dir}/certs/${puppetboard_certname}.pem"
}
```
If you are re-using the existing puppet client certificates, they will already exist on the node (assuming puppet has been run and the client cert signed by the puppet master). However, the puppetboaard user will not have permission to read the private key unless you add it to the puppet group.

Here's a complete example, re-using the puppet client certs:

```puppet
$ssl_dir = $::settings::ssldir
$puppetboard_certname = $::certname
class { 'puppetboard':
    groups            => 'puppet',
    manage_virtualenv => true,
    puppetdb_host     => 'puppetdb.example.com',
    puppetdb_port     => '8081',
    puppetdb_key      => "${ssl_dir}/private_keys/${puppetboard_certname}.pem",
    puppetdb_ssl      => 'True',
    puppetdb_cert     => "${ssl_dir}/certs/${puppetboard_certname}.pem"
}
```

Note that both the above approaches only work if you have the Puppet CA root certificate added to the root certificate authority file used by your operating system. If you want to specify the location to the Puppet CA file ( you probably do) you have to use the syntax below. Currently this is a bit of a gross hack, but it's an open issue to resolve it in the Puppet module:

```puppet
$ssl_dir = $::settings::ssldir
$puppetboard_certname = $::certname
class { 'puppetboard':
    groups            => 'puppet',
    manage_virtualenv => true,
    puppetdb_host     => 'puppetdb.example.com',
    puppetdb_port     => '8081',
    puppetdb_key      => "${ssl_dir}/private_keys/${puppetboard_certname}.pem",
    puppetdb_ssl      => "${ssl_dir}/certs/ca.pem",
    puppetdb_cert     => "${ssl_dir}/certs/${puppetboard_certname}.pem",
}
```

License
-------
Apache 2

Attribution
-----------

This module is a fork of [nibalizer-puppetboard](https://github.com/puppet-community/puppet-module-puppetboard) by Spencer Krum.

The core of this module was based on Hunter Haugen's puppetboard-vagrant repo.
