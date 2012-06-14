class UserTimeline < CouchRest::Model::Base
  use_database :user_timeline
  property :screen_name
  property :tweet_created_at, Time
  property :tweet_text
  property :twitter_id
  timestamps!
  design do
    view :by_twitter_id
    view :by_screen_name,
         :map =>
             "function(doc) {
               if(doc.screen_name == 'kunday'){
                 tweet_date_time = new Date(doc.tweet_created_at)

                emit(Date.parse(new Date(tweet_date_time.getFullYear(), tweet_date_time.getMonth())), 1);
             }
          }",
         :reduce =>
             "function(key, values, rereduce) {
             return sum(values);
             }"
  end

  def self.save_timeline(screen_name, user_timeline)
    user_timeline.each do |user|
      if UserTimeline.by_twitter_id.key(user.attrs["id_str"]).empty?
        time_line =  UserTimeline.new(:screen_name => screen_name, :tweet_text => user.text,
                                           :tweet_created_at => user.created_at, :twitter_id => user.attrs["id_str"])
        time_line.save
      end
    end
  end

  def self.fetch_and_save(screen_name)
    user_timeline = []
    twitter_params = {:screen_name => screen_name, :count => 200, :trim_user => "t"}
    loop do
      user_timeline = fetch_from_twitter(twitter_params)
      save_timeline(screen_name, user_timeline)
      break if user_timeline.empty? || user_timeline.length == 1
      twitter_params.merge!({:max_id => user_timeline.last.attrs["id_str"]})
    end

  end

  def self.fetch_from_twitter(twitter_params)
    begin
      Twitter.user_timeline(twitter_params)
    rescue => e
      throw e
    end
  end

end
