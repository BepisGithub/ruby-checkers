class LinkedNode
  attr_accessor :data ,:next

  def initialize(data, next_node = nil)
    @data = data
    @next = next_node
  end

end

class LinkedList
  attr_accessor :head, :tail
  
  def initialize(node = nil)
    @head = node
    @tail = @head
  end
end