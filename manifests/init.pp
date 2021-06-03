# =Class superset
class superset (
  String $python_version,
  String $admin_email,
  String $admin_user,
  String $admin_pass,
  String $base_dir,
  String $owner,
  String $group,
  String $db_host,
  String $db_name,
  String $db_user,
  String $db_pass,
  String $db_repo_url,
  String $db_repo_revision = master,
  String $db_repo_user,
  String $db_repo_ssh_private_key_path,
  String $ldap_server,
  String $ldap_bind_user,
  String $ldap_bind_pass,
  String $ldap_base_dn,
  String $ldap_group_dn,
  String $log_level,
  Integer $concurrency,
  Variant[Integer, Enum['None']] $row_limit,
  Variant[Enum[present, absent, latest], String[1]] $version,
  Boolean $dynamic_plugins,
  Boolean $ldap_enabled,
  Boolean $manage_database,
  Boolean $import_database,
  Boolean $ldap_filter_login,
  Hash[String, Array[String]] $ldap_roles_mapping,
  Optional[String] $logo_path = undef,
  Optional[String] $ldap_user_filter = undef,
) {
  contain superset::db
  contain superset::selinux
  contain superset::package
  contain superset::python
  contain superset::celery
  contain superset::gunicorn
  contain superset::config
  contain superset::install
  contain superset::service
}
