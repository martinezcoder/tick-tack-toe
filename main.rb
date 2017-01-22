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

  def draw
    puts "    0 1 2  "
    puts "  #########"
    puts "0 # #{x_axis(0).join(":")} #"
    puts "1 # #{x_axis(1).join(":")} #"
    puts "2 # #{x_axis(2).join(":")} #"
    puts "  #########"
    puts
  end

  def valid_position?(position)
    position.x <= MAX && position.y <= MAX && board[position] == "_"
  end

  private

  def x_axis(x)
    [x].product((0..MAX).to_a).collect { |index| board[index] }
  end

  def y_axis(y)
    (0..MAX).to_a.product([y]).collect { |index| board[index] }
  end

  def []=(position, player)
    raise OutOfBoard unless valid_position?(position)
    @board[[position.x, position.y]] = player
  end

  def in_diagonal?(position)
    position.x == position.y || position.x == 2 || position.y == 2
  end

  def winner?(player, coord)
    return true if x_axis(coord.x).join == player*(MAX+1)
    return true if y_axis(coord.y).join == player*(MAX+1)
    false
  end
end

class Position
  attr_reader :x, :y
  def initialize(coord)
    if coord
      @x = coord[1].to_i
      @y = coord[2].to_i
    end
  end

  def nil?
    x.nil? || y.nil?
  end
end

board = Board.new

begin
  begin
    board.draw
    puts "Insert a valid coordinate (e.g., '1,1'):"
    input = gets.chomp.downcase
    #coord = /([0-2]),\s?([0-2])/.match(input)
    position = Position.new(/([0-2]),\s?([0-2])/.match(input))
  end while position.nil? || !board.valid_position?(position)

  begin
    winner = board.set("X", position)
    if winner
      board.draw
      puts "X wins!"
    end
  rescue Board::OutOfBoard => e
    puts "#{e}. Please, enter a valid coordinate"
  end
end until winner

