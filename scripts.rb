class LinkedNode
  attr_accessor :data, :next_node

  def initialize(data, next_node = nil)
    @data = data
    @next_node = next_node
  end

end

class LinkedList
  attr_accessor :head, :tail

  def initialize(node = nil)
    @head = node
    @tail = nil
    unless node.nil?
      @tail = @head
      @tail = @tail.next_node until @tail.next_node.nil?
    end
  end

  def append(node)
    if @head.nil?
      @head = node
      @tail = @head
    else
      @tail.next_node = node
      until @tail.next_node.nil?
        @tail = @tail.next_node
      end
    end
  end

  def size
    return 0 if @head.nil?
    counter = 1
    next_node = @head.next_node
    until next_node.nil?
      next_node = next_node.next_node
      counter += 1
    end
    counter
  end

  def traverse
    nodes = []
    traversing = @head
    nodes.push(traversing)
    until traversing.next_node.nil?
      traversing = traversing.next_node
      nodes.push(traversing)
    end
    nodes
  end

  def empty?
    return true if @head.nil?
    false
  end
end

class SpotNode
  attr_accessor :dark, :coordinate, :occupant

  def initialize(bool_dark, coordinate, occupant = nil)
    @dark = bool_dark
    @coordinate = coordinate
    @occupant = occupant
  end
end

class Move
  attr_accessor :end_spot, :jumped_piece

  def initialize(end_spot, jumped_piece = nil)
    @end_spot = end_spot
    @jumped_piece = jumped_piece
  end
end

class Board
  attr_accessor :graph

  def initialize
    @graph = LinkedList.new
    create_graph
  end

  def create_graph
    # A checkers grid is 8 x 8 with alternating dark and white spots
    # I will need the list to start at the top left and end at the bottom right
    # That means the coordinates will start at 1, 8 and end at 8, 1
    8.downto(1) do |y|
      8.times do |x|
        
      end
    end
  end
end