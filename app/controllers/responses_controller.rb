class ResponsesController < ApiController
    def index
        render json: Response.all
    end

    def create
        $stderr.puts "params: #{params.inspect}"
#        {"respondentIdentifier"=>"00001", "responses"=>[{"questionId"=>1, "body"=>4}, {"questionId"=>2, "body"=>"Unclear expectations"}
        respondent_identifier = params[:respondentIdentifier]
        $stderr.puts "respondent_identifier: #{respondent_identifier}"
        count = Response.where(respondent_id: respondent_identifier).count
        $stderr.puts "count => #{count}"
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

        params_responses.zip(questions).map do |response_param, question|
            $stderr.puts response_param.inspect
            $stderr.puts question.inspect
            response = Response.new(respondent_id: respondent_identifier, question_id: question.id, response_body: response_body)
            response.response_body = if question.question_type == 'scored' then
                ScoredResponse.new(score: response_param[:body].to_i)
            else
                OpenEndedResponse.new(body: response_param[:body])
            end
            $stderr.puts(response.inspect)
            response.save!
        end

        render json: []
    end
end
