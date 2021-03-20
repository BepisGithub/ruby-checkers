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
end