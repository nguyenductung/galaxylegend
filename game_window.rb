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
  attr_accessor :life_left, :ship, :enemies, :enemies_destroyed

  def initialize
    super Constants::WINDOW_WIDTH, Constants::WINDOW_HEIGHT, false, 20
    self.caption = "Galaxy Legend"

    @background_image = Gosu::Image.new(
      self, "assets/battle_bg.png", true, 0, 96,
      Constants::WINDOW_WIDTH, Constants::WINDOW_HEIGHT
    )
    @life_image = Gosu::Image.new(self, "assets/life.png")
    @level_image = Gosu::Image.new(self, "assets/level.png", true)
    @digits = load_digit_image
    @background_music = Gosu::Song.new(self, "assets/battle.ogg")
    @background_music.play(true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @stage = Stage.new self, 5
    @frame = 0
    @enemies = []
    @enemies_destroyed = 0
    @screen = 1
    @score = 0
    @life_left = Constants::MAX_LIFE
    @ship = PlayerShip.new self
    @bonus = Gosu::Image.new(self, "assets/bonus_satk1.png", true)
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
      end
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    draw_life_left
    draw_level
    @stage.draw
    @ship.draw if @ship
    @enemies.each { |enemy| enemy.draw }
    @font.draw("Mouse X: #{mouse_x}, Mouse Y: #{mouse_y}", 600, 20, ZOrder::Text)
   end

  def button_down id
    if id == Gosu::KbEscape
      close
    end
  end

  private

  def load_digit_image
    (0..9).to_a.map { |i| Gosu::Image.new(self, "assets/#{i}.png") }
  end

  def draw_life_left
    @life_left.times do |i|
      @life_image.draw(@life_image.width * i, 40, ZOrder::Text)
    end
  end

  def draw_level
    @level_image.draw(780, 510, ZOrder::Text, 0.5, 0.5)
    @digits[@stage.level].draw(955, 515, ZOrder::Text, 0.47, 0.47)
  end
end
