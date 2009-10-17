#
# A simple spark-class
# Random x/y velocity and a decrementing @alpha (fading out)
# Kill when almost fully faded
#
class Spark < Chingu::GameObject
  #
  # Set @velocity_x and @velocity_y and velocity-trait will add them to @x / @y each game iteration
  # @acceleration_x / @acceleration_y is also available.
  #
  has_trait :velocity
  
  def initialize( options )
    super
    @velocity_x = 5 - rand(10)  
    @velocity_y = 5 - rand(10)
  end
  
  def update
    @color.alpha -= 10
    
    # We check < 10 instead of < 0 since Gosu will throw an error if alpha goes bellow 0
    destroy if @color.alpha < 10
  end
  
  def draw
    $window.draw_line(@x, @y, @color, @x + @velocity_x, @y + @velocity_y, @color)
  end
end

# Big pixels
class BigSpark < Spark
  def initialize( options )
    
    if options[:color].respond_to? :each
      # We got an array of colors, pick one at random
      c = options[:color][rand(options[:color].length)].dup
      options[:color] = c
    end
    
    super
    
    @size = 1+rand(3)
  end
  
  def on_collision
  end
  
  def draw
    $window.draw_quad(@x-@size, @y-@size, @color, @x+@size, @y-@size, @color, @x+@size, @y+@size, @color, @x-@size, @y+@size, @color)
  end
end

class Smoke < BigSpark
  def initialize(options)
    super
    @max_size = 2+rand(4)
    @size = 0
    @velocity_y = -0.1
  end
  
  def update
    @size += 0.25 if @size < @max_size
    @velocity_x *= 0.85
    @velocity_y *= 1.25
    super
  end
end

class Blood < BigSpark
  def initialize(options)
    super
    @friction = 0.45 + rand()/2
  end
  def update    
    @velocity_x *= @friction
    @velocity_y *= @friction
  end
end

class Explosion < Chingu::GameObject
  has_trait :timer
  
  def initialize(options)
    super
    self.rotation_center(:center_center)
    
    @image = Image["explosion_radius.png"]
    Sound["explosion.wav"].play(0.3)
    
    Chingu::GameObject.all.each do |obj|
      if Gosu::distance(@x+11,@y+16, obj.x,obj.y) < 65
        obj.on_collision  if obj.respond_to?(:on_collision)
      end
    end
    
    after(50) { destroy }
  end  
end
