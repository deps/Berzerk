class PlayState < Chingu::GameState
  
  def setup
    @pop_at = nil
    @room_x = 0
    @room_y = 0
        
    create_player
    
    @lives = 3
    
    self.input = { :escape => :exit }
    
    @player_pos = Chingu::Text.new(:text => "n/a", :x => 25, :y => 5 )
    
    # Original screenshot, used to compare with my walls
    @background = nil
    #@background = Gosu::Image.new($window, "media/debug.png")
    
  end
  
  
  def create_player( ex = 50, ey = 292, rx = 0, ry = 0, moving_dir = :none )
    @entry_x = ex
    @entry_y = ey
    
    @room.destroy if @room
    @room = Room.new( :roomx=>rx, :roomy => ry, :create_seed => (moving_dir == :none) )
    
    case moving_dir
      when :north
        @room.close(:south)
      when :south
        @room.close(:north)
      when :west
        @room.close(:east)
      when :east
        @room.close(:west)
    end
    
    @player = Player.create( :x => @entry_x, :y => @entry_y )
    
  end
  
  
  def change_room( dir )
    ex = 50
    ey = 255
    rx = @room_x
    ry = @room_y
    case dir
      when :north
        ex = 325
        ey = 490
        ry-=1
      when :south
        ey = 40
        ex = 325
        ry+=1
      when :west
        ex = 610
        rx-=1
      when :east
        ex = 50
        rx+=1
    end
    
    game_objects.remove_all
    
    create_player(ex,ey,rx,ry, dir)
    
    @room_x = rx
    @room_y = ry
    @entry_x = ex
    @entry_y = ey
  end
 
  
  def update
    super
    $window.caption = "FPS:#{$window.fps} - dt:#{$window.milliseconds_since_last_tick} - objects:#{current_game_state.game_objects.size}"
    
    if @player
      #@player_pos.text = "#{@player.x}, #{@player.y}"
      if @player.x <= 25
        change_room(:west)
      elsif @player.x >= 635
        change_room(:east)
      elsif @player.y <= 10
        change_room(:north)
      elsif @player.y >= 540
        change_room(:south)
      end
    end
    
    if @pop_at
      self.close if Time.now >= @pop_at
    end
    
    players = game_objects_of_class( Player )
    @player = nil if players.count == 0
    if !@player and @lives > 0
      @lives -= 1
      if @lives != 0
        puts "Player is alive again"
        create_player
      else
        @pop_at = Time.now + 2
        puts "Game Over at #{@pop_at} (is not #{Time.now})"
      end
    end
    
  end
  
  def draw
    
    @background.draw( 25,25,0, 2.5, 2.5 ) if @background
    
    super
    
    draw_hud
    
  end
  
  def draw_hud
    
    if @player
      @player_pos.draw
      
    end
  end
  
end
