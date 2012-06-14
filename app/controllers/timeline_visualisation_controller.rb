class TimelineVisualisationController < ApplicationController

  def visualise
    @screen_name = params[:screen_name]
    if @screen_name
      UserTimeline.fetch_and_save(@screen_name)
      rows = UserTimeline.by_screen_name.reduce.group_level(1).rows
      @user_timeline_json = []
      rows.each{ |row|
      temp = [row["key"], row["value"]]
      @user_timeline_json << temp
      }

    end
    respond_to do |format|
      format.html
      format.json {render :json => @user_timeline_json || "No results fetched"}
    end
  end

  def index

  end
end