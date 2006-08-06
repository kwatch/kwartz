# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
end

require 'kwartz/helper/rails'
ActionView::Base.register_template_handler('html', Kwartz::Helper::RailsTemplate)
#Kwartz::Helper::RailsTemplate.pdata_suffix  = '.html'
#Kwartz::Helper::RailsTemplate.plogic_suffix = '.plogic'
#Kwartz::Helper::RailsTemplate.default_properties = { :escape=>true }
#Kwartz::Helper::RailsTemplate.debug = false

