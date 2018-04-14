Rails.application.routes.draw do
  get 'live/index'

  get 'live/room'

  get '/' => 'dashboard#index'

  get 'assets' => 'assets#index'
  get 'assets/view/:assetId' => 'assets#view'
  get 'assets/bucket/:bucketName' => 'assets#bucket'
  
  get 'assets/editevent/:bucketName/:eventId' => 'assets#editevent'

  # TODO: Make this work
  post 'actions/assets/editevent/:bucketName/:eventId' => 'assets#editevent_post'
  
  get 'assets' => 'assets#index'
  
  get 'events' => 'events#index'

  get 'live' => 'live#index'
  get 'live/room/:roomId' => 'live#room'

  get 'jobs' => 'jobs#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
