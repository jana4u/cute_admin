begin
  Searchlogic
rescue NameError
  STDERR.puts "CuteAdmin requires 'searchlogic' gem (or plug-in) to work correctly"
  STDERR.puts "Add 'config.gem \"searchlogic\"' to config/environment.rb"
end

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'active_record/acts/cute_admin'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::CuteAdmin }

require 'cute_admin_helper'
ActionView::Base.send :include, CuteAdminHelper

require 'cute_admin_form_builder'

begin
  require 'remote_link_renderer'
rescue NameError
  STDERR.puts "CuteAdmin requires 'will_paginate' gem (or plug-in) to work correctly"
  STDERR.puts "Add 'config.gem \"will_paginate\"' to config/environment.rb"
end

require 'remote_rails_helpers'
ActionView::Base.send :include, Searchlogic::RemoteRailsHelpers
