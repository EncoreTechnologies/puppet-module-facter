require 'spec_helper'
describe 'facter::fact' do
  context 'with fact and facts_dir specified' do
    let(:title) { 'fact1' }
    let(:params) do
      Hash['fact' => 'fact1']
      Hash['value' => 'fact1value']
      Hash['file' => 'custom.txt']
      Hash['facts_dir' => '/factsdir']
      facts_hash = Hash[
        'fact' => Hash['value' => 'value']
      ]
      Hash['facts_hash' => facts_hash]
    end

    it {
      is_expected.to contain_file('facts_file_fact1').with(
        {
          'ensure'  => 'file',
          'path'    => '/factsdir/custom.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        },
      )
    }

    it {
      is_expected.to contain_file_line('fact_line_fact1').with(
        {
          'name' => 'fact_line_fact1',
          'path' => '/factsdir/custom.txt',
          'line' => 'fact1=fact1value',
          'match' => '^fact1=\S*$',
        },
      )
    }
  end

  context 'with fact specified ' do
    let(:title) { 'fact2' }
    let(:params) do
      Hash['fact' => 'fact2']
      Hash['value' => 'fact2value']
      facts_hash = Hash[
        'fact' => Hash['value' => 'value']
      ]
      Hash['facts_hash' => facts_hash]
    end

    # Does not contain this file, because we are using the default which is
    # managed in the facter class.
    it { is_expected.not_to contain_file('facts_file_fact2') }

    it {
      is_expected.to contain_file_line('fact_line_fact2').with(
        {
          'name' => 'fact_line_fact2',
          'line' => 'fact2=fact2value',
          'path' => '/etc/facter/facts.d/facts.txt',
        },
      )
    }
  end
end
