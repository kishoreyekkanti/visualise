class TimelineVisualisationController < ApplicationController

  def visualise
    begin
      @screen_name = params[:screen_name]
      UserTimeline.fetch_and_save(@screen_name)
      tweet_timeline = UserTimeline.by_tweet_created_at(@screen_name)
      @user_timeline_json = []

      tweet_timeline.each { |date_count_hash|
        temp = [date_count_hash["_id"].to_i, date_count_hash["value"].to_i]
        @user_timeline_json << temp
      }

    rescue => e
      puts e.inspect, e.message
      message = e.message.include?("NotFound")?"Screen name not found. Please try with a different screen name":"Twitter API is facing down time. Please visit after some time"
      flash[:error] = message
      redirect_to tweets_index_path and return
    end
    respond_to do |format|
      format.html
      format.json {render :json => @user_timeline_json || "No results fetched"}
    end
  end

  def index

  end
end