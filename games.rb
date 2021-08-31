require 'net/http'
require 'json'

url = URI("https://fabi-games-api.herokuapp.com/api/v1/games")

continue = true
options = ['Ver todos games', 'Adicionar game', 'Apagar game', 'Alterar game']
options.unshift 'Sair'

def view_games(url)
  puts 'Games'
  resp = Net::HTTP.get(url)
  games = JSON.parse(resp, symbolize_names: true)[:games]

  games.each.with_index do |game, index|
    puts "#{index +1} - Game: #{game[:name]},
                        Genero: #{game[:genre]},
                        Descricao: #{game[:description]},
                        Nota: #{game[:grade]}
    -----------------------------------------"
  end
  sleep 5
end

def add_game(url)
  puts 'Adicionar game?'

  puts 'Digite o nome do jogo:'
  name_game = gets.chomp

  puts 'Digite uma descricao do jogo:'
  description_game = gets.chomp

  puts 'Digite o genero do jogo:'
  genre_game = gets.chomp

  puts 'Digite uma nota para o jogo'
  grade_game = gets.chomp

  json_game = {game: { name: name_game,
                       description: description_game,
                       genre: genre_game,
                       grade: grade_game}}.to_json

  res = Net::HTTP.post(url, json_game, "Content-Type": "application/json")

  puts 'Game adicionado!' if res.is_a?(Net::HTTPSuccess)
  puts res.body
  sleep 5
end

def del_game(url)
  resp = Net::HTTP.get(url)
  games = JSON.parse(resp, symbolize_names: true)[:games]

  puts 'Escolha o id do game que deseja apagar:'

  games.each.with_index do |game, index|
    puts "#{index +1} - #{game[:name]} - id: #{game[:id]}"
  end

  game_id = gets.chomp

  res = Net::HTTP.new('fabi-games-api.herokuapp.com').delete("/api/v1/games/#{game_id}")
  puts JSON.parse(res.body, symbolize_names: true)[:message]

  sleep 7
end

def update_game(url)
  resp = Net::HTTP.get(url)
  games = JSON.parse(resp, symbolize_names: true)[:games]

  puts 'Escolha o id do game que deseja alterar:'

  games.each.with_index do |game, index|
    puts "#{index +1} - #{game[:name]} - id: #{game[:id]}"
  end

  game_id = gets.chomp
  game_url = URI("https://fabi-games-api.herokuapp.com/api/v1/games/#{game_id}")

  resp_game = Net::HTTP.get(game_url)
  game =  puts JSON.parse(resp_game, symbolize_names: true)[:game]

  puts 'Digite a alteracao do nome:'
  name_game = gets.chomp
  name_game = [:name] if name_game.empty?

  puts 'Digite a alteracao da descricao:'
  description_game = gets.chomp
  description_game = [:description] if description_game.empty?

  puts 'Digite a alteracao do genero:'
  genre_game = gets.chomp
  genre_game = [:genre] if genre_game.empty?

  puts 'Digite a alteracao da nota'
  grade_game = gets.chomp
  grade_game = [:grade] if grade_game.empty?

  json_game = {game: { name: name_game,
                       description: description_game,
                       genre: genre_game,
                       grade: grade_game}}.to_json


  http = Net::HTTP.new('fabi-games-api.herokuapp.com')
  res = http.send_request('PUT', game_url, json_game, "Content-Type": "application/json")

  puts 'Game alterado!' if res.is_a?(Net::HTTPSuccess)

  sleep 5
end

while continue
  system('clear')
  puts 'Escolha um numero:'

  options.each.with_index do |option, index|
    puts "#{index} - #{option}"
  end

  option = gets.chomp.to_i

  view_games(url) if option == options.index('Ver todos games')
  add_game(url) if option == options.index('Adicionar game')
  del_game(url) if option == options.index('Apagar game')
  update_game(url) if option == options.index('Alterar game')

  continue = false if option.zero?
end
