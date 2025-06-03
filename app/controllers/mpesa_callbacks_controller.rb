class MpesaCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    mpesa_response = JSON.parse(request.body.read)

    result_code = mpesa_response.dig('Body', 'stkCallback', 'ResultCode')
    checkout_request_id = mpesa_response.dig('Body', 'stkCallback', 'CheckoutRequestID')
    amount = mpesa_response.dig('Body', 'stkCallback', 'CallbackMetadata', 'Item')&.find { |i| i['Name'] == 'Amount' }&.dig('Value')
    mpesa_receipt = mpesa_response.dig('Body', 'stkCallback', 'CallbackMetadata', 'Item')&.find { |i| i['Name'] == 'MpesaReceiptNumber' }&.dig('Value')
    phone_number = mpesa_response.dig('Body', 'stkCallback', 'CallbackMetadata', 'Item')&.find { |i| i['Name'] == 'PhoneNumber' }&.dig('Value')

    if result_code == 0
      # TODO: Find and update your order using checkout_request_id here
      # e.g. Order.find_by(checkout_request_id: checkout_request_id)&.update(status: 'paid', receipt: mpesa_receipt)

      render json: { message: 'Payment confirmed' }, status: :ok
    else
      render json: { message: 'Payment failed or cancelled' }, status: :ok
    end
  rescue JSON::ParserError
    render json: { message: 'Invalid JSON' }, status: :bad_request
  end
end

