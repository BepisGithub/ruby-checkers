require 'pry'
require 'yaml'
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
    puts ' '
    puts '--------------------'
    dark_occupant = ['▆']
    light_occupant = [' ']
    graph_nodes = @graph.traverse
    y_coordinate_counter = graph_nodes[0].data.coordinate[1]
    print [y_coordinate_counter]
    graph_nodes.each do |linked_node|
      if y_coordinate_counter == linked_node.data.coordinate[1]
        # print linked_node.data.occupant.to_s
        if linked_node.data.occupant # There is a piece that needs to be displayed
          # display_array = []
          # name = linked_node.data.occupant.owner.name
          # display_array.push(name)
          # linked_node.data.occupant.king ? display_array.push('K') : display_array.push('M')
          # display_array.push(linked_node.data.occupant.id)
          # print ["#{display_array[0]}#{display_array[1]}#{display_array[2]}"]
          print linked_node.data.occupant.display_symbol
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
        print [y_coordinate_counter].to_s
        if linked_node.data.occupant # There is a piece that needs to be displayed
          print linked_node.data.occupant.display_symbol
        else
          if linked_node.data.dark
            print dark_occupant
          else
            print light_occupant
          end
        end
      end
    end
    puts ' '
    arr = [0]
    8.times do |i|
      arr.push([i + 1])
    end
    puts arr.to_s
  end

  def won?
    nodes = get_occupied_dark_spots
    first_person_on_list = nodes[0].data.occupant.owner
    winner = first_person_on_list
    nodes.each do |node|
      winner = false if node.data.occupant.owner != first_person_on_list
    end
    return winner
  end

  def find_by_id(id)
    nodes = get_occupied_dark_spots
    nodes.select! { |node| node.data.occupant.id == id }
    return nodes[0]
  end

  def find_by_coord(coord_array)
    nodes = @graph.traverse
    nodes.select! { |node| node.data.coordinate == coord_array}
    return nodes[0]
  end

  def populate_adjacenct_direction(piece, direction)
    piece_linked_node = find_by_id(piece.id)
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
    linked_diagonal_node = find_by_coord(diagonal_check_coord)
    jump_coord = [diagonal_check_coord[0] + x_shift, diagonal_check_coord[1] + y_shift]
    linked_jump_node = find_by_coord(jump_coord)
    return if linked_diagonal_node.nil?
    if linked_diagonal_node.data.occupant.nil?
      piece_linked_node.data.occupant.adjacent_moves[direction] = Move.new(linked_diagonal_node)
    elsif linked_jump_node.nil?
      return nil
    elsif linked_diagonal_node.data.occupant.owner.name != piece_linked_node.data.occupant.owner.name && linked_jump_node.data.occupant.nil?
      piece_linked_node.data.occupant.adjacent_moves[direction] = Move.new(linked_jump_node, linked_diagonal_node.data.occupant)
    end
  end

  def populate_adjacency_list(piece)
    piece.adjacent_moves = {}
    if piece.move_up
      populate_adjacenct_direction(piece, :tr)
      populate_adjacenct_direction(piece, :tl)
    end
    if piece.move_down
      populate_adjacenct_direction(piece, :br)
      populate_adjacenct_direction(piece, :bl)
    end
  end

  def populate_all_pieces_adjacency_list
    occupied = get_occupied_dark_spots
    occupied.each do |node|
      populate_adjacency_list(node.data.occupant)
    end
  end

  def occupy(coordinates, occupant)
    return 'error' unless Board.within_bounds?(coordinates)
    linked_node = find_by_coord(coordinates)
    linked_node.data.occupant = occupant
    # populate_all_pieces_adjacency_list
  end

  def occupant_remover(coordinates)
    return 'error' unless Board.within_bounds?(coordinates)
    linked_node = find_by_coord(coordinates)
    linked_node.data.occupant = nil
    # populate_all_pieces_adjacency_list
  end

  def remove_by_id(id)
    occupied_dark_spots = get_occupied_dark_spots
    occupied_dark_spots.select! { |spot| spot.data.occupant.id == id }
    return 'error' if occupied_dark_spots.empty?
    
    popped_occupant = occupied_dark_spots[0].data.occupant
    occupied_dark_spots[0].data.occupant = nil
    # populate_all_pieces_adjacency_list
    return popped_occupant
  end

  def move_by_id(id, coordinates)
    occupant = remove_by_id(id)
    occupy(coordinates, occupant)
    # populate_all_pieces_adjacency_list
  end

  def setup_board(player1, player2)
    dark_spots = get_dark_spots
    player1_pieces = player1.pieces_list.traverse
    player2_pieces = player2.pieces_list.traverse
    dark_spots.each do |linked_spot|
      break if player1_pieces.empty?
      shifted_value = (player1_pieces.shift).data
      occupy(linked_spot.data.coordinate, shifted_value)
    end
    dark_spots.reverse!
    dark_spots.each do |linked_spot|
      break if player2_pieces.empty?
      shifted_value = (player2_pieces.shift).data
      occupy(linked_spot.data.coordinate, shifted_value)
    end
    populate_all_pieces_adjacency_list
  end

  def king_check
    occupied_dark_spots = get_occupied_dark_spots
    # Check if any are at the edges of the board (y coord 1 or y coord 8)
    occupied_dark_spots.select! { |linked_spot| linked_spot.data.coordinate[1] == 1 || linked_spot.data.coordinate[1] == 8 }
    # Reject any kings (because we dont need to make it into a king)
    occupied_dark_spots.reject! { |linked_spot| linked_spot.data.occupant.king }
    return nil if occupied_dark_spots.nil?
    # The pieces that turn into a king at the top have the variable move up as true (bc they spawned at the bottom) and they are at the top (to turn into a king)
    top_kings = occupied_dark_spots.select { |linked_spot| linked_spot.data.occupant.move_up && linked_spot.data.coordinate[1] == 8 }
    # A similar check is done for the bottom pieces
    bottom_kings = occupied_dark_spots.select { |linked_spot| linked_spot.data.occupant.move_down && linked_spot.data.coordinate[1] == 1 }

    # Now to make them into kings
    top_kings.each do |top_king|
      top_king.data.occupant.king = true
      top_king.data.occupant.move_down = true
      top_king.data.occupant.display_symbol == ['⛀'] ? top_king.data.occupant.display_symbol = ['⛁'] : top_king.data.occupant.display_symbol = ['⛃']
    end
    bottom_kings.each do |bottom_king|
      bottom_king.data.occupant.king = true
      bottom_king.data.occupant.move_up = true
      bottom_king.data.occupant.display_symbol == ['⛀'] ? bottom_king.data.occupant.display_symbol = ['⛁'] : bottom_king.data.occupant.display_symbol = ['⛃']
    end
  end
