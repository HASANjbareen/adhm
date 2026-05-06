#!/usr/bin/env ruby
# Hangman Game

WORDS = {
  easy: %w[cat dog sun hat cup ball tree bird fish star moon cake],
  medium: %w[python jungle rocket guitar bridge planet flower castle spider palace],
  hard: %w[javascript algorithm fibonacci labyrinth encyclopedia chrysanthemum]
}

HANGMAN = [
  "
  +---+
  |   |
      |
      |
      |
      |
=========",
  "
  +---+
  |   |
  O   |
      |
      |
      |
=========",
  "
  +---+
  |   |
  O   |
  |   |
      |
      |
=========",
  "
  +---+
  |   |
  O   |
 /|   |
      |
      |
=========",
  "
  +---+
  |   |
  O   |
 /|\\  |
      |
      |
=========",
  "
  +---+
  |   |
  O   |
 /|\\  |
 /    |
      |
=========",
  "
  +---+
  |   |
  O   |
 /|\\  |
 / \\  |
      |
========="
]

COLORS = {
  red:     "\e[31m",
  green:   "\e[32m",
  yellow:  "\e[33m",
  cyan:    "\e[36m",
  magenta: "\e[35m",
  bold:    "\e[1m",
  reset:   "\e[0m"
}

def c(color, text)
  "#{COLORS[color]}#{text}#{COLORS[:reset]}"
end

def clear_screen
  system('clear') || system('cls')
end

def draw(wrong, word, guessed)
  clear_screen
  puts c(:magenta, c(:bold, "\n  ╔══════════════════════════╗"))
  puts c(:magenta, c(:bold, "  ║        HANGMAN            ║"))
  puts c(:magenta, c(:bold, "  ╚══════════════════════════╝"))

  HANGMAN[wrong].each_line { |l| puts c(wrong >= 5 ? :red : :cyan, l) }

  puts "\n  " + word.chars.map { |ch|
    guessed.include?(ch) ? c(:green, c(:bold, " #{ch} ")) : c(:yellow, " _ ")
  }.join(" ")

  puts "\n  " + c(:cyan, "Wrong guesses (#{wrong}/6): ") +
       (guessed - word.chars).map { |g| c(:red, g) }.join(" ")
  puts
end

def play_round(difficulty)
  word  = WORDS[difficulty].sample
  guessed = []
  wrong = 0

  loop do
    draw(wrong, word, guessed)

    if word.chars.all? { |ch| guessed.include?(ch) }
      puts c(:green, c(:bold, "  ✓ YOU WON! The word was '#{word}'!"))
      return true
    end

    if wrong >= 6
      puts c(:red, c(:bold, "  ✗ YOU LOST! The word was '#{word}'."))
      return false
    end

    print "  " + c(:yellow, "Guess a letter: ")
    input = gets&.chomp&.downcase

    unless input&.match?(/^[a-z]$/)
      puts c(:red, "  Enter a single letter a-z.")
      sleep 1
      next
    end

    if guessed.include?(input)
      puts c(:yellow, "  Already guessed '#{input}'!")
      sleep 0.8
      next
    end

    guessed << input
    if word.include?(input)
      puts c(:green, "  Good guess!")
    else
      wrong += 1
      puts c(:red, "  '#{input}' is not in the word.")
    end
    sleep 0.5
  end
end

wins = 0
losses = 0

loop do
  clear_screen
  puts c(:magenta, c(:bold, "\n  === HANGMAN ==="))
  puts "\n  " + c(:cyan, "Difficulty:")
  puts "    1) Easy    2) Medium    3) Hard    0) Quit"
  print "\n  Choice: "
  choice = gets&.chomp

  break if choice == '0'

  diff = case choice
         when '1' then :easy
         when '2' then :medium
         when '3' then :hard
         else
           puts c(:red, "  Invalid choice.")
           sleep 1
           next
         end

  result = play_round(diff)
  result ? wins += 1 : losses += 1

  puts "\n  " + c(:yellow, "Score — Wins: #{wins} | Losses: #{losses}")
  print "  " + c(:cyan, "Play again? [y/n]: ")
  break unless gets&.chomp&.downcase == 'y'
end

puts "\n" + c(:magenta, c(:bold, "  Final: Wins=#{wins}  Losses=#{losses}"))
puts c(:cyan, "  Thanks for playing!\n")
