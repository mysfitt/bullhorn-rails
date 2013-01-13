module Bullhorn

  class Core

    class << self
      
      attr_writer :username, :password, :apiKey
      
      def add_file params={}
        (api "addFile", add_file_request(params)).body[:add_file_repsonse][:return]
      end
      
      def add_note_reference params={}
      end
      
      def associate params={}
      end
      
      def associate_multiple params={}
      end
      
      def delete params={}
      end
      
      def delete_by_i_d params={}
      end
      
      def delete_file params={}
      end
      
      def events_count params={}
      end
      
      def events_get_events params={}
      end
      
      def events_get_last_request_id params={} 
      end
      
      def events_reget_events params={}
      end
      
      def events_subscribe params={}
      end
      
      def events_unsubscribe params={}
      end
      
      def find params={}
        (api "find", find_request(params)).body[:find_response][:return]
      end
      
      def find_multiple params={}
        (api "findMultiple", find_multiple_request(entity_name, ids)).body[:find_multiple_response][:return]
      end
      
      def get_association_i_ds 
      end
      
      def get_certifications 
      end
      
      def get_client_corporation_template_data 
      end
      
      def get_client_corporation_template_data_ids 
      end
      
      def get_client_corporation_template_ids 
      end
      
      def get_client_corporation_template_metadata 
      end
      
      def get_department_user_ids 
      end
      
      def get_entity_files entity_name, ids
        (api "getEntityFiles", get_entity_files_request(entity_name, ids)).body[:get_entity_files_response][:return]
      end
      
      def get_entity_metadata 
      end
      
      def get_entity_notes 
      end
      
      def get_entity_notes_where 
      end
      
      def get_file entity_name, entity_id, file_id
        (api "getFile", get_file_request(entity_name, entity_id, file_id)).body[:get_file_response][:return]
      end
      
      def get_edit_history 
      end
      
      def get_edit_history_by_dates 
      end
      
      def get_edit_history_by_transaction_id 
      end
      
      def get_job_order_metadata 
      end
      
      def get_job_order_template_data 
      end
      
      def get_job_order_template_data_ids 
      end
      
      def get_job_order_template_ids 
      end
      
      def get_job_order_template_metadata 
      end
      
      def get_note_references 
      end
      
      def get_user_department_ids 
      end
      
      def get_user_primary_department_id 
      end
      
      def get_user_template_data 
      end
      
      def get_user_template_data_ids 
      end
      
      def get_user_template_ids 
      end
      
      def get_user_template_metadata 
      end
      
      def get_user_types 
      end
      
      def parse_resume base_64_chunked_resume
        (api "parseResume", parse_resume_request(base_64_chunked_resume)).body[:parse_resume_response][:return]
      end
      
      def query dto
      end
      
      def remove_note_reference
      end
      
      def save 
      end
      
      def start_partner_session 
      end
      
      def start_session 
      end
      
      def unassociate 
      end
      
      def unassociate_multiple 
      end
      
      def update_file 
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
