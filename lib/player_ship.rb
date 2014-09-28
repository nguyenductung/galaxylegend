class PlayerShip < Ship

  def initialize window
    super window, "Flagship", Constants::START_X, Constants::START_Y, 0
    @fire_image = Gosu::Image.new(@window, "assets/fire.png", true)
    @offset_x = @ship_image.width / 2
    @offset_y = @ship_image.height / 2
    @amplitude = 0.35
    @speed = 5
    @bullet_speed = 10
    @cooldown = 25
    create_shield
    @window.life_left -= 1 if @window.life_left > 0
  end

  def update
    return if destroyed?

    @bullets.each { |bullet| bullet.update }
    @shield.update if has_shield?

    check_collision

    if exploding?
      @explosion.update
      return
    end

    if @window.button_down?(Gosu::KbSpace)
      fire
    end
    if @window.button_down?(Gosu::KbE)
      explode
    end
    if @window.button_down?(Gosu::KbS)
      create_shield
    end
    if @window.button_down?(Gosu::KbLeft)
      move_leftward
    elsif @window.button_down?(Gosu::KbRight)
      move_rightward
    elsif @window.button_down?(Gosu::KbUp)
      move_forward
    elsif @window.button_down?(Gosu::KbDown)
      move_backward
    else
      @amplitude = -@amplitude if @window.frame % 20 == 0
      move_back_and_forth
    end
  end

  def draw
    return if destroyed?

    @bullets.each { |bullet| bullet.draw }
    @shield.draw if has_shield?

    if exploding?
      draw_exploding
      return
    end

    @ship_image.draw_rot(@x, @y, ZOrder::Ship, 0, 0.5, 0.5)

    if @window.frame % 25 > 5
      @fire_image.draw_rot(@x - 16, @y + 18, ZOrder::Fire, -10, 0.5, 0.5, 0.7, 0.7)
      @fire_image.draw_rot(@x - 32, @y + 3,  ZOrder::Fire, -10, 0.5, 0.5, 0.7, 0.7)
    end
  end

  def destroy
    super
    @window.ship = nil
  end

  private

  def move_back_and_forth
    move_toward Gosu::angle(@x, @y, Constants::END_X, Constants::END_Y), @amplitude
  end

  def move_forward
    if @x < @window.width - @offset_x && @y <= @offset_y
      angle = 90
    elsif @x >= @window.width - @offset_x && @y > @offset_y
      angle = 0
    elsif @x < @window.width - @offset_x && @y > @offset_y
      angle = Gosu::angle(@x, @y, Constants::END_X, Constants::END_Y)
    end
    move_toward angle
  end

  def move_backward
    if @x <= @offset_x && @y < @window.height - @offset_y
      angle = 180
    elsif @x > @offset_x && @y >= @window.height - @offset_y
      angle = -90
    elsif @x > @offset_x && @y < @window.height - @offset_y
      angle = Gosu::angle(@x, @y, Constants::END_X, Constants::END_Y) + 180
    end
    move_toward angle
  end

  def move_leftward
    if 0.3973941368 * @x + @y - 244 < 30
      return # ship cannot move beyond border
    elsif @x > @offset_x && @y <= @offset_y
      angle = -90
    elsif @x <= @offset_x && @y > @offset_y
      angle = 0
    elsif @x > @offset_x && @y > @offset_y
      angle = Constants::ANGLE
    end
    move_toward angle
  end

  def move_rightward
    if 0.5355731225 * @x + @y - 853.4268775 > - 30
      return # ship cannot move beyond border
    elsif @x >= @window.width - @offset_x && @y < @window.height - @offset_y
      angle = 180
    elsif @x < @window.width - @offset_x && @y >= @window.height - @offset_y
      angle = 90
    elsif @x < @window.width - @offset_x && @y < @window.height - @offset_y
      angle = Constants::ANGLE + 180
    end
    move_toward angle
  end

  def check_collision
    @window.enemies.each do |enemy|
      if collided? enemy
        if has_shield?
          enemy.explode
        else
          explode
        end
        return
      end
    end
  end
end
