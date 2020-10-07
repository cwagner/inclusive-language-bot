# frozen_string_literal: true

require_relative 'non_inclusive_words'
require 'rubyprobot'
require 'set'

class Hacktest
  include Gem::RubyProbot
  include Gem::RubyProbot::AWSInstance
  extend Gem::RubyProbot::AWS

  def initialize
    register_handler(&method(:my_handler))
  end

  def my_handler(_event_type, _headers, data)
    data_hash = data.to_h
    files = github_client.pull_files(
      data_hash[:repository][:full_name],
      data_hash[:pull_request][:number]
    ) # TODO: handle pagination
    non_inclusive_words_found = search_files(files)

    if data_hash.key?(:pull_request) &&
        (data_hash[:action] == 'opened' || data_hash[:action] == 'ready_for_review' || data_hash[:action] == 'reopened' || data_hash[:action] == 'edited')

      handle_pull_request(data_hash, non_inclusive_words_found)
    end
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
    return non_inclusive_words_found
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

  def handle_pull_request(pr_payload, non_inclusive_words_found)
    remove_pr_comments(pr_payload)
    add_pr_comment(pr_payload, 'Non inclusive words found:')
  end

  def remove_pr_comments(pr_payload)
    comments = github_client.issue_comments(
        pr_payload[:repository][:full_name],
        pr_payload[:pull_request][:number])

    comments.each do |comment|
      github_client.delete_comment(
          pr_payload[:repository][:full_name],
          comment.to_h[:id])
    end
  end

  def add_pr_comment(pr_payload, message)
    github_client.add_comment(
        pr_payload[:repository][:full_name],
        pr_payload[:pull_request][:number],
        message
    )
  end
end
