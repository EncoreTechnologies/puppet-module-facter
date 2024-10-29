require 'spec_helper'

describe 'facter' do
  # This module is meant to work on all POSIX systems. Because of this, we just
  # use the most popular here. There is no logic in the module based on the
  # platform, so no need to test different POSIX platforms.
  context 'on RedHat' do
    redhat = {
      supported_os: [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['7'],
        },
      ],
    }
    on_supported_os(redhat).each do |_os, os_facts|
      let(:facts) do
        os_facts
      end
      context 'with default options' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('facter') }

        it {
          is_expected.to contain_concat('facts_file').with(
            {
              'ensure'         => 'present',
              'path'           => '/etc/facter/facts.d/facts.txt',
              'owner'          => 'root',
              'group'          => 'root',
              'mode'           => '0644',
              'ensure_newline' => 'true',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('facts_file-header').with(
            {
              'target'  => 'facts_file',
              'content' => "# File managed by Puppet\n#DO NOT EDIT",
              'order'   => '00',
            },
          )
        }

        it {
          is_expected.to contain_file('facts_d_directory').with(
            {
              'ensure'  => 'directory',
              'path'    => '/etc/facter/facts.d',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0755',
              'purge'   => false,
              'recurse' => false,
              'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
            },
          )
        }

        it {
          is_expected.to contain_exec('mkdir_p-/etc/facter/facts.d').with(
            {
              'command' => 'mkdir -p /etc/facter/facts.d',
              'creates' => '/etc/facter/facts.d',
              'path'    => '/bin:/usr/bin',
            },
          )
        }
      end

      describe 'with purge_facts_d' do
        [true, false].each do |value|
          context "set to #{value}" do
            let(:params) { Hash['purge_facts_d' => value] }

            it {
              is_expected.to contain_file('facts_d_directory').with(
                {
                  'ensure'  => 'directory',
                  'path'    => '/etc/facter/facts.d',
                  'owner'   => 'root',
                  'group'   => 'root',
                  'mode'    => '0755',
                  'purge'   => value,
                  'recurse' => value,
                  'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
                },
              )
            }
          end
        end
      end

      describe 'the package should not be managed' do
        it { is_expected.not_to contain_package('facter') }
      end

      context 'with default options with manage_facts_d_dir = false' do
        let(:params) { Hash['manage_facts_d_dir' => false] }

        it { is_expected.to contain_class('facter') }

        it { is_expected.not_to contain_file('facts_d_directory') }

        it { is_expected.not_to contain_exec('mkdir_p-/etc/facter/facts.d') }
      end

      context 'with default options with manage_facts_d_dir = true' do
        let(:params) { Hash['manage_facts_d_dir' => true] }

        it { is_expected.to contain_class('facter') }

        it {
          is_expected.to contain_file('facts_d_directory').with(
            {
              'ensure' => 'directory',
              'path'   => '/etc/facter/facts.d',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755',
              'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
            },
          )
        }

        it {
          is_expected.to contain_exec('mkdir_p-/etc/facter/facts.d').with(
            {
              'command' => 'mkdir -p /etc/facter/facts.d',
              'creates' => '/etc/facter/facts.d',
              'path'    => '/bin:/usr/bin',
            },
          )
        }
      end

      context 'with facts specified as a hash' do
        let(:params) do
          facts_hash = Hash[
            'fact1' => Hash['value' => 'fact1value'],
            'fact2' => Hash['value' => 'fact2value']
          ]
          Hash['facts_hash' => facts_hash]
        end

        it {
          is_expected.to contain_concat('facts_file').with(
            {
              'ensure'  => 'present',
              'path'    => '/etc/facter/facts.d/facts.txt',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('fact_line_fact1').with(
            {
              'content' => 'fact1=fact1value',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('fact_line_fact2').with(
            {
              'content' => 'fact2=fact2value',
            },
          )
        }

        it { is_expected.to contain_file('facts_d_directory') }
        it { is_expected.to contain_exec('mkdir_p-/etc/facter/facts.d') }
      end

      context 'with structured_data_facts_hash specified' do
        let(:params) do
          structured_data_facts_hash = Hash[
            'foo' => Hash['data' => Hash[
              'my_array' => ['one', 'two', 'three'],
              'my_hash' => Hash['k' => 'v']
              ]
            ]
          ]
          Hash['structured_data_facts_hash' => structured_data_facts_hash]
        end

        foo_content = <<-END.gsub(%r{^\s+\|}, '')
          |# This file is being maintained by Puppet.
          |# DO NOT EDIT
          |---
          |my_array:
          |- one
          |- two
          |- three
          |my_hash:
          |  k: v
        END

        bar_content = <<-END.gsub(%r{^\s+\|}, '')
          |# This file is being maintained by Puppet.
          |# DO NOT EDIT
          |---
          |bar_array:
          |- one
          |- two
          |- three
        END

        it { is_expected.to contain_facter__structured_data_fact('foo') }
        it { is_expected.to contain_facter__structured_data_fact('bar') }

        it {
          is_expected.to contain_file('structured_data_fact_facts.yaml').with(
            {
              'ensure'  => 'file',
              'path'    => '/etc/facter/facts.d/facts.yaml',
              'content' => foo_content,
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            },
          )
        }

        it {
          is_expected.to contain_file('structured_data_fact_bar.yaml').with(
            {
              'ensure'  => 'file',
              'path'    => '/factsdir/bar.yaml',
              'content' => bar_content,
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            },
          )
        }
      end

      context 'with facts specified as a hash with different file and facts_dir' do
        let(:params) do
          Hash['facts_file' => 'file.txt']
          facts_hash = Hash[
            'fact1' => Hash['value' => 'fact1value'],
            'fact2' => Hash['value' => 'fact2value', 'file' => 'file2.txt'],
            'fact3' => Hash['value' => 'fact3value', 'file' => 'file3.txt', 'facts_dir' => '/etc/facts3']
          ]
          Hash['facts_hash' => facts_hash]
        end

        it { is_expected.to contain_facter__fact('fact1') }
        it { is_expected.to contain_facter__fact('fact2') }
        it { is_expected.to contain_facter__fact('fact3') }

        it {
          is_expected.to contain_concat('facts_file').with(
            {
              'ensure'  => 'present',
              'path'    => '/etc/facter/facts.d/file.txt',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            },
          )
        }

        it {
          is_expected.to contain_concat('facts_file_fact2').with(
            {
              'ensure'  => 'present',
              'path'    => '/etc/facter/facts.d/file2.txt',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            },
          )
        }

        it {
          is_expected.to contain_concat('facts_file_fact3').with(
            {
              'ensure'  => 'present',
              'path'    => '/etc/facts3/file3.txt',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('fact_line_fact1').with(
            {
              'content' => 'fact1=fact1value',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('fact_line_fact2').with(
            {
              'content' => 'fact2=fact2value',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('fact_line_fact3').with(
            {
              'content' => 'fact3=fact3value',
            },
          )
        }

        it { is_expected.to contain_file('facts_d_directory') }
        it { is_expected.to contain_exec('mkdir_p-/etc/facter/facts.d') }
      end

      context 'with all options specified' do
        let(:params) do
          Hash['ensure_facter_symlink' => true]
          Hash['facts_d_dir' => '/etc/puppet/facter/facts.d']
          Hash['facts_d_owner' => 'puppet']
          Hash['facts_d_group' => 'puppet']
          Hash['facts_d_mode' => '0775']
          Hash['facts_file' => 'file.txt']
          Hash['facts_file_owner' => 'puppet']
          Hash['facts_file_group' => 'puppet']
          facts_hash = Hash[
            'fact' => Hash['value' => 'value']
          ]
          Hash['facts_hash' => facts_hash]
        end

        it { is_expected.to contain_class('facter') }

        it { is_expected.to contain_facter__fact('fact') }

        it {
          is_expected.to contain_file('facts_d_directory').with(
            {
              'ensure'  => 'directory',
              'path'    => '/etc/puppet/facter/facts.d',
              'owner'   => 'puppet',
              'group'   => 'puppet',
              'mode'    => '0775',
              'purge'   => false,
              'recurse' => false,
              'require' => 'Exec[mkdir_p-/etc/puppet/facter/facts.d]',
            },
          )
        }

        it {
          is_expected.to contain_exec('mkdir_p-/etc/puppet/facter/facts.d').with(
            {
              'command' => 'mkdir -p /etc/puppet/facter/facts.d',
              'creates' => '/etc/puppet/facter/facts.d',
              'path'    => '/bin:/usr/bin',
            },
          )
        }

        it {
          is_expected.to contain_file('facter_symlink').with(
            {
              'ensure' => 'link',
              'path'   => '/usr/local/bin/facter',
              'target' => '/opt/puppetlabs/bin/facter',
            },
          )
        }

        it {
          is_expected.to contain_concat('facts_file').with(
            {
              'ensure'  => 'present',
              'path'    => '/etc/puppet/facter/facts.d/file.txt',
              'owner'   => 'puppet',
              'group'   => 'puppet',
              'mode'    => '0775',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('fact_line_fact').with(
            {
              'content' => 'fact=value',
            },
          )
        }
      end

      describe 'variable type and content validations' do
        # set needed custom facts and variables
        let(:facts) do
          os_facts.merge(
            {
              'fqdn' => 'facter.example.local',
            },
          )
        end
        let(:validation_params) do
          {
            # :param => 'value',
          }
        end

        validations = {
          'Boolean' => {
            'name'    => ['manage_facts_d_dir', 'purge_facts_d', 'ensure_facter_symlink'],
            'valid'   => [true, false],
            'invalid' => ['invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, nil],
            'message' => 'expects a Boolean value, got',
          },
          'Stdlib::Absolutepath' => {
            'name'    => ['facts_d_dir', 'path_to_facter', 'path_to_facter_symlink'],
            'valid'   => ['/absolute/filepath', '/absolute/directory/'],
            'invalid' => ['../invalid', '', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
            'message' => 'expects a Stdlib::Absolutepath',
          },
          'String[1]' => {
            'name'    => ['facts_d_owner', 'facts_d_group', 'facts_file_owner', 'facts_file_group'],
            'valid'   => ['string'],
            'invalid' => ['', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false],
            'message' => '(expects a String value, got|expects a String\[1\] value, got)',
          },
          'Pattern to match strings that end with .txt' => {
            'name'    => ['facts_file'],
            'valid'   => ['foo.txt'],
            'invalid' => ['foo.text', 'foo-text', 'foo.text1', '', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false],
            'message' => 'Error while evaluating a Resource Statement',
          },
          'Optional[Stdlib::Filemode]' => {
            'name'    => ['facts_d_mode', 'facts_file_mode'],
            'valid'   => ['0777', :undef],
            'invalid' => ['8888', 'invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, true, false],
            'message' => '(expects a match for Stdlib::Filemode)',
          },
        }

        validations.sort.each do |type, var|
          var[:name].each do |var_name|
            var[:valid].each do |valid|
              context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
                let(:params) do
                  validation_params.merge({ var_name.to_s => valid, })
                end

                # Without this, the coverage report will incorrectly mark these as untested.
                if (var_name == 'facts_d_dir') && (['/absolute/filepath', '/absolute/directory/'].include? valid)
                  it { is_expected.to contain_exec("mkdir_p-#{valid}") }
                end

                it { is_expected.to compile }
              end
            end

            var[:invalid].each do |invalid|
              context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
                let(:params) do
                  validation_params.merge({ var_name.to_s => invalid, })
                end

                it 'is expected to fail' do
                  expect { is_expected.to contain_class(subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
                end
              end
            end
          end # var[:name].each
        end # validations.sort.each
      end # describe 'variable type and content validations'
    end # on_support_os(redhat)
  end # context 'on RedHat'

  context 'on Windows' do
    windows = {
      supported_os: [
        {
          'operatingsystem'        => 'windows',
          'operatingsystemrelease' => ['2016'],
        },
      ],
    }
    on_supported_os(windows).each do |_os, os_facts|
      let(:facts) do
        os_facts.merge(
          {
            path: 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
          },
        )
      end
      context 'with default options' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('facter') }

        it {
          is_expected.to contain_concat('facts_file').with(
            {
              'ensure'         => 'present',
              'path'           => 'C:\ProgramData\PuppetLabs\facter\facts.d\facts.txt',
              'owner'          => 'NT AUTHORITY\SYSTEM',
              'group'          => 'NT AUTHORITY\SYSTEM',
              'ensure_newline' => 'true',
            },
          )
        }

        it {
          is_expected.to contain_file('facts_d_directory').with(
            {
              'ensure'  => 'directory',
              'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
              'owner'   => 'NT AUTHORITY\SYSTEM',
              'group'   => 'NT AUTHORITY\SYSTEM',
              'purge'   => false,
              'recurse' => false,
              'mode'    => nil,
              'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
            },
          )
        }

        it {
          is_expected.to contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d').with(
            {
              'command' => 'cmd /c mkdir C:\ProgramData\PuppetLabs\facter\facts.d',
              'creates' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
              'path'    => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
            },
          )
        }

        it { is_expected.not_to contain_file('facter_symlink') }
      end

      describe 'with purge_facts_d' do
        [true, false].each do |value|
          context "set to #{value}" do
            let(:params) { { 'purge_facts_d' => value } }

            it {
              is_expected.to contain_file('facts_d_directory').with(
                {
                  'ensure'  => 'directory',
                  'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
                  'owner'   => 'NT AUTHORITY\SYSTEM',
                  'group'   => 'NT AUTHORITY\SYSTEM',
                  'mode'    => nil,
                  'purge'   => value,
                  'recurse' => value,
                  'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
                },
              )
            }
          end
        end
      end

      describe 'the package should not be managed' do
        it { is_expected.not_to contain_package('facter') }
      end

      context 'with default options with manage_facts_d_dir = false' do
        let(:params) { { 'manage_facts_d_dir' => false } }

        it { is_expected.to contain_class('facter') }

        it { is_expected.not_to contain_file('facts_d_directory') }

        it { is_expected.not_to contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d') }
      end

      context 'with default options with manage_facts_d_dir = true' do
        let(:params) { { 'manage_facts_d_dir' => true } }

        it { is_expected.to contain_class('facter') }

        it {
          is_expected.to contain_file('facts_d_directory').with(
            {
              'ensure'  => 'directory',
              'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
              'owner'   => 'NT AUTHORITY\SYSTEM',
              'group'   => 'NT AUTHORITY\SYSTEM',
              'mode'    => nil,
              'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
            },
          )
        }

        it {
          is_expected.to contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d').with(
            {
              'command' => 'cmd /c mkdir C:\ProgramData\PuppetLabs\facter\facts.d',
              'creates' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
              'path'    => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
            },
          )
        }
      end

      context 'with all options specified' do
        let(:params) do
          {
            'facts_d_dir'      => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            'facts_d_owner'    => 'puppet',
            'facts_d_group'    => 'puppet',
            'facts_file'       => 'file.txt',
            'facts_file_owner' => 'puppet',
            'facts_file_group' => 'puppet',
            'facts_hash'       => {
              'fact' => {
                'value' => 'value',
              },
            }
          }
        end

        it { is_expected.to contain_class('facter') }
        it {
          is_expected.to contain_file('facts_d_directory').with(
            {
              'ensure'  => 'directory',
              'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
              'owner'   => 'puppet',
              'group'   => 'puppet',
              'purge'   => false,
              'recurse' => false,
              'mode'    => nil,
              'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
            },
          )
        }

        it {
          is_expected.to contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d').with(
            {
              'command' => 'cmd /c mkdir C:\ProgramData\PuppetLabs\facter\facts.d',
              'creates' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
              'path'    => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
            },
          )
        }

        it {
          is_expected.to contain_concat('facts_file').with(
            {
              'ensure'  => 'present',
              'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d\file.txt',
              'owner'   => 'puppet',
              'group'   => 'puppet',
            },
          )
        }

        it {
          is_expected.to contain_concat__fragment('fact_line_fact').with(
            {
              'content' => 'fact=value',
            },
          )
        }
      end # context 'with all options specified'
    end # on_support_os(windows)
  end # context 'on windows'
end # describe 'facter'
