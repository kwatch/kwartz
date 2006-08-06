# Methods added to this helper will be available to all templates in the application.


module ApplicationHelper


  ##
  ## print only start-tag
  ##
  ## ex.
  ##   <%= start_link_to :action=>'new' %>Create new member</a>
  ##    #=>  <a href="/member/new">Create new member</a>
  ##
  def start_link_to(options = {}, html_options = nil, *parameters_for_method_reference)
    s = link_to('', options, html_options, *parameters_for_method_reference)
    s.sub!(/<\/a>\z/, '')
  end
  alias anchor start_link_to


  ##
  ## print only start tag
  ##
  def start_link_to_remote(options = {}, html_options = {})
    s = link_to_remote(options, html_options)
    s.sub!(/<\/a>\z/, '')
  end
  alias anchor_remote start_link_to_remote


end
