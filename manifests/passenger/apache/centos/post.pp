class rvm::passenger::apache::centos::post(
  $ruby_version,
  $version,
  $rvm_prefix = '/usr/local/',
  $compiled_module_fn = 'ext/apache2/mod_passenger.so',
  $mininstances = '1',
  $maxpoolsize = '6',
  $poolidletime = '300',
  $maxinstancesperapp = '0',
  $spawnmethod = 'smart-lv2',
  $gempath,
  $binpath
) {
  exec {
    'passenger-install-apache2-module':
      environment => ["rvm_prefix=${rvm_prefix}", "rvm_path=${rvm_prefix}/rvm", "rvm_bin_path=${binpath}", "HOME=/tmp"],
      command   => "${rvm::passenger::apache::binpath}rvm ${rvm::passenger::apache::ruby_version} exec passenger-install-apache2-module -a",
      creates   => "${gempath}/passenger-${version}/${compiled_module_fn}",
      logoutput => 'on_failure',
      require   => [Rvm_gem['passenger'], Package['httpd','httpd-devel','mod_ssl']];
  }

  file {
    '/etc/httpd/conf.d/passenger.conf':
      ensure  => file,
      content => template('rvm/passenger-apache.load.erb', 'rvm/passenger-apache.conf.erb'),
      require => Exec['passenger-install-apache2-module'];
  }

  # Add Apache restart hooks
  if defined(Service['httpd']) {
    File['/etc/httpd/conf.d/passenger.conf'] ~> Service['httpd']
  }
}
