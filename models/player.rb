
class Player < Chingu::GameObject
  has_trait :collision_detection, :timer, :velocity
  attr_reader :status, :die_sound
  
  def initialize( options = {} )
    super 
    
    @speed = options[:speed] || 2    
    @x = options[:x] || 90
    @y = options[:y] || 255

    # self.input = { 
    #   :holding_left => :move_left, 
    #   :holding_right => :move_right, 
    #   :holding_up => :move_up, 
    #   :holding_down => :move_down,
    #   :holding_space => :shoot,
    #   :released_space => :stop_shooting
    # }
    
    @full_animation = Chingu::Animation.new(:file => "player.png", :width=>8, :height=>16, :bounce => true ).retrofy
    
    @animations = {}
    @animations[:idle] = @full_animation[0..0]
    @animations[:left] = @full_animation[3..4]
    @animations[:right] = @full_animation[1..2]
    @animations[:die] = @full_animation[7..8]
    @animations[:die].delay = 25
    use_animation(:idle)
    
    self.factor = $window.factor        
    self.rotation_center(:top_left)
    @bounding_box = Chingu::Rect.new([@x, @y, 8*@factor_x, 16*@factor_y])
    
    @lives = 3
    @shooting = false
    @cooling_down = false
    @movement = {}
    @status = :default
    
    @die_sound = nil
  end
  
  def use_animation( name )
    return if name == @current_animation or @current_animation == :die
    @current_animation = name
    @animation = @animations[name]
    @image = @animation.first
  end
  
    
  
  def on_collision
    return if dying?
    self.input = {}
    use_animation(:die)
    @die_sound = Sound["electrocute.wav"].play($settings['sound'],1,true)
    
    @velocity_x, @velocity_y = 0, 0
    
    after(1000) do 
      @die_sound.stop()
      Sound["explosion.wav"].play($settings['sound'])
      hide!
      10.times { Blood.create(:x => @x+5, :y => @y+8, :color => Gosu::Color.new(255,128+rand(127),0,0) ) } 
      $window.current_game_state.droid_speech(["got the humanoid","got the intruder"][rand(2)])
    end.then do
      after(3000) { @status = :dead; destroy;  }
    end
    
  end
  
  def dying?
    @current_animation == :die
  end
  
  def dead?
    @status == :dead
  end
  
  def move_left
    @movement[:west] = true
    use_animation(:left)
  end
  
  def move_right
    @movement[:east] = true
    use_animation(:right)
  end
  
  def move_up
    @movement[:north] = true
  end
  
  def move_down
    @movement[:south] = true
  end
  
  def shoot
    return if @cooling_down or @movement.length == 0
    
    @shooting = true
    @cooling_down = true
    Bullet.create( :x => @x+8, :y => @y+16, :directions => @movement, :owner => self )
    after(400) { @cooling_down = false }
  end
  
  def stop_shooting
    @shooting = false
  end
  
  # def draw
  #   super
  #   $window.fill_rect(@bounding_box, Color.new(128,255,0,0))
  # end
  
  def update
    
    @image = @animation.next
    return if dying?
    
    move_left if $window.button_down?(KbLeft) or $window.button_down?(GpLeft)
    move_right if $window.button_down?(KbRight) or $window.button_down?(GpRight)
    move_up if $window.button_down?(KbUp) or $window.button_down?(GpUp)
    move_down if $window.button_down?(KbDown) or $window.button_down?(GpDown)
    
    if $window.button_down?(KbSpace) or $window.button_down?(GpButton0)
      shoot
    else
      stop_shooting
    end
    
    each_collision([TileObject, Droid, Otto]) { |me, obj| on_collision }
    return if dying?

    @velocity_x, @velocity_y = 0, 0
    unless @shooting
      x, y = $window.directions_to_xy(@movement)
      @velocity_x = x * @speed
      @velocity_y = y * @speed
    end
        
    use_animation(:idle)  if @velocity_x == 0 and @velocity_y == 0
    @movement = {} 
  end
  
end
