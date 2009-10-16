#
# Droid - Our basic enemy class
#
# See Playstate#update for overall movement / collision logic
#
class Droid < Chingu::GameObject
  has_trait :timer, :velocity, :collision_detection
  attr_reader :current_animation
  
  @@red = Gosu::Color.new(255, 255, 0, 0)
  @@blue = Gosu::Color.new(255, 0, 255, 0)
  @@green = Gosu::Color.new(255, 0, 0, 255)
  @@white = Gosu::Color.new(255, 255, 255, 255)
  @@grey = Gosu::Color.new(255, 127, 127, 127)
  @@yellow = Gosu::Color.new(255, 255, 255, 0)
  
  def initialize( options )
    super
    @width = 11
    @height = 16
    @full_animation = Chingu::Animation.new(:file => media_path("droid.bmp"), :size => [@width,@height]).retrofy
    
    @animations = {}
    @animations[:scan] = @full_animation[0..5]
    @animations[:up] = @full_animation[6..7]
    @animations[:down] = @full_animation[8..9]
    @animations[:left] = @full_animation[10..11]
    @animations[:right] = @full_animation[12..13]
    @animations[:die] = @full_animation[0..1]     # TODO, make some real exploding frames?
    @animations[:die].delay = 25    
    stop
    
    self.rotation_center(:top_left)
    
    self.factor = $window.factor
    @bounding_box = Chingu::Rect.new(@x, @y, @width*$window.factor, @height*$window.factor)
  
    @max_speed = 1
  end
  
  def on_collision
    return if @current_animation == :die
    @status = :paused
    stop
    use_animation(:die)
    die_colors = [@@red, @@blue, @@green]
    explosion_colors = [@@red, @@yellow, @@grey]
    during(1000) do
        @color = die_colors[rand(die_colors.size)] 
        Smoke.create(:x => @x+5, :y => @y+8, :color => @@grey.dup ) 
      end.then do
        Sound["explosion.wav"].play(0.3)
        50.times { BigSpark.create(:x => @x+5, :y => @y+8, :color => explosion_colors ) } 
        destroy 
        # TODO: kill other droids, laser shots or the player in a explosion if they are too close to this one.
      end
        
  end
  
  def stop
    @velocity_x = 0
    @velocity_y = 0
    use_animation(:scan)
  end
  
  def walk_towards(x, y)
    return if @current_animation == :die or @status == :paused
    
    # Set correct velocity so droid walks towards x, y (well, somewhat towards it)
    @velocity_x  = (self.x > x) ? -@max_speed : @max_speed
    @velocity_y  = (self.y > y) ? -@max_speed : @max_speed
    
    @velocity_x  = 0 if (self.x - x).abs < 40
    @velocity_y  = 0 if (self.y - y).abs < 40
    
    after(1000 + rand(2000)) { stop }
  end
  
  def use_animation( name )
    return if name == @current_animation
    @current_animation = name
    @animation = @animations[name]
    @image = @animation.first
  end
  
  def update    
    @image = @animation.next!
    
    use_animation(:left)  if @velocity_x < 0 and @velocity_y == 0
    use_animation(:right) if @velocity_x > 0 and @velocity_y == 0
    use_animation(:down)  if @velocity_y > 0
    use_animation(:up)    if @velocity_y < 0

    #return if @status == :paused
    
    each_collision([TileObject, Droid]) do |me, obj|
      next if me == obj
      on_collision
    end
  end
  
end