require "webrick"
require 'json'

class AddWordFromJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    word       = request.query["word"]
    definition = request.query["definition"]

    hash = {
      :word => word,
      :definition => definition
    }

    array_of_hashes = JSON.parse(File.read("dictionary.json"))
    array_of_hashes << hash

    File.open("dictionary.json", "w") do |file|
      file.puts array_of_hashes.to_json
    end

    response.status = 201
    response["Access-Control-Allow-Origin"] = "*"
    response["Content-Type"] = "application/json"
    response.body = {status: :ok}.to_json
  end
end

class ServeWordsInJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request,response)
    dictionary_lines = File.open("dictionary.json")

    # array_of_hashes = dictionary_lines.map do |line|
    #   word, definition = line.chomp.split(" = ")
    #   {
    #     word: word,
    #     definition: definition
    #   }


    response.status = 200
    response["Content-Type"] = "application/json"
    response["Access-Control-Allow-Origin"] = "*"
    response.body   = dictionary_lines
  end
end

class SearchWordInJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    search = request.query["q"]
    # found_word = nil
    # array_of_hashes = nil
    array_of_hashes = JSON.parse(File.read("dictionary.json"))
    search_results = array_of_hashes.find_all {|file| file["word"].start_with?(search)}
      # found_word = file.find_all {|line| line.start_with?(search)}
      # array_of_hashes = found_word.map do |line|
      #   word, definition = line.chomp.split(" = ")
      #   {
      #     word: word,
      #     definition: definition
      #   }
    #   end
    # end


  response.status = 200
  response["Content-Type"] = "application/json"
  response["Access-Control-Allow-Origin"] = "*"
  response.body = search_results.to_json
end
end


server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/words.json", ServeWordsInJSON
server.mount "/create", AddWordFromJSON
server.mount "/search", SearchWordInJSON
# Create a new class for search and mount it here

trap "INT" do server.shutdown end
  server.start
