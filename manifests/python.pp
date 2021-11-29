# =Class superset::python
class superset::python inherits superset {
  require superset::package
  if downcase($::osfamily) == 'redhat'{
    require superset::selinux
  }

  class { 'python':
    version => $python_version,
    pip     => present,
    dev     => present,
  }

  $supersets.each |Hash $superset| {
    file { $superset['base_dir']:
      ensure => directory,
      owner  => $owner,
      group  => $group,
    }
  
    python::pyvenv { "${superset['base_dir']}/venv":
      ensure   => present,
      venv_dir => "${superset['base_dir']}/venv",
      version  => $python_version,
      owner    => $owner,
      group    => $group,
      require  => [Class['python'], File[$superset['base_dir']]],
    }
  
    $deps = [
      'eventlet',
      'gevent',
      'greenlet',
      'gsheetsdb',
      'gunicorn',
      'pyldap',
      'sqlalchemy',
      'systemd',
    ]

    python::pip { "${superset['base_dir']} deps":
      pkgname      => join($deps, ' '),
      ensure       => present,
      virtualenv   => "${superset['base_dir']}/venv",
      pip_provider => 'pip3',
      owner        => $owner,
      require      => Python::Pyvenv["${superset['base_dir']}/venv"],
    }
  
    if $package_index_url != undef {
      if $package_index_username != undef and $package_index_password != undef {
        $package_index = "https://${package_index_username}:${package_index_password}@${package_index_url}"
      } else {
        $package_index = "https://${package_index_url}"
      }
    } else {
      $package_index = false
    }

    python::pip { "${superset['base_dir']} apache-superset":
      pkgname      => 'apache-superset',
      ensure       => $superset_version,
      extras       => ['prophet', 'postgres'],
      virtualenv   => "${superset['base_dir']}/venv",
      pip_provider => 'pip3',
      index        => $package_index,
      install_args => $pip_args,
      owner        => $owner,
      require      => [Python::Pip["${superset['base_dir']} deps"]]
    }
 
    exec { "restorecon -r ${superset['base_dir']}/venv/bin":
      command => "restorecon -r ${superset['base_dir']}/venv/bin",
      onlyif  => "test `ls -aZ ${superset['base_dir']}/venv/bin/gunicorn | grep -c bin_t` -eq 0",
      user    => 'root',
      path    => '/sbin:/usr/sbin:/bin:/usr/bin',
      require => [Python::Pip["${superset['base_dir']} apache-superset"]]
    }
  }
}
