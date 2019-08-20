require "yaml"

class Hangman
  def initialize
    @word = get_valid_word()
    @wrong_guesses = []
    game_loop
  end

  def game_loop   
    while true
      load_game() if get_startup_entry == "LOAD" 

      until @wrong_guesses.length == 6
        display_guessing_area()

        user_entry = (get_valid_entry(gets.chomp.upcase, ["SAVE", "LOAD", "NEW", "QUIT", unguessed_letters].flatten))
        handle_user_entry(user_entry)

        break if @word == @word.upcase
      end

      display_end_of_game()
      
      display_play_again()
      handle_user_entry(gets.chomp.upcase == "NEW" ? "NEW" : "QUIT" )
    end
  end

  def unguessed_letters
    letters = ("A".."Z").to_a
    @wrong_guesses.each {|letter| letters.delete(letter)}
    @word.split('').each {|letter| letters.delete(letter)}
    letters
  end
  
  def display_play_again
    puts ["" ,
      " Enter 'NEW' to play again" ,
      " or anything else to quit" ,
      "" ]
    print " Entry: "
  end

  def handle_user_entry(user_entry)
    case user_entry
    when "SAVE"
      save_game 
    when "LOAD"
      load_game
    when "NEW"
      new_game
    when "QUIT"
      quit_game
    else
      @wrong_guesses.push(user_entry) unless @word.upcase.include?(user_entry)
      @word.gsub!(user_entry.downcase, user_entry)
    end
  end

  def clear_display
    system("clear") || system("cls")
  end

  def display_game_rules
    puts [
      "|| Rules:                       ||" ,
      "|| Enter a letter to reveal its ||" ,
      "|| location within the password.||" ,
      "|| You must guess all letters   ||" ,
      "|| in the password to be set    ||" ,
      "|| free. Careful though! If you ||" ,
      "|| guess incorrectly six times, ||" ,
      "|| you'll hang!                 ||" ,
      "##################################" ]
  end

  def display_entry_rules(linked=false)
    unless linked 
      puts [
      "                                  " ,
      "##################################" ,] 
    end
    puts [
      "|| Player entries are case      ||" ,
      "|| insensative.                 ||" ,
      "||                              ||" ,
      "|| During the game, enter a     ||" ,
      "|| single letter (upper or      ||" ,
      "|| lowercase) to make a guess.  ||" ,
      "||                              ||" ,
      "|| The other commands avaialbe  ||" ,
      "|| for use at anytime are:      ||" ,
      "|| 'SAVE' -save current game    ||" ,
      "|| 'LOAD' -load the saved game  ||" ,
      "|| 'NEW'  -start a new game     ||" ,
      "|| 'QUIT' -exit the game        ||" ,
      "##################################" ,
      "                                  " ]
    print "Entry: "
  end

  def display_guessing_area()
    clear_display
    puts display_hangman(@wrong_guesses.length)
    puts [
      " Password: #{@word.gsub(/[a-z]/, "_").split('').join(" ")}" ,
      " \n" ,
      " Incorrect guesses: #{@wrong_guesses.join(" ")}" ,
      " \n" ]  
    print " Entry: "
  end

  def display_hangman(num_of_wrong_guesses)
    body = [" O ",
          "     ", 
            "   "]
    body[0] =  "(_)"   if num_of_wrong_guesses >= 1
    body[1] = " |_| "  if num_of_wrong_guesses == 2
    body[1] = "/|_| "  if num_of_wrong_guesses == 3
    body[1] = "/|_|\\" if num_of_wrong_guesses >= 4
    body[2] =  "|  "   if num_of_wrong_guesses == 5
    body[2] =  "| |"   if num_of_wrong_guesses >= 6
    puts [
      "________                            " , 
      "||/    |                            " , 
      "||    #{body[0]}      H A N G M A N " ,  
      "||   #{body[1]}     - - - - - - -   " ,
      "||    #{body[2]}                    " ,
      "||                                  " ,
      "##################################  " ]
  end

  def display_end_of_game
    clear_display
    puts display_hangman(@wrong_guesses.length == 6 ? 6 : 0)
    puts [ 
      " Password: #{@word.upcase.split('').join(' ')}" ,
      " \n" ,
      " #{@wrong_guesses.length == 6 ? "You hung until dead." : "Congratulations! You're free!"}" ]
  end

  def get_valid_word 
    dictionary = File.readlines "dictionary.txt"
    word = ""
    until word.length >= 5 && word.length <= 12
      word = dictionary[rand(0...dictionary.length)].downcase
    end
    word
  end

  def get_startup_entry
    clear_display
    display_hangman(6)
    display_game_rules
    display_entry_rules(linked = true)

    startup_entry = get_valid_entry(gets.chomp.upcase, ["NEW", "LOAD", "QUIT"])
    startup_entry
  end

  def get_valid_entry(user_entry, allowed_commands)
    until allowed_commands.include?(user_entry) 
      display_entry_rules(linked = false)
      user_entry = gets.chomp.upcase
    end
    user_entry
  end 

  def quit_game
    abort("Thanks for playing!")
  end

  def new_game
    @word = get_valid_word()
    @wrong_guesses = []
  end

  def load_game
   if Dir.glob("saves/*").length > 0
    saved_file = get_saved_file
    data = YAML.load File.read(saved_file)
    @word = data[:word]
    @wrong_guesses = data[:wrong_guesses]
    puts " Loading game"
    sleep(1.5)
   else
    puts "There are no saved games"
    sleep(1.5)
   end
  end
  
  def get_saved_file
    save_files = Dir.glob("saves/*").map {|file| file.split(".")[0].split("/")[1]}
    puts "\n Which saved game would you"
    puts " like to load?\n\n"
    puts  save_files
    print "\n File: "
    file = gets.chomp
    until save_files.include? file
      puts "\n Please enter the name of a"
      puts " save file from the list.\n\n"
      print "\n File: "
      file = gets.chomp
    end
    file = "saves/#{file}"
  end

  def save_game
    puts "\n What woud you like to name"
    puts " your save file? \n\n"
    print " File name: "
    file_name = gets.chomp
    save = YAML.dump({
      :word => @word.dup,
      :wrong_guesses => @wrong_guesses.dup
    })
    save_file = File.open("saves/#{file_name}", 'w')
    save_file.puts save
    save_file.close
  end
end

Hangman.new

