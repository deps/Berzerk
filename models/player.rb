
class Player < Chingu::GameObject
  has_trait :collision_detection
  has_trait :timer
  
  def initialize( options = {} )
    super 
    
    
    self.input = { :holding_left => :move_left, :holding_right => :move_right, :holding_up => :move_up, :holding_down => :move_down}
    
    @anim_file = Chingu::Animation.new(:file => media_path("player.png"), :width=>8, :height=>16, :bounce => true )
    @anim_file.retrofy
    
    @anim = {}
    @anim[:idle] = (0..0)
    @anim[:left] = (3..4)
    @anim[:right] = (1..2)
    @anim[:die] = (7..8)
    @moving = false
    
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
    
    
  end
  
  def use_animation( anim )
    return if anim == @current_animation 
    @current_animation = anim
    puts "Changing animation to #{anim}"
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
    move(-1,0)
    @new_anim = :left
  end
  
  def move_right
    move(1,0)
    @new_anim = :right
  end
  
  def move_up
    move(0,-1)
  end
  
  def move_down
    move(0,1)
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
  
  # def draw
  #   super
  #   $window.fill_rect(@bounding_box, Color.new(128,255,0,0))
  # end
  
  def update
    unless frozen?
      if @moving
        if @new_anim and @current_animation != :die
          use_animation(@new_anim)
          @new_anim = nil
        end
      #else
      #  use_animation(:idle) unless @current_animation == :die
      end
    end
  
    super
    
    update_animation if @moving or @current_animation == :die
    @moving = false unless frozen?
    
  end
  
end
