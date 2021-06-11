# =Class superset::python
class superset::python inherits superset {
  require superset::selinux
  require superset::package

  class { 'python':
    pip => present,
    dev => present,
  }

  file { $base_dir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
  }

  python::pyvenv { "${base_dir}/venv":
    ensure   => present,
    venv_dir => "${base_dir}/venv",
    version  => 'system',
    owner    => $owner,
    group    => $group,
    require  => [Class['python'], File[$base_dir]],
  }

  $deps = [
    'eventlet', 'gevent', 'greenlet', 'gsheetsdb', 'gunicorn', 'pyldap', 'sqlalchemy'
  ]

  python::pip { 'pystan':
    ensure       => '2.19.1.1',
    virtualenv   => "${base_dir}/venv",
    pip_provider => 'pip3',
    owner        => $owner,
    require      => Python::Pyvenv["${base_dir}/venv"]
  }

  python::pip { $deps:
    ensure       => present,
    virtualenv   => "${base_dir}/venv",
    pip_provider => 'pip3',
    owner        => $owner,
    require      => Python::Pip['pystan']
  }

  # from https://puppet.com/docs/puppet/7.6/types/package.html#package-attribute-install_options
  if $pip_repo == [] {
    $pip_install_args = []
  } else {
    $pip_install_args = ['-i ' + $pip_repo.shift]
    if $pip_repo.length > 0 {
      $pip_install_args = $pip_install_args + ['--extra-index-url ' + $pip_repo.join(' ')]
    }
  }

  python::pip { 'apache-superset':
    ensure          => $version,
    extras          => ['prophet', 'postgres'],
    virtualenv      => "${base_dir}/venv",
    pip_provider    => 'pip3',
    install_args    => $pip_install_args.join(' '),
    owner           => $owner,
    require         => [Python::Pip['pystan'], Python::Pip[$deps]]
  }

  exec { "restorecon -r ${base_dir}/venv/bin":
    command => "restorecon -r ${base_dir}/venv/bin",
    onlyif  => "test `ls -aZ ${base_dir}/venv/bin/gunicorn | grep -c bin_t` -eq 0",
    user    => 'root',
    path    => '/sbin:/usr/sbin:/bin:/usr/bin',
    require => [Python::Pip['apache-superset']]
  }
}
