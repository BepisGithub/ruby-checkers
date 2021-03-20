class LinkedNode

end

class LinkedList
  attr_accessor :head, :tail
  
  def initialize(node = nil)
    @head = node
    @tail = @head
  end
end