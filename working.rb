require "json"

file = File.read("dictionary.json")
array_of_hashes = JSON.parse(file)
search_results = array_of_hashes.select {|file| file["word"].start_with?(search)}
 p some
