# encoding: utf-8
class UserTimeline < CouchRest::Model::Base
  use_database :user_timeline
  property :screen_name
  property :tweet_created_at, Time
  property :tweet_text
  property :twitter_id
  property :tweets, {}
  timestamps!

  validates_presence_of :screen_name
  validates_uniqueness_of :screen_name

  design do
    view :by_twitter_id
    view :by_screen_name
    view :by_tweet_created_at,
         :map =>
             "function(doc) {
              for(var i in doc.tweets){
                tweet = doc.tweets[i]
                value = {}
                tweet_date_time = new Date(tweet.tweet_created_at);
                parsed_date =  Date.parse(new Date(tweet_date_time.getFullYear(), tweet_date_time.getMonth()))
                value[parsed_date] = 1
                emit(doc.screen_name, value)
              }
             }",
         :reduce =>
             "function(key, values, rereduce){
                if(!rereduce){
                var count = {}
                for(var i in values){
                  for(var id in values[i]){
                  if(count[id]){
                  count[id] = values[i][id] + count[id]
                  }else{
                  count[id] = values[i][id]
                  }
                }
              }
             return count
            }
            else{
            sum(values)
            }
          }"
  end

  def self.transform_tweet(user_timeline)
    user_timeline.collect do |tweet|
        {:tweet_created_at => tweet.created_at, :tweet_text => tweet.text, :tweet_id => tweet.attrs["id_str"] }
    end
  end

  def self.fetch_and_save(screen_name)
    tweets = []
    options = {:screen_name => screen_name}
    timeline_by_screen = UserTimeline.by_screen_name.key(screen_name)

    if !timeline_by_screen.rows.empty?
      user_timeline = UserTimeline.get(timeline_by_screen.rows.first.id)
      since_id = user_timeline.tweets.first["tweet_id"]
      options.merge!(:since_id => since_id)
    end

    loop do
      timeline = fetch_from_twitter(options)
      tweets << transform_tweet(timeline)
      break if timeline.empty? || timeline.length == 1
      options.merge!({:max_id => timeline.last.attrs["id_str"]})
    end
    tweets = tweets.flatten

    if !timeline_by_screen.rows.empty?
      user_timeline.tweets << tweets
    else
      user_timeline = UserTimeline.new({:screen_name => screen_name, :tweets => tweets})
    end 
    user_timeline.save
  end

  def self.fetch_from_twitter(options)
    options.merge!(:count => 200, :trim_user => "t")
    begin
      Twitter.user_timeline(options)
    rescue => e
      throw e
    end
  end

end
