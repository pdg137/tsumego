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

  def to_play=(value)
    @black_to_play = value == Black
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
    group_identity = {}
    groups_alive = {}
    groups = []
    next_group = 0

    # 1 pass to determine groups and life/death
    @array.each_with_index do |row, y|
      groups[y] = []
      row.each_with_index do |value, x|
        if value != player
          groups[y][x] = nil
          next
        end

        # check for groups up and left
        up_group = y>0 && group_identity[groups[y-1][x]]
        left_group = x>0 && group_identity[groups[y][x-1]]

        # copy left by default
        my_group = left_group || up_group

        # maybe identify groups
        if my_group && up_group && my_group != up_group
          group_identity.keys.each do |old_group|
            if up_group == group_identity[old_group]
              # found an old group to identify
              group_identity[old_group] = my_group
              groups_alive[my_group] ||= groups_alive[old_group]
            end
          end
        end

        # new group?
        if !my_group
          my_group = next_group
          next_group += 1
          group_identity[my_group] = my_group
        end

        # record group
        groups[y][x] = my_group

        # check for life
        if y > 0 && [Open, Closed].include?(self[x, y-1]) ||
           x > 0 && [Open, Closed].include?(self[x-1, y]) ||
           y+1 < @height && [Open, Closed].include?(self[x, y+1]) ||
           x+1 < @width && [Open, Closed].include?(self[x+1, y])
          groups_alive[my_group] = true
        end
      end
    end

    @array.each_with_index do |row, y|
      row.each_with_index do |value, x|
        next if player != self[x, y]

        group = group_identity[groups[y][x]]
        alive = groups_alive[group]
        if !alive
          self[x, y] = Open
        end
      end
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
      new_board.height = height
      new_board.width = width
      new_board.black_to_play = !black_to_play
      new_board.array = Marshal.load(Marshal.dump(array))

      new_board[x, y] = to_play
      new_board.remove_captures!
      if new_board[x, y] != to_play
        next # suicide
      end

      yield(x, y, new_board)
    end
  end
end
