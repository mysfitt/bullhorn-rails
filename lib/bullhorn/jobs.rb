module Bullhorn

  class Jobs

    class << self

      # Get all Jobs
      def all
        response = Bullhorn::Client.query open_approved_job_id_request
        ids = get_ids_from response
        get_jobs_from ids
      end
      
      def all_where where
        response = Bullhorn::Client.query where
        ids = get_ids_from response
        get_jobs_from ids
      end
      
      # Get Job Description Array from Id Array 
      def fetch_job_descriptions job_ids
        get_jobs_from job_ids
      end  
      
      def fetch_job_description job_id
        get_job_from job_id
      end  
      
      # Get Nested Hash of Category ID's by Job ID
      def fetch_category_ids_from_job_ids job_ids
        get_category_ids_from_job_ids job_ids
      end  
      
      def subscribe
        Bullhorn::Client.eventsSubscribe subscribe_request #[:body][:subscription_meta_data]
      end
      
      def unsubscribe
        (Bullhorn::Client.eventsUnsubscribe unsubscribe_request).body[:events_unsubscribe_response][:return][:unsubscribed]
      end
      
      def new_events
        event_response = (Bullhorn::Client.eventsGetEvents get_events_request).body[:events_get_events_response][:return][:results]
        if event_response
          if event_response[:events].kind_of?(Array)
            event_response[:events]
          else
            return [event_response[:events]]
          end
        else
          puts "NO EVENTS?"
        end  
      end  

      protected
      
      def all_jobs_query
        { :query => { :entityName => "JobOrder", :where => "(dateAdded >= '#{1.year.ago.to_formatted_s(:db)}' OR isOpen=1)" } }
      end

      def open_approved_job_id_request 
        { :query => { :entityName => "JobOrder", :where => "isOpen=1 AND isPublic=1 AND (status='Accepting Candidates' OR status='Website Only')"} }
      end
      
      def get_category_ids_from_job_ids job_ids
        responses = []
        job_ids.each do |job_id|
          job_id_response = Bullhorn::Client.getAssociationIds category_ids_from_job_id_request(job_id)
          responses << {job_id => job_id_response.body[:get_association_ids_response][:return][:ids]}
        end  
        responses
      end
      
      def get_events_request
        {
          :subscriptionId => "JobOrderEventAllEvents",
          :max_events => 20
        }
      end  
      
      def subscribe_request
        {
          :subscriptionId => "JobOrderEventAllEvents",
          :criteria => {
              :entityNames => "JobOrder",
              :entityEventTypes => ["INSERTED","UPDATED","DELETED"]
            },
          :attributes! => {
              :criteria => {
                  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                  "xmlns:ns4" => "http://subscription.dataevent.bullhorn.com/",
                  "xsi:type" => "ns4:entityEventSubscriptionCriteria"
                }
            }
        }
      end
      
      def unsubscribe_request
        {
          :subscriptionId => "JobOrderEventAllEvents"
        }
      end
      
      def category_ids_from_job_id_request job_id
        {
          :entityName => "JobOrder",
          :id => job_id,
          :attributes! => { :id => {"xsi:type" => "xsd:int"}},
          :associationName => "categories"
          }
      end
      
      def job_detail_request page_of_ids
        {
          :entityName => "JobOrder",
          :ids => page_of_ids,
          :attributes! => { :ids => { "xsi:type" => "xsd:int" } }
        }
      end

      def get_ids_from response
        response[:query_response][:return][:ids]
      end
      
      def job_detail job
        {
          :id => job[:job_order_id].to_i,
          :title => job[:title], 
          :years => job[:years_required], 
          :added => job[:date_added],
          :description => remove_html(job[:public_description]),
          :site => job[:on_site],
          :employment => job[:employment_type],
          :status => job[:status],
          :is_open => job[:is_open],
          :is_public => job[:is_public]
        }
      end

      def get_job_details_from page_of_job_results
        page = page_of_job_results[:find_multiple_response][:return][:dtos]
        
      end
      
      def remove_html html 
        html
        
      end
      
      def get_job_from id
        job_detail_response = Bullhorn::Client.findMultiple job_detail_request([id])
        job_detail(get_job_details_from(job_detail_response))
      end
      
      def get_jobs_from ids
        jobs = []
        index = 1
        while ids.page(index) != nil
          job_detail_response = Bullhorn::Client.findMultiple job_detail_request(ids.page(index))
          details = get_job_details_from(job_detail_response)
          
          details = [details] if !(details.class == Array)
          puts details
          details.each do |job|
            puts job.inspect
            jobs << job_detail(job) 
          end 
          
          index += 1
        end
        
        
        
        jobs
      end
    end
  end
end
