class ResponsesController < ApiController

    # GET /responses
    def index
        responses = Response.all.map do |response|
            {
                questionId: response.question_id,
                body: response.type == 'OpenEndedResponse' ? response.body : response.score
            }
        end
        render json: {responses: responses}
    end


    # POST /responses
    # {
    #   "respondentIdentifier"=>"00001",
    #   "responses"=>[
    #     {"questionId"=>1, "body"=>4},
    #     {"questionId"=>2, "body"=>"Unclear expectations"}
    #   ]
    # }
    def create
        respondent_identifier = params[:respondentIdentifier]
        respondent = Respondent.where(identifier: respondent_identifier).take
        if respondent.nil? then
            errors = [{status: 400, title: "No respondent with identifier \"#{respondent_identifier}\""}]
            return render(status: :bad_request, json: {errors: errors})
        end

        count = respondent.responses.count
        if count > 0 then
            errors = [{status: 400, title: "Respondent already submitted response(s)"}]
            return render(status: :bad_request, json: {errors: errors})
        end

        params_responses = params[:responses]
        questions = params_responses.map {|r| Question.find(r[:questionId])}

        question_not_found_index = questions.index(&:nil?)
        if question_not_found_index then
            question_id = params_responses[question_not_found_index]
            errors = [{
                        status: 400,
                        source: "/responses[#{question_not_found_index}]/questionId",
                        title: "Question id #{question_id} not found"
            }]
            return render(status: :bad_request, json: {errors: errors})
        end

        responses = params_responses.zip(questions).map do |response_param, question|
            response = if question.question_type == 'scored' then
                ScoredResponse.new(
                    respondent_id: respondent_identifier,
                    question_id: question.id,
                    body: response_param[:body]
                )
            else
                OpenEndedResponse.new(
                    respondent_id: respondent_identifier,
                    question_id: question.id,
                    body: response_param[:body]
                )
            end
            response.respondent = respondent
            response.save!
            response
        end

        data = responses.map do |response|
            {
                id: response.id,
                respondentIdentifier: response.respondent.identifier,
                questionId: response.question_id,
                body: response.type == 'OpenEndedResponse' ? response.body : response.score
            }
        end

        render json: {data: data}
    end

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
