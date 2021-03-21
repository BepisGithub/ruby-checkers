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

  def self.within_bounds?(coordinates, length = 8)
    if coordinates[0] <= length && coordinates[1] <= length
      if (coordinates[0]).positive? && (coordinates[1]).positive?
        return true
      end
      return false
    end
    return false
  end

  def create_graph
    # A checkers grid is 8 x 8 with alternating dark and white spots
    # I will need the list to start at the top left and end at the bottom right
    # That means the coordinates will start at 1, 8 and end at 8, 1
    y_dark = true
    8.downto(1) do |y|
      y_dark = !y_dark
      x_dark = y_dark
      8.times do |x|
        @graph.append(LinkedNode.new(SpotNode.new(x_dark, [x + 1, y])))
        x_dark = !x_dark
      end
    end
  end

  def get_dark_spots
    nodes = @graph.traverse
    nodes.select { |node| node.data.dark }
  end

  def get_occupied_dark_spots
    nodes = get_dark_spots
    nodes.select { |node| node.data.occupant }
  end

  def get_unoccupied_dark_spots
    nodes = get_dark_spots
    nodes.select { |node| node.data.occupant.nil? }
  end

  def display
    puts '--------------------'
    dark_occupant = ['▆']
    light_occupant = [' ']
    graph_nodes = @graph.traverse
    y_coordinate_counter = graph_nodes[0].data.coordinate[1]
    graph_nodes.each do |linked_node|
      if y_coordinate_counter == linked_node.data.coordinate[1]
        # print linked_node.data.occupant.to_s
        if linked_node.data.occupant # There is a piece that needs to be displayed
          display_array = []
          display_array.push(linked_node.data.occupant.owner)
          linked_node.data.occupant.king ? display_array.push('K') : display_array.push('M')
          display_array.push(linked_node.data.occupant.id)
          print ["#{display_array[0]}#{display_array[1]}#{display_array[2]}"]
        else
          if linked_node.data.dark
            print dark_occupant
          else
            print light_occupant
          end
        end
      else
        y_coordinate_counter = linked_node.data.coordinate[1]
        puts ' '
        if linked_node.data.occupant # There is a piece that needs to be displayed
          display_array = []
          display_array.push(linked_node.data.occupant.owner)
          linked_node.data.occupant.king ? display_array.push('K') : display_array.push('M')
          display_array.push(linked_node.data.occupant.id)
          print ["#{display_array[0]}#{display_array[1]}#{display_array[2]}"]
        else
          if linked_node.data.dark
            print dark_occupant
          else
            print light_occupant
          end
        end
      end
    end
  end

  def won?
    nodes = @graph.get_occupied_dark_spots
    first_person_on_list = nodes[0].data.occupant.owner
    winner = true
    nodes.each do |node|
      winner = false if node.data.occupant.owner != first_person_on_list
      break if node.data.occupant.owner != first_person_on_list
    end
    return winner
  end

  def find_by_id(id)
    nodes = @graph.get_occupied_dark_spots
    nodes.select { |node| node.data.occupant.id == id }
    return nodes[0]
  end

  def find_by_coord(coord_array)
    nodes = @graph.traverse
    nodes.select { |node| node.data.coordinate == coord_array}
    return nodes[0]
  end

  def populate_adjacency_list(piece)
    piece_linked_node = find_by_id(piece.id)
    dark_spots = get_dark_spots
    if piece.move_up
      # Check the spots that are directly up (top right and top left)
      x_coord = piece_linked_node.data.coordinate[0]
      y_coord = piece_linked_node.data.coordinate[1]
      top_right_coords = [x_coord + 1, y_coord + 1]
      if Board.within_bounds?(top_right_coords)
        linked_top_right_node = find_by_coord(top_right_coords)
        # If the spot is empty, add the move to the adjacency list (the hash)
        if linked_top_right_node.data.occupant.nil?
          piece.adjacent_moves[:tr] = Move.new(linked_top_right_node)
        else
          # However, if the spot is occupied then we need to check for the possibility of a jump
          # Jumping is mandatory, if you can jump then you must
          jump_top_right_coords = top_right_coords.map { |coord| coord + 1 }
          break unless Board.within_bounds?(jump_top_right_coords)

          jump_tr_linked_node = find_by_coord(jump_top_right_coords)
          piece.adjacent_moves[:tr] = Move.new(jump_tr_linked_node, linked_top_right_node.occupant)
        end
      end
      top_left_coords = [x_coord - 1, y_coord + 1]
      if Board.within_bounds?(top_left_coords)
        linked_top_left_node = find_by_coord(top_left_coords)
      end
      # Multi stage jumps are not a concern because if the move including the first stage of
      # a multi stage jump is attempted, after the jump is actually performed (by a future board move piece method)
      # then the adjacency list will be recalculated for all the nodes, then the same situation occurs where if a move can be made then it must
    elsif piece.move_down

    end

    # At the end, check if there are any moves which involve jumps
    # If there are any jumps, then remove any adjacent moves which are not jumps
  end
end

class Pieces
  attr_accessor :id, :owner, :king, :move_up, :move_down, :adjacent_moves

  def initialize(id, owner, king = false, move_up)
    @id = id
    @owner = owner
    @king = king
    if king
      @move_up = true
      @move_down = true
    else
      @move_up = move_up
      @move_down = !move_up
    end
    @adjacent_moves = {}
  end
end