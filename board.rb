class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]
  SIZE = 3
  attr_reader :squares

  def initialize
    @squares = formulate_squares
  end

  def generate_draw_lines
    lines = [
      "     |     |     ",
      "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  ",
      "     |     |     ",
      "-----+-----+-----",
      "     |     |     ",
      "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  ",
      "     |     |     ",
      "-----+-----+-----",
      "     |     |     ",
      "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  ",
      "     |     |     "
    ]

    lines
  end

  def unmarked_sq_nums
    @squares.reject { |_, square| square.marked? }.keys
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def full?
    unmarked_sq_nums.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      marked_squares = @squares.values_at(*line).select(&:marked?)
      markers = marked_squares.map(&:marker)
      markers.each { |marker| return marker if markers.count(marker) == SIZE }
    end
    nil
  end

  private

  def formulate_squares
    (1..9).map { |idx| [idx, Square.new(idx.to_s.white)] }.to_h
  end
end

class Square
  attr_accessor :marker

  def initialize(marker)
    @marker = marker
  end

  def marked?
    !('1'..'9').include?(marker.uncolorize)
  end

  def to_s
    @marker
  end
end
