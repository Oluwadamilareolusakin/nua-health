Rails.application.routes.draw do

  root :to => 'messages#index'

  resources :messages
  post 'request_prescription', to: "messages#request_prescription"

end
