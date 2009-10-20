class PlayState < Chingu::GameState
  
  attr_reader :player
  
  def initialize(options = {})
    super
    @pop_at = nil
    @room_x = 0
    @room_y = 0
    
    @opposite_directions = {:north => :south, :south => :north, :west => :east, :east => :west}
    @direction_to_velocity = { :north => [0, 10], :south => [0, -10], :west => [10, 0], :east => [-10, 0] }
            
    @lives = 3
    @score = 0
    @score_counter = 0
    @award_5k = false
    @award_10k = false
    
    self.input = { :escape => :close, :p => Pause }
    
    @font = Gosu::Font.new($window, default_font_name, 20)
        
    # Original screenshot, used to compare with my walls
    @background = nil
    
    @hud_overlay = Image["overlay.png"]
    @life_icon = Image["life_icon.png"]
    
    @messages = []
    @current_message = nil
    @typed_message = ""
    @type_timer = 0
    @message_x = 0
    #@message_img = nil
    
    @chatter_time = Time.now+5+rand(10)
    @chicken_taunt_used = false
    @pitch = 0.8
    
    @scroll = nil
    @scroll_steps = 0
    
    #set_otto_timer
    
    show_new_room
    
    droid_speech("humanoid detected")
    
  end
  
  def setup
    s = Song["Diablo.ogg"]
    s.volume = $settings['music']
    s.play(true)
  end  
  
  def finalize
    @player.die_sound.stop if @player and @player.die_sound
  end
  
  
  def get_score( value )
    @score += value
    
    if @score >= 5000 and !@award_5k
      @award_5k = true
      @lives += 1 if @lives < 4
      show_message("1UP")
    end

    if @score >= 10000 and !@award_10k
      @award_10k = true
      @lives += 1 if @lives < 4
      show_message("1UP")
    end
    
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
    else
      # Bonus time! :D
      # All droids was killed, or killed themselves.
      bonus = @droids_in_room*10
      get_score bonus
      #show_message("#{bonus} points for clearing room")
    end
    droid_speech(msg)    
    
    game_objects.pause!
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
        
    # Create some droids at random positions
    @droids_in_room = 3+rand(7)
    
    spawnpos = [
      [6,9],[18,9],[42,9],[54,9],
      [18,24],[30,24],[42,24],
      [6,40],[18,40],[42,40],[54,40]
      ]
        
    
    color = nil
    bullets = 0
    supershot = false
    speed = 0.25
    
    case @score
    when (0..260)
      color = Gosu::Color.new(0xFFFFFF00)
      @pitch = 0.8
    when (261..1200)
      color = Gosu::Color.new(0xFFFF0000)
      bullets = 1
      @pitch = 0.9
    when (1201..3000)
      color = Gosu::Color.new(0xFF7777FF)      
      bullets = 2
      @pitch = 1.0
    when (3001..4500)
      color = Gosu::Color.new(0xFF77FF00)
      bullets = 3
      @pitch = 1.1
    when (4501..6000)
      color = Gosu::Color.new(0xFFFF00FF)
      bullets = 4
      speed = 0.5
      @pitch = 1.2
    when (6001..8000)
      color = Gosu::Color.new(0xFFFFFF00)
      bullets = 5
      speed = 0.5
      @pitch = 1.3
    when (8001..10000)
      color = Gosu::Color.new(0xFFFFFFFF)
      bullets = 1
      supershot = true
      speed = 0.5
      @pitch = 1.4
    when (10001..12000)
      color = Gosu::Color.new(0xFF77FF00)
      bullets = 2
      supershot = true
      speed = 0.5
      @pitch = 1.5
      
    # Color cycle repeats
    when (12001..13000)
      color = Gosu::Color.new(0xFFFFFF00)
      bullets = 2
      supershot = true
      speed = 0.75
      @pitch = 1.5
    when (13001..14000)
      color = Gosu::Color.new(0xFFFF0000)
      bullets = 2
      supershot = true
      speed = 0.75
      @pitch = 1.5
    when (14001..15000)
      color = Gosu::Color.new(0xFF7777FF)      
      bullets = 2
      supershot = true
      speed = 0.75
      @pitch = 1.5
    when (15001..16000)
      color = Gosu::Color.new(0xFF77FF00)
      bullets = 2
      supershot = true
      speed = 1
      @pitch = 1.5
    when (16001..17000)
      color = Gosu::Color.new(0xFFFF00FF)
      bullets = 2
      supershot = true
      speed = 1.25
      @pitch = 1.5
    when (17001..18000)
      color = Gosu::Color.new(0xFFFFFF00)
      bullets = 2
      supershot = true
      speed = 1.5
      @pitch = 1.5
    when (18001..19000)
      color = Gosu::Color.new(0xFFFFFFFF)
      bullets = 2
      supershot = true
      speed = 1.75
      @pitch = 1.5
    else
      color = Gosu::Color.new(0xFF77FF00)      
      bullets = 2
      supershot = true
      speed = 2.0
      @pitch = 1.5
    end
    
    #puts "Droid attributes - Bullets: #{bullets}, supershot: #{supershot}, speed: #{speed}"
    
    @droids_in_room.times do |i|
      pos = spawnpos.delete_at(rand(spawnpos.length))
      pos[0] += Gosu::random(-3,3)
      pos[1] += Gosu::random(-3,3)
      x = 25+(pos[0])*10
      y = 25+(pos[1])*10
      d = Droid.create(:x => x, :y => y, :color => color, :max_bullets => bullets, :supershot => supershot, :speed => speed)
    end
    
    @room.destroy if @room
    # Don't create a new seed if we just switched rooms. (@scroll is != :nil if we switch rooms)
    @room = Room.new(:room_x => @room_x, :room_y => @room_y, :create_seed => (@scroll == nil) )
    @room.close(@opposite_directions[@scroll], color) if close_door
    
        
    set_otto_timer( @droids_in_room )
  end
  
  def set_otto_timer( num_droids )
    delay = num_droids * 3
    @otto_timer = delay*1000
    #puts "Otto will appear at #{@otto_timer} (in #{delay} seconds, based on #{num_droids} droids)"    
  end
  
  def update
    $window.caption = "FPS:#{$window.fps} - dt:#{$window.milliseconds_since_last_tick} - objects:#{current_game_state.game_objects.size}"
    
    @score_counter += 5 if @score_counter < @score
    
    if @scroll
      @scroll_steps -= 1
      if @scroll_steps <= 0
        show_new_room
        @scroll = nil
        return
      end
      
      # Depending on direction i @scroll, move all game objects in a certain direction
      game_objects.each do |game_object| 
        game_object.x += @direction_to_velocity[@scroll][0]
        game_object.y += @direction_to_velocity[@scroll][1]
      end
    end
      
    super
    
    @otto_timer -= $window.dt if @otto_timer
    if @otto_timer and @otto_timer <= 0
      droid_speech( "intruder alert intruder alert" )
      @otto_timer = nil
      Otto.create( :x => @entry_x, :y => @entry_y )
      #puts "Otto spawned"
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
      if Time.now >= @pop_at
        $last_score = @score # TODO: check if this is high enough to be added on highscore list
        #pop_game_state( :setup => false )
        pop_game_state( :setup => false )
        push_game_state( GameOver )
      end
    end
    

    @player = nil if @player and @player.dead?  # if player is dead, remove the last reference to it.    
    if !@player and @lives > 0
      @lives -= 1
      #puts "Player lives left: #{@lives}"
      if @lives != 0
        #puts "Player is alive again"
        #create_player
        show_new_room
      else
        @pop_at = Time.now + 3
        show_message("game over")
      end
    end
  
    # Update messages    
    if Time.now >= @chatter_time
      random_droid_chatter
      @chatter_time = Time.now + 5+rand(20)
    end
    $window.update_speech
    
    if @current_message
      @typed_timer -= $window.dt
      if @typed_timer <= 0
        if @typed_index < @current_message.length
          @typed_timer = 50
          @typed_index+=1
          @typed_timer = 1000 if @typed_index == @current_message.length
        else
          @current_message = nil
        end
      end
    else
      unless @messages.empty?
        @current_message = @messages.shift
        @typed_index = 0
        @typed_timer = 50

        # media/texasled.ttf does not work on OSX
        #@message_img = Gosu::Image.from_text($window,@current_message,default_font_name(),50) 
        @message_remove_pos = -@current_message.length*32
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
    
    #Bullet.each_bounding_box_collision([Droid, Player]) do |bullet, target|
    #  next if bullet.owner == target
    #  bullet.on_collision
    #  target.on_collision
    #end
    
    
  end
  
  def draw
    @background.draw( 25,25,0, 2.5, 2.5 ) if @background
    super
    draw_hud
  end
  
  def draw_hud
    @hud_overlay.draw(0,0,200)
    
    # Scrolling messages
    if @current_message
      #@message_img.draw( @message_x, 550, 200 )
      $window.string_to_index(@current_message[(0..@typed_index)]).each_with_index do |num, i|
        $window.metalfont[num].draw(5+(i*26), 560, 200)
      end
    end
    
    # Score
    #$window.string_to_index(@score.to_s.rjust(6,"0")).each_with_index do |num, i|
      #$window.metalfont[num].draw( 670, 80+(i*60), 220, 2,2)
    #end
    @score_counter.to_s.rjust(6,"0").split("").each_with_index do |num, i|
      @font.draw( num, 680, 80+(i*70),200, 10,5)
    end
    
    # Lifes
    @lives.times do |i|
      @life_icon.draw(657+(i*30), 30, 210)
    end
  end
  
  def show_message( msg )
    @messages << msg.upcase
    #puts "Message '#{msg}' added to message queue"
    #puts "Messages in queue: #{@messages.length}"
  end
  
  def droid_speech( message )
    show_message message
    
    $window.speak( message, @pitch )
  end
    
  def random_droid_chatter
    first = ["charge", "attack", "kill", "destroy", "get"]
    second = ["the humanoid", "the intruder", "it"] 
    second << "the chicken" if @chicken_taunt_used
    droid_speech( first[rand(first.length)]+" "+second[rand(second.length)] )
  end
  
  
  def droid_owned_bullets
    bullets = Bullet.all.select { |b| b.class == Bullet }
    bullets.length
  end
  
  
end
