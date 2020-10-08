class CommentHelper
  MESSAGE_FORMAT = "This PR includes the following non-inclusive terms: \n%s"

  def self.create_comment(found_words)
    word_detail = ''
    found_words.each do |word, files|
      word_detail << format(
        "_%<word>s_ in file(s): %<filenames>s \n",
        word: word, filenames: files.to_a.join(', ')
      )
    end
    MESSAGE_FORMAT % word_detail
  end
end
