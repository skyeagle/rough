require_relative 'rpc_registry'
require_relative 'invalid_request_proto'
require 'action_dispatch'

module Rough

  module BaseController

    PROTO_MIME = Mime::Type.new('application/x-protobuf')
    JSON_MIME = Mime::Type.new('application/json')

    def self.included(base)
      base.class_eval do
        before_action :log_proto, if: :rpc?
      end
    end

    def default_render(*args)
      if rpc?
        if request.accept == PROTO_MIME || request.content_type == PROTO_MIME
          response.headers['Content-Type'] = PROTO_MIME.to_s
          render body: RpcRegistry.response_class_for(rpc_name).send(RpcRegistry.marshall_method_for(rpc_name), response_proto)
        else
          render json: RpcRegistry.response_class_for(rpc_name).encode_json(response_proto)
        end
      else
        super(*args)
      end
    end

    def request_proto
      return nil unless rpc?
      @request_proto ||=
        if request.content_type == PROTO_MIME
          RpcRegistry.request_class_for(rpc_name).send(RpcRegistry.unmarshall_method_for(rpc_name), request.body.read)
        elsif request.content_type == JSON_MIME
          RpcRegistry.request_class_for(rpc_name).decode_json(request.body.read)
        end
    rescue Google::Protobuf::ParseError => e
      raise InvalidRequestProto, e
    end

    def response_proto
      return nil unless rpc?
      @response_proto ||= RpcRegistry.response_class_for(rpc_name).new
    end

    private

    def rpc?
      rpc_name
    end

    def log_proto
      Rails.logger.info("  Request Proto: #{request_proto.inspect}")
    end

    def rpc_name
      params[:rpc]
    end

  end

end
