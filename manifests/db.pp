# =Class superset::db
class superset::db inherits superset {
  include redis
  include postgresql::lib::devel
  include postgresql::lib::python

  if $manage_database and ($db_host == 'localhost' or $db_host =~ /^127\./) {
    include postgresql::server

    postgresql::server::db { $db_name:
      user     => $db_user,
      password => postgresql_password($db_user, $db_pass),
    }

    postgresql::server::role { $db_user:
      password_hash => postgresql::postgresql_password($db_user, $db_pass),
    }

    if $import_database {
      $db_repo_path = "/home/${owner}/db_repo"
      $db_local_path = "${db_repo_path}/db.sql"
      $db_file = 'db file'
      $db_repo_tidy = 'tidy db repo'

      exec { 'remove repo dir':
        command => "/usr/bin/rm -rf ${db_repo_path}",
      }

      file { $db_repo_ssh_private_key_path:
        ensure => present,
      }

      vcsrepo { $db_repo_path:
        ensure   => present,
        provider => git,
        source   => $db_repo_url,
        revision => $db_repo_revision,
        user     => $owner,
        require  => [ Exec['remove repo dir'], File[$db_repo_ssh_private_key_path] ],
        notify   => File[$db_local_path],
      }

      file { $db_local_path:
        ensure => present,
      }

      postgresql::server::database_grant { 'revoke':
        privilege => 'CONNECT',
	db        => $db_name,
        role      => $db_user,
	ensure    =>  absent,
        notify    => Postgresql_psql["terminate connections"],
      }

      postgresql_psql { "terminate connections":
        command => "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '${db_name}';",
        notify  => Postgresql_psql["drop database"],
      }

      postgresql_psql { "drop database":
        command => "DROP DATABASE \"${db_name}\"",
        onlyif => "SELECT * FROM pg_database WHERE datname='${db_name}'",
        notify  => Postgresql_psql["create database"],
      }

      postgresql_psql { "create database":
        command => "CREATE DATABASE \"${db_name}\"",
        unless => "SELECT * FROM pg_database WHERE datname='${db_name}'",
        notify  => Postgresql::Server::Database_grant['grant all'],
      }

      postgresql::server::database_grant { 'grant all':
        privilege => 'ALL',
        db        => $db_name,
        role      => $db_pass,
        ensure    =>  present,
      }

      exec { "import database":
        command => join([
          "${postgresql::server::psql_path}",
          "--dbname=postgresql://${db_user}:${db_pass}@localhost:5432/${db_name} ${db_name}",
          "< ${db_local_path}",
        ], ' '),
        require => [ File[$db_local_path], Postgresql::Server::Database_grant['grant all'] ],
      }

    }

    if defined('pgdump::dump') {
      class { 'pgdump::dump':
        db_name     => $db_name,
        db_dump_dir => '/var/lib/pgsql/dump',
        require     => Postgresql::Server::Db[$db_name]
      }
    }
  }
}
