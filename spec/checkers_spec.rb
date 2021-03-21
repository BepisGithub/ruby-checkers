require './spec/spec_helper'
require './scripts'

describe Board do
  it 'doesnt throw a syntax error when intializing the board' do
    board = Board.new
    expect(board).to be_truthy
  end
  it 'starts at coordinate [1, 8]' do
    board = Board.new
    expect(board.graph.head.data.coordinate).to eql([1, 8])
  end
  it 'ends at coordinate [8, 1]' do
    board = Board.new
    expect(board.graph.tail.data.coordinate).to eql([8, 1])
  end
  it 'alternates the dark and white spots for the first two nodes' do
    board = Board.new
    expect(board.graph.head.data.dark).to be false
    expect(board.graph.head.next_node.data.dark).to be_truthy
  end
  it 'alternates the dark and white spots correctly across the whole board' do
    broken = false
    board = Board.new
    nodes_array = board.graph.traverse
    nodes_array.each_with_index do |node, index|
      next if node.next_node.nil?
      if node.data.dark == node.next_node.data.dark
        broken = true unless (index + 1) % 8
      end
    end
    expect(broken).to be false
  end
  describe '#get_dark_spots' do
    it 'returns an array of dark spots' do
      board = Board.new
      arr = board.get_dark_spots
      working = true
      arr.each do |node|
        working = false unless node.data.dark == true
      end
      expect(working).to be true
    end
  end
  describe '#display' do
    it 'presents the board in a human readable format' do
      board = Board.new
      board.display
    end
  end
end

describe Player do
  describe 'name holding' do
    it 'holds the name you passed in' do
      player = Player.new('dave')
      expect(player.name).to eql('dave')
    end
  end
end