# =Class superset::celery
class superset::celery inherits superset {
  require superset::python
  require superset::db
  
  $supersets.each |Hash $superset| {  
    file { "/etc/conf.d/celery-${superset['name']}":
      ensure  => present,
      content => template("${module_name}/etc/conf.d/celery.erb"),
      owner   => 'root',
      group   => 'root',
      require => File['/etc/conf.d']
    }
  
    file { "/etc/systemd/system/celery-${superset['name']}.service":
      ensure  => present,
      content => template("${module_name}/etc/systemd/system/celery.service.erb"),
      owner   => 'root',
      group   => 'root'
    }
  
    file { [
        "/var/run/celery-${superset['name']}",
        "/var/log/celery-${superset['name']}"
      ]:
        ensure => directory,
        owner  => $owner,
        group  => $group
    }
  }
}
