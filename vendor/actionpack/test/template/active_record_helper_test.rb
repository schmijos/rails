require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/date_helper'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/form_helper'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/active_record_helper'

class ActiveRecordHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::ActiveRecordHelper

  Post   = Struct.new("Post", :title, :author_name, :body, :secret, :written_on)
  Column = Struct.new("Column", :type, :name, :human_name)

  def setup
    @post = Post.new    
    def @post.errors() Class.new{ def on(field) field == "author_name" end }.new end
    def @post.new_record?() true end

    def @post.column_for_attribute(attr_name)
      Post.content_columns.select { |column| column.name == attr_name }.first
    end

    def Post.content_columns() [ Column.new(:string, "title", "Title") ] end

    @post.title       = "Hello World"
    @post.author_name = ""
    @post.body        = "Back to the hill and over it again!"
    @post.secret = 1
    @post.written_on  = Date.new(2004, 6, 15)
  end

  def test_generic_input_tag
    assert_equal(
      '<input id="post_title" name="post[title]" size="30" type="text" value="Hello World" />', input("post", "title")
    )
  end

  def test_text_field_with_errors
    assert_equal(
      '<div class="fieldWithErrors"><input id="post_author_name" name="post[author_name]" size="30" type="text" value="" /></div>',
      text_field("post", "author_name")
    )
  end
  
  def test_form_with_string
    assert_equal(
      "<form action='create' method='POST'><p><b>Title</b><br /><input id=\"post_title\" name=\"post[title]\" size=\"30\" type=\"text\" value=\"Hello World\" /></p><input type='submit' value='Create' /></form>",
      form("post")
    )
  end
  
  def test_form_with_date
    def Post.content_columns() [ Column.new(:date, "written_on", "Written on") ] end

    assert_equal(
      "<form action='create' method='POST'><p><b>Written on</b><br /><select name='post[written_on(1i)]'>\n<option>1999</option>\n<option>2000</option>\n<option>2001</option>\n<option>2002</option>\n<option>2003</option>\n<option selected>2004</option>\n<option>2005</option>\n<option>2006</option>\n<option>2007</option>\n<option>2008</option>\n<option>2009</option>\n</select>\n<select name='post[written_on(2i)]'>\n<option value='1'>January</option>\n<option value='2'>February</option>\n<option value='3'>March</option>\n<option value='4'>April</option>\n<option value='5'>May</option>\n<option value='6' selected>June</option>\n<option value='7'>July</option>\n<option value='8'>August</option>\n<option value='9'>September</option>\n<option value='10'>October</option>\n<option value='11'>November</option>\n<option value='12'>December</option>\n</select>\n<select name='post[written_on(3i)]'>\n<option>1</option>\n<option>2</option>\n<option>3</option>\n<option>4</option>\n<option>5</option>\n<option>6</option>\n<option>7</option>\n<option>8</option>\n<option>9</option>\n<option>10</option>\n<option>11</option>\n<option>12</option>\n<option>13</option>\n<option>14</option>\n<option selected>15</option>\n<option>16</option>\n<option>17</option>\n<option>18</option>\n<option>19</option>\n<option>20</option>\n<option>21</option>\n<option>22</option>\n<option>23</option>\n<option>24</option>\n<option>25</option>\n<option>26</option>\n<option>27</option>\n<option>28</option>\n<option>29</option>\n<option>30</option>\n<option>31</option>\n</select>\n</p><input type='submit' value='Create' /></form>",
      form("post")
    )
  end
  
  def test_form_with_datetime
    def Post.content_columns() [ Column.new(:datetime, "written_on", "Written on") ] end
    @post.written_on  = Time.gm(2004, 6, 15, 16, 30)

    assert_equal(
      "<form action='create' method='POST'><p><b>Written on</b><br /><select name='post[written_on(1i)]'>\n<option>1999</option>\n<option>2000</option>\n<option>2001</option>\n<option>2002</option>\n<option>2003</option>\n<option selected>2004</option>\n<option>2005</option>\n<option>2006</option>\n<option>2007</option>\n<option>2008</option>\n<option>2009</option>\n</select>\n<select name='post[written_on(2i)]'>\n<option value='1'>January</option>\n<option value='2'>February</option>\n<option value='3'>March</option>\n<option value='4'>April</option>\n<option value='5'>May</option>\n<option value='6' selected>June</option>\n<option value='7'>July</option>\n<option value='8'>August</option>\n<option value='9'>September</option>\n<option value='10'>October</option>\n<option value='11'>November</option>\n<option value='12'>December</option>\n</select>\n<select name='post[written_on(3i)]'>\n<option>1</option>\n<option>2</option>\n<option>3</option>\n<option>4</option>\n<option>5</option>\n<option>6</option>\n<option>7</option>\n<option>8</option>\n<option>9</option>\n<option>10</option>\n<option>11</option>\n<option>12</option>\n<option>13</option>\n<option>14</option>\n<option selected>15</option>\n<option>16</option>\n<option>17</option>\n<option>18</option>\n<option>19</option>\n<option>20</option>\n<option>21</option>\n<option>22</option>\n<option>23</option>\n<option>24</option>\n<option>25</option>\n<option>26</option>\n<option>27</option>\n<option>28</option>\n<option>29</option>\n<option>30</option>\n<option>31</option>\n</select>\n<select name='post[written_on(3i)]'>\n<option value='1'>January</option>\n<option value='2'>February</option>\n<option value='3'>March</option>\n<option value='4'>April</option>\n<option value='5'>May</option>\n<option value='6' selected>June</option>\n<option value='7'>July</option>\n<option value='8'>August</option>\n<option value='9'>September</option>\n<option value='10'>October</option>\n<option value='11'>November</option>\n<option value='12'>December</option>\n</select>\n<select name='post[written_on(3i)]'>\n<option>1999</option>\n<option>2000</option>\n<option>2001</option>\n<option>2002</option>\n<option>2003</option>\n<option selected>2004</option>\n<option>2005</option>\n<option>2006</option>\n<option>2007</option>\n<option>2008</option>\n<option>2009</option>\n</select>\n &mdash; <select name='post[written_on(4i)]'>\n<option>00</option>\n<option>01</option>\n<option>02</option>\n<option>03</option>\n<option>04</option>\n<option>05</option>\n<option>06</option>\n<option>07</option>\n<option>08</option>\n<option>09</option>\n<option>10</option>\n<option>11</option>\n<option>12</option>\n<option>13</option>\n<option>14</option>\n<option>15</option>\n<option selected>16</option>\n<option>17</option>\n<option>18</option>\n<option>19</option>\n<option>20</option>\n<option>21</option>\n<option>22</option>\n<option>23</option>\n</select>\n : <select name='post[written_on(5i)]'>\n<option>00</option>\n<option>01</option>\n<option>02</option>\n<option>03</option>\n<option>04</option>\n<option>05</option>\n<option>06</option>\n<option>07</option>\n<option>08</option>\n<option>09</option>\n<option>10</option>\n<option>11</option>\n<option>12</option>\n<option>13</option>\n<option>14</option>\n<option>15</option>\n<option>16</option>\n<option>17</option>\n<option>18</option>\n<option>19</option>\n<option>20</option>\n<option>21</option>\n<option>22</option>\n<option>23</option>\n<option>24</option>\n<option>25</option>\n<option>26</option>\n<option>27</option>\n<option>28</option>\n<option>29</option>\n<option selected>30</option>\n<option>31</option>\n<option>32</option>\n<option>33</option>\n<option>34</option>\n<option>35</option>\n<option>36</option>\n<option>37</option>\n<option>38</option>\n<option>39</option>\n<option>40</option>\n<option>41</option>\n<option>42</option>\n<option>43</option>\n<option>44</option>\n<option>45</option>\n<option>46</option>\n<option>47</option>\n<option>48</option>\n<option>49</option>\n<option>50</option>\n<option>51</option>\n<option>52</option>\n<option>53</option>\n<option>54</option>\n<option>55</option>\n<option>56</option>\n<option>57</option>\n<option>58</option>\n<option>59</option>\n</select>\n</p><input type='submit' value='Create' /></form>",
      form("post")
    )
  end
end