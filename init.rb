$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'active_record/acts/cute_admin'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::CuteAdmin }
require 'cute_admin_helper'
ActionView::Base.send :include, CuteAdminHelper
require 'cute_admin_form_builder'
require 'remote_link_renderer'
require 'remote_rails_helpers'
ActionView::Base.send :include, Searchlogic::RemoteRailsHelpers