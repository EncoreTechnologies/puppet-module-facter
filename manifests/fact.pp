# @summary Define txt based external facts
#
# @param value
#   Value of the fact.
#
# @param fact
#   Name of the fact
#
# @param file
#   File in which the fact will be placed. If not specified, use the default
#   facts file.
#
# @param facts_dir
#   Directory in which the file will be placed. If not specified, use the
#   default facts_d_dir.
#
define facter::fact (
  String[1]             $value,
  String[1]             $fact      = $name,
  String[1]             $file      = 'facts.txt',
  Stdlib::Absolutepath  $facts_dir = '/etc/facter/facts.d',
) {
  include facter

  $match = "^${name}=\\S*$"

  if $file != $facter::facts_file {
    file { "facts_file_${name}":
      ensure => file,
      path   => "${facts_dir}/${file}",
      owner  => $facter::facts_file_owner,
      group  => $facter::facts_file_group,
      mode   => $facter::facts_file_mode,
    }
  }

  file_line { "fact_line_${name}":
    path  => "${facts_dir}/${file}",
    line  => "${name}=${value}",
    match => $match,
  }
}
