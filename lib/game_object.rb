class GameObject

  attr_reader :x, :y, :name, :speed, :width, :height

  def initialize window, name = nil, x = nil, y = nil, speed = nil
    @window = window
    @name = name
    @x = x
    @y = y
    @width = 0
    @height = 0
    @speed = speed
    @exploding = false
    @destroyed = false
  end

  def radius
    [@width, @height].min / 2.0
  end

  def update
    return if destroyed?
  end

  def draw
    return if destroyed?
  end

  def exploding?
    @exploding
  end

  def destroyed?
    @destroyed || gone?
  end

  def destroy
    @destroyed = true
  end

  def out_of_map?
    @x <= 0 || @x >= @window.width || @y <= 0 || @y >= @window.height
  end

  def gone?
    @x < 0 || (@x <= @window.width && @y > @window.height)
  end

  def collided? object
    !!object && Gosu::distance(self.x, self.y, object.x, object.y) <= self.radius + object.radius
  end

  def move_toward angle, distance = @speed
    return unless angle
    @x += Gosu::offset_x(angle, distance)
    @y += Gosu::offset_y(angle, distance)
  end
end