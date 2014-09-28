class Explosion
  class << self
    def images window
      @images ||= Dir.glob("assets/explosion*.png").sort.map do |file|
        Gosu::Image.new(window, file, true)
      end
    end

    def sound window
      @sound ||= Gosu::Sample.new(window, "assets/explosion.ogg")
    end
  end

  def initialize window, object
    @window = window
    @object = object
    @x = @object.x
    @y = @object.y
    @images = self.class.images @window
    @image_index = 0
    @sound = self.class.sound @window
    @sound.play
  end

  def update
    if @image_index < @images.size - 1
      @image_index += 1 if @window.frame % 4 == 0
    else
      @object.destroy
    end
  end

  def draw
    @images[@image_index].draw_rot(@x, @y, ZOrder::Explosion, 0, 0.5, 0.5, 0.75, 0.75)
  end
end