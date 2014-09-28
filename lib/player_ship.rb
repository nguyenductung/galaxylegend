class PlayerShip < Ship

  SATK_UPTIME    = 5  * 50
  SATK_INTERVAL  = 15 * 50
  BOOST_UPTIME   = 10 * 50
  BOOST_INTERVAL = 10 * 50

  SHIELD_COUNT = {
    1 => 1,
    2 => 1,
    3 => 1,
    4 => 2,
    5 => 2
  }

  attr_accessor :shield_left

  def initialize window
    super window, "Flagship", Constants::START_X, Constants::START_Y
    @fire_image = Ship.fire_image @window
    @offset_x = @ship_image.width / 2
    @offset_y = @ship_image.height / 2
    @amplitude = 0.35
    @speed = 5
    @bullet_speed = 10
    @cooldown = 25
    @window.life_left -= 1 if @window.life_left > 0
    @shield_left = SHIELD_COUNT[@window.level]
    @boost_up_frame = 0
    @boost_down_frame = 0
    @satk_up_frame = 0
    @satk_down_frame = 0
    create_shield false
    @bonus_images = Ship.bonus_images @window
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

    if is_boosting?
      unboost if @window.frame >= @boost_up_frame + BOOST_UPTIME
    else
      boost if @window.score > 0 && @window.score % 100 == 0 && @window.frame >= @boost_down_frame + BOOST_INTERVAL
    end

    if special_attack_available?
      deactivate_satk if @window.frame >= @satk_up_frame + SATK_UPTIME
    else
      activate_satk if @window.stage.enemies_count > 10 && @window.frame >= @satk_down_frame + SATK_INTERVAL
    end

    if @window.button_down?(Gosu::KbSpace)
      fire special_attack_available?
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
    draw_bonus

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

  def create_shield subtract = true
    return if @shield || @shield_left <= 0

    @shield_left -= 1 if subtract
    @shield = Shield.new @window, self
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

  def boost
    @boosting = true
    @original_speed = @speed
    @original_cooldown = @cooldown
    @speed *= 1.5
    @cooldown /= 2.0
    @boost_up_frame = @window.frame
  end

  def unboost
    @boosting = false
    @speed = @original_speed
    @cooldown = @original_cooldown
    @boost_down_frame = @window.frame
  end

  def activate_satk
    @special_attack = true
    @satk_up_frame = @window.frame
  end

  def deactivate_satk
    @special_attack = false
    @satk_down_frame = @window.frame
  end

  def activate_shield
    @shield_available = true
  end

  def deactivate_shield
    @shield_available = false
    @last_shield_frame = @window.frame
  end

  def draw_bonus
    x = 8
    y = 50
    if @shield_left > 0
      @bonus_images["shield"].draw(x, y, ZOrder::Text)
      x += @bonus_images["shield"].width
    end
    if is_boosting?
      @bonus_images["boost"].draw(x, y, ZOrder::Text)
      x += @bonus_images["boost"].width
    end
    if special_attack_available?
      @bonus_images["satk"].draw(x, y, ZOrder::Text)
      x += @bonus_images["satk"].width
    end
  end
end
