
class Player < Chingu::GameObject
  has_trait :collision_detection
  has_trait :timer
  
  attr_reader :moving_dir, :status
  
  def initialize( options = {} )
    super 
    
    @speed = options[:speed] || 1.5    
    @x = options[:x] || 90
    @y = options[:y] || 255
    @moving_dir = options[:moving_dir] || :none

    self.input = { 
      :holding_left => :move_left, 
      :holding_right => :move_right, 
      :holding_up => :move_up, 
      :holding_down => :move_down,
      :space => :shoot,
      :released_space => :stop_shooting
    }
    
    @full_animation = Chingu::Animation.new(:file => media_path("player.png"), :width=>8, :height=>16, :bounce => true ).retrofy
    
    @animations = {}
    @animations[:idle] = @full_animation[0..0]
    @animations[:left] = @full_animation[3..4]
    @animations[:right] = @full_animation[1..2]
    @animations[:die] = @full_animation[7..8]
    @animations[:die].delay = 25

    use_animation(:idle)
    
    @moving = false
    @movement = {}
    
    @factor_x = 2.5
    @factor_y = 2.5
    @lives = 3
        
    @bounding_box = Chingu::Rect.new([@x, @y, 8*@factor_x, 16*@factor_y])
    self.rotation_center(:top_left)
    
    @shooting = false
    @cool_down = 0    # don't fire too often
    @status = :default
  end
  
  def use_animation( name )
    return if name == @current_animation or @current_animation == :die
    @current_animation = name
    @animation = @animations[name]
    @image = @animation.first
  end
  
  def on_collision
    return if @current_animation == :die
    self.input = {}
    use_animation(:die)
    
    after(1000) do 
      hide!
      spawn_gibs 
    end.then do
      after(3000) { @status = :destroy }
    end
    
  end
  
  def spawn_gibs
    puts "Pretend that blood and gore is everywhere. And some smoke"
  end
    
  def move_left
    @movement[:west] = true
    return if @shooting
    move(-1,0)
    use_animation(:left)
    @moving_dir = :west
  end
  
  def move_right
    @movement[:east] = true
    return if @shooting
    move(1,0)
    use_animation(:right)
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
    @moving = true
    ox = @x
    oy = @y
    @x+=xoff*@speed
    @y+=yoff*@speed
    
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
    @bullet = nil   if @bullet

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
    end

    each_collision(Chingu::GameObject) do |me, obj|
      next if (obj.respond_to? :owner and obj.owner == self) or me == obj # Do not collide with it's own bullets
      on_collision
    end

    super
    @movement = {} 

    @image = @animation.next!   if @moving or @current_animation == :die

    @moving = false 
  end
  
end
