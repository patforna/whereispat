require 'twitter'

class Tweet
  START_DATE = Time.new(2012,4,10)
  
  def self.load() 
    begin
      @@tweets = Twitter.user_timeline("patforna", :count => 50).select { |t| t.created_at > START_DATE }
    rescue => e
      puts 'Failed to get tweets from Twitter. Falling back to last known tweets. ' + e.message
      @@tweets
    end
  end
  
end