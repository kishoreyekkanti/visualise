class TimelineVisualisationController < ApplicationController

  def visualise
    begin
      @screen_name = params[:screen_name]
      UserTimeline.fetch_and_save(@screen_name)
      rows = UserTimeline.by_tweet_created_at.reduce.group_level(1).rows
      @user_timeline_json = []
      rows.each{ |row|
      if row["key"] == params[:screen_name]
        row["value"].keys.each do |key|
          temp = [key.to_i, row["value"][key]]
          @user_timeline_json << temp
        end
      end
      }
    rescue => e
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