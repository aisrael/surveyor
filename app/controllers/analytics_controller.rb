class AnalyticsController < ApiController
  # GET /response-averages
  def averages
    scored_response_averages = ScoredResponse.group(:question_id).average('body::integer')
    question_averages = scored_response_averages.map do |question_id, average|
      {
        questionId: question_id,
        averageScore: average.to_f # BigDecimal
      }
    end
    render json: {questionAverages: question_averages}
  end
end
