class Array
  def page(pg, offset = 5)
    self[((pg-1)*offset)..((pg*offset)-1)]
  end
  
  def smaller_page(pg, offset = 5)
    self[((pg-1)*offset)..((pg*offset)-1)]
  end
end

module Bullhorn
  class Util
    class << self
      def to_camel dto
        # camelcase and symbolize
        dto = Hash[dto.map {|k,v| [k.to_s.camelize.sub(/Id/, "ID").to_sym, v]}]
      end

      def to_snake dto
        # Snakecase and symbolize
        dto = Hash[dto.map {|k,v| [k.to_s.snakecase.to_sym, v]}]
      end
    end
  end
end
