require 'pry'

class Board
  class OutOfBoard < StandardError; end

  attr_reader :board, :movements, :winner

  MAX = 2

  def initialize
    @board = Hash.new("_")
    @movements = 0
    @winner = nil
  end

  def [](position)
    @board[[position.x, position.y]]
  end

  def []=(position, player)
    return nil unless valid_position?(position)
    board[[position.x, position.y]] = player
    @movements += 1
    @winner = player if winner?(player, position)
  end

  def draw
    puts "    0 1 2  "
    puts "  #########"
    puts "0 # #{x_axis(0).join("|")} #"
    puts "1 # #{x_axis(1).join("|")} #"
    puts "2 # #{x_axis(2).join("|")} #"
    puts "  #########"
    puts
  end

  def valid_position?(position)
    self[position] == "_" && position.x <= MAX && position.y <= MAX
  end

  def straight_winner_line(player, axis)
    [0,1,2].each do |line|
      return line if winner_line?(player, axis, line)
    end
    nil
  end

  def diagonal_winner_line(player, num)
    diagonal = self.send("diagonal_#{num}".to_sym)
    if diagonal.count(player) == 2 && diagonal.count('_') == 1
      return diagonal.index('_')
    end
  end

  def x_axis(x)
    [x].product((0..MAX).to_a).collect { |index| board[index] }
  end

  def y_axis(y)
    (0..MAX).to_a.product([y]).collect { |index| board[index] }
  end

  def diagonal_1
    "#{board[[0,0]]}#{board[[1,1]]}#{board[[2,2]]}"
  end

  def diagonal_2
    "#{board[[2,0]]}#{board[[1,1]]}#{board[[0,2]]}"
  end

  private

  def in_diagonal?(position)
    position.x == position.y || position.x == 2 || position.y == 2
  end

  def winner?(player, position)
    return false if movements < 3 # FIXME: movements < 5
    expected = player*(MAX+1)
    return true if x_axis(position.x).join == expected
    return true if y_axis(position.y).join == expected
    if in_diagonal?(position)
      return true if diagonal_1 == expected
      return true if diagonal_2 == expected
    end
    false
  end

  def winner_line?(player, axis, line)
    board_line = self.send(axis, line)
    board_line.count(player) == 2 && board_line.count('_') == 1
  end
end

class Position
  attr_accessor :x, :y

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

class ComputerPlayer
  attr_accessor :board, :position

  def initialize(board)
    @board = board
    @position = Position.new( {1 => 1, 2 => 1} )
  end

  def find_position
    if board.movements < 3
      position = random_position
    else
      unless position = winner_position('O')
        unless position = winner_position('X')
          position = random_position
        end
      end
    end
    return position
  end

  private

  def winner_position(player)
    winner_numline = board.straight_winner_line(player, :x_axis)
    if winner_numline
      position.x = winner_numline
      position.y = board.x_axis(winner_numline).join.index("_")
    else
      winner_numline = board.straight_winner_line(player, :y_axis)
      if winner_numline
        position.x = board.y_axis(winner_numline).join.index("_")
        position.y = winner_numline
      else
        winner_numline = board.diagonal_winner_line(player, 1)
        if winner_numline
          position.x = winner_numline
          position.y = winner_numline
          return position
        else
          winner_numline = board.diagonal_winner_line(player, 2)
          if winner_numline
            position.x = (winner_numline == 0) ? 2 : 0
            position.y = winner_numline
            return position
          else
            return nil
          end
        end
      end
    end
    return position
  end

  def random_position
    return position if board.valid_position?(position)
    begin
      position.x = rand(0..2)
      position.y = rand(0..2)
    end while !board.valid_position?(position)
    position
  end

end

board = Board.new

begin
  begin
    board.draw
    puts "Insert a valid coordinate (e.g., '1,1'):"
    input = gets.chomp.downcase
    position = Position.new(/([0-2]),\s?([0-2])/.match(input))
  end while position.nil? || !board.valid_position?(position)

  board[position] = "X"
  if board.winner == "X"
    board.draw
    puts "X wins!"
  else
    computer_position = ComputerPlayer.new(board).find_position
    board[computer_position] = "O"

    if board.winner == "O"
      board.draw
      puts "O wins!"
    end
  end
end until board.winner

