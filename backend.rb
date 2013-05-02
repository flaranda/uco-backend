# enconding: utf-8

require 'sinatra'
require 'i18n'
require 'json'
require 'base64'

configure :development, :production do
  set :server, :puma
end

helpers do
  def load64( path )
    Base64.encode64( File.open( path ).read )
  end
end

before do
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token'
  content_type 'application/json'
end

get '/' do
  "UCO-BACKEND\n\nPeticion de prueba: uco-backend.herokuapp.com/games/puzzle/new"
end

get '/games/puzzle/new' do
  {
    puzzle: {
      difficult: 3,
      time: 5,
      image: load64( "games/puzzle/juego1/imagen.jpg" )
    }
  }.to_json
end

get '/games/rasca/new' do
  {
    rasca: {

    }
  }.to_json
end