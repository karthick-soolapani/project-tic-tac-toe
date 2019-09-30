class Player
  include UXAmplifiers
  attr_reader :name, :marker
  attr_accessor :choice
end

class Human < Player
  def initialize
    determine_name
  end

  def determine_marker
    puts nil
    marker_choice = nil

    loop do
      prompt("Choose one alphabet for your marker (A-Z)")
      marker_choice = gets.chomp

      break if ('A'..'Z').include?(marker_choice.strip.upcase)
      puts "'#{marker_choice}' is not a valid choice"
    end

    @marker = marker_choice.strip.upcase.green
  end

  def move!(board)
    square = nil

    loop do
      prompt("Choose a square - numbers visible on the board are available")
      square = gets.chomp

      break if valid_square?(square, board)
      puts "'#{square}' is not a valid choice"
    end

    @choice = square.to_i
    board[@choice] = marker
  end

  private

  def determine_name
    prompt("How would you like me to call you?")
    answer = gets.chomp

    if answer.strip.empty?
      answer = %w[Dovahkiin Neo Samus Rambo Achilles].sample
      puts "Alright, we will call you #{answer.green} then"
    else
      puts "Hello, #{answer.capitalize.green}"
    end

    @name = answer.capitalize.green
  end

  def valid_square?(choice, board)
    return false unless check_integer(choice) == :positive

    board.unmarked_sq_nums.include?(choice.to_i)
  end
end

class Computer < Player
  COMPUTER_MATRIX = {
    'pikachu'   => Proc.new { Pikachu.new },
    'yorha-2b'  => Proc.new { Yorha2B.new },
    'hal-9000'  => Proc.new { Hal9000.new }
  }

  COMPUTERS = %w[(P)ikachu (Y)oRHa-2B (H)AL-9000]

  COMPUTER_PERSONALITIES = [
    'Pikachu loves THAT square',
    '2B has no battle plan as she has lost contact with HQ',
    'Hal is calm, intelligent, extremely rational and is reactive'
  ]

  def determine_marker(available_markers)
    return @marker = 'O'.red if available_markers.include?('O')

    @marker = available_markers.sample.red
  end

  def move!(board)
    @choice = board.unmarked_sq_nums.sample

    board[@choice] = marker
  end
end

class Pikachu < Computer
  def initialize
    @name = 'Pikachu'.red
  end

  def move!(board)
    center_num = 5
    if board.unmarked_sq_nums.include?(center_num)
      @choice = center_num
      board[@choice] = marker
      return
    end

    super
  end
end

class Yorha2B < Computer
  def initialize
    @name = 'YoRHa-2B'.red
  end
end

class Hal9000 < Computer
  def initialize
    @name = 'HAL-9000'.red
  end

  def move!(board)
    @choice = find_offense_choice(board)
    return board[@choice] = marker if @choice

    @choice = find_defense_choice(board)
    return board[@choice] = marker if @choice

    super
  end

  private

  def find_offense_choice(board)
    Board::WINNING_LINES.each do |line|
      mark_sqs, unmark_sqs = board.squares.values_at(*line).partition(&:marked?)

      comp_count = mark_sqs.count { |sq| sq.marker == marker }

      if comp_count == (Board::SIZE - 1) && !unmark_sqs.empty?
        return line.find { |sq_num| !board.squares[sq_num].marked? }
      end
    end
    nil
  end

  def find_defense_choice(board)
    Board::WINNING_LINES.each do |line|
      mark_sqs, unmark_sqs = board.squares.values_at(*line).partition(&:marked?)

      human_count = mark_sqs.count { |sq| sq.marker != marker }

      if human_count == (Board::SIZE - 1) && !unmark_sqs.empty?
        return line.find { |sq_num| !board.squares[sq_num].marked? }
      end
    end
    nil
  end
end