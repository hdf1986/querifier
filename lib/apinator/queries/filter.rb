module Apinator
  module Queries
    module Filter
      FILTER_ATTRIBUTES = [].freeze

      def collection
        super
        filter
        @collection
      end

      def filter
        return self if @filtered
        self.class::FILTER_ATTRIBUTES.each do |attribute|
          filter_content = filter_value(attribute)
          send("filter_by_#{attribute}", filter_content) if filter_content
        end
        @filtered = true
        self
      end

      def filter_value(key)
        filter_params.fetch(key.to_sym, nil)
      end

      def filter_by(name)
        filter_content = filter_value(name)
        @collection = @collection.where("#{name} LIKE ?", "%#{filter_content}%") if filter_content
        self
      end

      def method_missing(message, *args, &block)
        return filter_by(Regexp.last_match(1).to_sym) if message.to_s =~ /filter_by_(.*)/ # rubocop:disable Performance/RegexpMatch, Metrics/LineLength
        super
      end

      def filter_params
        @filter_params ||= params.fetch(:where, {}) #TODO: unhardcode where
      end
    end
  end
end
