module Berzerk
  
  
  class TileObject < Chingu::GameObject
    
    has_trait :collision_detection
    
    def initialize( options = {} )
      super
      
      @dir = options[:dir]
      @walltype = options[:type] || 1
            
      raise "Wrong dir: '#{@dir}'" unless @dir or ( @dir != :north and @dir != :south and @dir != :west and @dir != :east)
      
      @scale = 2.5
      if @dir == :north or @dir == :south
        @scale = 3.5
      end
      
      
      @width = 48*@scale
      @height = 10
      if @dir == :north or @dir == :south
        @width,@height = @height,@width
      end
      
      yoff = 0
      if @dir == :north
        @height += 2
        @height += 10 if @x == 275 and @y == 195
        @y -= @height - 10
      elsif @dir == :south
        @height += 10 if @x == 275 and @y == 365
        @height -= 10 if @walltype == 2
        @height += 2
      elsif @dir == :west
        if @x == 155
          @width += 10
        end
        @x -= @width - 10
      elsif @dir == :east and (@y == 25 or @y == 535) and (@x == 145 or @x == 515)
        @width += 10
      end
      
      alpha = 255 # When debugging, I lower this one to see if walls overlap
      @glow = Gosu::Color.new(96,0,0,255)
      case @walltype
      when 2
        @c = Gosu::Color.new(alpha,255,0,255)
      else
        @c = Gosu::Color.new(alpha,0,0,255)
      end
      @bounding_box = Chingu::Rect.new([@x, @y, @width, @height])

    end
    
    def draw
      #super
      
      #$window.draw_quad(@x-5, @y-5, @glow, @x+@width+5, @y-5, @glow, @x+@width+5, @y+@height+5, @glow, @x-5, @y+@height+5, @glow)
      $window.draw_quad(@x, @y, @c, @x+@width, @y, @c, @x+@width, @y+@height, @c, @x, @y+@height, @c)
      
      #$window.fill_rect(@bounding_box, Color.new(128,255,0,0))
    end
    
    
  end
  
  class Room 
        
    # :roomx and :roomy are used to seed the random number generator
    # The room should look the same when the player reenters the room
    def initialize( options = {} )
      
      @tiles = []
      
      setup_room(options)      
    end
    
    def setup_room(options = {})
      
      if options[:create_seed]
        puts "Creating new global room seed (#{options[:create_seed]})"
        @@room_seed = rand(100).to_s 
      end
      
      seed = options[:roomx].to_s + @@room_seed + options[:roomy].to_s
      puts "Using random seed #{seed.to_i}"
      srand( seed.to_i )
      
      destroy
      create_border           
       
      randomize_wall(13,17)
      randomize_wall(25,17)
      randomize_wall(37,17)
      randomize_wall(49,17)
      
      randomize_wall(13,34)
      randomize_wall(25,34)
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
    def close( direction, tile=2 )
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
      end
      
      create_wall(x,y, dir, tile)
      
    end    
    
    # Returns false if there isn't a wall on this tile
    # If it is, it returns the tile number
    def wall?(x,y)
      @tilemap[x][y]
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
      
      create_wall( 0,1 , :south )
      create_wall( 0,34, :south )
      create_wall( 61,1 ,:south )
      create_wall( 61,34,:south )
      
    end
    
    def create_wall( x,y, angle, type=1 )
      w = TileObject.create(:type => type, :x => 25+x*10.0, :y => 25+y*10.0, :dir => angle )
      #w.angle = angle
      #w.factor_x = factor
      @tiles << w
    end
    
    def randomize_wall( x,y )
      
      create_wall( x,y, [:north,:south,:west,:east][rand(4)] )
      
    end
    
      
  end
  
end