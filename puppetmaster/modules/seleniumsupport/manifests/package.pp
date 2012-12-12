class seleniumsupport::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['firefox']) { package { 'firefox': ensure => installed, } }
  if ! defined(Package['flashplugin-installer']) { package { 'flashplugin-installer': ensure => installed, } }
  if ! defined(Package['xvfb']) { package { 'xvfb': ensure => installed, } }
  # Google Chrome for selenium
  # get apt key
  exec { 'seleniumsupport::package::google_apt_key':
    command => 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -',
    user    => root,
    unless  => 'apt-key list | grep -i google',
  }
  file { '/etc/apt/sources.list.d/google-chrome.list':
    alias   => 'seleniumsupport::package::google_chrome_apt_source_list',
    ensure  => present,
    content => "deb http://dl.google.com/linux/deb/ stable main\n",
    owner   => root,
    notify  => Exec['seleniumsupport::package::apt_update'],
    require => Exec['seleniumsupport::package::google_apt_key'],
  }
  exec { 'seleniumsupport::package::apt_update':
    command     => 'apt-get update',
    user        => root,
    refreshonly => true,
  }
  if ! defined(Package["google-chrome-stable"]) {
    package { "google-chrome-stable":
      ensure  => installed,
      require => [ File['seleniumsupport::package::google_chrome_apt_source_list'], Exec['seleniumsupport::package::apt_update'] ],
    }
  }
  # chrome driver
  exec { 'seleniumsupport::package::install_chromedriver':
    command   => "wget $seleniumsupport::package::chromedriver_url -O /tmp/chromedriver.zip ; unzip -d /usr/local/bin/ /tmp/chromedriver.zip ; rm /tmp/chromedriver.zip",
    user      => root,
    unless    => 'test -e /usr/local/bin/chromedriver',
  }

}
