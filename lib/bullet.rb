class Bullet < GameObject

  class << self
    def image1 window
      @image1 ||= Gosu::Image.new(window, "assets/bullet1.png", true)
    end

    def image2 window
      @image2 ||= Gosu::Image.new(window, "assets/bullet2.png", true)
    end

    def fire_sound window
      @fire_sound ||= Gosu::Sample.new(window, "assets/missle_fire.ogg")
    end

    def impact_sound window
      @impact_sound ||= Gosu::Sample.new(window, "assets/missle_impact.ogg")
    end
  end

  def initialize window, source, speed = 10, x = nil, y = nil
    @window = window
    @source = source
    @image = source == @window.ship ? self.class.image1(@window) : self.class.image2(@window)
    @x = x || source.x
    @y = y || source.y
    @width = @image.width
    @height = @image.height
    @target_x = Constants::END_X
    @target_y = Constants::END_Y
    @speed = speed
    @sound = self.class.fire_sound @window
    @sound.play
  end

  def update
    destroy and return if out_of_map?
    check_hit
    angle = Gosu::angle(@x, @y, @target_x, @target_y)
    angle += 180 if @source != @window.ship
    move_toward angle unless destroyed?
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Bullet, 0, 0.5, 0.5)
  end

  def destroy
    super
    @source.bullets.delete self
  end

  def explode
    self.class.impact_sound(@window).play
    destroy
  end

  def check_hit
    return if destroyed?
    if @source == @window.ship
      @window.enemies.each do |enemy|
        if collided? enemy
          explode
          enemy.explode
          return
        end
      end
    else
      if collided? @window.ship
        explode
        @window.ship.explode unless @window.ship.has_shield?
      end
    end
  end
end