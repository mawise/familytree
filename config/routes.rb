Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :people
  get 'people/:id/addparent', to: 'people#add_parent', as: 'add_parent'
  post 'relationships', to: 'people#create_relationship', as: 'create_relationship'
  delete 'people/:parent_id/remove_child/:child_id', to: 'people#remove_child', as: 'remove_child'
  delete 'people/:child_id/remove_parent/:parent_id', to: 'people#remove_parent', as: 'remove_parent'

  root to: 'people#index'
end
