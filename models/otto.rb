
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

  def initialize( options )
    super
    @width = 12
    @height = 12

    @image = Image["otto.png"]
    #self.rotation_center(:center_center)    
    self.factor = $window.factor
    
    @bounding_box = Chingu::Rect.new(@x, @y, @width*$window.factor, @height*$window.factor)
    

    @speed = 1

  end


  def update
    player = $window.current_game_state.player
    return if @status == :paused or !player
    
    @speed = 2 if Droid.all.length == 0
    
    px = player.x
    py = player.y
    
    
    # TODO: it should bounce it's way across the screen
    angle = Gosu::angle(px+11,py+16, @x,@y)+90
    
    @x += Math::cos(angle.to_rad) * @speed
    @y += Math::sin(angle.to_rad) * @speed
    
  end


end