class AnalyticsController < ApiController
  # GET /averages
  def averages
    scored_response_averages = ScoredResponse.group(:question_id).average("body::integer")
    question_averages = scored_response_averages.map do |question_id, average|
      {
        questionId: question_id,
        averageScore: average.to_f, # BigDecimal
      }
    end
    render json: { questionAverages: question_averages }
  end

  # GET /scored-question-distributions
  def scored_question_distributions
    scored_questions = Question.where(question_type: "scored").all
    scored_question_distributions = scored_questions.map do |question|
      responses_grouped_by_score = question.responses.group_by(&:score)
      response_frequencies = (1..5).map do |score|
        frequency = if responses_grouped_by_score.has_key?(score)
            responses_grouped_by_score[score].size
          else
            0
          end
        { 'score': score, 'frequency': frequency }
      end
      {
        'questionId': question.id,
        'responseFrequencies': response_frequencies,
      }
    end
    render json: { scored_question_distributions: scored_question_distributions }
  end
end
