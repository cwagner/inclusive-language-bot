# frozen_string_literal: true

require 'rubyprobot'

class Hacktest
  include Gem::RubyProbot

  def initialize
    register_handler(&method(:my_handler))
  end

  def my_handler(_event_type, headers, data)
    data.to_h.to_json # data is a 'Sawyer' object from the Octokit library
  end
end
