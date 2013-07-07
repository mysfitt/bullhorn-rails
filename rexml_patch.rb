class REXML::Document
  @@entity_expansion_text_limit = 100_240

  def self.entity_expansion_text_limit=( val )
    @@entity_expansion_text_limit = val
  end

  def self.entity_expansion_text_limit
    @@entity_expansion_text_limit
  end
end

class REXML::Text
  def self.unnormalize(string, doctype=nil, filter=nil, illegal=nil)
    sum = 0
    string.gsub( /\r\n?/, "\n" ).gsub( REFERENCE ) {
      s = self.expand($&, doctype, filter)
      if sum + s.bytesize > REXML::Document.entity_expansion_text_limit
        raise "entity expansion has grown too large"
      else
        sum += s.bytesize
      end
      s
    }
  end

  def self.expand(ref, doctype, filter)
    if ref[1] == ?#
      if ref[2] == ?x
        [ref[3...-1].to_i(16)].pack('U*')
      else
        [ref[2...-1].to_i].pack('U*')
      end
    elsif ref == '&amp;'
      '&'
    elsif filter and filter.include?( ref[1...-1] )
      ref
    elsif doctype
      doctype.entity( ref[1...-1] ) or ref
    else
      entity_value = DocType::DEFAULT_ENTITIES[ ref[1...-1] ]
      entity_value ? entity_value.value : ref
    end
  end
end