# frozen_string_literal: true

NON_INCLUSIVE_WORDS = %w[blacklist whitelist master slave].freeze

require 'rubyprobot'
require 'set'

class Hacktest
  include Gem::RubyProbot

  def initialize
    register_handler(&method(:my_handler))
  end

  def my_handler(_event_type, _headers, data)
    data_hash = data.to_h
    files = github_client.pull_files(
      data_hash[:repository][:full_name],
      data_hash[:pull_request][:number]
    ) # TODO: handle pagination
    search_files(files)
  end

  private

  # @param [Array<Sawyer::Resource>] files
  # @return [Hash] that maps words to a Set of the filenames they appear in
  def search_files(files)
    non_inclusive_words_found = {}
    files.each do |file|
      file_hash = file.to_h
      lines = file_hash[:patch].split("\n")
      file_name = file_hash[:filename]
      search_lines(non_inclusive_words_found, lines, file_name)
    end
    non_inclusive_words_found
  end

  def search_lines(found_words, lines, file_name)
    lines.each do |line|
      NON_INCLUSIVE_WORDS.each do |word|
        if added_line?(line) && line.include?(word)
          add_to_hash(found_words, word, file_name)
        end
      end
    end
  end

  def added_line?(line)
    line[0] == '+'
  end

  def add_to_hash(found_words, word, file_name)
    if found_words[word]
      found_words[word] << file_name
    else
      found_words[word] = Set[file_name]
    end
  end
end
