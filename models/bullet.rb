
class Bullet < Chingu::GameObject
  @@red = Gosu::Color.new(255, 255, 0, 0)
  @@white = Gosu::Color.new(255, 255, 255, 255)
  
  has_trait :collision_detection, :velocity
  attr_reader :owner
  
  def initialize( options )
    super
    @owner = options[:owner] || nil    
    @velocity = options[:velocity]
    @dir = options[:dir] # :west, :east, :north, :south, :ne, :nw, :se, :sw
    @c = @@red.dup
    @speed = options[:supershot] ? 8.0 : 4.0
        
    @bounding_box = Chingu::Rect.new([@x, @y, 3,3])
    @length = 5
    Sound["laser.wav"].play($settings['sound'])
    
    if @velocity
      @velocity_x, @velocity_y = @velocity
    else
      @directions = options[:directions]  # A hash like: {:east => true, :north => true}
      @velocity_x, @velocity_y = $window.directions_to_xy(@directions)
    end
      
    @velocity_x *= @speed
    @velocity_y *= @speed
    
    @anim = Chingu::Animation.new( :file => "laser.png", :size=>[2,8], :delay => 10).retrofy
    @image = @anim.next!
    self.factor = $window.factor
    
    @angle = Gosu::angle(0,0,@velocity_x,@velocity_y)
  end
  
  def on_collision(object = nil)
    # Spawn 5 white sparks and 5 red sparks ... maybe we should just go with red?
    5.times { Spark.create(:x => @x, :y => @y, :color => @@red.dup ) }
    5.times { Spark.create(:x => @x, :y => @y, :color => @@white.dup ) }
    Sound["laser_hits_wall.wav"].play($settings['sound'])
    
    destroy
  end
  
  def update    
    @image = @anim.next!
    each_collision([TileObject, Otto, Bullet, Droid, Player]) do |me, obj|
      next if me == obj or me.owner == obj
      on_collision(obj)
      obj.on_collision(me) if obj.respond_to? :on_collision
    end
    
    destroy   if outside_window?
  end
  
  # def draw
  #   $window.draw_line(@x, @y, @c, @x + @velocity_x * @length, @y + @velocity_y * @length, @c)
  # end
  
end