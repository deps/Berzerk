#
# Droid - Our basic enemy class
#
# See Playstate#update for overall movement / collision logic
#
class Droid < Chingu::GameObject
  has_trait :timer, :velocity, :collision_detection
  attr_reader :current_animation, :status
  
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
    @full_animation = Chingu::Animation.new(:file => "droid.bmp", :size => [@width,@height]).retrofy
    
    @max_bullets = options[:max_bullets] || 0
    @supershot = options[:supershot] || false
    
    @animations = {}
    @animations[:scan] = @full_animation[0..5]
    @animations[:up] = @full_animation[6..7]
    @animations[:down] = @full_animation[8..9]
    @animations[:left] = @full_animation[10..11]
    @animations[:right] = @full_animation[12..13]
    @animations[:die] = @full_animation[0..1]     # TODO, make some real exploding frames?
    @animations[:die].delay = 25    
    stop
    @status = :paused
    after(2000) { @status = :scan }
    
    self.rotation_center(:top_left)
    
    self.factor = $window.factor
    @bounding_box = Chingu::Rect.new(@x, @y, @width*$window.factor, @height*$window.factor)
  
    @max_speed = options[:speed] || 0.25
    
    # "feelers" for the droid to see if there is a wall nearby
    # The rects are small, so it is possible for the droid to be wrong, and therefore walk into it.
    @feel_left = Chingu::Rect.new(@x-16,@y+16, 2,2)
    @feel_right = Chingu::Rect.new(@x+40,@y+16, 2,2)
    @feel_up = Chingu::Rect.new(@x+11,y-16, 2,2)
    @feel_down = Chingu::Rect.new(@x+11,@y+50,2,2)
    @wall = {} # :left, :right, :up, :down. true or false if a wall is nearby
  end
  
  def on_collision(object = nil)
    if @current_animation == :die 
      explode
      return
    end
    
    stop
    @status = :paused
    #puts "Droid dying, status: #{@status}"
    use_animation(:die)
    die_colors = [@@red, @@blue, @@green]
    during( 3000 ) do
        @color = die_colors[rand(die_colors.size)] 
        Smoke.create(:x => @x+5, :y => @y+8, :color => @@grey.dup ) 
    end.then do
      explode
    end
  end
  
  def explode
    $window.current_game_state.get_score 50
    Explosion.create(:x => @x+11, :y => @y+16, :owner => self )
    destroy     
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
    if @status == :paused or !player or @current_animation == :die
      @velocity_x, @velocity_y = 0,0
      return
    end
    
    
    update_feelers
        
    if @wall.values.include? true
      # Almost bumped into a wall there...      
      @velocity_x = 0 if (@wall[:left] and @velocity_x < 0) or (@wall[:right] and @velocity_x > 0)
      @velocity_y = 0 if (@wall[:up] and @velocity_y < 0) or (@wall[:down] and @velocity_y > 0)
      
      #stop
    end

    each_collision([TileObject, Droid, Otto]) do |me, obj|
      next if me == obj
      on_collision
    end
    
    use_animation(:left)  if @velocity_x < 0 and @velocity_y == 0
    use_animation(:right) if @velocity_x > 0 and @velocity_y == 0
    use_animation(:down)  if @velocity_y > 0
    use_animation(:up)    if @velocity_y < 0
    
    @velocity = [0, 0]
    
    px = player.x
    py = player.y
    #dist = distance(@x,@y, px,py)
    angle_deg = Gosu::angle(@x, @y, px, py)
    angle = case angle_deg
      when (355..360),(0..5) then :north; @velocity = [0, -1]
      when (40..50) then :ne; @velocity = [1, -1]
      when (85..95) then :east; @velocity = [1, 0]
      when (130..140) then :se; @velocity = [1,1]
      when (175..185) then :south; @velocity = [0, 1]
      when (220..230) then :sw; @velocity = [-1,1]
      when (265..275) then :west; @velocity = [-1, 0]
      when (310..320) then :nw; @velocity = [-1,-1]
      else nil
    end
        
    dx = (@x-px).abs
    dy = (@y-py).abs
    
    case @status
    when :scan
      if angle != nil
        if  $window.current_game_state.droid_owned_bullets < @max_bullets and angle != nil
          
          ## ugly hack, create a hash like @movements in Player for the new Bullet.create interface
          
      

          @bullet = Bullet.create( :x => @x+8, :y => @y+16, :velocity => @velocity, :owner => self, :supershot => @supershot )
        end
        @status = :idle
        after(500+rand(500)) { @status = :scan }
      elsif rand(4) == 0
        walk_towards(px,py)
        @status = :walk
      end
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