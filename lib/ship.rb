class Ship < GameObject

  NAMES = %w(Flagship Alpha Beta Gamma Delta Volkof)

  class << self
    def font
      @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    end

    def fire_image window
      @fire_image ||= Gosu::Image.new(window, "assets/fire.png", true)
    end

    def ship_images window
      unless @ship_images
        @ship_images = {}
        NAMES.each { |name| @ship_images[name] = Gosu::Image.new(window, "assets/#{name}.png", true) }
      end
      @ship_images
    end

    def exploded_images window
      unless @exploded_images
        @exploded_images = {}
        NAMES.each { |name| @exploded_images[name] = Gosu::Image.new(window, "assets/#{name}_exploded.png", true) }
      end
      @exploded_images
    end

    def bonus_images window
      unless @bonus_images
        @bonus_images = {}
        %w(boost satk shield).each { |item| @bonus_images[item] = Gosu::Image.new(window, "assets/bonus_#{item}.png") }
      end
      @bonus_images
    end
  end

  attr_accessor :speed, :bullet_speed, :cooldown, :fire_rate, :level, :bullets, :shield, :destroy_score, :special_attack, :boosting
  attr_writer :x, :y

  def initialize window, name, x, y
    super
    @ship_image = self.class.ship_images(@window)[name]
    @exploded_image = self.class.exploded_images(@window)[name]
    @width = @ship_image.width
    @height = @ship_image.height
    @bullets = []
    @last_fire_frame = 0
    @shield_available = false
    @special_attack = false
    @boosting = false
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

  def fire use_satk = false
    return if out_of_map? || @window.frame < @last_fire_frame + @cooldown

    @last_fire_frame = @window.frame
    @bullets << Bullet.new(@window, self, @bullet_speed)

    if @special_attack && use_satk
      @bullets << Bullet.new(@window, self, @bullet_speed,
        @x + Gosu::offset_x(Constants::ANGLE, 60), @y + Gosu::offset_y(Constants::ANGLE, 60))
      @bullets << Bullet.new(@window, self, @bullet_speed,
        @x + Gosu::offset_x(Constants::ANGLE + 180, 60), @y + Gosu::offset_y(Constants::ANGLE + 180, 60))
    end
  end

  def radius
    has_shield? ? super * 1.5 : super
  end

  def has_shield?
    !@shield.nil?
  end

  def special_attack_available?
    @special_attack
  end

  def is_boosting?
    @boosting
  end
end
