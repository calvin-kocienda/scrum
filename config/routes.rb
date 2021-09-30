Rails.application.routes.draw do
  post "/import", to: "scrum#import"
  post "/index", to: "scrum#index"
  post '/story/:storyid', to: "scrum#story"
  get '/story/:storyid', to: "scrum#story"
  get "/index", to: "scrum#index"
  get "/recap", to: "scrum#recap"
  get "/end_screen", to: "scrum#end_screen"
  root 'scrum#welcome'
end
