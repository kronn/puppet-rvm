class rvm::system($version=undef) {
  include rvm::gpg

  $actual_version = $version ? {
    undef     => 'latest',
    'present' => 'latest',
    default   => $version,
  }

  exec { 'system-rvm-gpg-key':
    command     => 'gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3',
    unless      => 'gpg2 --list-keys 409B6B1796C275462A1703113804BB82D39DC0E3',
    require     => Class['::rvm::gpg']
  }

  exec { 'system-rvm':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => "/usr/bin/curl -fsSL https://get.rvm.io | bash -s -- --version ${actual_version}",
    creates     => '/usr/local/rvm/bin/rvm',
    require     => [
      Class['rvm::dependencies'],
      Exec['system-rvm-gpg-key'],
    ],
  }

  # the fact won't work until rvm is installed before puppet starts
  if "${::rvm_version}" != "" {
    if ($version != undef) and ($version != present) and ($version != $::rvm_version) {
      notify { 'rvm_version': message => "RVM version ${::rvm_version}" }

      # Update the rvm installation to the version specified
      notify { 'rvm-get_version':
        message => "RVM updating to version ${version}",
        require => Notify['rvm_version'],
      } ->
      exec { 'system-rvm-get':
        path    => '/usr/local/rvm/bin:/usr/bin:/usr/sbin:/bin',
        command => "rvm get ${version}",
        before  => Exec['system-rvm'], # so it doesn't run after being installed the first time
      }
    }
  }

}
