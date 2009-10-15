class PlayState < Chingu::GameState
  
  def setup
    @pop_at = nil
    @room_x = 0
    @room_y = 0
    @opposite_directions = {:north => :south, :south => :north, :west => :east, :east => :west}
    
    @player = Player.create
    @room.destroy if @room
    @room = Room.new(:room_x => 0, :room_y => 0, :create_seed => true)
    #@room.close(@opposite_directions[@player.moving_dir])
        
    @lives = 3
    
    self.input = { :escape => :exit }
    
    
    # Original screenshot, used to compare with my walls
    @background = nil
    #@background = Gosu::Image.new($window, "media/debug.png")
    
    @hud_overlay = Gosu::Image.new($window, File.join("media","overlay.png") )
    @messages = []
    @current_message = nil
    @message_x = 0
    @message_img = nil
    
    @scroll = nil
    @scroll_steps = 0
    
    show_message("Kill everything, and stay alive.")
    
  end
  
  def change_room( dir )
    ex = 50
    ey = 255
    rx = @room_x
    ry = @room_y

    case dir
      when :north
        ex = 325
        ey = 480
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
    
    @scroll = dir
    @scroll_steps = 60
    @player.input = {}
    
    @room_x = rx
    @room_y = ry
    @entry_x = ex
    @entry_y = ey
    
    msg = "Chicken, fight like a robot!"
    if game_objects_of_class( Droid ).length == 0
      msg = "the humanoid must not escape!"
    end
    show_message(msg)    
  end

  def show_new_room
    game_objects.remove_all

    @room.destroy if @room
    # Don't create a new seed if we just switched rooms. (@scroll is != :nil if we switch rooms)
    @room = Room.new(:room_x => @room_x, :room_y => @room_y, :create_seed => (@scroll == nil) )
    
    
    if @player
      # Player only switched rooms
      @room.close(@opposite_directions[@scroll])      
    else
      # Player was dead
      @entry_x = 90
      @entry_y = 255
    end
    
    @player = Player.create(:x => @entry_x, :y => @entry_y)
  end
  
  def update
    super
    $window.caption = "FPS:#{$window.fps} - dt:#{$window.milliseconds_since_last_tick} - objects:#{current_game_state.game_objects.size}"
    
    
    xo = 0
    yo = 0
        
    if @scroll
      @scroll_steps -= 1
      if @scroll_steps <= 0
        show_new_room
        @scroll = nil
        return
      end
      
      case @scroll
      when :north
        yo = 10
      when :south
        yo = -10
      when :west
        xo = 10
      when :east
        xo = -10
      end
      
      #return
    end
    
    game_objects.each do |obj|
      # Scrolling?
      obj.x += xo
      obj.y += yo
      # Remove dead objects
      #obj.destroy if obj.respond_to? :status and obj.status == :destroy
    end
    
    #return if @scroll # Don't 
    
    
    # Change room if player walked outside map
    if @player and !@scroll
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
    
    # Pop this state if the game is over
    if @pop_at
      self.close if Time.now >= @pop_at
    end
    
    # Is the player alive?
    players = game_objects_of_class( Player )
    @player = nil if players.count == 0
    if !@player and @lives > 0
      @lives -= 1
      puts "Player lives left: #{@lives}"
      if @lives != 0
        puts "Player is alive again"
        #create_player
        show_new_room
      else
        @pop_at = Time.now + 2
        puts "Game Over at #{@pop_at} (is not #{Time.now})"
        show_message("game over")
      end
    end
  
    # Update messages
    if @message_img
      @message_x -= 10
      if @message_x <= @message_remove_pos
        @current_message = nil
        @message_img = nil
      end
    else
      unless @messages.empty?
        @current_message = @messages.shift
        @message_x = 800
        # media/texasled.ttf does not work on OSX
        @message_img = Gosu::Image.from_text($window,@current_message,default_font_name(),50) 
        @message_remove_pos = -@message_img.width
      end
    end
    
    if @player
      #
      # Let's have some droids walking towards the player
      # The more droids the lazier
      #
      if rand(Droid.size * 10) == 0
        # Fins first scanning robot and have it walk!
        scanning_droids = Droid.all.select { |droid| droid.current_animation == :scan }
        if (droid = scanning_droids.first)
          droid.walk_towards(@player.x, @player.y)  
        end
      end
    end
        
  end
  
  def draw
    @background.draw( 25,25,0, 2.5, 2.5 ) if @background
    super
    draw_hud
  end
  
  def draw_hud
    @hud_overlay.draw(0,0,200)
    if @message_img
      @message_img.draw( @message_x, 550, 200 )
    end
  end
  
  def show_message( msg )
    @messages << msg.upcase
    #puts "Message '#{msg}' added to message queue"
    #puts "Messages in queue: #{@messages.length}"
  end
  
end
