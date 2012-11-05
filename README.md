# Calendrier

[![travis](https://secure.travis-ci.org/lafourmi/calendrier.png?branch=master)](http://travis-ci.org/lafourmi/calendrier)

##DESCRIPTION

A simple helper for creating calendars. It includes a method to sort objects by date and an helpers to display events/meetings and other objects.

##SYNOPSIS:

The gem provides `calendrier` helper to display calendars

    # Simple example
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true, :display => :week, :title => "My calendar title") %>

    # Complex example
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true, :display => :month) do |cell_begin_time, cell_end_time| %>
      <!-- this code is run for every cell of the calendar -->
      
      <!-- you have access to `cell_begin_time` and `cell_end_time` which let you create links or custom content -->
      <%= content_tag(:span, "Add meeting/event at #{l(cell_begin_time)} ?") %>
    <% end %>

Now you have a calendar, but you may need to display events inside. If you have many events to display, the gem provides a method `sort_events` for the controller to create a hash of events.
This avoid the calendar to check every events of the month to display every single cell.
To use that method, you could pass as argument a mix of any objects which `respond_to?` one of the following method sets :

  * `year`, `month`, `day`
  * `begin_time`, `end_time`

This method will return an array like this :

    events_by_date => {"2012"=>{"5"=>{"21"=>[#<Event>, #<Event>],
                                      "22"=>[#<Event>, #<Event>, #<Event>],
                                      "23"=>[#<Meeting>],
                                      "25"=>[#<Event>, #<Meeting>],
                                      "26"=>[#<Event>],
                                      "27"=>[#<Meeting>, #<Event>]}}}

In your controller :

    class HomeController < ApplicationController
      include Calendrier::EventExtension

      def index
        arr = Meeting.all
        arr << Event.all
        @events_by_date = sort_events(arr)
      end
    end

In your view :

    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true, :display => :month) do |cell_begin_time, cell_end_time| %>
      <!-- this code is run for every cell of the calendar -->
      
      <% if count_sorted_events(@events_by_date, cell_begin_time, cell_end_time) > 0 %>
        <!-- this code is run only there is at least one event between cell begin and end -->

        <ul>
        <% yield_sorted_events(@events_by_date, cell_begin_time, cell_end_time) do |obj| %>
          <!-- you may handle event/meeting/... with the obj variable -->
          <li><%= obj.title %></li>
        <% end %>
        </ul>
      <% end %>

    <% end %>
    


##Custom builder

If you need a more complex calendar, you'll need to define a custom builder. To create such builder, add a file like the following. 

    # /lib/calendrier/calendrier_builder/custom_builder.rb
    module Calendrier
      module CalendrierBuilder
        class CustomBuilder < Builder

          def render(header, content)
             # header is an array like this, having Date object of each columns
             # [Mon, 21 May 2012,
             #  Tue, 22 May 2012,
             #  Wed, 23 May 2012,
             #  Thu, 24 May 2012,
             #  Fri, 25 May 2012,
             #  Sat, 26 May 2012,
             #  Sun, 27 May 2012]
             # 
             # content is a double array like that, containing one Hash for each cell : {:time => Time.utc(<cell_begin_time>), :content => '<block content of this cell>' }
             # [ [ 7 Hash for one week ], [ 7 Hash for the next week ], ... ]
             #
             # [[{:time=>nil, :content=>nil}, # time could be nil on monthly display if week do not starts on monday/sunday (first day of week) 
             #   {:time=>2012-05-01 00:00:00 +0200, :content=>nil},
             #   {:time=>2012-05-02 00:00:00 +0200, :content=>nil},
             #   {:time=>2012-05-03 00:00:00 +0200, :content=>nil},
             #   {:time=>2012-05-04 00:00:00 +0200, :content=>nil},
             #   {:time=>2012-05-05 00:00:00 +0200, :content=>nil},
             #   {:time=>2012-05-06 00:00:00 +0200, :content=>nil}],
             #   ...
             # 
          end

        end
      end
    end

And do not forget to add /lib to rails autoload_paths by adding the following line.

    # config/application.rb
    module MyNiceRailsApplication
      class Application < Rails::Application

        ...

        # Custom directories with classes and modules you want to be autoloadable.
        # config.autoload_paths += %W(#{config.root}/extras)
        config.autoload_paths += %W( #{config.root}/lib )

        ...

      end
    end

Use your new builder by adding the builder option to the renderer.

    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true, :display => :month, :builder => Calendrier::CalendrierBuilder::CustomBuilder) %>


##INSTALLATION

Add this line to your application's Gemfile :

    gem 'calendrier', :git => "git://github.com/lafourmi/calendrier.git", :branch => "master"

And then execute :

    $ bundle install

Or install it yourself as :

    $ gem install calendrier


##AUTHORS

Romain Castel

Thomas Kienlen

##USAGE

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
