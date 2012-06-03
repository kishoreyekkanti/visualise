class StaticPagesController  < ApplicationController
  def experience

    render :json => File.read(File.join(Rails.root,'doc',"experience.json"))
  end
end