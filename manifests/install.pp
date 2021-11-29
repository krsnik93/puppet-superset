# =Class superset::install
class superset::install inherits superset {
  require superset::config

  $supersets.each |Hash $superset| {

  exec { "${superset['name']} superset upgrade":
    command     => join([
      "${superset['base_dir']}/venv/bin/superset db upgrade",
    ], ' '),
    cwd         => $superset['base_dir'],
    user        => $owner,
    group       => $group,
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    environment => [
      "PYTHONPATH=${superset['base_dir']}",
      "SUPERSET_CONFIG_PATH=${superset['base_dir']}/superset_config.py",
      'FLASK_APP=superset'
    ],
  }

  exec { "${superset['name']} superset create-admin":
    command     => join([
      "${superset['base_dir']}/venv/bin/superset fab create-admin",
      "--username ${admin_user}",
      "--firstname admin",
      "--lastname admin",
      "--email ${admin_email}",
      "--password ${admin_pass}",
    ], ' '),
    cwd         => $superset['base_dir'],
    user        => $owner,
    group       => $group,
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    environment => [
      "PYTHONPATH=${superset['base_dir']}",
      "SUPERSET_CONFIG_PATH=${superset['base_dir']}/superset_config.py",
      'FLASK_APP=superset'
    ],
    require     => Exec["${superset['name']} superset upgrade"]
  }

  exec { "${superset['name']} superset init":
    command     => join([
      "${superset['base_dir']}/venv/bin/superset init",
    ], ' '),
    cwd         => $superset['base_dir'],
    user        => $owner,
    group       => $group,
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    environment => [
      "PYTHONPATH=${superset['base_dir']}",
      "SUPERSET_CONFIG_PATH=${superset['base_dir']}/superset_config.py",
      'FLASK_APP=superset'
    ],
    require     => Exec["${superset['name']} superset create-admin"]
  }

  if ($logo_path) {
    file { "${superset['base_dir']}/venv/lib/python${facts['python3_release']}/site-packages/superset/static/assets/images/logo.png":
      ensure => present,
      source => $logo_path,
      owner  => $owner,
      group  => $group
    }
  }
  }
}
