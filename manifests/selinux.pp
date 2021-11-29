# =Class superset::selinux
class superset::selinux inherits superset {
  selinux::boolean { 'httpd_can_network_connect': }
  
  $supersets.each |Hash $superset| {
    selinux::fcontext { "${superset['base_dir']}/venv/bin":
      seltype  => 'bin_t',
      pathspec => "${superset['base_dir']}/venv/bin(/.*)?",
    }
  }
}
