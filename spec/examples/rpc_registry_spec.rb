require 'spec_helper'

describe Rough::RpcRegistry do

  shared_examples 'rpc_lookup' do

    context 'when the service class does not exist' do

      let(:rpc_name) { 'SomethingFake#fake' }

      it 'should raise a NameError' do
        expect { subject }.to raise_error(NameError)
      end

    end

    context 'when the service class has the wrong superclass' do

      let(:rpc_name) { 'String#reverse' }

      it 'should raise a RuntimeError' do
        expect { subject }.to raise_error(RuntimeError, 'not a service class')
      end

    end

    context 'when the service class is a valid service' do

      context 'and the method struct does not exist on the service' do

        let(:rpc_name) { 'Greeter#say_bye' }

        it 'should raise a RuntimeError' do
          expect { subject }.to raise_error(RuntimeError, 'no corresponding rpc descriptor')
        end

      end

      context 'and the method struct exists on the service' do

        let(:rpc_name) { 'Greeter#say_hello' }

        it 'should return the proper method struct' do
          expect(subject).to eq(request ? Greeter::Request : Greeter::Response)
        end

        context 'when accessing a second time' do

          it 'should use a cached copy' do
            expect(subject).to eq(request ? Greeter::Request : Greeter::Response)
            expect(Rough::RpcRegistry.send(:methods)).to have_key("Greeter#say_hello")
          end

        end

      end

    end

  end

  describe '#request_class_for' do

    subject { Rough::RpcRegistry.request_class_for(rpc_name) }
    let(:request) { true }

    it_should_behave_like 'rpc_lookup'

  end

  describe '#response_class_for' do

    subject { Rough::RpcRegistry.response_class_for(rpc_name) }
    let(:request) { false }

    it_should_behave_like 'rpc_lookup'

  end

end
