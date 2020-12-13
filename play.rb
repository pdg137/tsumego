require_relative 'lib/board.rb'

board = Board.parse(Board::Black, <<END)
x . x . x o _
o x x x x o _
o o o o o o _
_ _ _ _ _ _ _
END

board.each_move do |x, y, board|
  puts "#{x}, #{y} ->"
  puts board
  puts ''
end
