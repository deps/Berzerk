
class Bullet < Chingu::GameObject
  @@red = Gosu::Color.new(255, 255, 0, 0)
  @@white = Gosu::Color.new(255, 255, 255, 255)
  
  has_trait :collision_detection, :velocity
  attr_reader :owner
  
  def initialize( options )
    super
    @owner = options[:owner] || nil    
    @dir = options[:dir] # :west, :east, :north, :south, :ne, :nw, :se, :sw
    @c = @@red.dup
    @speed = options[:supershot] ? 8.0 : 4.0
    @bounding_box = Chingu::Rect.new([@x, @y, 3,3])
    @length = 5
    Sound["laser.wav"].play(0.3)
    
    @directions = options[:directions]  # A hash like: {:east => true, :north => true}
    @velocity_x, @velocity_y = $window.directions_to_xy(@directions)
    @velocity_x *= @speed
    @velocity_y *= @speed
  end
  
  def on_collision
    # Spawn 5 white sparks and 5 red sparks ... maybe we should just go with red?
    5.times { Spark.create(:x => @x, :y => @y, :color => @@red.dup ) }
    5.times { Spark.create(:x => @x, :y => @y, :color => @@white.dup ) }
    Sound["laser_hits_wall.wav"].play(0.3)
    
    destroy
  end
  
  def update    
    each_collision([TileObject, Otto, Bullet, Droid, Player]) do |me, obj|
      next if me == obj or me.owner == obj
      on_collision
      obj.on_collision if obj.respond_to? :on_collision
    end
    
    destroy   if outside_window?
  end
  
  def draw
    $window.draw_line(@x, @y, @c, @x + @velocity_x * @length, @y + @velocity_y * @length, @c)
  end
  
end