Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :responses, only: [:create, :index]

  get "/averages", to: "analytics#averages"
  get "/scored-question-distributions", to: "analytics#scored_question_distributions"
  get "/profile-segment-scores-by-gender", to: "analytics#profile_segment_scores_by_gender"
end
