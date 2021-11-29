# =Class superset::service
class superset::service inherits superset {
  require superset::install
  
  $supersets.each |Hash $superset| {
    service { "celery-${superset['name']}":
      ensure => running,
      enable => true,
    }
  
    service { "gunicorn-${superset['name']}":
      ensure => running,
      enable => true,
    }
  }
}
