require 'rubygems'
require 'gosu'

require './lib/constants'
require './lib/game_object'
require './lib/explosion'
require './lib/shield'
require './lib/bullet'
require './lib/ship'
require './lib/player_ship'
require './lib/enemy_ship'
require './lib/stage'

class GameWindow < Gosu::Window

  attr_reader :frame
  attr_accessor :life_left, :ship, :enemies, :enemies_destroyed, :score, :game_state, :stage

  def initialize
    super Constants::WINDOW_WIDTH, Constants::WINDOW_HEIGHT, false, 20
    self.caption = "Galaxy Legend"

    @background_image = Gosu::Image.new(
      self, "assets/battle_bg.png", true, 0, 96,
      Constants::WINDOW_WIDTH, Constants::WINDOW_HEIGHT
    )
    @life_image = Gosu::Image.new(self, "assets/life.png")
    @level_image = Gosu::Image.new(self, "assets/level.png", true)
    @digits = load_digit_images
    @game_state_images = load_game_state_images
    @background_music = Gosu::Song.new(self, "assets/battle.ogg")
    @background_music.play(true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @stage = Stage.new self, 1
    @frame = 0
    @enemies = []
    @enemies_destroyed = 0
    @score = 0
    @life_left = Constants::MAX_LIFE
    @ship = PlayerShip.new self
    @game_state = :none
  end

  def needs_cursor?
    true
  end

  def update
    @frame += 1
    @stage.update
    @ship.update if @ship
    @enemies.each { |enemy| enemy.update }

    unless @ship
      if @life_left > 0
        @ship = PlayerShip.new self
      else
        @game_state = :over
      end
    end

    restart if (@game_state == :over || @game_state == :victory) && button_down?(Gosu::KbReturn)
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    draw_score
    draw_life_left
    draw_level
    @stage.draw
    @ship.draw if @ship

    if @game_state == :over
      draw_game_over
      return
    elsif @game_state == :victory
      draw_victory
      return
    end

    @enemies.each { |enemy| enemy.draw }
   end

  def button_down id
    if id == Gosu::KbEscape
      close
    end
  end

  def level
    @stage.level
  end

  private

  def restart
    @stage = Stage.new self
    @frame = 0
    @enemies = []
    @enemies_destroyed = 0
    @score = 0
    @life_left = Constants::MAX_LIFE
    @ship = PlayerShip.new self
    @game_state = :none
  end

  def load_digit_images
    (0..9).to_a.map { |i| Gosu::Image.new(self, "assets/#{i}.png") }
  end

  def load_game_state_images
    unless @game_state_images
      @game_state_images = {}
      @game_state_images[:over] = Gosu::Image.new(self, "assets/failed.png")
      @game_state_images[:victory] = Gosu::Image.new(self, "assets/victory.png")
    end
    @game_state_images
  end

  def draw_score
    offset = 0
    @score.to_s.each_char do |c|
      digit = c.to_i
      @digits[digit].draw(offset, 0, ZOrder::Text, 0.35, 0.35)
      offset += @digits[digit].width * 0.35 - 10
    end
  end

  def draw_life_left
    @life_left.times do |i|
      @life_image.draw(width - 15 - @life_image.width * (i + 1), 455, ZOrder::Text)
    end
  end

  def draw_level
    x = width - @digits[@stage.level].width * 0.47
    @digits[@stage.level].draw(x, 515, ZOrder::Text, 0.47, 0.47)
    x = x - @level_image.width * 0.5 + 20
    @level_image.draw(x, 510, ZOrder::Text, 0.5, 0.5)
  end

  def draw_game_over
    @game_state_images[:over].draw_rot(width / 2, height / 2, ZOrder::Text,
      0, 0.5, 0.5, 0.6, 0.6)
    @font.draw_rel("Press Enter to restart", width / 2, height / 2 + 50, ZOrder::Text,
      0.5, 0.5) if @frame % 20 > 3
  end

  def draw_victory
    @game_state_images[:victory].draw_rot(width / 2, height / 2, ZOrder::Text,
      0, 0.5, 0.5, 0.6, 0.6)
    @font.draw_rel("Press Enter to restart", width / 2, height / 2 + 50, ZOrder::Text,
      0.5, 0.5) if @frame % 20 > 3
  end
end
