class Stage

  MAX_LEVEL = 5

  ENEMIES_COUNT = {
    1 => 20,
    2 => 30,
    3 => 40,
    4 => 50,
    5 => 60
  }

  ADD_COUNT = {
    1 => 4..8,
    2 => 5..9,
    3 => 6..10,
    4 => 7..11,
    5 => 8..12
  }

  ENEMIES_MIN_COUNT = {
    1 => 6,
    2 => 8,
    3 => 10,
    4 => 12,
    5 => 14
  }

  attr_reader :level

  def initialize window, level = 1
    @window = window
    @font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
    @total_enemies_count = 0
    @level = level
  end

  def update
    add_enemies if enemies_count(:existing) < ENEMIES_MIN_COUNT[@level]
    level_up if enemies_count(:existing) == 0 && enemies_count(:created) >= ENEMIES_COUNT[@level]
  end

  def draw
    @font.draw("Enemies: #{enemies_count :left}/#{ENEMIES_COUNT[@level]}", 870, 500, ZOrder::Text)
  end

  def level_up
    return if @level == MAX_LEVEL

    @level += 1
    @total_enemies_count = 0
    if @window.ship
      @window.ship.create_shield
      @window.ship.cooldown = [@window.ship.cooldown - 2, 10].max
      @window.ship.speed = [@window.ship.speed + 0.5, 7].min
      @window.ship.bullet_speed = [@window.ship.bullet_speed + 1, 15].min
    end
  end

  def add_enemies
    count = [rand(ADD_COUNT[@level]), ENEMIES_COUNT[@level] - @total_enemies_count].min
    return if count <= 0

    @total_enemies_count += count
    enemies = []
    count.times do
      enemy = nil
      while true
        position = random_position
        if enemy
          enemy.x = position[:x]
          enemy.y = position[:y]
        else
          enemy = EnemyShip.new(@window, Ship::NAMES.sample, position[:x], position[:y], @level)
        end
        flag = true
        (@window.enemies + enemies).each do |e|
          if enemy.collided? e
            flag = false
            break
          end
        end
        if flag
          enemies << enemy
          enemy = nil
          break
        end
      end
    end
    @window.enemies += enemies
  end

  def enemies_count type = :on_map
    case type
    when :on_map
      @window.enemies.reject(&:out_of_map?).size
    when :existing
      @window.enemies.reject(&:destroyed?).size
    when :destroyed
      @window.enemies_destroyed
    when :left
      ENEMIES_COUNT[@level] - @window.enemies_destroyed
    when :created
      @total_enemies_count
    end
  end

  private

  def random_position
    angle1 = Gosu::angle(0, 288, Constants::END_X, Constants::END_Y)
    angle2 = Gosu::angle(478, 576, Constants::END_X, Constants::END_Y)
    angle = rand(angle2..angle1)
    distance = 100 * rand(18..33)
    x = Constants::END_X + Gosu::offset_x(angle + 180, distance)
    y = Constants::END_Y + Gosu::offset_y(angle + 180, distance)
    {x: x, y: y}
  end
end