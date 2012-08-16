# == Class: config
#
# Configuration for Amara
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { config: }
#    or
#  include config
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class config ($graphite_host=$config::params::graphite_host) inherits config::params {
  # this needs to match the appserver::apps_dir variable for the fabric tasks
  $apps_dir = '/opt/apps'
  $ve_root = '/opt/ve'
  $app_group = 'deploy'
  $envs = $::system_environments ? {
    undef   => [],
    default => $::system_environments,
  }
  $roles = $::system_roles ? {
    undef => [],
    default => $::system_roles,
  }
  # hash for controlling revisions for the app and data roles
  $revisions = {
    'vagrant'     => 'dev',
    'local'       => 'x-new-puppet-setup',
    'dev'         => 'dev',
    'staging'     => 'staging',
    'nf'          => 'x-nf',
    'production'  => 'production',
  }
  # conditional to check for roles
  if 'app' in $roles {
    if ! defined(Class['config::roles::app']) {
      class { 'config::roles::app':
        graphite_host => $graphite_host,
        revisions     => $revisions,
      }
    }
  }
  if 'data' in $roles {
    if ! defined(Class['config::roles::data']) {
      class { 'config::roles::data':
        revisions => $revisions,
      }
    }
  }
  if 'util' in $roles {
    if ! defined(Class['config::roles::util']) { class { 'config::roles::util': } }
  }
  # local vagrant dev
  if 'vagrant' in $roles {
    if ! defined(Class['config::roles::app']) { class { 'config::roles::app': } }
    if ! defined(Class['config::roles::data']) { class { 'config::roles::data': } }
    if ! defined(Class['mysql']) { class { 'mysql': } }
  }
}
