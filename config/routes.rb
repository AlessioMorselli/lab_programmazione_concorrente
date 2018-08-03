Rails.application.routes.draw do
  ### URL DI DEFAULT ###
  resources :gruops do
    resources :events, except: [:show]
    resources :members, only: [:index]
    resources :messages, except: [:show, :new, :edit]
    resources :invitations, only: [:new, :create, :delete]
  end
  resources :courses, only: [:show, :index]
  resources :degree, only: [:show]
  resources :users, except: [:new, :create, :show] do
    resources :events, only: [:index, :show]
    resources :invitations, only: [:index]
  end

  ### URL NON DI DEFAULT ###
  get     '/signup',                                              to: 'users#new'
  post    '/signup',                                              to: 'users#create'

  get     '/',                                                    to: 'sessions#new'
  get     '/login',                                               to: 'sessions#new'
  post    '/login',                                               to: 'sessions#create'
  delete  '/logout',                                              to: 'sessions#destroy'

  get     '/gruops/:gruop_id/messages/pinned',                    to: 'messages#pinned', as: 'group_pinned_messages'
end
