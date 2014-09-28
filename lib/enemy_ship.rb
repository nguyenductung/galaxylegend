class EnemyShip < Ship

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

  DESTROY_SCORE = {
    1 => 10,
    2 => 15,
    3 => 20,
    4 => 25,
    5 => 30
  }

  def initialize window, name, x, y
    super window, name, x, y
    @level = @window.level
    @speed = SPEED[@level]
    @bullet_speed = BULLET_SPEED[@level]
    @cooldown = COOLDOWN[@level]
    @fire_rate = FIRE_RATE[@level]
    @destroy_score = DESTROY_SCORE[@level]
    @fire_image = Ship.fire_image @window
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

  def explode
    return if exploding?
    @exploding = true
    @exploded_at = @window.frame
    @explosion = Explosion.new @window, self
    @window.score += destroy_score
  end

  def fire
    return unless @window.frame >= @last_fire_frame + @cooldown && rand < @fire_rate && !out_of_map?

    @last_fire_frame = @window.frame
    @bullets << Bullet.new(@window, self, @bullet_speed)
  end
end
