require 'pry'

class Board
  class OutOfBoard < StandardError; end

  attr_reader :board

  MAX = 2

  def initialize
    @board = Hash.new("_")
  end

  def [](position)
    @board[[position.x, position.y]]
  end

  def set(player, position)
    self[position] = player
    return true if winner?(player, position)
    false
  end

  private

  def []=(coord, player)
    raise OutOfBoard unless coord.valid_position?(MAX)
    @board[[coord.x, coord.y]] = player
  end

  def winner?(player, coord)
    return true if x_axis(coord.x) == player*(MAX+1)
    return true if y_axis(coord.y) == player*(MAX+1)
    false
  end

  def x_axis(x)
    [x].product((0..MAX).to_a).collect { |index| board[index] }.join
  end

  def y_axis(y)
    (0..MAX).to_a.product([y]).collect { |index| board[index] }.join
  end
end

class Position
  attr_reader :x, :y
  def initialize(x, y)
    @x = x.to_i
    @y = y.to_i
  end

  def valid_position?(max)
    x <= max && y <= max
  end

  def is_corner?
    (x == 0 && y == 0) || x == 2 || y == 2
  end
end

board = Board.new

begin
  begin
    puts "Insert coordinate (e.g., '1,1'):"
    input = gets.chomp.downcase
    coord = /([0-2]),\s?([0-2])/.match(input)
  end while coord.nil?

  position = Position.new(coord[1], coord[2])

  begin
    winner = board.set("X", position)
    puts "X wins!" if winner
  rescue Board::OutOfBoard => e
    puts "#{e}. Please, enter a valid coordinate"
  end

end until winner


