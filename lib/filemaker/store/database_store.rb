module Filemaker
  module Store
    class DatabaseStore < Hash
      def initialize(server)
        @server = server
      end

      def [](name)
        super || self[name] = Filemaker::Database.new(name, @server)
      end

      def all
        params = { '-dbnames' => '' }
        response = @server.perform_request(:get, params)
        resultset = Filemaker::Resultset.new(@server, response.body)
        resultset.map do |record|
          record['DATABASE_NAME']
        end
      end
    end
  end
end
