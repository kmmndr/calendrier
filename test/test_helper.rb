require 'minitest/autorun'
require 'minitest/pride'

require 'nokogiri'

# minitest and turn
#require 'minitest_helper'

ENV["RAILS_ENV"] = "test"

require "active_support"
require "action_controller"
require "rails/railtie"
require "i18n"

$:.unshift File.expand_path('../../lib', __FILE__)
require 'calendrier'

Calendrier::Routes = ActionDispatch::Routing::RouteSet.new
Calendrier::Routes.draw do
  match ':controller(/:action(/:id))'
end

ActionController::Base.send :include, Calendrier::Routes.url_helpers


class FakeEvent
  attr_accessor :title
  def initialize
    @title = "essai"
  end
  def category
    "Category ?"
  end
  def self.model_name
    self.class.name
  end
end

class FakeDailyEvent < FakeEvent
  attr_accessor :year, :month, :day
  def initialize(year, month, day)
    @year, @month, @day = year, month, day
  end
end
class FakeLongEvent < FakeEvent
  attr_accessor :begin_time, :end_time
  def initialize(begin_time, end_time)
    @begin_time, @end_time = begin_time, end_time
  end
end

