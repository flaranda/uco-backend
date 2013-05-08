# enconding: utf-8

require 'sinatra'
require 'json'
require 'base64'
require 'yaml'

configure :development, :production do
  set :server, :puma
end

helpers do
  def load64( path )
    Base64.encode64( File.open( path ).read )
  end

  def load_random_game( type )
    n_games = YAML.load_file( "games/#{ type }/info.yml" )['info']['n_games']
    random = rand( n_games ) + 1

    game = YAML.load_file( "games/#{ type }/juego#{ random }/#{ type }.yml" )

    game["#{ type }"]["#{ type == 'rasca' ? 'foreground': 'image' }"] = load64( "games/#{ type }/juego#{ random }/image.jpg" )
    game["#{ type }"]['background'] = load64( "games/#{ type }/juego#{ random }/background.jpg" ) if type == 'rasca'
    game["#{ type }"]['subid'] = random

    game["#{ type }"]
  end

  def load_game_result( type, subid, result )
    game = YAML.load_file( "games/#{ type }/juego#{ subid }/#{ type }.yml" )

    save_results( type, subid, result )

    if result < 0
      game['lose']['image'] = load64( "games/#{ type }/juego#{ subid }/lose.jpg" )
      game['lose']
    else
      game['win']['image'] = load64( "games/#{ type }/juego#{ subid }/win.jpg" )
      game['win']
    end
  end

  def save_results( type, subid, result )
    if File.exists? "games/#{ type }/juego#{ subid }/results.yml"
      results = YAML.load_file( "games/#{ type }/juego#{ subid }/results.yml" )
      results["results_#{ ( results.size + 1 ) }"] = result
    else
      results = { "results_1" => result }
    end

    File.open( "games/#{ type }/juego#{ subid }/results.yml", 'w+' ) do |f|
      f.write( results.to_yaml )
    end
  end

  def determine_game( id )
    return 'puzzle' if id == 1
    return 'rasca' if id == 2
  end
end

before do
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token'

  content_type 'application/json'
end

get '/' do
  "UCO-BACKEND"
end

get '/games/new' do
  type = determine_game( params['id'].to_i )

  load_random_game( type ).to_json
end

get '/games/result' do
  type = determine_game( params['id'].to_i )
  subid = params['subid']
  result = params['result'].to_i

  load_game_result( type, subid, result ).to_json
end