require "calendrier/version"
require "calendrier/calendrier_builder"
require "calendrier/controllers/event_extension"
require "calendrier/helpers/calendrier_helper"
require "calendrier/helpers/event_helper"

module Calendrier
  # including our calendar
  ActiveSupport.on_load(:action_view) do
    ::ActionView::Base.send :include, Calendrier::CalendrierHelper
    # this one is crapy
    ::ActionView::Base.send :include, Calendrier::EventHelper
  end
  # no automatic load
  # you need to include manually in the controllers where it is needed
  #ActiveSupport.on_load(:action_controller) do
  #  ::ActionController::Base.send :include, Calendrier::EventExtension
  #end
end


