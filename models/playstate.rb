class PlayState < Chingu::GameState
  
  attr_reader :player, :debugfont
  
  def setup
    @pop_at = nil
    @room_x = 0
    @room_y = 0
    @opposite_directions = {:north => :south, :south => :north, :west => :east, :east => :west}
    
    # @player = Player.create
    # @room.destroy if @room
    # @room = Room.new(:room_x => 0, :room_y => 0, :create_seed => true)
    #@room.close(@opposite_directions[@player.moving_dir])
        
    @lives = 3
    
    self.input = { :escape => :exit }
    
    @debugfont = Gosu::Font.new($window, default_font_name, 20)
        
    # Original screenshot, used to compare with my walls
    @background = nil
    #@background = Gosu::Image.new($window, "media/debug.png")
    
    @hud_overlay = Gosu::Image.new($window, File.join("media","overlay.png") )
    
    @messages = []
    @current_message = nil
    @message_x = 0
    @message_img = nil
    
    @sample_queue = []
    @current_samples = []
    @current_word = nil
    @sample_speed = 1.0
    @chatter_time = Time.now+5+rand(10)
    @chicken_taunt_used = false
    
    @scroll = nil
    @scroll_steps = 0
    
    #set_otto_timer
    
    show_new_room
    
    
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
    
    
    msg = "the humanoid must not escape"
    @chicken_taunt_used = false
    if game_objects_of_class( Droid ).length > 0
      msg = "chicken fight like a robot"
      @chicken_taunt_used = true
    end
    droid_speech(msg)    
    
    pause_game_objects
  end

  def show_new_room
    game_objects.remove_all
    close_door = false
    
    if @player
      # Player only switched rooms
      close_door = true
    else
      # Player was dead
      @entry_x = 90
      @entry_y = 255
    end
    
    @player = Player.create(:x => @entry_x, :y => @entry_y)
    
    @room.destroy if @room
    # Don't create a new seed if we just switched rooms. (@scroll is != :nil if we switch rooms)
    @room = Room.new(:room_x => @room_x, :room_y => @room_y, :create_seed => (@scroll == nil) )
    @room.close(@opposite_directions[@scroll]) if close_door
    
    # Create some droids at random positions
    num = 3+rand(7)
    
    spawnpos = [
      [6,9],[18,9],[42,9],[54,9],
      [18,24],[30,24],[42,24],
      [6,40],[18,40],[42,40],[54,40]
      ]
    
    color = Gosu::Color.new(0xFFFF0000)
    
    num.times do |i|
      pos = spawnpos.delete_at(rand(spawnpos.length))
      pos[0] += Gosu::random(-3,3)
      pos[1] += Gosu::random(-3,3)
      x = 25+(pos[0])*10
      y = 25+(pos[1])*10
      d = Droid.create(:x => x, :y => y, :color => color)
    end
        
    set_otto_timer( num )
  end
  
  def set_otto_timer( num_droids )
    @otto_timer = Time.now + ( num_droids * 2 )
    puts "Otto will appear at #{@otto_timer} (in #{num_droids * 2} seconds, based on #{num_droids} droids)"    
  end
  
  def pause_game_objects
    game_objects.each do |obj|
      obj.pause!
    end
  end
  
  def update
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
    
    super
    
    if @otto_timer != 0 and Time.now >= @otto_timer
      droid_speech( "intruder alert intruder alert" )
      @otto_timer = 0
      Otto.create( :x => @entry_x, :y => @entry_y )
      puts "Otto spawned"
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
    if Time.now >= @chatter_time
      random_droid_chatter
      @chatter_time = Time.now + 5+rand(20)
    end
    update_speak
    
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
    
    # if @player
    #   #
    #   # Let's have some droids walking towards the player
    #   # The more droids the lazier
    #   #
    #   if rand(Droid.size * 10) == 0
    #     # Fins first scanning robot and have it walk!
    #     scanning_droids = Droid.all.select { |droid| droid.current_animation == :scan }
    #     if (droid = scanning_droids.first)
    #       droid.walk_towards(@player.x, @player.y)  
    #     end
    #   end
    # end
    
    Bullet.each_bounding_box_collision([Droid, Player]) do |bullet, target|
      next if bullet.owner == target
      bullet.on_collision
      target.on_collision
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
  
  def droid_speech( message )
    show_message message
    
    words = message.split(" ")
    samples = []
    words.each do |w|
      samples << "word_#{w}.wav"
    end
    
    speak samples
  end
  
  def speak( samples )
    @sample_queue << samples
  end
  
  def random_droid_chatter
    first = ["charge", "attack", "kill", "destroy", "get"]
    second = ["the humanoid", "the intruder", "it"] 
    second << "the chicken" if @chicken_taunt_used
    droid_speech( first[rand(first.length)]+" "+second[rand(second.length)] )
  end
  
  def update_speak
    if @current_samples.empty? and @current_word == nil
      return if @sample_queue.length == 0
      @current_samples = @sample_queue.shift
      @sample_speed = 0.85 + rand(0.25)
    end
    
    if @current_word == nil
      @current_word = Sound[@current_samples.shift].play(0.3, @sample_speed)
    else
      unless @current_word.playing?
        @current_word = nil
      end
    end
    
  end
  
  
  def droid_owned_bullets
    bullets = Bullet.all.select { |b| b.class == Bullet }
    bullets.length
  end
  
  
end
