class solr::config inherits solr::params {
  $tomcat_user = 'tomcat6'
  $envs = $::system_environments ? {
    undef   => [],
    default => split($::system_environments, ','),
  }
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ($solr::configure) {
    file { 'solr::config::tomcat_server_conf':
      path    => '/etc/tomcat6/server.xml',
      content => template('solr/server.xml.erb'),
      owner   => "${solr::config::tomcat_user}",
      require => Package["tomcat6"],
    }
    file { 'solr::config::solr_core_conf':
      ensure  => present,
      content => template('solr/solr.xml.erb'),
      path    => '/usr/share/solr/solr.xml',
      owner   => "${solr::config::tomcat_user}",
      mode    => 0644,
      require => Package['solr-tomcat'],
      notify  => Service['tomcat6'],
    }
  }
}