end

class Pieces
  attr_accessor :id, :owner, :king, :move_up, :move_down, :adjacent_moves, :display_symbol

  def initialize(id, owner, move_up, king = false)
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
    @display_symbol = owner.piece_symbol
  end
end

class Player
  attr_accessor :name, :active, :won, :pieces_list, :piece_symbol

  def initialize(name = nil)
    @name = name unless name.nil?
    @active = false
    @won = false
    @pieces_list = LinkedList.new
    @piece_symbol
  end

  def get_name
    puts 'What\'s your name? '
    name = gets.chomp.capitalize
    @name = name
    puts "Hey, #{name}"
  end

  def get_choice(board)
    # Need to check the pieces that can jump, if any
    # Other moves must be discarded if a jump can be made
    all_pieces = board.get_occupied_dark_spots
    all_pieces.select! { | linked_spot | linked_spot.data.occupant.owner.name == @name}
    jump_possible = false
    all_pieces.each do |piece|
      piece.data.occupant.adjacent_moves.each do |k, v|
        jump_possible = true unless v.jumped_piece.nil?
      end
      break if jump_possible
    end
    # Filtering out non jumps if a jump is possible
    if jump_possible
      all_pieces.each do |piece|
        piece.data.occupant.adjacent_moves.select! { |direction, move| move.jumped_piece } # Possible source of bug
      end
    end
    choice_node = nil
    loop do
      puts 'Write the x coordinate of the piece you want to get'
      puts 'If you can make a jump, you must' if jump_possible
      x_choice = -1
      y_choice = -1
      x_choice = gets.chomp.to_i until x_choice <= 8 && x_choice.positive? # FIX later
      puts 'Write the y coordinate of the piece you want to get'
      y_choice = gets.chomp.to_i until y_choice <= 8 && y_choice.positive? # FIX later
      choice_node = board.find_by_coord([x_choice, y_choice])
      puts 'Invalid, try again' if choice_node.data.occupant.nil? || choice_node.data.occupant.owner.name != @name
      # choice_node = nil if choice_node.data.occupant.owner.name != @name # HACK
      break unless choice_node.data.occupant.nil? || choice_node.data.occupant.owner.name != @name # HACK
    end
    piece = choice_node.data.occupant
    return nil if piece.nil?
    return nil if piece.adjacent_moves.empty?
    puts 'Which direction do you want to move the piece in?'
    puts 'Top right? (type tr)' unless piece.adjacent_moves[:tr].nil?
    puts 'Top left? (type tl)' unless piece.adjacent_moves[:tl].nil?
    puts 'Bottom right? (type br)' unless piece.adjacent_moves[:br].nil?
    puts 'Bottom left? (type bl)' unless piece.adjacent_moves[:bl].nil?
    move_choice = nil
    loop do
      move_choice = gets.chomp until move_choice.is_a? String
      case move_choice
      when 'tr'
        move_choice = :tr unless piece.adjacent_moves[:tr].nil?
        break
      when 'tl'
        move_choice = :tl unless piece.adjacent_moves[:tl].nil?
        break
      when 'bl'
        move_choice = :bl unless piece.adjacent_moves[:bl].nil?
        break
      when 'br'
        move_choice = :br unless piece.adjacent_moves[:br].nil?
        break
      else
        move_choice = nil
      end
      break unless move_choice.nil?
    end
    return [piece.id, move_choice]
  end
