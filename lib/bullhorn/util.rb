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
      def key_to_camel dto
        # camelcase and symbolize
        dto = Hash[dto.map {|k,v| [k.to_s.camelize(:lower).sub(/Id/, "ID").to_sym, v]}]
      end

      def key_to_snake dto
        # Snakecase and symbolize
        dto = Hash[dto.map {|k,v| [k.to_s.snakecase.to_sym, v]}]
      end

      def key_to_string dto
        dto = Hash[dto.map {|k,v| [k.to_s, v]}]
      end

      def key_to_symbol dto
        dto = Hash[dto.map {|k,v| [k.to_sym, v]}]
      end
    end
  end
end
