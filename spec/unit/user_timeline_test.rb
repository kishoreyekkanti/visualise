require 'spec_helper'

describe UserTimeline do

  describe "fetch the time line from twitter " do
    it "should fetch the time line for a given screen name from twitter" do
      options = {:screen_name => "kishoreyekkanti", :count => 200, :trim_user => "t"}
      Twitter.should_receive(:user_timeline).with(options)
      UserTimeline.fetch_from_twitter(options)
    end

    it "should throw error for invalid screen names" do
      options = {:screen_name => "invalid screen name", :count => 200, :trim_user => "t"}
      Twitter.should_receive(:user_timeline).and_return(Twitter::Error::NotFound)
      UserTimeline.fetch_from_twitter(options)
    end
  end

end