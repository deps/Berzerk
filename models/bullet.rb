

  
class Bullet < Chingu::GameObject
  @@red = Gosu::Color.new(255, 255, 0, 0)
  @@white = Gosu::Color.new(255, 255, 255, 255)
  
  has_trait :collision_detection
  attr_reader :owner
  
  def initialize( options )
    super
    @owner = options[:owner] || nil    
    @dir = options[:dir] # :west, :east, :north, :south, :ne, :nw, :se, :sw
    @c = @@red.dup
    @speed = options[:supershot] ? 8.0 : 4.0
    @bounding_box = Chingu::Rect.new([@x, @y, 1,1])
    Sound["laser.wav"].play(0.3)
  end
  
  def move( xoff, yoff )
    @x += xoff*@speed
    @y += yoff*@speed
  end
  
  
  def on_collision
    # Spawn 5 white sparks and 5 red sparks ... maybe we should just go with red?
    5.times { Spark.create(:x => @x, :y => @y, :color => @@red.dup ) }
    5.times { Spark.create(:x => @x, :y => @y, :color => @@white.dup ) }
    Sound["laser_hits_wall.wav"].play(0.3)
    
    destroy
  end
  
  def update

    super
    
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
      raise "Bullet is moving in an unknown direction '#{@dir}'"
    end
    
    each_collision([TileObject, Otto]) do |me, obj|
      on_collision
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