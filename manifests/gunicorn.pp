# =Class superset::gunicorn
class superset::gunicorn inherits superset {
  require superset::python
  require superset::db

  $supersets.each |Hash $superset| {
    file { "/etc/conf.d/gunicorn-${superset['name']}":
      ensure  => present,
      content => template("${module_name}/etc/conf.d/gunicorn.erb"),
      owner   => 'root',
      group   => 'root',
      require => File['/etc/conf.d']
    }
  
    file { "/etc/systemd/system/gunicorn-${superset['name']}.service":
      ensure  => present,
      content => template("${module_name}/etc/systemd/system/gunicorn.service.erb"),
      owner   => 'root',
      group   => 'root',
    }
  
    file { "/etc/systemd/system/gunicorn-${superset['name']}.socket":
      ensure  => present,
      content => template("${module_name}/etc/systemd/system/gunicorn.socket.erb"),
      owner   => 'root',
      group   => 'root',
    }
  }
}
