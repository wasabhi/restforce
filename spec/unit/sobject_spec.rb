require 'spec_helper'

describe Restforce::SObject do
  let(:client)      { double('Client') }
  let(:hash)        { JSON.parse(fixture('sobject/query_success_response'))['records'].first }
  subject(:sobject) { described_class.new(hash, client) }

  describe '#new' do
    context 'with valid options' do
      it                 { should be_a Restforce::SObject }
      it                 { should have_client client }
      its(:sobject_type) { should eq 'Whizbang' }
      its(:Text_Label)   { should eq 'Hi there!' }

      describe 'children' do
        subject(:children) { sobject.Whizbangs__r }

        it { should be_a Restforce::Collection }

        describe 'each child' do
          it { should be_all { |sobject| expect(sobject).to be_a Restforce::SObject } }
          it { should be_all { |sobject| expect(sobject).to have_client client } }
        end
      end

      describe 'parent' do
        subject(:parent) { sobject.ParentWhizbang__r }

        it                 { should be_a Restforce::SObject }
        its(:sobject_type) { should eq 'Whizbang' }
        its(:Name)         { should eq 'Parent Whizbang' }
        it                 { should have_client client }
      end
    end
  end

  { :save     => :update,
    :save!    => :update!,
    :destroy  => :destroy,
    :destroy! => :destroy! }.each do |method, receiver|
    describe ".#{method}" do
      subject { lambda { sobject.send(method) } }

      context 'when an Id was not queried' do
        it { should raise_error ArgumentError, 'You need to query the Id for the record first.' }
      end

      context 'when an Id is present' do
        before do
          hash.merge!(:Id => '001D000000INjVe')
          client.should_receive(receiver)
        end

        it { should_not raise_error }
      end
    end
  end

  describe '.describe' do
    subject { lambda { sobject.describe } }

    before do
      client.should_receive(:describe).with('Whizbang')
    end

    it { should_not raise_error }
  end
end
