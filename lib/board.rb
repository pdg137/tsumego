class Board
  attr_accessor :black_to_play, :width, :height
  attr_accessor :array

  Open = :'.'
  Closed = :'_'
  Black = :'x'
  White = :'o'

  def initialize
  end

  def self.parse(player, s)
    s = s.gsub(/ /,'')
    lines = s.split("\n")

    board = Board.new
    board.black_to_play = (player == Black)
    board.width = lines[0].length
    board.height = lines.length

    lines.each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        board[x,y] = c.to_sym
      end
    end

    board
  end

  def white_to_play=(value)
    @black_to_play = !value
  end

  def white_to_play
    !@black_to_play
  end

  def to_play
    @black_to_play ? Black : White
  end

  def not_to_play
    @black_to_play ? White : Black
  end

  def to_play_s
    @black_to_play ? 'Black' : 'White'
  end

  def []=(x, y, value)
    @array = [] if !@array
    @array[y] = [] if !@array[y]
    @array[y][x] = value
  end

  def [](x, y)
    @array[y][x]
  end

  def to_s
    @array.map { |line| line.join(" ") }.join("\n") +
      "\n#{to_play_s} to play."
  end

  def each_point
    @width.times.each do |x|
      @height.times.each do |y|
        yield(x, y)
      end
    end
  end

  def each_open_point
    each_point do |x, y|
      if self[x, y] == Open
        yield(x, y)
      end
    end
  end

  def remove_captures!
    remove_captures_of!(to_play)
    remove_captures_of!(not_to_play)
  end

  def remove_captures_of!(player)
    @array.each_with_index do |row, row_index|
      chunks = row.chunk(&:itself).to_a

      new_row = []
      chunks.each_with_index do |chunk, index|
        value = chunk[0]
        length = chunk[1].length

        if value != player ||
           index > 0 && chunks[index - 1][0] == Open ||
           index < chunks.length - 1 && chunks[index + 1][0] == Open
          # alive
          length.times { new_row << value }
        else
          # dead
          length.times { new_row << Open }
        end
      end

      @array[row_index] = new_row
    end
  end

  def each_row
    @array.each do |row|
      yield row
    end
  end

  def each_move
    each_open_point do |x, y|
      new_board = Board.new
      new_board.black_to_play = !black_to_play
      new_board.array = Marshal.load(Marshal.dump(array))
      new_board[x, y] = to_play
      new_board.remove_captures!
      yield(x, y, new_board)
    end
  end
end
