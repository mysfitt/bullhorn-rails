class Array
  def page(pg, offset = 5)
    self[((pg-1)*offset)..((pg*offset)-1)]
  end
  
  def smaller_page(pg, offset = 5)
    self[((pg-1)*offset)..((pg*offset)-1)]
  end
end
