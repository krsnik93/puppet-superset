# =Class superset::db
class superset::db inherits superset {
  include redis
  include postgresql::lib::devel
  include postgresql::lib::python

  $supersets.each |Hash $superset| {
    if $manage_database and ($superset['db_host'] == 'localhost' or $superset['db_host'] =~ /^127\./) {
      include postgresql::server
  
      postgresql::server::db { $superset['db_name']:
        user     => $superset['db_user'],
        password => postgresql_password($superset['db_user'], $superset['db_pass']),
      }
    }
  }
}
