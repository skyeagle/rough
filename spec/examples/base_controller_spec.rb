require 'spec_helper'
require 'action_controller'

describe TestController, type: :request do

  context 'when the route is rpc' do

    let(:request_msg) { Greeter::Request.new(name: 'John') }
    let(:response_msg) { Greeter::Response.new(message: 'Hello John!') }

    context 'and called over json' do

      before do
        allow(Rails.logger).to receive(:info)
        post '/test-rpc', {
          name: 'John'
        }.to_json, 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'
      end

      it 'should pass back the response status' do
        expect(response.status).to eq(200)
      end

      it 'should respond with json' do
        expect(response.content_type).to eq('application/json')
      end

      it 'should log the request proto' do
        expect(Rails.logger).to have_received(:info).with(%Q(  Request Proto: <Greeter::Request: name: "John">))
      end

      it 'should return the encoding' do
        expect(Greeter::Response.decode_json(response.body)).to eq(response_msg)
      end

    end

    context 'and called over proto' do

      let(:mime) { Rough::BaseController::PROTO_MIME.to_s }

      before do
        allow(Rails.logger).to receive(:info)
        post '/test-rpc', Greeter::Request.encode(request_msg), 'CONTENT_TYPE' => mime, 'ACCEPT' => mime
      end

      it 'should pass back the underlying status' do
        expect(response.status).to eq(200)
      end

      it 'should return the encoding' do
        expect(Greeter::Response.decode(response.body)).to eq(response_msg)
      end

      it 'should respond with proto' do
        expect(response.content_type).to eq(mime)
      end
    end

    context 'when there is a type error while decoding' do

      before do
      end

      it 'should raise InvalidRequestProto' do
        expect { post '/test-rpc', 'bad json' }.to raise_error(Rough::InvalidRequestProto)
      end

    end

  end

end
