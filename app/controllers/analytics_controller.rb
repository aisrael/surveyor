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

  # GET /profile-segment-scores-by-gender
  def profile_segment_scores_by_gender
    profile_segment_scores = Respondent.profile_segment_scores_by_gender
    render json: { profileSegmentScores: profile_segment_scores }
  end
end
