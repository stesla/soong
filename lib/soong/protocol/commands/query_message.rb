require 'soong/protocol/commands/private_message'

module Soong
  module Protocol
    class QueryMessage < PrivateMessage
      concrete

      class QuerySource < Protocol::Source
        def reply_to() from end
      end

      def source_klass() QuerySource end
    end
  end
end
