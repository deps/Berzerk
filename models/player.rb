
class Player < Chingu::GameObject
  has_trait :collision_detection
  has_trait :timer
  
  attr_reader :moving_dir
  
  def initialize( options = {} )
    super 
    
    @x = options[:x] || 50
    @y = options[:y] || 292
    @moving_dir = options[:moving_dir] || :none
    
    #@x = @entry_x
    #@y = @entry_y


    self.input = { 
      :holding_left => :move_left, 
      :holding_right => :move_right, 
      :holding_up => :move_up, 
      :holding_down => :move_down, 
      
      :space => :shoot,
      :released_space => :stop_shooting
      }
    
    @anim_file = Chingu::Animation.new(:file => media_path("player.png"), :width=>8, :height=>16, :bounce => true ).retrofy
    
    @anim = {}
    @anim[:idle] = (0..0)
    @anim[:left] = (3..4)
    @anim[:right] = (1..2)
    @anim[:die] = (7..8)
    @moving = false
    @movement = {}
    
    @new_anim = nil
    use_animation(:idle)
    
    #@image = Image["player.png"]
    #@image.retrofy
    
    @factor_x = 2.5
    @factor_y = 2.5
    
    @lives = 3
    
    @entry_x = x
    @entry_y = y
    
    @bounding_box = Chingu::Rect.new([@x, @y, 8*@factor_x, 16*@factor_y])
    self.rotation_center(:top_left)
    
    @shooting = false
    @cool_down = 0# don't fire too often
  end
  
  def use_animation( anim )
    return if anim == @current_animation 
    @current_animation = anim
    #puts "Changing animation to #{anim}"
    new_anim = @anim_file.new_from_frames( @anim[anim] )
    @animation = new_anim
    if anim == :die
      @animation.delay = 25
    end
    @image = @animation.image
  end
  
  def update_animation
    return if frozen?
    @image = @animation.next!
  end
  
  def collide_with_wall
    return if @current_animation == :die
    self.input = {}
    use_animation(:die)
    
    after(1000) do 
      hide!
      spawn_gibs 
    end.then do
      after(3000) { destroy }
    end
    
  end
  
  def spawn_gibs
    puts "Pretend that blood and gore is everywhere. And some smoke"
  end
    
  def move_left
    @movement[:west] = true
    return if @shooting
    move(-1,0)
    @new_anim = :left
    @moving_dir = :west
  end
  
  def move_right
    @movement[:east] = true
    return if @shooting
    move(1,0)
    @new_anim = :right
    @moving_dir = :east
  end
  
  def move_up
    @movement[:north] = true
    return if @shooting
    move(0,-1)
    @moving_dir = :north
  end
  
  def move_down
    @movement[:south] = true
    return if @shooting
    move(0,1)
    @moving_dir = :south
  end
  
  def move( xoff, yoff )
    return if frozen?
    @moving = true
    ox = @x
    oy = @y
    @x+=xoff
    @y+=yoff
    each_collision(TileObject) do |player, tile|
      collide_with_wall
      return
    end
  end
  
  def shoot
    @shooting = true
  end
  
  def stop_shooting
    @shooting = false
  end
  
  # def draw
  #   super
  #   $window.fill_rect(@bounding_box, Color.new(128,255,0,0))
  # end
  
  def update
    
    if @bullet and @bullet.frozen?
      #puts "I think the bullet is dead now..."
      @bullet = nil
    end
    
    unless frozen?
      
      @cool_down -= 1 if @cool_down > 0
      
      if @shooting and @cool_down <= 0
        k = @movement.keys
        dir = k[0]
        
        if k.length > 1
          if @movement[:north] 
            if @movement[:west]
              dir = :nw
            elsif @movement[:east]
              dir = :ne
            end
          elsif @movement[:south]
            if @movement[:west]
              dir = :sw
            elsif @movement[:east]
              dir = :se
            end
          end
        end
        
        if dir
          @bullet = Bullet.create( :x => @x+8, :y => @y+16, :dir => dir, :owner => self )
          @cool_down = 25
        end
        
      else
        if @moving
          if @new_anim and @current_animation != :die
            use_animation(@new_anim)
            @new_anim = nil
          end
        end
      end
      
    end
    
    
  
    super
    @movement = {} unless frozen?
    
    update_animation if @moving or @current_animation == :die
    @moving = false unless frozen?
    
  end
  
end
