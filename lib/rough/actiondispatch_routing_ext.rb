module ActionDispatch
  module Routing
    class Mapper
      # Define a rough endpoint.
      #
      # @param [Class] service the GRPC service
      # @param [Symbol] rpc the RPC name
      # @param [String] action in usual 'controller#action' format
      # @param [Hash] options options will be passed directly to `post` as options, except:
      #               :path which overrides the auto-generated HTTP path for the rpc endpoint
      #
      def rough(service, rpc, action, options = {})
        options = options.dup
        raise 'service is not a grpc service class' unless service::Service.include?(GRPC::GenericService)
        raise 'service does contain a #{rpc} rpc' unless service::Service.rpc_descs.include?(rpc)

        path = options.delete(:path) || "#{service.to_s.gsub('::', '.')}/#{rpc.to_s}"

        post path, options.merge(rpc: "#{service.to_s}##{rpc.to_s}", to: action)
      end
    end
  end
end