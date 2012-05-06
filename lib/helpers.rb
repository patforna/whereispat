module Helpers
  require 'time-ago-in-words'
  
  def auto_link(string)
    string.gsub /((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/, %Q{<a href="\\1">\\1</a>}
  end
  
  def ago_in_words(time)
     time.ago_in_words
  end
end