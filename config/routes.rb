Visualise::Application.routes.draw do

  match ":action.html" => "static_pages#:action", :as => :static_page

  match "experience.json" => "static_pages#experience"
  root :to =>"static_pages#index"
  match "/thoughtworks" => "static_pages#index", :as => :experience
  match "/tweets" => "timeline_visualisation#index", :as => :tweets_index
  match "/visualise" => "timeline_visualisation#visualise", :as => :tweets_visualise
end
