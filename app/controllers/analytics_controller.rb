class AnalyticsController < ApiController
  # GET /averages
  def averages
    question_averages = ScoredResponse.question_averages
    render json: { questionAverages: question_averages }
  end

  # GET /scored-question-distributions
  def scored_question_distributions
    scored_question_distributions = Question.scored_question_distributions
    render json: { scored_question_distributions: scored_question_distributions }
  end
end
