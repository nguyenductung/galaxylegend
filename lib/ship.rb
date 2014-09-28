class Ship < GameObject

  NAMES = %w(Alpha Beta Gamma Delta Volkof)

  SPEED = {
    1 => 1,
    2 => 1.1,
    3 => 1.2,
    4 => 1.3,
    5 => 1.4
  }

  BULLET_SPEED = {
    1 => 7,
    2 => 8,
    3 => 9,
    4 => 10,
    5 => 11
  }

  COOLDOWN = {
    1 => 25,
    2 => 22,
    3 => 19,
    4 => 16,
    5 => 13
  }

  FIRE_RATE = {
    1 => 0.006,
    2 => 0.007,
    3 => 0.008,
    4 => 0.009,
    5 => 0.01
  }
  attr_accessor :speed, :bullet_speed, :cooldown, :fire_rate, :level, :bullets, :shield, :special_attack
  attr_writer :x, :y

  def initialize window, name, x, y, level = 1
    @level = level
    @speed = SPEED[@level]
    @bullet_speed = BULLET_SPEED[@level]
    @cooldown = COOLDOWN[@level]
    @fire_rate = FIRE_RATE[@level]
    super window, name, x, y, speed
    @ship_image = Gosu::Image.new(@window, "assets/#{@name}.png", true)
    @exploded_image = Gosu::Image.new(@window, "assets/#{@name}_exploded.png", true)
    @width = @ship_image.width
    @height = @ship_image.height
    @bullets = []
    @last_fire_frame = 0
    @special_attack = false
  end

  def explode
    return if exploding?
    @exploding = true
    @exploded_at = @window.frame
    @explosion = Explosion.new @window, self
  end

  def draw_exploding
    if @window.frame < @exploded_at + 2
      @exploded_image.draw_rot(@x, @y, ZOrder::Explosion, 0, 0.5, 0.5)
    elsif @window.frame > @exploded_at + 5
      @explosion.draw
    end
  end

  def fire
    return if out_of_map? || @window.frame < @last_fire_frame + @cooldown

    @last_fire_frame = @window.frame
    @bullets << Bullet.new(@window, self, @bullet_speed)

    if @special_attack
      @bullets << Bullet.new(@window, self, @bullet_speed,
        @x + Gosu::offset_x(Constants::ANGLE, 60), @y + Gosu::offset_y(Constants::ANGLE, 60))
      @bullets << Bullet.new(@window, self, @bullet_speed,
        @x + Gosu::offset_x(Constants::ANGLE + 180, 60), @y + Gosu::offset_y(Constants::ANGLE + 180, 60))
    end
  end

  def radius
    has_shield? ? super * 1.5 : super
  end

  def create_shield
    @shield ||= Shield.new @window, self
  end

  def has_shield?
    !@shield.nil?
  end

end