end

class Game
  attr_accessor :player1, :player2, :board, :save_file_name

  def initialize
    @save_file_name = 'save.JSON'
    load_status = load_game
    if load_status.nil?
      @player1 = Player.new
      @player2 = Player.new
      puts 'Player 1!'
      @player1.get_name
      puts 'Player 2!'
      @player2.get_name
      @player1.piece_symbol = ['⛀']
      @player2.piece_symbol = ['⛂']
      @board = Board.new
      @board.display
      rand(1..10) % 2 ? @player1.active = true : @player2.active = true
      num_of_player_pieces = 24
      @player1.active ? active = @player1 : active = @player2
      move_up = true
      num_of_player_pieces.times do |id|
        if (id + 1) == 13
          active == @player1 ? active = @player2 : active = @player1
          move_up = false
        end
        # Create pieces for player 1, then player 2
        # Each player has a pieces list which is a linked list
        # Append a piece to the linked list with the ID
        active.pieces_list.append(LinkedNode.new(Pieces.new((id + 1), active, move_up)))
        # The piece will take the id, the owner and the direction to move (which will be the opposite the two players)
      end
      if @player1.pieces_list.head.data.move_down
        down_moving_player = @player1
        up_moving_player = @player2
      else
        down_moving_player = @player2
        up_moving_player = @player1
      end
      @board.setup_board(down_moving_player, up_moving_player)
    end
  end

  def play
    #binding.pry
    @player1.active ? active = @player1 : active = @player2
    # check for a return value indicating a win
    winner = round(active)
    until winner
    # if no win switch active players
    # repeat
      if @player1.active
        @player1.active = false
        @player2.active = true
        active = @player2
      else
        @player1.active = true
        @player2.active = false
        active = @player1
      end
      winner = round(active)
      @board.populate_all_pieces_adjacency_list
      save_game_prompt
    end
    game_end(winner)
  end

  def game_end(winner)

  end

  def round(active)
    @board.king_check
    @board.display
    puts "#{active.name}, your symbol is #{active.piece_symbol}. It's your turn to make a move"
    move_choice = active.get_choice(@board) # returns an array with the id and the direction choice
    while move_choice.nil?
      move_choice = active.get_choice(@board) # returns an array with the id and the direction choice
    end
    id_choice = move_choice[0]
    move_choice = move_choice[1]

    # find the piece by id
    piece = @board.find_by_id(id_choice)
    @board.populate_all_pieces_adjacency_list
    move = piece.data.occupant.adjacent_moves[move_choice]
    piece = piece.data.occupant
    # check the direction choice
    if move.jumped_piece.nil?
      # if it does not involve a jump, make the move
      @board.move_by_id(id_choice, move.end_spot.data.coordinate)
    else
      # else if it does involve a jump
      # remove the jumped piece from the board (find the jumped piece using the move item)
      @board.remove_by_id(move.jumped_piece.id)
      @board.move_by_id(id_choice, move.end_spot.data.coordinate)
      # recalculate adjacency list (the other board methods should do this automatically)
      @board.populate_all_pieces_adjacency_list
      piece = @board.find_by_id(id_choice)
      piece = piece.data.occupant
      jump_num = 0
      piece.adjacent_moves.each do |k, v|
        if v.jumped_piece
          jump_num += 1
          break
        end
      end
      while jump_num.positive?
        @board.display
        puts 'There is a multi jump (you performed a jump and there is another jump available). You must take it'
        puts 'This will be done automatically unless there are multiple potential directions'
        @board.populate_all_pieces_adjacency_list
        piece = @board.find_by_id(id_choice)
        piece = piece.data.occupant
        piece.adjacent_moves.select! { |k, v| v.jumped_piece }
        jump_num = piece.adjacent_moves.count
        if jump_num == 1
          # The piece has one move in the hash
          # The key is the direction
          # The value is a move instance
          move = piece.adjacent_moves[piece.adjacent_moves.keys[0]]
          # The move instance contains an end coordinate and a jumped piece
          # Remove the jumped piece
          @board.remove_by_id(move.jumped_piece.id)
          # Move the piece to the end coordinate
          @board.move_by_id(id_choice, move.end_spot.data.coordinate)
        elsif jump_num > 1
          # List the possble jumps to make
          puts 'Which direction do you want to move the piece in?'
          puts 'Top right? (type tr)' unless piece.adjacent_moves[:tr].nil?
          puts 'Top left? (type tl)' unless piece.adjacent_moves[:tl].nil?
          puts 'Bottom right? (type br)' unless piece.adjacent_moves[:br].nil?
          puts 'Bottom left? (type bl)' unless piece.adjacent_moves[:bl].nil?
          # Get the users choice of which jump to make
          move_choice = nil
          loop do
            move_choice = gets.chomp until move_choice.is_a? String
            case move_choice
            when 'tr'
              move_choice = :tr unless piece.adjacent_moves[:tr].nil?
              break
            when 'tl'
              move_choice = :tl unless piece.adjacent_moves[:tl].nil?
              break
            when 'bl'
              move_choice = :bl unless piece.adjacent_moves[:bl].nil?
              break
            when 'br'
              move_choice = :br unless piece.adjacent_moves[:br].nil?
              break
            else
              move_choice = nil
            end
            break unless move_choice.nil?
          end
          # Get the move for that direction in the hash
          move = piece.adjacent_moves[move_choice]
          # Remove the jumped piece
          @board.remove_by_id(move.jumped_piece.id)
          # Move the piece to the end coordinate
          @board.move_by_id(id_choice, move.end_spot.data.coordinate)
        end
      end
    end
    @board.won?
    # if win then set winner and break
  end

  def save_game_prompt
    # binding.pry
    puts 'Would you like to save the game? Type y for yes'
    response = gets.chomp
    return unless response == 'y' || response == 'yes'
    puts 'saving'
    # save_data = JSON.generate('player1': @player1.to_json, 'player2': @player2.to_json, 'board': @board.to_json)
    @board.populate_all_pieces_adjacency_list
    save_data = {:player1 => @player1, :player2 => @player2, :board => @board }.to_yaml
    puts 'Serialized data'
    File.open(@save_file_name, 'w+') # Overwrite the file
    puts 'Opened file'
    File.write(@save_file_name, save_data) # Write the data
    puts 'Saved game!'
  end

  def load_game
    return nil unless File.file?(@save_file_name)
    puts 'Would you like to resume from the saved game? Type y for yes'
    response = gets.chomp
    return nil unless response == 'y' || response == 'yes'
    #binding.pry
    puts 'loading...'
    save_data = File.read(@save_file_name)
    puts 'Loaded file!'
    save_data = YAML.load(save_data)
    puts 'Parsed data!'
    @player1 = save_data[:player1]
    puts 'Loaded first player!'
    @player2 = save_data[:player2]
    puts 'Loaded second player!'
    @board = save_data[:board]
    puts 'Loaded board!'
    if @player1.active
      @player1.active = false
      @player2.active = true
    else
      @player2.active = false
      @player1.active = true
    end
    # binding.pry
  end
end