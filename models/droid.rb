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
  
    @max_speed = 0.25
    
    # "feelers" for the droid to see if there is a wall nearby
    # The rects are small, so it is possible for the droid to be wrong, and therefore walk into it.
    @feel_left = Chingu::Rect.new(@x-16,@y+16, 2,2)
    @feel_right = Chingu::Rect.new(@x+40,@y+16, 2,2)
    @feel_up = Chingu::Rect.new(@x+11,y-16, 2,2)
    @feel_down = Chingu::Rect.new(@x+11,@y+50,2,2)
    @wall = {} # :left, :right, :up, :down. true or false if a wall is nearby
  end
  
  def on_collision
    return if @current_animation == :die
    stop
    @status = :paused
    #puts "Droid dying, status: #{@status}"
    use_animation(:die)
    die_colors = [@@red, @@blue, @@green]
    explosion_colors = [@@red, @@yellow, @@grey]
    during(1000) do
        @color = die_colors[rand(die_colors.size)] 
        Smoke.create(:x => @x+5, :y => @y+8, :color => @@grey.dup ) 
      end.then do
        Sound["explosion.wav"].play(0.3)
        ExplosionOverlay.create(:x => @x+11, :y => @y+16)
        50.times { BigSpark.create(:x => @x+5, :y => @y+8, :color => explosion_colors ) } 
        # Kill nearby droids, bullets or the player
        Chingu::GameObject.all.each do |obj|
          next if obj == self or obj.class == TileObject or obj.kind_of? Spark or obj.class == ExplosionOverlay
          dist = Gosu::distance(@x+11,@y+16, obj.x,obj.y)
          if dist < 64
            obj.on_collision
          end
        end
        destroy 
        # TODO: kill other droids, laser shots or the player in a explosion if they are too close to this one.
      end
        
  end
  
  def stop
    #puts "Stopping"
    @velocity_x = 0
    @velocity_y = 0
    return if @status == :paused
    
    #puts "Scan"
    use_animation(:scan)
    @status = :scan
  end
  
  def walk_towards(x, y)
    return if @current_animation == :die or @status == :paused
    
    # Set correct velocity so droid walks towards x, y (well, somewhat towards it)
    dx = self.x - x
    dy = self.y - y
    
    if rand(2) == 0
      @velocity_x  = ((self.x > x) ? -@max_speed : @max_speed) if dx != 0
    else
      @velocity_y  = ((self.y > y) ? -@max_speed : @max_speed) if dy != 0
    end
    #@velocity_x  = 0 if (self.x - x).abs < 40
    #@velocity_y  = 0 if (self.y - y).abs < 40
    
    @velocity_x = 0 if (@wall[:left] and @velocity_x < 0) or (@wall[:right] and @velocity_x > 0)
    @velocity_y = 0 if (@wall[:up] and @velocity_y < 0) or (@wall[:down] and @velocity_y > 0)
    
    
    after(1000 + rand(2000)) { stop }
  end
  
  def use_animation( name )
    return if name == @current_animation
    @current_animation = name
    @animation = @animations[name]
    @image = @animation.first
  end
  
  def update_feelers
    # Reposition the feelers
    @feel_left.x = @x-16
    @feel_left.y = @y+16

    @feel_right.x = @x+40
    @feel_right.y = @y+16

    @feel_up.x = @x+11
    @feel_up.y = @y-16

    @feel_down.x = @x+11
    @feel_down.y = @y+50
    
    # Reset past knowledge of walls
    @wall[:left] = false
    @wall[:right] = false
    @wall[:up]= false
    @wall[:down]= false
    # Find walls
    TileObject.all.each do |tile|
      bb = tile.bounding_box
      @wall[:left] ||= bb.collide_rect? @feel_left
      @wall[:right] ||= bb.collide_rect? @feel_right
      @wall[:up] ||= bb.collide_rect? @feel_up
      @wall[:down] ||= bb.collide_rect? @feel_down
    end
    
    
    #@feel_right = Chingu::Rect.new(@x+40,@y+16, 2,2)
    #@feel_up = Chingu::Rect.new(@x+11,y-16, 2,2)
    #@feel_down = Chingu::Rect.new(@x+11,@y+50,2,2)
    
  end
  
  def update    
    @image = @animation.next!
    player = $window.current_game_state.player
    return if @status == :paused or !player
    
    
    update_feelers
        
    if @wall.values.include? true
      # Almost bumped into a wall there...      
      @velocity_x = 0 if (@wall[:left] and @velocity_x < 0) or (@wall[:right] and @velocity_x > 0)
      @velocity_y = 0 if (@wall[:up] and @velocity_y < 0) or (@wall[:down] and @velocity_y > 0)
      
      #stop
    end

    each_collision([TileObject, Droid]) do |me, obj|
      next if me == obj
      on_collision
    end
    
    use_animation(:left)  if @velocity_x < 0 and @velocity_y == 0
    use_animation(:right) if @velocity_x > 0 and @velocity_y == 0
    use_animation(:down)  if @velocity_y > 0
    use_animation(:up)    if @velocity_y < 0
    
    #if @status != :paused and $window.current_game_state.droid_owned_bullets() < 1 # TODO: number of bullets should be increased when player get more scores      
    #  @bullet = Bullet.create( :x => @x+8, :y => @y+16, :dir => [:north,:south,:west,:east,:nw,:ne,:sw,:se][rand(8)], :owner => self )
    #end

    px = player.x
    py = player.y
    dist = distance(@x,@y, px,py)
    angle_deg = Gosu::angle(px, py, @x, @y)+135
    angle_deg -= 360 if angle_deg > 360
    angle_deg += 360 if angle_deg < 0
    angle = [:east,:se,:south,:sw,:west,:nw,:north,:ne][(angle_deg/360)*8]
    dx = (@x-px).abs
    dy = (@y-py).abs
    
    case @status
    when :scan
      if rand(10) == 5
        #puts "#{angle_deg}, #{angle}"
        @status = :shoot
      elsif dist < 300 and rand(4) == 0
        walk_towards(px,py)
        @status = :walk
        #puts "Walking"
      end
      
      
      
    when :shoot
      if  $window.current_game_state.droid_owned_bullets < 1
        @bullet = Bullet.create( :x => @x+8, :y => @y+16, :dir => angle, :owner => self )
        #puts "Shooting"
      end
      @status = :idle
      after(500+rand(1500)) { @status = :scan }
    end
    
  end
  
  # def draw
  #   super
  #   #$window.current_game_state.debugfont.draw("Status: #{@status}", @x,@y,300)
  #   
  #   wc = Gosu::Color.new(255,255,0,0)
  #   nwc = Gosu::Color.new(255,0,255,0)
  #   
  #   [[@feel_left,:left],[@feel_right,:right],[@feel_up,:up],[@feel_down,:down]].each do |pair|
  #     r = pair[0]
  #     hit = @wall[pair[1]]
  #     c = (hit ? wc : nwc)
  #     $window.draw_quad( r.x,r.y,c, r.x+r.w,r.y,c, r.x+r.w,r.y+r.h,c, r.x,r.y+r.h,c )
  #   end
  #   
  # end
  
end