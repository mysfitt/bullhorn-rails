module Bullhorn

  class Files

    class << self

      #--------- Upload a new File and attach it to a Candidate (New) Returns new File Id
      def add file, entity_id=114755, entity_name="Candidate" 
        response = (Bullhorn::Client.add_file file_request(file, entity_name, entity_id)).body[:add_file_response][:return][:id]
        
      end
      
      #---------- Upload a replacement to a File attached to a Candidate (Udate)
      def update file, entity_id=114755, entity_name="Candidate" 
        Bullhorn::Client.update_file file_request(file)
      end
      
      #---------- Get list of all Files' meta data attached to a Candidate (Index)
      #---------- Returns:    :comments, :content_sub_type, :content_type, :id, :name, :type
      def get_entity_files entity_id = 114755, entity = "Candidate"
        response = (Bullhorn::Client.get_entity_files get_entity_files_request(entity_id, entity)).body[:get_entity_files_response][:return][:api_entity_metas]
      end  
      
      #---------- Get a File specified by its Id (Show) Returns File
      def get_file_by id, entity_id=114775, entity_name="Candidate" 
        (Bullhorn::Client.getFile get_file_request(id, entity_name, entity_id)).body[:get_file_response][:return][:file_data]
      end
      
      #---------- Delete all files for a Candidate
      def delete_all candidate_id
        (get_entity_files candidate_id).each do |file|
          Bullhorn::Client.api "deleteFile", delete_file_request(file, candidate_id)
        end  
      end
      
      
      
      ###--------- Find a Candidate by Email or create a new Candidate, 
      ###          then update Candidate fields with resume file and save
      def store file_by_candidate
        sum = []
        response = (Bullhorn::Candidates.query_by file_by_candidate[:email]) || Bullhorn::Candidates.default_candidate
        candidate = {
          :address => response[:address],
          :categoryID => response[:category_id],                            #integer
          :comments => response[:comments],   
          :email => response[:email],                         
          :employeeType => response[:employee_type],
          :firstName => response[:first_name],
          :isDeleted => response[:is_deleted],                               #boolean
          :isEditable => response[:is_editable],         #boolean
          :lastName => response[:last_name],
          :name => response[:name],
          :ownerID => response[:owner_id],               #integer
          :password => response[:password],
          :preferredContact => response[:preferred_contact],
          :status => response[:status],
          :username => response[:username], 
          :userTypeID => response[:user_type_id],         
          :isDayLightSavings => response[:is_day_light_savings],
          :massMailOptOut => response[:mass_mail_opt_out],
          :timeZoneOffsetEST => response[:time_zone_offset_est],
          :dayRate => response[:day_rate],
          :dayRateLow => response[:day_rate_low],
          :degreeList => response[:degree_list],
          :salary => response[:salary],
          :travelLimit => response[:travel_limit],
          :willRelocate => response[:will_relocate],
          :workAuthorized => response[:work_authorized],
      
          :attributes! => {
            :categoryID => {"xsi:type" => "xs:int"},
            :isDeleted => {"xsi:type" => "xs:boolean"},
            :isEditable => {"xsi:type" => "xs:boolean"},
            :ownerID => {"xsi:type" => "xs:int"},
            :userTypeID => {"xsi:type" => "xs:int"},
            :isDayLightSavings => {"xsi:type" => "xs:boolean"},
          }
        }
        file_by_candidate.each do |key, value|
          if (value.class != HashWithIndifferentAccess)
            candidate[key.to_s.camelize(:lower).to_sym] = value if (value && (value != ""))
          else
            value.each do |k, v|
              candidate[key.to_sym][k.to_sym] = v if (v != (nil || "" || " ")) 
            end    
          end  
        end
        
        ###--------- Clean up DTO
        candidate.delete(:attachment)
        if response.has_key?(:user_id)
          sum << "has id"
          sum << (candidate[:userID] = response[:user_id])
          candidate[:attributes!][:userID] = {"xsi:type" => "xs:int"}
        else  
          sum << "no id"
          candidate[:username] = candidate[:email]
          sum << candidate[:username]
          sum << candidate[:lastName]
          candidate[:password] = "hireminds766"
        end 
        [:"@xmlns:xsi", :"@xmlns:ns4", :"@xsi:type", :alerts].each do |key|
          candidate.delete(key)
        end  
        
        Bullhorn::Candidates.save candidate
        
        
        sum << candidate
      end  
      
      ###---------- Parse a Resume or return nil if parsing fails
      def parse resume
        request = {:base64ChunkedResume => resume}
        response = nil
        index = 15
        
        #--- Bullhorn's parseResume sometimes does't return the proper result.  Keep trying up to index times until captured
        while index > 0 do
          index -= 1
          response = (Bullhorn::Client.parse request).body[:parse_resume_response][:return][:hr_xml]
          return response if response
        end 
        nil
      end
        
   
    
      protected
      
      def delete_file_request file, entity_id, entity = "Candidate"
      {
        :entityName => entity,
        :entityId => entity_id.to_i,
        :fileId => file[:id],
        :attributes! => {
          :fileId => {"xsi:type" => "xsd:int"},
          :entityId => {"xsi:type" => "xsd:int"}
        }
      }
      end
      
      def get_file_request id, entity_name, entity_id
      {
        :entityName => entity_name,
        :entityId => entity_id,
        :fileId => id,
        :attributes! => { 
          :entity_Id => { "xsi:type" => "xsd:int" }, 
          :fileId => { "xsi:type" => "xsd:int" }
          }
      }
      end
      
      def file_request file, entity_name="Candidate", entity_id=114755
        puts file.to_json
        file_type, subtype = file[:content_type].to_s.split('/')
        {          
          :fileMetaData => {
            :comments => "Uploaded file",
            :contentSubType => subtype,
            :contentType => file_type,
            :name => file[:filename],
            :type => "Resume",
            },
          :fileContent => Base64.encode64(file[:document]),
          :entityName => entity_name,
          :entityId => entity_id,
          :attributes! => { :entityId => {"xsi:type" => "xsd:int"}}
        }
      end
      
      def get_entity_files_request entity_id, entity
      {
        :entityName => entity,
        :entityId => entity_id,
        :attributes! => { :entityId => {"xsi:type" => "xsd:int"}}
      }
      end
      
      def save_request file
      {
        :dto => file,
        :attributes! => {
          :dto => {
            "xsi:type"=>"ns4:fileDto", 
            "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", 
            "xmlns:ns4"=>"http://file.entity.bullhorn.com/"
          }
        }
      }  
      end
     
    end
  end
end
