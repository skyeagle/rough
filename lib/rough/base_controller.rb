require_relative 'rpc_registry'
require_relative 'invalid_request_proto'
require 'action_dispatch'

module Rough

  module BaseController

    PROTO_MIME = Mime::Type.new('application/x-protobuf')

    def self.included(base)
      base.class_eval do
        before_filter :log_proto, if: :rpc?
      end
    end

    def default_render(*args)
      if rpc?
        if request.accept == PROTO_MIME || request.content_type == PROTO_MIME
          response.headers['Content-Type'] = PROTO_MIME.to_s
          render text: response_class.encode(response_proto)
        else
          render json: response_class.encode_json(response_proto)
        end
      else
        super(*args)
      end
    end

    def request_proto
      return nil unless rpc?
      @request_proto ||=
        if request.content_type == PROTO_MIME
          request_class.decode(request.body.read)
        else
          request_class.decode_json(request.body.read)
        end
    rescue Google::Protobuf::ParseError => e
      raise InvalidRequestProto, e
    end

    def response_proto
      return nil unless rpc?
      @response_proto ||= response_class.new
    end

    private

    def rpc?
      rpc_name
    end

    def request_class
      RpcRegistry.request_class_for(rpc_name)
    end

    def response_class
      RpcRegistry.response_class_for(rpc_name)
    end

    def log_proto
      Rails.logger.info("  Request Proto: #{request_proto.inspect}")
    end

    def rpc_name
      params[:rpc]
    end

  end

end
