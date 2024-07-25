require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/date_helper'

class DateHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::DateHelper

  def test_distance_in_words
    from = Time.mktime(2004, 3, 6, 21, 41, 18)
    
    assert_equal "5 minutes", distance_of_time_in_words(from, Time.mktime(2004, 3, 6, 21, 46, 25))
    assert_equal "about 1 hour", distance_of_time_in_words(from, Time.mktime(2004, 3, 6, 22, 47, 25))
    assert_equal "about 3 hours", distance_of_time_in_words(from, Time.mktime(2004, 3, 7, 0, 41))
    assert_equal "about 4 hours", distance_of_time_in_words(from, Time.mktime(2004, 3, 7, 1, 20))
    assert_equal "2 days", distance_of_time_in_words(from, Time.mktime(2004, 3, 9, 15, 40))
  end

  def test_select_day
    expected = "<select name='date[day]'>\n"
    expected <<
"<option>1</option>\n<option>2</option>\n<option>3</option>\n<option>4</option>\n<option>5</option>\n<option>6</option>\n<option>7</option>\n<option>8</option>\n<option>9</option>\n<option>10</option>\n<option>11</option>\n<option>12</option>\n<option>13</option>\n<option>14</option>\n<option>15</option>\n<option selected>16</option>\n<option>17</option>\n<option>18</option>\n<option>19</option>\n<option>20</option>\n<option>21</option>\n<option>22</option>\n<option>23</option>\n<option>24</option>\n<option>25</option>\n<option>26</option>\n<option>27</option>\n<option>28</option>\n<option>29</option>\n<option>30</option>\n<option>31</option>\n"
    expected << "</select>\n"

    assert_equal expected, select_day(Time.mktime(2003, 8, 16))
    assert_equal expected, select_day(16)
  end

  def test_select_day_with_blank
    expected = "<select name='date[day]'>\n"
    expected <<
"<option></option>\n<option>1</option>\n<option>2</option>\n<option>3</option>\n<option>4</option>\n<option>5</option>\n<option>6</option>\n<option>7</option>\n<option>8</option>\n<option>9</option>\n<option>10</option>\n<option>11</option>\n<option>12</option>\n<option>13</option>\n<option>14</option>\n<option>15</option>\n<option selected>16</option>\n<option>17</option>\n<option>18</option>\n<option>19</option>\n<option>20</option>\n<option>21</option>\n<option>22</option>\n<option>23</option>\n<option>24</option>\n<option>25</option>\n<option>26</option>\n<option>27</option>\n<option>28</option>\n<option>29</option>\n<option>30</option>\n<option>31</option>\n"
    expected << "</select>\n"

    assert_equal expected, select_day(Time.mktime(2003, 8, 16), :include_blank => true)
    assert_equal expected, select_day(16, :include_blank => true)
  end
  
  def test_select_month
    expected = "<select name='date[month]'>\n"
    expected << "<option value='1'>January</option>\n<option value='2'>February</option>\n<option value='3'>March</option>\n<option value='4'>April</option>\n<option value='5'>May</option>\n<option value='6'>June</option>\n<option value='7'>July</option>\n<option value='8' selected>August</option>\n<option value='9'>September</option>\n<option value='10'>October</option>\n<option value='11'>November</option>\n<option value='12'>December</option>\n"
    expected << "</select>\n"

    assert_equal expected, select_month(Time.mktime(2003, 8, 16))
    assert_equal expected, select_month(8)
  end

  def test_select_month_with_numbers
    expected = "<select name='date[month]'>\n"
    expected << "<option value='1'>1</option>\n<option value='2'>2</option>\n<option value='3'>3</option>\n<option value='4'>4</option>\n<option value='5'>5</option>\n<option value='6'>6</option>\n<option value='7'>7</option>\n<option value='8' selected>8</option>\n<option value='9'>9</option>\n<option value='10'>10</option>\n<option value='11'>11</option>\n<option value='12'>12</option>\n"
    expected << "</select>\n"

    assert_equal expected, select_month(Time.mktime(2003, 8, 16), :use_month_numbers => true)
    assert_equal expected, select_month(8, :use_month_numbers => true)
  end
  
  def test_select_year
    expected = "<select name='date[year]'>\n"
    expected << "<option selected>2003</option>\n<option>2004</option>\n<option>2005</option>\n"
    expected << "</select>\n"
    
    assert_equal expected, select_year(Time.mktime(2003, 8, 16), :start_year => 2003, :end_year => 2005)
    assert_equal expected, select_year(2003, :start_year => 2003, :end_year => 2005)
  end
  
  def test_select_year_with_type_discarding
    expected = "<select name='date_year'>\n"
    expected << "<option selected>2003</option>\n<option>2004</option>\n<option>2005</option>\n"
    expected << "</select>\n"
    
    assert_equal expected, select_year(
      Time.mktime(2003, 8, 16), :prefix => "date_year", :discard_type => true, :start_year => 2003, :end_year => 2005)
    assert_equal expected, select_year(
      2003, :prefix => "date_year", :discard_type => true, :start_year => 2003, :end_year => 2005)
  end
  
  
  def test_select_date
    expected = "<select name='date[first][day]'>\n"
    expected <<
"<option>1</option>\n<option>2</option>\n<option>3</option>\n<option>4</option>\n<option>5</option>\n<option>6</option>\n<option>7</option>\n<option>8</option>\n<option>9</option>\n<option>10</option>\n<option>11</option>\n<option>12</option>\n<option>13</option>\n<option>14</option>\n<option>15</option>\n<option selected>16</option>\n<option>17</option>\n<option>18</option>\n<option>19</option>\n<option>20</option>\n<option>21</option>\n<option>22</option>\n<option>23</option>\n<option>24</option>\n<option>25</option>\n<option>26</option>\n<option>27</option>\n<option>28</option>\n<option>29</option>\n<option>30</option>\n<option>31</option>\n"
    expected << "</select>\n"

    expected << "<select name='date[first][month]'>\n"
    expected << "<option value='1'>January</option>\n<option value='2'>February</option>\n<option value='3'>March</option>\n<option value='4'>April</option>\n<option value='5'>May</option>\n<option value='6'>June</option>\n<option value='7'>July</option>\n<option value='8' selected>August</option>\n<option value='9'>September</option>\n<option value='10'>October</option>\n<option value='11'>November</option>\n<option value='12'>December</option>\n"
    expected << "</select>\n"

    expected << "<select name='date[first][year]'>\n"
    expected << "<option selected>2003</option>\n<option>2004</option>\n<option>2005</option>\n"
    expected << "</select>\n"
    
    assert_equal expected, select_date(
      Time.mktime(2003, 8, 16), :start_year => 2003, :end_year => 2005, :prefix => "date[first]"
    )
  end
end