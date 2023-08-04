# frozen_string_literal: true

class ApplicationController < ActionController::API
  wrap_parameters false
  before_action do
    endpoint = format('%<controller_name>s/%<action_name>s', controller_name: controller_name, action_name: action_name)

    RequestLogger.create(endpoint: endpoint, payload: params, request_id: request.request_id)
  end

  rescue_from ActionController::BadRequest do |ex|
    render json: { error: ex.message }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordInvalid do |ex|
    render json: { error: ex.message }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |ex|
    render json: { error: ex.message }, status: :not_found
  end

  def route_not_found
    render json: { error: 'not found' }, status: :not_found
  end
end
