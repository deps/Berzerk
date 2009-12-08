class TileObject < Chingu::GameObject
  has_trait :collision_detection
  attr_reader :bounding_box

  def initialize( options = {} )
    super

    @dir = options[:dir]

    raise "Wrong dir: '#{@dir}'" unless @dir or ( @dir != :north and @dir != :south and @dir != :west and @dir != :east)

    @anim = Animation.new(:file => 'wall.png', :size => [122,10], :delay => 50)
    @image = @anim.next
    self.rotation_center( :center_left )
    
    @generator = Image["generator.png"]


    # @scale = 2.5
    # if @dir == :north or @dir == :south
    #   @scale = 3.5
    # end
    # 
    # @width = 48*@scale
    # @height = 10
    # if @dir == :north or @dir == :south
    #   @width,@height = @height,@width
    # end
    # 
    # yoff = 0
    # if @dir == :north
    #   @height += 2
    #   @height += 10 if @x == 275 and @y == 195
    #   @y -= @height - 10
    # elsif @dir == :south
    #   @height += 10 if @x == 275 and @y == 365
    #   @height -= 10 if @walltype == 2
    #   @height += 2
    # elsif @dir == :west
    #   if @x == 155
    #     @width += 10
    #   end
    #   @x -= @width - 10
    # elsif @dir == :east and (@y == 25 or @y == 535) and (@x == 145 or @x == 515)
    #   @width += 10
    # end
    # 
    # alpha = 255 # When debugging, I lower this one to see if walls overlap
    # if options[:color]
    #   # TODO: door color based on color of the droids
    #   @c = options[:color]
    # else # Normal wall
    #   @c = Gosu::Color.new(alpha,0,0,255)
    # end
    # @bounding_box = Chingu::Rect.new([@x, @y, @width, @height])


    @factor_x = 1.0
    bw = 122
    bh = 10
    @xoff = 0
    @yoff = -5
    @y2 = 0
    @x2 = 122
    if @dir == :north or @dir == :south
      @factor_x = 1.4
      @angle = (@dir == :north ? 270 : 90)
      bw = 10
      bh = 170
      bh = -bh if @dir == :north
      @xoff = -5
      @yoff = 0
      @x2 = 0
      @y2 = bh
    end
    
    @color = Gosu::Color.new(255,96,96,255)

    @bounding_box = Chingu::Rect.new([@x, @y, bw, bh])
    @bounding_box.move!(@xoff,@yoff)
    
  end
  
  def update
    #@bounding_box.move!(@xoff,@yoff)
    super
    @image = @anim.next
  end
  
  def draw
    super
    @generator.draw(@x-7,@y-7,200)
    @generator.draw((@x + @x2)-7,(@y + @y2)-7,200)
    #$window.fill_rect(@bounding_box, Color.new(128,255,0,0))
    #$window.draw_quad(@x, @y, @c, @x+@width, @y, @c, @x+@width, @y+@height, @c, @x, @y+@height, @c)
  end

end


class DoorObject < TileObject
  def initialize( options = {} )
    super
    @anim = Animation.new(:file => 'door.png', :size => [122,10], :delay => 20)
    @image = @anim.next
    @color = options[:color]
  end
  
  def draw
    @image.draw_rot(@x, @y, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode)
  end
  
end

class Room 

  # :room_x and :room_y are used to seed the random number generator
  # The room should look the same when the player reenters the room
  def initialize( options = {} )
    @tiles = []
    setup_room(options)      
  end

  def setup_room(options = {})
    #puts "setup_room"
    
    # create_seed should only be true when the game starts, if the player was dead but now is alive again
    # and so on. It should be false if the player switches rooms.
    # Because if the player walks in a circle (east, north, west, south) the room should look like it did
    # the first time the player was there. But if the player dies, the maze should look completley different.
    if options[:create_seed]
      @@room_seed = (1+rand(100))
      #puts "Creating new global room seed (#{@@room_seed})"
    end
    seed = options[:room_x].to_s + @@room_seed.to_s + options[:room_y].abs.to_s
    
    #puts "Using random seed #{seed}"
    srand( seed.to_i )

    destroy
    create_border           

    randomize_wall(12,17)
    randomize_wall(24,17)
    randomize_wall(37,17)
    randomize_wall(49,17)

    randomize_wall(12,34)
    randomize_wall(24,34)
    randomize_wall(37,34)
    randomize_wall(49,34)

    # Debugging walls, used to compare with original screenshot
    # create_wall(13,17,   :south)
    # create_wall(25,17,   :north)
    # create_wall(37,17,   :west)
    # create_wall(49,17,   :south)
    #  
    # create_wall(13,34,   :west)
    # create_wall(25,34,   :north)
    # create_wall(37,34,   :north)
    # create_wall(49,34,   :south)

    # close( :west )
    # close( :east )
    # close( :north )
    # close( :south )
    
  end

  # Close an exit with a "forefield"
  # Used after the player has entered a new room
  # The optional argument "tile" can be set to 1 to make it
  # look like a solid wall, and not a forcefield
  def close( direction, color )
    dir = :south
    x = 0
    y = 0

    case direction 
    when :north
      dir = :east
      x = 25
    when :south
      dir = :east
      y = 51
      x = 25
    when :east
      x = 61
      y = 18
    when :west
      y = 18
    else
      raise "Unknown direction: '#{direction}'"
    end

    create_wall(x,y, dir, color)
  end    


  def destroy
    @tiles.each do |t|
      t.destroy
    end
    @tiles = []
  end


  private    

  def create_border()
    create_wall(0,0,   :east)
    create_wall(12,0,  :east)
    create_wall(37,0,  :east)
    create_wall(49,0,  :east)

    create_wall(0,51,  :east)
    create_wall(12,51, :east)
    create_wall(37,51, :east)
    create_wall(49,51, :east)

    create_wall( 0,0 , :south )
    create_wall( 0,34, :south )
    create_wall( 61,0 ,:south )
    create_wall( 61,34,:south )
  end

  def create_wall( x,y, angle, color=nil )
    w = nil
    if color
      w = DoorObject.create(:x => 30+x*10.0, :y => 30+y*10.0, :dir => angle, :color => color )
    else
      w = TileObject.create(:x => 30+x*10.0, :y => 30+y*10.0, :dir => angle )
    end
    @tiles << w
  end

  def randomize_wall( x,y )
    create_wall( x,y, [:north,:south,:west,:east][rand(4)] )
  end

end

