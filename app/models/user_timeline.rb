# encoding: utf-8
class UserTimeline 
  include Mongoid::Document
  include Mongoid::Timestamps

  field :screen_name
  field :tweets, type: Array
  validates_presence_of :screen_name

         @map = <<-eos
             function() {
                for(var i in this.tweets){
                tweet = this.tweets[i]
                tweet_date_time = new Date(tweet.tweet_created_at);
                parsed_date =  Date.parse(new Date(tweet_date_time.getFullYear(), tweet_date_time.getMonth()))
                if(!isNaN(parsed_date))
                  emit(parsed_date,1)
              }
             }
            eos
         @reduce = <<-eos
             function(key, values){
              var total = 0;
              for(var i=0;i<values.length;i++){
                total+=values[i];
              }
              return total;
            }
         eos
  scope :old_tweets, order_by(:created_at => :asc).only(:_id, :screen_name)

  after_save do 
    if ENV['MONGOLAB_URI']
    uri = URI.parse(ENV['MONGOLAB_URI'])
    db_size_hash = UserTimeline.mongo_session.command({dataSize: "#{uri.path.sub('/','')}.user_timelines"})
    if db_size_hash["size"]/1000000 > 200
      UserTimeline.old_tweets.each do |user_timeline|
        if db_size_hash["size"]/1000000 > 200
          user_timeline.delete
        else
          break
        end    
      end
    end
    end  
  end

  def self.transform_tweet(user_timeline)
    user_timeline.collect do |tweet|
        {:tweet_created_at => tweet.created_at, :tweet_text => tweet.text, :tweet_id => tweet.attrs["id_str"] }
    end
  end

  def self.fetch_and_save(screen_name)
    options = {:screen_name => screen_name}
    timeline_by_screen = UserTimeline.where(:screen_name => screen_name).first

    if timeline_by_screen.present?
      user_timeline = UserTimeline.find_by(:screen_name => screen_name)
      since_id = user_timeline.tweets.first["tweet_id"]
      options.merge!(:since_id => since_id)
    end

    tweets = load_tweets(options)

    if !timeline_by_screen.present?
      user_timeline = UserTimeline.new({:screen_name => screen_name, :tweets => tweets})
    else
      user_timeline.tweets << tweets
    end
    user_timeline.save
  end

  def self.load_tweets(options)
    tweets = []
    loop do
      timeline = fetch_from_twitter(options)
      tweets << transform_tweet(timeline)
      break if timeline.empty? || timeline.length == 1
      options.merge!({:max_id => timeline.last.attrs["id_str"]})
    end
    tweets.flatten
  end

  def self.fetch_from_twitter(options)
    options.merge!(:count => 200, :trim_user => "t")
    begin
      Twitter.user_timeline(options)
    rescue => e
      throw e
    end
  end

  def self.by_tweet_created_at(screen_name)
    UserTimeline.where(:screen_name => screen_name ).map_reduce(@map, @reduce).out(inline: true)
  end
end
