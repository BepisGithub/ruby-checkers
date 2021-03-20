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
end

class SpotNode
  attr_accessor :dark, :coordinate, :occupant

  def initialize(bool_dark, coordinate, occupant = [' '])
    @dark = bool_dark
    @coordinate = coordinate
    @occupant = occupant
  end
end