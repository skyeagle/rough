require 'grpc'

module Rough

  module RpcRegistry

    class << self

      def request_class_for(rpc_name)
        rpc_desc_for(rpc_name).input
      end

      def response_class_for(rpc_name)
        rpc_desc_for(rpc_name).output
      end

      def marshall_method_for(rpc_name)
        rpc_desc_for(rpc_name).marshal_method
      end

      def unmarshall_method_for(rpc_name)
        rpc_desc_for(rpc_name).unmarshal_method
      end

      private

      def rpc_desc_for(rpc_name)
        return methods[rpc_name] if methods.key?(rpc_name)

        # TODO: in the future, should you be able to pass in a Rpc::Service, or separate rpc_name and method_names?
        service_name, method_name = rpc_name.split('#')

        service_class = service_name.constantize
        fail 'not a service class' if rpc_service?(service_class)

        rpc_desc = service_class::Service.rpc_descs[method_name.to_sym]
        fail 'no corresponding rpc descriptor' unless rpc_desc

        methods[rpc_name] = rpc_desc
      end

      def methods
        @methods ||= {}
      end

      def rpc_service?(klass)
        !klass.const_defined?("Service") || !klass::Service.include?(GRPC::GenericService)
      end
    end
  end
end
