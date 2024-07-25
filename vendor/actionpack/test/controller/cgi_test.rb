$:.unshift(File.dirname(__FILE__) + '/../../lib')

require 'test/unit'
require 'action_controller/cgi_ext/cgi_methods'
require 'stringio'

class MockUploadedFile < StringIO
  def content_type
    "img/jpeg"
  end

  def original_filename
    "my_file.doc"
  end
end

class CGITest < Test::Unit::TestCase
  def setup
    @query_string = "action=create_customer&full_name=David%20Heinemeier%20Hansson&customerId=1"
    @query_string_with_nil = "action=create_customer&full_name="
    @query_string_with_multiple_of_same_name = 
      "action=update_order&full_name=Lau%20Taarnskov&products=4&products=2&products=3"
  end

  def test_query_string
    assert_equal(
      { "action" => "create_customer", "full_name" => "David Heinemeier Hansson", "customerId" => "1"},
      CGIMethods.parse_query_parameters(@query_string)
    )
  end

  def test_query_string_with_nil
    assert_equal(
      { "action" => "create_customer", "full_name" => nil},
      CGIMethods.parse_query_parameters(@query_string_with_nil)
    )
  end
  
  def test_parse_params
    input = {
      "customers[boston][first][name]" => [ "David" ],
      "customers[boston][first][url]" => [ "http://David" ],
      "customers[boston][second][name]" => [ "Allan" ],
      "customers[boston][second][url]" => [ "http://Allan" ],
      "something_else" => [ "blah" ],
      "something_nil" => [ nil ],
      "something_empty" => [ "" ],
      "products[first]" => [ "Apple Computer" ],
      "products[second]" => [ "Pc" ]
    }
    
    expected_output =  {
      "customers" => {
        "boston" => {
          "first" => {
            "name" => "David",
            "url" => "http://David"
          },
          "second" => {
            "name" => "Allan",
            "url" => "http://Allan"
          }
        }
      },
      "something_else" => "blah",
      "something_empty" => "",
      "something_nil" => "",
      "products" => {
        "first" => "Apple Computer",
        "second" => "Pc"
      }
    }

    assert_equal expected_output, CGIMethods.parse_request_parameters(input)
  end
  
  def test_parse_params_from_multipart_upload
    mock_file = MockUploadedFile.new
  
    input = {
      "something" => [ StringIO.new("") ],
      "products[string]" => [ StringIO.new("Apple Computer") ],
      "products[file]" => [ mock_file ]
    }
    
    expected_output =  {
      "something" => "",
      "products"  => {
        "string"  => "Apple Computer",
        "file"    => mock_file
      }
    }

    assert_equal expected_output, CGIMethods.parse_request_parameters(input)
  end
  
  def test_parse_params_with_file
    input = {
      "customers[boston][first][name]" => [ "David" ],
      "something_else" => [ "blah" ],
      "logo" => [ File.new(File.dirname(__FILE__) + "/cgi_test.rb").path ]
    }
    
    expected_output = {
      "customers" => {
        "boston" => {
          "first" => {
            "name" => "David"
          }
        }
      },
      "something_else" => "blah",
      "logo" => File.new(File.dirname(__FILE__) + "/cgi_test.rb").path,
    }

    assert_equal expected_output, CGIMethods.parse_request_parameters(input)
  end

  def xtest_query_string_multiple_of_same_name
    assert_equal(
      { "action" => "update_order", "full_name" => "Lau Taarnskov", "products" => [4,2,3]},
      CGIMethods.parse_query_parameters(@query_string_with_multiple_of_same_name)
    )
  end
end