require 'rack/test'
require 'rspec'

OUTER_APP = Rack::Builder.parse_file('./config.ru').first
describe 'Racker' do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  let(:user_input) { { 'attempt' => '1312' } }
  let(:response_200) { expect(last_response.status).to eq 200 }
  let(:sessions) { YAML.load_file('./spec/test_data.yaml') if File.exist?('./spec/test_data.yaml') }
  before do
    allow_any_instance_of(Breaker).to receive(:score).and_return([])
    set_cookie sessions['session']
    File.open('session_store.yaml', 'w') { |f| f.write sessions.to_yaml }
  end

  it 'go to /' do
    get '/'
    response_200
    expect(last_response.body).to include('It is a logic game')
  end

  it '/win' do
    get '/win'
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('You successfully guessed code')
  end

  it '/new_game has proper content' do
    get '/new_game'
    expect(last_response.body).to include('Guess code with number from 1 to 6')
  end

  it 'has status 200' do
    get '/new_game'
    response_200
  end

  it 'set cookies' do
    get '/new_game'
    expect(last_response.has_header?('Set-Cookie')).to be true
  end

  it '/try and return status 200' do
    post '/try', user_input
    response_200
  end

  it '/try has proper content' do
    post '/try', user_input
    expect(last_response.body).to include('Guess code with number from 1 to 6')
  end

  it '/try and redirect' do
    allow_any_instance_of(Breaker).to receive(:approach).and_return(0)
    post '/try', user_input
    expect(last_response.status).to eq 302
  end

  it '/try and win' do
    allow_any_instance_of(Breaker).to receive(:play).and_return('++++')
    post '/try', user_input
    expect(last_response.status).to eq 302
  end

  it 'has proper content' do
    get '/lost'
    response_200
    expect(last_response.body).to include('Unfortunately, you lost')
  end

  it 'has status 200' do
    get '/score'
    response_200
  end

  it 'show score' do
    get '/score'
    expect(last_response.body).to include('Score' && 'Name' && 'Date Time')
  end

  it 'show hint' do
    get '/hint'
    expect(last_response.body).to include('hint:')
  end

  it 'return status 200' do
    get '/hint'
    response_200
  end

  15.times do
    random_path = (1..8).map { ('a'..'z').to_a[rand(26)] }.join
    it "return '404' status when get: /#{random_path}" do
      get "/#{random_path}"
      expect(last_response.status).to eq 404
    end
  end
end
