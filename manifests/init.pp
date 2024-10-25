# @summary Manage facter
#
# This class will manage facter and allow you to specify external facts.
#
# @param manage_facts_d_dir
#   Boolean to determine if the external facts directory will be managed.
# @param purge_facts_d
#   Boolean to determine if the external facts directory should be purged. This
#   will remove files not managed by Puppet.
# @param facts_d_dir
#   Path to the directory which will contain the external facts.
# @param facts_d_owner
#   The owner of the `facts_d_dir`.
# @param facts_d_group
#   The group of the `facts_d_dir`.
# @param facts_d_mode
#   The mode of the `facts_d_dir`.
# @param path_to_facter
#   The path to the facter binary.
# @param path_to_facter_symlink
#   Path to a symlink that points to the facter binary.
# @param ensure_facter_symlink
#   Boolean to determine if the symlink should be present.
# @param facts_hash
#   A hash of `facter::fact` entries.
# @param facts_file
#   The file in which the text based external facts are stored. This file must
#   end with '.txt'.
# @param facts_file_owner
#   The owner of the facts_file.
# @param facts_file_group
#   The group of the facts_file.
# @param facts_file_mode
#   The mode of the facts_file.
#
class facter (
  Boolean                    $manage_facts_d_dir     = true,
  Boolean                    $purge_facts_d          = false,
  Stdlib::Absolutepath       $facts_d_dir            = '/etc/facter/facts.d',
  String[1]                  $facts_d_owner          = 'root',
  String[1]                  $facts_d_group          = 'root',
  Stdlib::Filemode           $facts_d_mode           = '0755',
  Stdlib::Absolutepath       $path_to_facter         = '/usr/bin/facter',
  Stdlib::Absolutepath       $path_to_facter_symlink = '/usr/local/bin/facter',
  Boolean                    $ensure_facter_symlink  = false,
  Hash                       $facts_hash             = {},
  Pattern[/\.txt*\Z/]        $facts_file             = 'facts.txt',
  String[1]                  $facts_file_owner       = 'root',
  String[1]                  $facts_file_group       = 'root',
  Stdlib::Filemode           $facts_file_mode        = '0644',
) {
  if $manage_facts_d_dir == true {
    exec { "mkdir_p-${facts_d_dir}":
      command => "mkdir -p ${facts_d_dir}",
      unless  => "test -d ${facts_d_dir}",
      path    => '/bin:/usr/bin',
    }

    file { 'facts_d_directory':
      ensure  => 'directory',
      path    => $facts_d_dir,
      owner   => $facts_d_owner,
      group   => $facts_d_group,
      mode    => $facts_d_mode,
      purge   => $purge_facts_d,
      recurse => $purge_facts_d,
      require => Exec["mkdir_p-${facts_d_dir}"],
    }
  }

  # optionally create symlinks to facter binary
  if $ensure_facter_symlink == true {
    file { 'facter_symlink':
      ensure => 'link',
      path   => $path_to_facter_symlink,
      target => $path_to_facter,
    }
  }

  file { 'facts_file':
    ensure => file,
    path   => "${facts_d_dir}/${facts_file}",
    owner  => $facts_file_owner,
    group  => $facts_file_group,
    mode   => $facts_file_mode,
  }

  if ! empty( $facts_hash ) {
    $facts_defaults = {
      'file'      => $facts_file,
      'facts_dir' => $facts_d_dir,
    }
    create_resources('facter::fact', $facts_hash, $facts_defaults)
  }
}
