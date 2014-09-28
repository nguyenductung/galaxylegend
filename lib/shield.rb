class Shield < GameObject

  UP_TIME = 5 * 50

  class << self
    def images window
      @images ||= Dir.glob("assets/shield*.png").sort.map do |file|
        Gosu::Image.new(window, file, true)
      end
    end

    def sound window
      @sound ||= Gosu::Sample.new(window, "assets/shield.ogg")
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
    @up_frame = @window.frame
  end

  def update
    if @window.frame > @up_frame + UP_TIME
      @object.shield = nil
      destroy
    end

    return if destroyed?

    @x = @object.x
    @y = @object.y

    if @window.frame % 2 == 0
      @image_index += 1
      @image_index %= @images.size
    end
  end

  def draw
    return if destroyed?

    @images[@image_index].draw_rot(@x, @y - 5, ZOrder::Shield, 0, 0.5, 0.5, 0.6, 0.6)
  end
end