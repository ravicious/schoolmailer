require_relative "simple_config_file"
require "rest_client"

class SendGrid

  def initialize(username, api_key)
    @username = username
    @api_key = api_key
    @api = RestClient::Resource.new 'https://sendgrid.com/api/'
  end

  def enough_of_free_credits?(required_number_of_tickets)
    response = JSON.parse( @api[request_params('stats.get.json?')].get )
    free_credits = response.first['requests']
    (200 - free_credits) > required_number_of_tickets
  end

  private

  def request_params(params = "")
    params += "&api_user=#{@username}&api_key=#{@api_key}"
  end

end
