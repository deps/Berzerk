#
# Droid - Our basic enemy class
#
class Droid < Chingu::GameObject
  has_trait :timer, :velocity
  attr_reader :current_animation
  
  def initialize( options )
    super
    @full_animation = Chingu::Animation.new(:file => media_path("droid.bmp"), :size => [11,16]).retrofy
    
    @animations = {}
    @animations[:scan] = @full_animation[0..5]
    @animations[:up] = @full_animation[6..7]
    @animations[:down] = @full_animation[8..9]
    @animations[:left] = @full_animation[10..11]
    @animations[:right] = @full_animation[10..11]
    
    #
    # TODO: add exploding droid frames
    # @animations[:die] = @full_animation[12..15]
    # @animations[:die].delay = 25
    #

    self.factor = $window.factor
    @speed = 1
    
    stop
  end
  
  def stop
    @velocity_x = 0
    @velocity_y = 0
    use_animation(:scan)
  end
  
  def walk_towards(x, y)
    # Set correct velocity so droid walks towards x, y (well, somewhat towards it)
    @velocity_x  = (self.x > x) ? -@speed : @speed
    @velocity_y  = (self.y > y) ? -@speed : @speed
    
    @velocity_x  = 0 if (self.x - x).abs < 40
    @velocity_y  = 0 if (self.y - y).abs < 40
    
    after(3000) { stop }
  end
  
  def use_animation( name )
    return if name == @current_animation or @current_animation == :die
    @current_animation = name
    @animation = @animations[name]
    @image = @animation.first
  end
  
  def update
    self.factor_x = $window.factor
    use_animation(:left) if @velocity_x < 0
    
    if @velocity_x > 0
      self.factor_x = -$window.factor
      use_animation(:left)
    end
    
    use_animation(:down)  if @velocity_y > 0
    use_animation(:up)    if @velocity_y < 0
    
    #
    # Collide with walls? Change direction? How?
    #
    
    
    @image = @animation.next!
  end
  
end