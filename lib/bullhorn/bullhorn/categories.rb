module Bullhorn

  class Categories

    class << self

      def all
        response = Bullhorn::Client.query category_id_request
        ids = get_ids_from response
        get_category_names_from ids
      end

      protected

      def category_id_request
        { :query => { :entityName => "Category" } }
      end

      def category_detail_request page_of_ids
        {
          :entityName => "Category",
          :ids => page_of_ids,
          :attributes! => { :ids => { "xsi:type" => "xsd:int" } }
        }
      end

      def get_ids_from response
        response[:query_response][:return][:ids]
      end

      def get_category_details_from page_of_category_results
        page_of_category_results[:find_multiple_response][:return][:dtos]
      end

      def get_category_names_from ids
        categories = []
        index = 1

        while ids.page(index) != nil
          category_detail_response = Bullhorn::Client.findMultiple category_detail_request(ids.page(index))

          get_category_details_from(category_detail_response).each { |c| categories << {:id => c[:category_id], :name => c[:name].titleize} }

          index += 1
        end

        categories
      end      
    end
  end
end
