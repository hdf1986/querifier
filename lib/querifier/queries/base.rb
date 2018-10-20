module Querifier
  module Queries
    module Base
      def initialize(params)
        @params = params
        check_params!
      end

      def collection
        @collection ||= self.class.entity_class.all
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def params
        @params.fetch(Config.filter_param, {})
      end

      module ClassMethods
        def entity_class(value = nil)
          return entity_class = value unless value.nil?
          @@entity_class ||= Object.const_get self.name.split('::').last.split('Query').first
        end

        def entity_class=(value)
          @@entity_class = value
        end
      end

      private

      def check_params!
        return if @params.respond_to?(:keys) && @params.respond_to?(:has_key?)
        raise ArgumentError, "The params should extend of a hash, instead, they are a #{@params.class}" # rubocop:disable Metrics/LineLength
      end
    end
  end
end
