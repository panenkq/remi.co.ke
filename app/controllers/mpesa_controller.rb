
class MpesaController < ApplicationController
  # Disable CSRF protection for this endpoint as it receives external POSTs
  protect_from_forgery with: :null_session

  def callback
    begin
      # Parse the incoming JSON body
      data = JSON.parse(request.body.read)

      # Log the received data for debugging
      Rails.logger.info("Mpesa callback received: #{data.inspect}")

      # TODO: Add your business logic here
      # For example, update order status based on data from Mpesa

      # Respond with HTTP 200 OK to acknowledge receipt
      head :ok
    rescue JSON::ParserError => e
      Rails.logger.error("Mpesa callback JSON parse error: #{e.message}")
      head :bad_request
    end
  end
end

