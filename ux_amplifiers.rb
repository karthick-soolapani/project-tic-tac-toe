module UXAmplifiers
  def prompt(msg)
    puts "=> #{msg}".blue
  end

  def display_divider
    50.times { print '-' }
    puts nil
  end

  def display_clear_screen
    puts "\e[H\e[2J"
  end

  def enter_to_continue
    puts nil
    prompt('Press enter/return to continue...')
    gets
  end

  def check_integer(num)
    num = num.to_s

    if /^[+-]?\d*\.?0*$/.match(num) && /\d/.match(num)
      return :positive if num.to_i.positive?
      return :negative if num.to_i.negative?
      :zero
    else
      :invalid
    end
  end
end
