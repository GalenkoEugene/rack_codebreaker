require 'test/unit'
require 'rack/test'

 # testing racker.rb
 class TestRacker < Test::Unit::TestCase
   include Rack::Test::Methods
   OUTER_APP = Rack::Builder.parse_file('../config.ru').first

   def app
     OUTER_APP
   end

   def test_root
     get '/'
     assert last_response.ok?
     assert_equal 200, last_response.status
   end

   def test_unknown_path
     get '/weird_path_foo_bar'
     assert last_response.ok?
     assert_includes last_response.body, 'alt="Not Found"'
   end

   def test_win
     get '/win'
     assert_equal 200, last_response.status
     assert_includes last_response.body, 'You successfully guessed code'
   end

   def test_lost
     get '/lost'
     assert_equal 200, last_response.status
     assert_includes last_response.body, 'Unfortunately, you lost'
   end
 end
