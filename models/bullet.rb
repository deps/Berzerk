


class Bullet < Chingu::GameObject
  has_trait :collision_detection
  
  def initialize( options )
    super
    @owner = options[:owner]
    @x = options[:x]
    @y = options[:y]
    @dir = options[:dir] # :west, :east, :north, :south, :ne, :nw, :se, :sw
    @c = Gosu::Color.new(255, 255,0,0)
    @speed = 4.0
    @bounding_box = Chingu::Rect.new([@x, @y, 1,1])
    
  end
  
  def move( xoff, yoff )
    @x += xoff*@speed
    @y += yoff*@speed
    
    each_collision(TileObject) do |bullet, tile|
      collide_with_wall
      return
    end
    
  end
  
  
  def collide_with_wall
    # Spawn some sparks here
    destroy
  end
  
  def update

    super
    return if frozen?
    
    case @dir
    when :north
      move(0,-1)
    when :ne
      move(1,-1)
    when :east
      move(1,0)
    when :se
      move(1,1)
    when :south
      move(0,1)
    when :sw
      move(-1,1)
    when :west
      move(-1,0)
    when :nw
      move(-1,-1)
    else
      raise "Bullet is moving in an unknown direction"
    end
    
    if outside_window?
      destroy 
    end
    
  end
  
  def draw

    case @dir
    when :north,:south
      $window.draw_line(@x,@y-5,@c, @x,@y+5,@c)
    when :east,:west
      $window.draw_line(@x-5,@y,@c, @x+5,@y,@c)
    when :ne,:sw
      $window.draw_line(@x+5,@y-5,@c, @x-5,@y+5,@c)
    when :nw,:se
      $window.draw_line(@x-5,@y-5,@c, @x+5,@y+5,@c)
    end
  end
  
end