Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :people

  get 'people/:id/modparents', to: 'people#modify_parents', as: 'modify_parents'
  get 'people/:id/modchildren', to: 'people#modify_children', as: 'modify_children'

  post 'relationships', to: 'people#create_relationship', as: 'create_relationship'
  delete 'people/:parent_id/remove_child/:child_id', to: 'people#remove_child', as: 'remove_child'
  delete 'people/:child_id/remove_parent/:parent_id', to: 'people#remove_parent', as: 'remove_parent'

  get 'people/:id/upgraph', to: 'people#show_upgraph', as: 'show_upgraph'
  get 'people/:id/downgraph', to: 'people#show_downgraph', as: 'show_downgraph'

  get 'people/:id/images', to: "people#modify_images", as: "images" 
  post 'people/:id/images', to: "people#create_image", as: "create_image"
  delete 'people/:id/images/:image_id', to: "people#destroy_image", as: "destroy_image"

  get 'gedcom', to: "people#show_gedcom", as: "show_gedcom"

  root to: 'people#index'
end
