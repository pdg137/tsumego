require_relative 'lib/board.rb'

board = Board.parse(Board::Black, <<END)
x . . . x o _
x x . . x o _
o x x x o o _
o o o o _ _ _
_ _ _ _ _ _ _
END

def best_move(board)
  #puts board

  found_move = nil
  board.each_move do |x, y, new_board|
    found_move = true

    puts "checking #{board.to_play_s} -> #{x}, #{y}"
    if !new_board.array.any? { |row| row.any?(new_board.to_play) }
      puts "killed #{new_board.to_play_s}!"
      return [x,y]
    end

    if best_move(new_board)
      puts "#{x}, #{y} is bad for #{board.to_play_s}!"
    else
      puts "#{x}, #{y} is good for #{board.to_play_s}!"
      return [x,y]
    end
  end

  if !found_move
    puts "no move for #{board.to_play_s} found"
  else
    puts "no good move for #{board.to_play_s} found"
  end

  return nil
end

puts "Best move: #{best_move(board)}"
