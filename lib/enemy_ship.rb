class EnemyShip < Ship

  def initialize window, name, x, y, level
    super
    @fire_image = Gosu::Image.new(@window, "assets/fire.png", true)
    @offset_x = @ship_image.width / 2
    @offset_y = @ship_image.height / 2
  end

  def update
    destroy if gone?
    return if destroyed?

    fire
    @bullets.each { |bullet| bullet.update }

    if exploding?
      @explosion.update
      return
    end

    move_toward Gosu::angle(@x, @y, Constants::END_X, Constants::END_Y) + 180 unless destroyed?
  end

  def draw
    return if destroyed?

    @bullets.each { |bullet| bullet.draw }

    if exploding?
      draw_exploding
      return
    end

    @ship_image.draw_rot(@x, @y, ZOrder::Ship, 0, 0.5, 0.5)
  end

  def destroy
    super
    @window.enemies.delete self
    @window.enemies_destroyed += 1
  end

  def fire
    return unless @window.frame >= @last_fire_frame + @cooldown && rand < @fire_rate && !out_of_map?

    @last_fire_frame = @window.frame
    @bullets << Bullet.new(@window, self, @bullet_speed)
  end
end
