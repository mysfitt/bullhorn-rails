module Bullhorn

  class API
    attr_reader :response, :body
    attr_writer :username, :password, :apiKey
    attr_accessor :request, :operation
   

  ###------------ Create Bullhorn Core Operation Methods
  #               and Attribute Accessors
    {                                                             #request structure      
      :find =>                                                      #operation
        :entityName => "Candidate",                                   #attribute
        :id => nil,                                                   #attribute
        :attributes! => {:id => {"xsi:type" => "xsd:int"}}            #attribute types
      },
      :findMultiple => {
        :entityName => "JobOrder",
        :ids => [],
        :paged => true,
        :attributes! => {:ids => {"xsi:type" => "xsd:int"}}
      }
    }.each do |operation, attributes|                             #iterate over all operations
      attr_accessor *(attributes.keys.delete_if {|attr| attr == :attributes!})    #create attribute accessors
      define_method(operation) do |input|                                         #create operation methods
        @request = attributes.merge(input)
        @operation = operation
        self                                                                      #methods return self
      end    
    end
    
  ###------------- Post request to Bullhorn
  #                returns self    
    
    def post          
      client = connection
      session = @session
      request = @request
      @response = (client.request @operation.to_sym do
        request[:session] = session
        soap.body = request
      end).body[(@operation.to_s + "_response").to_sym][:return].delete_if {|key| key == :session}  
      self
    end
    
    private
    
  ###------------- Savon Soap Connection    
    
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
