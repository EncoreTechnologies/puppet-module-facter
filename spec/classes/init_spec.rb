require 'spec_helper'
describe 'facter' do
  it { is_expected.to compile.with_all_deps }

  context 'with default options' do
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_class('facter') }

    it {
      is_expected.to contain_package('facter').with(
        {
          'ensure' => 'present',
          'name'   => 'facter',
        },
      )
    }

    it {
      is_expected.to contain_file('facts_file').with(
        {
          'ensure'  => 'file',
          'path'    => '/etc/facter/facts.d/facts.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
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
          'unless'  => 'test -d /etc/facter/facts.d',
        },
      )
    }
  end

  describe 'with purge_facts_d' do
    ['true', true].each do |value|
      context "set to #{value}" do
        let(:params) { { purge_facts_d: value } }
        let(:facts) { { osfamily: 'RedHat' } }

        it {
          is_expected.to contain_file('facts_d_directory').with(
            {
              'ensure'  => 'directory',
              'path'    => '/etc/facter/facts.d',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0755',
              'purge'   => true,
              'recurse' => true,
              'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
            },
          )
        }
      end
    end
    ['false', false].each do |value|
      context "set to #{value}" do
        let(:params) { { purge_facts_d: value } }
        let(:facts) { { osfamily: 'RedHat' } }

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
      end
    end
    context 'set to an invalid type' do
      let(:params) { { purge_facts_d: ['invalid', 'type'] } }

      it do
        expect {
          is_expected.to contain_class('facter')
        }.to raise_error(Puppet::Error, %r{\["invalid", "type"\] is not a boolean})
      end
    end
  end

  describe 'on puppet5 the package is_expected.to not be managed' do
    let(:facts) { { puppetversion: '5.3.0' } }

    [true, false].each do |value|
      context "with manage_package set to #{value}" do
        let(:params) { { manage_package: value } }

        it { is_expected.not_to contain_package('facter') }
      end
    end
  end

  describe 'on puppet4 the package is_expected.to not be managed' do
    let(:facts) { { puppetversion: '4.10.0' } }

    [true, false].each do |value|
      context "with manage_package set to #{value}" do
        let(:params) { { manage_package: value } }

        it { is_expected.not_to contain_package('facter') }
      end
    end
  end

  context 'with default options and stringified \'true\' for manage_package param' do
    let(:params) { { manage_package: 'true' } }
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_class('facter') }

    it {
      is_expected.to contain_package('facter').with(
        {
          'ensure' => 'present',
          'name'   => 'facter',
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
          'unless'  => 'test -d /etc/facter/facts.d',
        },
      )
    }
  end

  context 'with default options and stringified \'true\' for manage_facts_d_dir param' do
    let(:params) { { manage_facts_d_dir: 'true' } }
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_class('facter') }

    it {
      is_expected.to contain_package('facter').with(
        {
          'ensure' => 'present',
          'name'   => 'facter',
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
          'unless'  => 'test -d /etc/facter/facts.d',
        },
      )
    }
  end

  context 'with default options with manage_package = true and manage_facts_d_dir = false' do
    let(:params) do
      Hash['manage_package' => true]
      Hash['manage_facts_d_dir' => false]
      facts_hash = Hash[
        'fact' => Hash['value' => 'value']
      ]
      Hash['facts_hash' => facts_hash]
    end
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_class('facter') }

    it {
      is_expected.to contain_package('facter').with(
        {
          'ensure' => 'present',
          'name'   => 'facter',
        },
      )
    }

    it { is_expected.not_to contain_file('facts_d_directory') }

    it { is_expected.not_to contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with default options with manage_package = false and manage_facts_d_dir = true' do
    let(:params) do
      Hash['manage_package' => true]
      Hash['manage_facts_d_dir' => false]
      facts_hash = Hash[
        'fact' => Hash['value' => 'value']
      ]
      Hash['facts_hash' => facts_hash]
    end
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_class('facter') }

    it { is_expected.not_to contain_package('facter') }

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
          'unless'  => 'test -d /etc/facter/facts.d',
        },
      )
    }
  end

  context 'with default options with manage_package = false and manage_facts_d_dir = false' do
    let(:params) do
      Hash['manage_package' => true]
      Hash['manage_facts_d_dir' => false]
      facts_hash = Hash[
        'fact' => Hash['value' => 'value']
      ]
      Hash['facts_hash' => facts_hash]
    end
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_class('facter') }

    it { is_expected.not_to contain_package('facter') }

    it { is_expected.not_to contain_file('facts_d_directory') }

    it { is_expected.not_to contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with facts specified as a hash on RedHat' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) do
      facts_hash = Hash[
        'fact1' => Hash['value' => 'fact1value'],
        'fact2' => Hash['value' => 'fact2value']
      ]
      Hash['facts_hash' => facts_hash]
    end

    it {
      is_expected.to contain_file('facts_file').with(
        {
          'ensure'  => 'file',
          'path'    => '/etc/facter/facts.d/facts.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        },
      )
    }

    it {
      is_expected.to contain_file_line('fact_line_fact1').with(
        {
          'line' => 'fact1=fact1value',
        },
      )
    }

    it {
      is_expected.to contain_file_line('fact_line_fact2').with(
        {
          'line' => 'fact2=fact2value',
        },
      )
    }

    it { is_expected.to contain_file('facts_d_directory') }
    it { is_expected.to contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with facts specified as a hash with different file and facts_dir on RedHat' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) do
      Hash['facts_file' => 'file.txt']
      facts_hash = Hash[
        'fact1' => Hash['value' => 'fact1value'],
        'fact2' => Hash['value' => 'fact2value', 'file' => 'file2.txt'],
        'fact3' => Hash['value' => 'fact3value', 'file' => 'file3.txt', 'facts_dir' => '/etc/facts3']
      ]
      Hash['facts_hash' => facts_hash]
    end

    it {
      is_expected.to contain_file('facts_file').with(
        {
          'ensure'  => 'file',
          'path'    => '/etc/facter/facts.d/file.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        },
      )
    }

    it {
      is_expected.to contain_file('facts_file_fact2').with(
        {
          'ensure'  => 'file',
          'path'    => '/etc/facter/facts.d/file2.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        },
      )
    }

    it {
      is_expected.to contain_file('facts_file_fact3').with(
        {
          'ensure'  => 'file',
          'path'    => '/etc/facts3/file3.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        },
      )
    }

    it {
      is_expected.to contain_file_line('fact_line_fact1').with(
        {
          'line' => 'fact1=fact1value',
        },
      )
    }

    it {
      is_expected.to contain_file_line('fact_line_fact2').with(
        {
          'line' => 'fact2=fact2value',
        },
      )
    }

    it {
      is_expected.to contain_file_line('fact_line_fact3').with(
        {
          'line' => 'fact3=fact3value',
        },
      )
    }

    it { is_expected.to contain_file('facts_d_directory') }
    it { is_expected.to contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with all options specified' do
    let(:facts) { { osfamily: 'RedHat' } }
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

    it {
      is_expected.to contain_package('myfacter').with(
        {
          'ensure' => 'absent',
        },
      )
    }

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
          'unless'  => 'test -d /etc/puppet/facter/facts.d',
        },
      )
    }

    it {
      is_expected.to contain_file('facts_file').with(
        {
          'ensure'  => 'file',
          'path'    => '/etc/puppet/facter/facts.d/file.txt',
          'owner'   => 'puppet',
          'group'   => 'puppet',
          'mode'    => '0775',
        },
      )
    }

    it {
      is_expected.to contain_file_line('fact_line_fact').with(
        {
          'line' => 'fact=value',
        },
      )
    }
  end

  describe 'with package_name set to' do
    context 'a string' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) { { package_name: 'myfacter' } }

      it {
        is_expected.to contain_package('myfacter').with(
          {
            'ensure' => 'present',
          },
        )
      }
    end

    context 'an array' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) { { package_name: ['facter', 'facterfoo'] } }

      it {
        is_expected.to contain_package('facter').with(
          {
            'ensure' => 'present',
          },
        )
      }

      it {
        is_expected.to contain_package('facterfoo').with(
          {
            'ensure' => 'present',
          },
        )
      }
    end

    context 'an invalid type (boolean)' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) { { package_name: true } }

      it do
        expect {
          is_expected.to contain_class('facter')
        }.to raise_error(Puppet::Error, %r{/facter::package_name must be a string or an array./})
      end
    end
  end

  describe 'with package_ensure parameter' do
    ['present', 'absent', '23'].each do |value|
      context "set to a valid string value of #{value}" do
        let(:facts) { { osfamily: 'RedHat' } }
        let(:params) { { package_ensure: value } }

        it {
          is_expected.to contain_package('facter').with(
            {
              'ensure' => value,
            },
          )
        }
      end
    end

    context 'set to a non-string value' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) { { package_ensure: ['invalid'] } }

      it do
        expect {
          is_expected.to contain_class('facter')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  context 'with invalid facts_d_dir param' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) { { facts_d_dir: 'invalid/path/statement' } }

    it do
      expect {
        is_expected.to contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with invalid facts_d_mode param' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) { { facts_d_mode: '751' } }

    it do
      expect {
        is_expected.to contain_class('facter')
      }.to raise_error(Puppet::Error, %r{/facter::facts_d_mode must be a four digit mode. Detected value is <751>./})
    end
  end

  context 'with invalid manage_package param' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) { { manage_package: ['array', 'is', 'invalid'] } }

    it do
      expect {
        is_expected.to contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with invalid manage_facts_d_dir param' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) { { manage_facts_d_dir: ['array', 'is', 'invalid'] } }

    it do
      expect {
        is_expected.to contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  describe 'with ensure_facter_symlink' do
    ['true', true].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { osfamily: 'Debian' } }
        let(:params) { { ensure_facter_symlink: value } }

        it {
          is_expected.to contain_file('facter_symlink').with(
            {
              'ensure'  => 'link',
              'path'    => '/usr/local/bin/facter',
              'target'  => '/usr/bin/facter',
            },
          )
        }
      end
    end

    ['false', false].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { osfamily: 'Debian' } }
        let(:params) { { ensure_facter_symlink: value } }

        it { is_expected.not_to contain_file('facter_symlink') }
      end
    end

    context 'enabled with all params specified' do
      let(:facts) { { osfamily: 'Debian' } }
      let(:params) do
        Hash['ensure_facter_symlink' => true]
        Hash['path_to_facter' => '/foo/bar']
        Hash['path_to_facter_symlink' => '/bar']
        facts_hash = Hash[
          'fact' => Hash['value' => 'value']
        ]
        Hash['facts_hash' => facts_hash]
      end

      it {
        is_expected.to contain_file('facter_symlink').with(
          {
            'ensure'  => 'link',
            'path'    => '/bar',
            'target'  => '/foo/bar',
          },
        )
      }
    end
  end

  describe 'with invalid path for' do
    context 'path_to_facter' do
      let(:params) { { path_to_facter: 'invalid/path' } }

      it do
        expect {
          is_expected.to contain_class('facter')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'path_to_facter_symlink' do
      let(:params) { { path_to_facter_symlink: 'invalid/path' } }

      it do
        expect {
          is_expected.to contain_class('facter')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  context 'with invalid facts param' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) { { facts_hash: ['array', 'is', 'invalid'] } }

    it do
      expect {
        is_expected.to contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with invalid fact_file param' do
    let(:facts) { { osfamily: 'RedHat' } }
    let(:params) { { fact_file: ['array', 'is', 'invalid'] } }

    it do
      expect {
        is_expected.to contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  describe 'with facter::facts_hash_hiera_merge' do
    let :facts do
      Hash['osfamily' => 'RedHat']
      Hash['fqdn' => 'hieramerge.example.local']
      Hash['parameter_tests' => 'facts_hash_hiera_merge']
      facts_hash = Hash[
        'fact' => Hash['value' => 'value']
      ]
      Hash['facts_hash' => facts_hash]
    end

    context 'set to valid value true' do
      let(:params) { { facts_hash_hiera_merge: 'true' } }

      it { is_expected.to have_facter__fact_resource_count(2) }
      it do
        is_expected.to contain_facter__fact('role').with(
          {
            'file'      => 'facts.txt',
            'facts_dir' => '/etc/facter/facts.d',
            'value'     => 'puppetmaster',
          },
        )
      end
      it do
        is_expected.to contain_facter__fact('location').with(
          {
            'file'      => 'location.txt',
            'facts_dir' => '/etc/facter/facts.d',
            'value'     => 'RNB',
          },
        )
      end
    end

    context 'set to valid value false' do
      let(:params) { { facts_hash_hiera_merge: 'false' } }

      it { is_expected.to have_facter__fact_resource_count(1) }
      it do
        is_expected.to contain_facter__fact('role').with(
          {
            'file'      => 'facts.txt',
            'facts_dir' => '/etc/facter/facts.d',
            'value'     => 'puppetmaster',
          },
        )
      end
      it { is_expected.not_to contain_facter__fact('location') }
    end

    context 'set to invalid value <invalid>' do
      let(:params) { { facts_hash_hiera_merge: 'invalid' } }

      it 'is expected to fail' do
        expect {
          is_expected.to contain_class('facter')
        }.to raise_error(Puppet::Error, %r{/str2bool\(\): Unknown type of boolean given/})
      end
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      Hash['fqdn' => 'hieramerge.example.local']
      facts_hash = Hash[
        'fact' => Hash['value' => 'value']
      ]
      Hash['facts_hash' => facts_hash]
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
              subject(:test_subject) { described_class }

              expect { is_expected.to contain_class(test_subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
