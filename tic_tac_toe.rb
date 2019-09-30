$stdout.sync = true # To display output immediately on windows

require 'colorize'

require_relative 'ux_amplifiers'
require_relative 'players'
require_relative 'board'

class Scorecard
  include UXAmplifiers
  attr_reader :score

  def initialize(human, computer)
    @human = human
    @computer = computer
    @score = { human: 0, computer: 0, tie: 0 }
    @round_number = 1
  end

  def display_round_number
    width = TTTGame::FORMAT_WIDTH
    puts "[ROUND - #{@round_number}]".center(width)
  end

  def update_score(winner)
    @score[winner] += 1
  end

  def increment_round_number
    @round_number += 1
  end

  def display_scorecard
    win_score = TTTGame::WIN_SCORE
    score_array = ["#{@human.name} - #{score[:human]}/#{win_score}",
                   "#{@computer.name} - #{score[:computer]}/#{win_score}",
                   "#{'Tie'.yellow} - #{score[:tie]}"]
    formatted_scores = score_array.join('  |  ')

    puts formatted_scores
  end
end

class TTTGame
  include UXAmplifiers
  FIRST_TURN = 'choose' # valid values - 'human', 'computer', 'choose'
  WIN_SCORE = 3
  FORMAT_WIDTH = 32
  BOARD_PADDING = 8
  attr_reader :board, :human, :computer, :scorecard

  def initialize
    display_welcome_message
    @give_up = false
  end

  def play
    setup_human

    loop do
      setup_computer
      determine_first_turn
      setup_scorecard

      play_rounds until game_won? || give_up?
      display_game_winner_message

      break unless play_again?
      display_clear_screen
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    display_clear_screen
    puts <<~welcome
    Let's play Tic Tac Toe
    The first to win #{"#{WIN_SCORE} ROUNDS".red.underline} is the grand winner
    welcome
    puts nil
  end

  def setup_human
    @human = Human.new

    human.determine_marker
  end

  def setup_computer
    choose_computer

    available_markers = ('A'..'Z').to_a - [human.marker.uncolorize]
    computer.determine_marker(available_markers)
  end

  def choose_computer
    display_comp_personality
    comp_choice = nil

    prompt("Who do you want to play against?")
    loop do
      prompt("Choose one - #{Computer::COMPUTERS.join(', ')}")
      comp_choice = gets.chomp

      break if valid_comp?(comp_choice.strip.downcase)
      puts "'#{comp_choice}' is invalid"
    end

    comp_choice = retrieve_valid(comp_choice.strip.downcase)
    @computer = Computer::COMPUTER_MATRIX[comp_choice].call
  end

  def display_comp_personality
    puts nil
    puts Computer::COMPUTER_PERSONALITIES
    puts nil
  end

  def valid_comp?(comp_choice)
    return false if comp_choice.empty?
    Computer::COMPUTER_MATRIX.keys.any? { |comp| comp.start_with?(comp_choice) }
  end

  def retrieve_valid(comp_choice)
    Computer::COMPUTER_MATRIX.keys.each do |valids|
      return valids if valids.start_with?(comp_choice)
    end
  end

  def determine_first_turn
    return @first_turn = human    if FIRST_TURN == 'human'
    return @first_turn = computer if FIRST_TURN == 'computer'

    @first_turn = choose_first_turn == 1 ? human : computer
  end

  def choose_first_turn
    puts nil

    loop do
      prompt("Choose who would go first:")
      prompt("Enter '1' for #{human.name} (OR) '2' for #{computer.name}")
      first_turn = gets.chomp

      if check_integer(first_turn) == :positive && first_turn.to_i <= 2
        break first_turn.to_i
      end

      puts "Sorry, '#{first_turn}' is not valid"
    end
  end

  def setup_scorecard
    @scorecard = Scorecard.new(human, computer)
  end

  def play_rounds
    setup_round
    play_turns until board.someone_won? || board.full?
    scorecard.update_score(who_won)
    display_round_summary
    scorecard.increment_round_number
    enter_to_continue unless game_won? || give_up_trigger?
  end

  def setup_round
    @board = Board.new
    @give_up = false
    human.choice = nil
    computer.choice = nil
    @current_player = @first_turn
  end

  def play_turns
    if human_turn?
      display_clear_screen
      scorecard.display_round_number
      scorecard.display_scorecard
      display_board
      display_computer_choice if computer.choice
    end

    current_player_moves
  end

  def human_turn?
    @current_player == human
  end

  def display_board
    player_markers = marker_identification
    lines = board.generate_draw_lines

    puts player_markers.join('    |  ')
    puts nil
    puts lines.map { |line| (' ' * BOARD_PADDING) + line }
    puts nil
  end

  def marker_identification
    ["#{human.name} - #{human.marker}", "#{computer.name} - #{computer.marker}"]
  end

  def display_computer_choice
    puts "#{computer.name} chose square #{computer.choice}"
    puts nil
  end

  def current_player_moves
    @current_player.move!(board)
    @current_player = next_player
  end

  def next_player
    @current_player == human ? computer : human
  end

  def who_won
    win_marker = board.winning_marker
    return :human    if win_marker == human.marker
    return :computer if win_marker == computer.marker
    :tie
  end

  def display_round_summary
    display_clear_screen

    scorecard.display_round_number
    display_board

    display_divider
    display_round_winner_message
    scorecard.display_scorecard
    display_divider
  end

  def display_round_winner_message
    case who_won
    when :human    then puts "#{human.name} won!".green
    when :computer then puts "#{computer.name} won!".red
    when :tie      then puts "It's a tie".yellow
    end
  end

  def game_won?
    player_score = scorecard.score[:human]
    computer_score = scorecard.score[:computer]

    player_score >= WIN_SCORE || computer_score >= WIN_SCORE
  end

  def give_up?
    return false unless give_up_trigger?

    puts nil
    prompt('Tired? Enter y to give up or any other key to continue')
    reply = gets.chomp

    return @give_up = true if reply.strip.downcase == 'y'
    false
  end

  def give_up_trigger?
    scorecard.score[:tie] >= WIN_SCORE
  end

  def display_game_winner_message
    puts nil
    if @give_up
      puts 'Now you know how I get my wins MUHAHAHA'
      puts "#{computer.name} is the undisputed champion"
    elsif scorecard.score[:human] >= WIN_SCORE
      puts "#{human.name} is crowned as the champion"
      puts "Try playing against a different opponent"
    else
      puts 'Take that. You messed with the wrong person'
    end
    puts nil
  end

  def play_again?
    prompt('Do you want to play again? (y or n)')
    loop do
      play_again = gets.chomp

      return true if %w[y yes].include?(play_again.downcase)
      return false if %w[n no].include?(play_again.downcase)

      prompt("Sorry, '#{play_again}' is invalid. Answer with y or n")
    end
  end

  def display_goodbye_message
    puts nil
    puts "Thank you for playing Tic Tac Toe! See you again!"
    puts nil
  end
end

TTTGame.new.play
