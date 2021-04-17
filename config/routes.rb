Rails.application.routes.draw do
  root to: 'contracts#index'

  resources :contracts

  resources :attachments, only: %i[create]

  resources :direct_file_uploads, only: %i[create]
end
