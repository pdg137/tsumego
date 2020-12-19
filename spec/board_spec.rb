require_relative '../lib/board.rb'

describe Board do
  let(:board) { Board.parse(next_player, board_string) }
  let(:next_player) { Board::Black }

  context 'very simple fight' do
    let(:board_string) { 'x o' }

    context 'black next' do
      it 'kills black' do
        board.remove_captures!
        expect(board.array).to eq([%i(. o)])
      end
    end

    context 'white next' do
      let(:next_player) { Board::White }
      it 'kills white' do
        board.remove_captures!
        expect(board.array).to eq([%i(x .)])
      end
    end
  end

  context 'simple life' do
    let(:board_string) { 'x . o' }

    specify 'all survive' do
      board.remove_captures!
      expect(board.array).to eq([%i(x . o)])
    end
  end

  context 'simple life 2' do
    let(:board_string) { 'x x . x' }

    specify 'all survive' do
      board.remove_captures!
      expect(board.array).to eq([%i(x x . x)])
    end
  end

  context 'simple death' do
    let(:board_string) { 'x x' }
    specify 'all die' do
      board.remove_captures!
      expect(board.array).to eq([%i(. .)])
    end
  end

  context 'vertical life' do
    let(:board_string) { "x\n." }
    specify 'all live' do
      board.remove_captures!
      expect(board.array).to eq([%i(x), %i(.)])
    end
  end

  context 'complex' do
    let(:board_string) { <<END }
o o . x
x o o x
o x x x
x o o o
END
    specify do
      board.remove_captures!
      expect(board.to_s).to eq(<<END.strip)
o o . x
. o o x
o x x x
. o o o
Black to play.
END
    end

    context 'white to play' do
      let(:next_player) { Board::White }
      specify do
        board.remove_captures!
        expect(board.to_s).to eq(<<END.strip)
o o . x
x o o x
. x x x
x . . .
White to play.
END
      end
    end
  end
end
