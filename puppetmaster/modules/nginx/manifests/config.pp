class nginx::config inherits nginx::params {
  $www_user = 'www-data'
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
}
