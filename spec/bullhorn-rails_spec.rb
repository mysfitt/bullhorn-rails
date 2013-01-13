require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

 
describe "BullhornRails" do
  
  description1 = "--- can create Bullhorn::API objects"
  it description1 do
    bh = Bullhorn::API.new
    bh.request = "req"
    b2 = Bullhorn::API.new
  end
  
  
  
  description3 = "--- can make a method out of nothing"
  it description3 do
    bh = Bullhorn::API.new
    bh.username = '525.resumes'
    bh.password = 'scrub04k'
    bh.id = 999
    bh.apiKey   = '943C63E3-FB1A-4089-A3813849B9626393'
    puts bh.find(:id => 114755)
    puts bh.post.inspect[0..10000]
    puts bh.connection
    puts
  end
end
