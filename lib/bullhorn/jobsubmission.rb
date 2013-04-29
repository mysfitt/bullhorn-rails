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
          response = create_candidate(Bullhorn::Candidates.candidate_create_request(new_candidate, email))
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

        

    end
  end
end
