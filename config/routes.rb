Visualise::Application.routes.draw do

  match ":action.html" => "static_pages#:action", :as => :static_page

  match "experience.json" => "static_pages#experience"
  root :to =>"static_pages#index"

end
