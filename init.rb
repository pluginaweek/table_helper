require 'table_helper'

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::TableHelper
end