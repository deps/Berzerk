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
    
    @size = rand(4)
  end
  
  def draw
    $window.draw_quad(@x-@size, @y-@size, @color, @x+@size, @y-@size, @color, @x+@size, @y+@size, @color, @x-@size, @y+@size, @color)
  end
end