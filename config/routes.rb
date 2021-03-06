Rails.application.routes.draw do
  ### URL RESTFUL ###
  resources :groups, param: :uuid do
    resources :events
    resources :memberships, only: [:create, :destroy], param: :user_id
    resources :messages, except: [:show, :new, :edit]
    resources :invitations, only: [:index, :new, :create, :destroy], param: :url_string
  end
  resources :degrees_courses, only: [:index]
  resources :degrees, only: [:show] do
    resources :courses, only: [:index]
  end
  resources :users, except: [:index, :new, :create, :show] do
    resources :invitations, only: [:index]
  end
  resources :confirm_accounts, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]

  ### URL NON RESTFUL ###
  get     '/signup',                                                  to: 'users#new'
  post    '/signup',                                                  to: 'users#create'

  get     '/',                                                        to: 'session#landing', as: 'landing'
  get     '/login',                                                   to: 'session#new'
  post    '/login',                                                   to: 'session#create'
  get     '/logout',                                                  to: 'session#destroy'

  # Bacheca del gruppo
  get     '/groups/:group_uuid/messages/pinned',                      to: 'messages#pinned', as: 'group_pinned_messages'

  # Aggiunge / Toglie un messaggio dalla bacheca
  patch   '/groups/:group_uuid/messages/:id/pin',                     to: 'messages#pin_message', as: 'group_pin_message'
  # put     '/groups/:group_uuid/message/:id/pin',                      to: 'messages#pin_message', as: 'group_pin_message'

  # L'utente accetta l'invito ed entra nel gruppo
  get     '/groups/:group_uuid/invitations/:url_string/accept',       to: 'invitations#accept', as: 'group_accept_invitation'
  # L'utente rifiuta l'invito e non entra nel gruppo
  get     '/groups/:group_uuid/invitations/:url_string/refuse',       to: 'invitations#refuse', as: 'group_refuse_invitation'

  # Per scaricare l'allegato di un messaggio
  get     '/groups/:group_uuid/messages/:message_id/attachments/:id/download',
      to: 'attachments#download_attachment', as: 'group_message_attachment_download'
  
  # Aggiunge / Rimuove il titolo di amministratore
  patch   '/groups/:group_uuid/memberships/:user_id/admin',           to: 'memberships#set_admin', as: 'group_set_admin'
  # put     '/groups/:group_uuid/memberships/:user_id/admin',           to: 'memberships#set_admin', as: 'group_set_admin'

  # Trasferisce il titolo di super amministratore
  patch   '/groups/:group_uuid/memberships/:user_id/super_admin',
      to: 'memberships#set_super_admin', as: 'group_set_super_admin'
  # put     '/groups/:group_uuid/memberships/:user_id/super_admin',
  #     to: 'memberships#set_super_admin', as: 'group_set_super_admin'

  # Lista degli inviti di tutti 
end
