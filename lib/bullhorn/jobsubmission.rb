module Bullhorn
  class JobSubmission
    class << self
      # Job Submission API methods

      def associate job_id, email
        response = Bullhorn::Client.api "associate", job_submission_association_request(job_id, email)
        response.body
      end

      def create_job_app resume, job_id
        # get a fresh session. It can take a long time to type all that in.
        @session = Bullhorn::Client.new_connection
        # Capture all the nice data we got from the Resume form/controller.
        @job_id = job_id
        @email = resume[:email]
        @phone = resume[:phone]
        @salary = resume[:salary]
        @firstname = resume[:first_name] || "New"
        @lastname = resume[:last_name] || "Candidate"
        @address1 = resume[:address][:address1]
        @address2 = resume[:address][:address2]
        @city = resume[:address][:city]
        @state = resume[:address][:state]
        @country = resume[:address][:country]
        @zip = resume[:address][:zip]

        request = job_submission_create_request(@job_id, @email)
        response = Bullhorn::Client.api "save", save_request(request)
        response.body[:save_response][:return][:dto][:job_submission_id]
      end

      def create_candidate candidate
        response = (Bullhorn::Candidates.save candidate)
        response[:return][:dto]
      end

      def find_or_create job_id, email
        response = Bullhorn::Candidates.query_by email
        unless !response.nil? && response.has_key?(:user_id)
          new_candidate = Bullhorn::Candidates.default_candidate
          response = create_candidate(candidate_create_request(new_candidate, email))
        end
        response[:user_id]
      end

      # Convienience methods to format SOAP bodies
      protected

        def save_request request
          {
            :dto => request,
            :attributes! => {
              :dto => {
                "xsi:type"=>"ns1:jobSubmissionDto", 
                "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", 
                "xmlns:ns1"=>"http://job.entity.bullhorn.com/"
              }
            }
          }
        end

        def job_submission_association_request job_id, email
          {
            :entityName => "JobOrder",
            :id => job_id,
            :associationName => "submissions",
            :associateId => create_job_app(job_id, email),
            :attributes! => { 
              :id => {"xsi:type" => "xsd:int"}, 
              :associateIds => {"xsi:type" => "xsd:int"}
            }
          }
        end

        def job_submission_create_request job_id, email
          candidate_id = find_or_create(job_id, email)
          {
            :candidateID => candidate_id,
            :jobOrderID => job_id,
            :isDeleted => false,
            :sendingUserID => "43832",  # corporate user ID for HireMinds
            :source => "Web",
            :status => "New Lead",
            :attributes! => { 
              :candidateID => {"xsi:type" => "xsd:int"},
              :jobOrderID => {"xsi:type" => "xsd:int"},
              :isDeleted => {"xsi:type" => "xs:boolean"},
              :sendingUserID => {"xsi:type" => "xsd:int"}
            }
          }
        end

        def candidate_create_request dto, email
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
            candidate[:username] = email
            candidate[:password] = "hireminds766"
          end 
          [:"@xmlns:xsi", :"@xmlns:ns4", :"@xsi:type", :alerts].each do |key|
            candidate.delete(key)
          end

          # Camelcase for the SOAP request. Upcase Id to ID
          candidate = Hash[candidate.map {|k,v| [k.to_s.camelize.sub(/Id/, "ID").to_sym, v]}]
        end

    end
  end
end
