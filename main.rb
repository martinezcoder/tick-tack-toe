require 'pry'

RANGE = 0..2

board = Hash.new("_")

begin
  puts "Insert coordinate (e.g., '1,1'):"
  input = gets.chomp.downcase
  coord = /([0-2]),\s?([0-2])/.match(input)
end while coord.nil?

x = coord[1].to_i
y = coord[2].to_i

board[[x, y]] = "X"

binding.pry

[x].product((RANGE).to_a).collect { |index| board[index] }
(RANGE).to_a.product([y]).collect { |index| board[index] }



