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

  def populate_adjacenct_direction(piece, direction)
    piece_linked_node = find_by_id(piece.id)
    dark_spots = get_dark_spots
    case direction
    when :tr
      x_shift = 1
      y_shift = 1
    when :tl
      x_shift = -1
      y_shift = 1
    when :br
      x_shift = 1
      y_shift = -1
    when :bl
      x_shift = -1
      y_shift = -1
    end
    x_coord = piece_linked_node.data.coordinate[0]
    y_coord = piece_linked_node.data.coordinate[1]
    diagonal_check_coord = [x_coord + x_shift, y_coord + y_shift]
    # REFACTOR THE RETURN STATEMENT THEY MIGHT NOT WORK
    return unless Board.within_bounds?(diagonal_check_coord)

    linked_diagonal_node = find_by_coord(diagonal_check_coord)
    return unless dark_spots.include?(linked_diagonal_node)

    # If the spot is empty, add the move to the adjacency list (the hash)
    if linked_diagonal_node.data.occupant.nil?
      piece.adjacent_moves[direction] = Move.new(linked_diagonal_node)
    else
      # However, if the spot is occupied then we need to check for the possibility of a jump
      # Jumping is mandatory, if you can jump then you must
      jump_diagonal_coords = [diagonal_check_coord[0] + x_shift, diagonal_check_coord[1] + y_shift] # REFACTOR
      return unless Board.within_bounds?(jump_diagonal_coords)

      jump_diagonal_linked_node = find_by_coord(jump_diagonal_coords)
      piece.adjacent_moves[direction] = Move.new(jump_diagonal_linked_node, linked_diagonal_node.occupant)
    end
  end

  def populate_adjacency_list(piece)
    if piece.move_up
      populate_adjacenct_direction(piece, :tr)
      populate_adjacenct_direction(piece, :tl)
    end
    if piece.move_down
      populate_adjacenct_direction(piece, :br)
      populate_adjacenct_direction(piece, :bl)
    end
  end

  def occupy(coordinates, occupant)
    return 'error' unless Board.within_bounds?(coordinates)
    linked_node = find_by_coord(coordinates)
    linked_node.data.occupant = occupant
    occupied_spots = get_occupied_dark_spots
    occupied_spots.each do |spot|
      populate_adjacency_list(spot.data.occupant)
    end
  end

  def occupant_remover(coordinates)
    return 'error' unless Board.within_bounds?(coordinates)
    linked_node = find_by_coord(coordinates)
    linked_node.data.occupant = nil
    occupied_spots = get_occupied_dark_spots
    occupied_spots.each do |spot|
      populate_adjacency_list(spot.data.occupant)
    end
  end

  def remove_by_id(id)
    occupied_dark_spots = get_occupied_dark_spots
    occupied_dark_spots.select! { |spot| spot.data.occupant.id == id }
    return 'error' if occupied_dark_spots.empty?
    
    popped_occupant = occupied_dark_spots[0].occupant
    occupied_dark_spots[0].occupant = nil
    occupied_spots = get_occupied_dark_spots
    occupied_spots.each do |spot|
      populate_adjacency_list(spot.data.occupant)
    end
    return popped_occupant
  end

  def move_by_id(id, coordinates)
    occupant = remove_by_id(id)
    occupy(coordinates, occupant)
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

class Player

  def initialize(name = nil)
    get_name if name.nil?
  end

  def get_name
    puts 'What\'s your name? '
    name = gets.chomp
    @name = name
    puts "Hey, #{name}"
  end
end