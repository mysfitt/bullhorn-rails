module Bullhorn

  class Candidates

    class << self

      ###---------------- Find a Candidate by Id
      def find_by id
        (select_fields results(Bullhorn::Client.findMultiple find_multiple_request([id]))).first  
      end
    
      
      ###---------------- Find an array of Candidates by an array of Ids
      def find_multiple_by ids
        candidates = []
        index = 1
        while ids.page(index) != nil
          candidate_detail_response = Bullhorn::Client.findMultiple candidate_detail_request(ids.page(index))
          details = get_candidate_details_from(candidate_detail_response)
          
          details = [details] if !(details.class == Array)
          select_fields resultsdetails
          index += 1
        end
        candidates
      end   
      
      ###----------------- Find a Candidate by Email
      ###                  returns Candidate dto, or nil if not found
      def query_by email
        request = candidate_query_request
        request[:query][:where] = "email='" + email + "'"
        response=(Bullhorn::Client.query request).body[:query_response][:return]
        find_by response[:ids] if response.has_key?(:ids)
      end  
      
      ###----------------- Find a Candidate using a query string
      def query_where conditions
        candidate_query_request[:query][:where] = conditions
        response=(Bullhorn::Client.query candidate_query_request).body[:query_response][:return]
        find_by response[:ids] if response.has_key?(:ids)
      end  
      
      
      ###----------------- Gets first qty of Ids, for testing purposes  
      def get_ids qty
        get_id_response qty
      end  
      
      ###----------------- Gets first qty of Ids, for testing purposes
      def get_id_response qty
        request = candidate_query_request
        request[:query][:maxResults] = qty if qty
        response = (Bullhorn::Client.query request).body[:query_response][:return][:ids]
        response
      end
      
      ###------------------- Save Candidate
      def save candidate
        request = save_request(candidate)
        (Bullhorn::Client.save request).body[:save_response]
      end  
      
      def default_candidate  
      {
        :address => {
          :address1 => "",
          :address2 => "",
          :city => "",
          :state => "",
          :countryID => 1,
          :zip => ""
          },
        :category_id => 45,                            #integer
        :comments => "",   
        :email => "",                         
        :employee_type => "",
        :first_name => "",
        :is_deleted => 0,                               #boolean
        :is_editable => 1,         #boolean
        :last_name => "",
        :name => "",
        :owner_id => 43832,               #integer
        :password => "hireminds123",
        :preferred_contact => "",
        :status => "",
        :username => "",
        :user_type_id => 35,  
        :is_day_light_savings => true,
        :mass_mail_opt_out => false,
        :time_zone_offset_est => 0,
        :day_rate => 0,
        :day_rate_low => 0,
        :degree_list => "",
        :salary => 0,
        :travel_limit => 0,
        :will_relocate => false,
        :work_authorized => true,
      }  
      end

      def candidate_create_request dto
        candidate =
        {
          :address => {
            :address1 => @address1,
            :address2 => @address2,
            :city => @city,
            :state => @state,
            :countryID => 1,
            :zip => @zip
            },
          :categoryID => 45,
          :comments => "",   
          :email => @email,
          :phone => @phone,                         
          :employeeType => "W2",
          :firstName => @firstname,
          :isDeleted => false,
          :isEditable => true,
          :lastName => @lastname,
          :name => "#{@firstname} #{@lastname}",
          :ownerID => 43832,
          :password => "hireminds123",
          :preferredContact => "Email",
          :status => "New Lead",
          :username => @email,
          :userTypeID => 35,  
          :isDayLightSavings => true,
          :massMailOptOut => false,
          :timeZoneOffsetEST => 0,
          :dayRate => 0.0,
          :dayRateLow => 0.0,
          :degreeList => "",
          :salary => @salary,
          :travelLimit => 0,
          :willRelocate => false,
          :workAuthorized => true,
          :attributes! => { 
            :categoryID => {"xsi:type" => "xsd:int"},
            :ownerID => {"xsi:type" => "xsd:int"},
            :isDeleted => {"xsi:type" => "xs:boolean"},
            :isEditable => {"xsi:type" => "xs:boolean"},
            :isDayLightSavings => {"xsi:type" => "xs:boolean"},
            :massMailOptOut => {"xsi:type" => "xs:boolean"},
            :userTypeID => {"xsi:type" => "xsd:int"},
            :timeZoneOffsetEST => {"xsi:type" => "xsd:int"},
            :dayRate => {"xsi:type" => "xsd:decimal"},
            :dayRateLow => {"xsi:type" => "xsd:decimal"},
            :salary => {"xsi:type" => "xsd:decimal"},
            :travelLimit => {"xsi:type" => "xsd:int"},
            :willRelocate => {"xsi:type" => "xs:boolean"},
            :workAuthorized => {"xsi:type" => "xs:boolean"},
          }
        }

        # Snakecase for the merge
        candidate = Hash[candidate.map {|k,v| [k.to_s.snakecase.to_sym, v]}]
        candidate = dto.merge(candidate)

        if candidate.has_key?(:user_id)
          candidate[:userID] = candidate[:user_id]
          candidate[:attributes!][:userID] = {"xsi:type" => "xs:int"}
        else
          candidate[:username] = @email
          candidate[:password] = "hireminds766"
        end 
        [:"@xmlns:xsi", :"@xmlns:ns4", :"@xsi:type", :"alerts", :"copy", :"category"].each do |key|
          candidate.delete(key)
        end

        # Camelcase for the SOAP request. Upcase Id to ID
        candidate = Bullhorn::Util.to_camel candidate
      end
         
      protected
      
      def results response
        response.body[:find_multiple_response][:return][:dtos]
      end  
      
      def api operation, body
        Bullhorn::Client.api operation, body
      end
      
      def select_fields response
        candidates = []
        response = [response] if !(response.kind_of?(Array))
        response.each do |dto|
          candidate = dto                        
          candidates << candidate
        end 
        candidates 
      end
      
      def find_candidate_request id
      {
        :entity => 'Candidate',
        :id => id,
        :attributes! => { :id => {"xsi:type" => "xsd:int"}}
      }
      end
      
      def find_multiple_request page_of_ids
      {
        :entityName => "Candidate",
        :ids => page_of_ids,
        :attributes! => { :ids => { "xsi:type" => "xsd:int" } }
      }
      end
      
      def candidate_query_request 
        {:query => {:entityName => "Candidate", :maxResults => 10}} 
      end
      
      def save_request candidate
      {
        :dto => candidate,
        :attributes! => {
          :dto => {
            "xsi:type"=>"ns4:candidateDto", 
            "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", 
            "xmlns:ns4"=>"http://candidate.entity.bullhorn.com/"
          }
        }
      }  
      end
      
      def clean_up response
       response
      end
    
    #----------------------------------------------------

    end
  end
end
