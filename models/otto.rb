
class Numeric
  def to_deg
    self * (180/Math::PI)
  end
  
  def to_rad
    self * (Math::PI/180)
  end
end


class Otto < Chingu::GameObject
  has_trait :collision_detection  
  attr_reader :bounding_box

  def initialize( options )
    super
    @width = 12
    @height = 24
    
    @animation = Chingu::Animation.new(:file => "otto.png", :size => [12,24], :delay => 300).retrofy
    @image = @animation.next
    self.rotation_center(:top_left)   
    self.factor = $window.factor
    
    @bounding_box = Chingu::Rect.new(@x, @y, @width*$window.factor, @height*$window.factor)
    
    @speed = 1

  end

  def update
    @bounding_box.x = @x
    @bounding_box.y = @y
    
    @image = @animation.next
    player = $window.current_game_state.player
    return if @status == :paused or !player
    
    if Droid.all.length == 0
      @speed = 2 
      @animation.delay = 150
    end
    px = player.x
    py = player.y
    
    angle = Gosu::angle(px+11,py+16, @x,@y)+90
    
    @x += Math::cos(angle.to_rad) * @speed
    @y += Math::sin(angle.to_rad) * @speed
    
  end


end