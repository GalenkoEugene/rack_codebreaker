require 'rack/test'
require 'rspec'

# RSpec.configure do |conf|
#   conf.include Rack::Test::Methods
# end

OUTER_APP = Rack::Builder.parse_file('./config.ru').first
describe 'Racker' do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  it 'go to /' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('It is a logic game')
  end

  it '/win' do
    get '/win'
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('You successfully guessed code')
  end

  it '/new_game' do
    #allow_any_instance_of(Breaker).to receive(:hint).and_return(:return_value)
    get '/new_game'
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('Guess code with number from 1 to 6')
  end

  it '/try' do
    #allow_any_instance_of(Breaker).to receive(:hint).and_return(:return_value)
    set_cookie 'rack.session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiRTY2OWM3YzAzZGNjZjk4ZDNkNTIz%0AMmQxMmU2NTdhZWRiMDlmYjYxNDM1NTFmMjA4Y2I2Yjk1Y2Y0ZmQxY2IzZGYG%0AOwBGSSIJaW5pdAY7AFRU%0A--50fe8179da00b79ce6773ec431a592b806f8a62d; expires=Sat, 01 Jul 2017 06:28:50 GMT; path=/; domain=localhost; HttpOnly'
    get '/try'
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('Guess code with number from 1 to 6')
  end
end

