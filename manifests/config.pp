# == Class pam_pkcs11::config
#
# This class is called from pam_pkcs11 for service config.
#
class pam_pkcs11::config inherits pam_pkcs11 {

  require '::pam_pkcs11::install'

  File {
    owner => 'root',
    group => 'root',
  }

  file { '/etc/pam_pkcs11':
    ensure => directory,
    mode   => '0755',
  }

  file { 'pam_pkcs11.conf':
    ensure  => file,
    path    => '/etc/pam_pkcs11/pam_pkcs11.conf',
    mode    => '0600',
    content => template('pam_pkcs11/pam_pkcs11.conf.erb'),
  }

  # TODO: Mappings should really be a custom type so they can be collected.
  file { 'digest_mapping':
    ensure  => file,
    path    => '/etc/pam_pkcs11/digest_mapping',
    mode    => '0600',
    content => template('pam_pkcs11/digest_mapping.erb'),
  }

  file { 'subject_mapping':
    ensure  => file,
    path    => '/etc/pam_pkcs11/subject_mapping',
    mode    => '0600',
    content => template('pam_pkcs11/subject_mapping.erb'),
  }

  file { 'uid_mapping':
    ensure  => file,
    path    => '/etc/pam_pkcs11/uid_mapping',
    mode    => '0600',
    content => template('pam_pkcs11/uid_mapping.erb'),
  }

  # FIXME: CAs hash links could-- maybe should-- be done with a custom type &
  #        provider.  Hash links are generic to OpenSSL, so it would make sense
  #        to do such a thing in an OpenSSL module.
  if $::pam_pkcs11::ca_dir_source != [] and $::pam_pkcs11::merged_pkcs11_module['ca_dir'] != undef {

    file { 'ca_dir':
      ensure       => directory,
      recurse      => true,
      recurselimit => 1,
      path         => $::pam_pkcs11::merged_pkcs11_module['ca_dir'],
      mode         => '0644',
      source       => $::pam_pkcs11::ca_dir_source,
      sourceselect => $::pam_pkcs11::ca_dir_sourceselect,
      notify       => Exec['pkcs11_make_hash_link'],
    }

    exec { 'pkcs11_make_hash_link':
      refreshonly => true,
      cwd         => $::pam_pkcs11::merged_pkcs11_module['ca_dir'],
      path        => ['/usr/local/bin', '/usr/local/sbin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    }
  }
}
