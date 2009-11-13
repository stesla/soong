module Soong
  module Protocol
    class Source
      def initialize(protocol, from, to)
        @protocol = protocol
        @from = from
        @to = to
      end

      def puts(msg)
        @protocol.private_message reply_to, msg
      end

      protected

      attr_reader :from, :to
      def after_initialize; end
      def reply_to; end
    end
  end
end
