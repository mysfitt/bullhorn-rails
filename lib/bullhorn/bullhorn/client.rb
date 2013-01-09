module Bullhorn

  class Client

    class NoCredentials < StandardError; end

    class << self
      
      attr_writer :username, :password, :apiKey
      
      def api operation, body
        client = connection
        session = @session
        client.request :tns, operation.to_sym do
          body[:session] = session
          soap.body = body
        end
      end
      
      def get_entity_files body
        client = connection
        session = @session
        client.request :tns, :getEntityFiles do
          body[:session] = session
          soap.body = body
        end
      end    
      
      def parse body
        client = connection
        session = @session
        client.request :tns, :parseResume do
          body[:session] = session
          soap.body = body
        end
      end
      
      def add_file body
        client = connection
        session = @session
        client.request :tns, :addFile do
          body[:session] = session
          soap.body = body
        end
      end    
      
      def update_file body
        client = connection
        session = @session
        client.request :tns, :updateFile do
          body[:session] = session
          soap.body = body
        end
      end  
      
      def findCandidate body
        client = connection
        session = @session
        client.request :findCandidate do
          body[:session] = session
          soap.body = body
        end
      end
      
      def save body
        client = connection
        session = @session
        client.request :save do
          body[:session] = session
          soap.body = body
        end
      end
      
      def query body
        client = connection
        session = @session
        client.request :query do
          body[:session] = session
          soap.body = body
        end
      end
      
      def getFile body
        client = connection
        session = @session
        client.request :tns, :getFile do
          body[:session] = session
          soap.body = body
        end
      end

      def findMultiple body
        client = connection
        session = @session
        client.request :tns, :findMultiple do
          body[:session] = session
          soap.body = body
        end
      end
      
      def getAssociationIds body
        client = connection
        session = @session
        client.request :tns, :getAssociationIds do
          body[:session] = session
          soap.body = body
        end
      end
      
      def eventsSubscribe body
        client = connection
        session = @session
        client.request :tns, :eventsSubscribe do
          body[:session] = session
          soap.body = body
        end
      end    
          
      def eventsUnsubscribe body
        client = connection
        session = @session
        client.request :tns, :eventsUnsubscribe do
          body[:session] = session
          soap.body = body 
        end
       end
          
       def eventsGetEvents body
        client = connection
        session = @session
        client.request :tns, :eventsGetEvents do
          body[:session] = session
          soap.body = body
        end
      end    
      
      

      def connection

        raise NoCredentials if @username.nil?
        raise NoCredentials if @password.nil?
        raise NoCredentials if @apiKey.nil?

        @connection ||= new_connection
      end

      def new_connection
        @connection = Savon.client "https://api.bullhornstaffing.com/webservices-2.5/?wsdl"
        authenticate
      end

      def authenticate
        username = @username
        password = @password
        apiKey = @apiKey
        response = @connection.request :start_session do
          soap.body = {
            :username => username, 
            :password => password,
            :apiKey => apiKey
          }
        end

        @session = response.body[:start_session_response][:return][:session]
        @connection
      end

      def clear_connection
        @connection = nil
      end
    end
  end
end
