require 'rethinkdb'
include RethinkDB::Shortcuts

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def conn
  	r.connect(:db => 'video')
  end
end
