require 'base64'
require 'httparty'

class MpesaService
  include HTTParty
  base_uri 'https://sandbox.safaricom.co.ke'

  CONSUMER_KEY = 'w39eSQLyoJmIMUXCXSF9GdgG3vQSDOLvqbCiJnDnDSz3lm7Y'
  CONSUMER_SECRET = 'y4KJAwXLlRFClC2yHnMvLMXokq02nc5Wf0MEQxJKYRTx06eJVSskKNS0b5h2bA8z'
  SHORTCODE = '174379'
  PASSKEY = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919'

  def initialize
    @token = fetch_oauth_token
  end

  def fetch_oauth_token
    key_secret = Base64.strict_encode64("#{CONSUMER_KEY}:#{CONSUMER_SECRET}")
    headers = {
      "Authorization" => "Basic #{key_secret}"
    }

    response = self.class.get('/oauth/v1/generate?grant_type=client_credentials', headers: headers)
    if response.success?
      response["access_token"]
    else
      raise "Failed to get access token from M-Pesa: #{response.body}"
    end
  end

  def lipa_na_mpesa_push(phone_number, amount, account_reference, transaction_desc, callback_url)
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    password = Base64.strict_encode64("#{SHORTCODE}#{PASSKEY}#{timestamp}")

    body = {
      "BusinessShortCode": SHORTCODE,
      "Password": password,
      "Timestamp": timestamp,
      "TransactionType": "CustomerPayBillOnline",
      "Amount": amount,
      "PartyA": phone_number,
      "PartyB": SHORTCODE,
      "PhoneNumber": phone_number,
      "CallBackURL": callback_url,
      "AccountReference": account_reference,
      "TransactionDesc": transaction_desc
    }

    headers = {
      "Authorization" => "Bearer #{@token}",
      "Content-Type" => "application/json"
    }

    response = self.class.post('/mpesa/stkpush/v1/processrequest', 
                              headers: headers, 
                              body: body.to_json)

    if response.success?
      response.parsed_response
    else
      raise "Failed to initiate STK Push: #{response.body}"
    end
  end
end

