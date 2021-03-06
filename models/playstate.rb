
class NotifyPopup < Chingu::GameObject
  has_trait :timer
  attr_reader :state

  def initialize( options = {} )
    super(options)
    @destroyed = false
    
    @msg = options[:msg]
    @y = 600
    @target_y = options[:target_y] || 510
    @w = $window.font.text_width(@msg)+10
    @bgcol = Color.new(0x77000000)
    @state = :show
    
  end
  
  
  def draw
    $window.draw_quad(0,@y,@bgcol, 50+@w,@y,@bgcol, 50+@w,@y+40,@bgcol, 0, @y+40,@bgcol, 200)
    $window.font.draw(@msg, 55,@y,200)
  end
  
  def update
    super
    
    case @state
    when :show
      @y -= 5
      if @y <= @target_y
        @state = :idle 
        @y = @target_y
        after(3000) { @state = :hide }
      end
    when :hide
      @y += 5
      if @y > 600
        @state = :done
        destroy 
      end
    end
  end
  
end


class PlayState < Chingu::GameState
  
  attr_reader :player
  attr_accessor :bodycount, :shots
  
  def initialize(options = {})
    super
    @pop_at = nil
    @room_x = 0
    @room_y = 0
    
    @visited_rooms = {}
    @rooms_visited = 0
    $reward_list = []
    
    @notify_queue = []
    
    # --- Create achievements
    # Killing
    create_reward("Droid hunter (killed 10 robots)", :bodycount, 10)    
    create_reward("Robot exterminator (killed 50 robots)", :bodycount, 50)
    create_reward("Don't mess with humans! (killed 100 robots)", :bodycount, 100)    
    create_reward("Got anything against robots? (killed 500 robots)", :bodycount, 500)    
    create_reward("A lot of scrap metal! (killed 1000 robots)", :bodycount, 1000)
    
    # Score
    create_reward("Lots of points (5000 points collected)", :life_5k, 1)
    create_reward("Even more points! (10000 points collected)", :life_10k, 1)
    
    # Shooting
    create_reward("Pew pew (fired 10 shots)", :shots, 10)
    create_reward("Ratatatata (fired 100 shots)", :shots, 100)
    create_reward("Dangerous (fired 500 shots)", :shots, 500)
    create_reward("Run for your life! (fired 1000 shots)", :shots, 1000)
    
    # Rooms
    create_reward "Baby steps (visited 10 rooms)", :rooms, 10
    create_reward "Topography mapper (visited 50 rooms)", :rooms, 50
    create_reward "Marathon runner (visited 100 rooms)", :rooms, 100
    create_reward "Marathon expert (visited 200 rooms)", :rooms, 200
    create_reward "Are you still alive?! (visited 500 rooms)", :rooms, 500
    create_reward "Unstoppable explorer! (visited 1000 rooms)", :rooms, 1000
    
    # Chicken
    create_reward "Shoot them? (Left alive robots 10 times)", :chicken, 10
    create_reward "Cluck cluck (Left alive robots 10 times)", :chicken, 50
    create_reward "I'm covered with feathers (Left alive robots 10 times)", :chicken, 100
    
    # Otto
    create_reward "Slow runner (Evil Otto appeared 10 times)", :otto, 10
    create_reward "Loitering (Evil Otto appeared 50 times)", :otto, 50
    create_reward "I love smileys! ^^ (Evil Otto appeared 100 times)", :otto, 100
    
    
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
    #@background = Image["floor.png"]
        
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
    @scroll_x = 0
    @scroll_y = 0
    
    #set_otto_timer
    
    show_new_room
    
    droid_speech("humanoid detected")
    
    @rooms_visited = 0
    
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
      update_reward(:life_5k)
    end

    if @score >= 10000 and !@award_10k
      @award_10k = true
      @lives += 1 if @lives < 4
      show_message("1UP")
      update_reward(:life_10k)
    end
    
  end
  
  def update_popups
    return if (@notify_queue.length == 0) 
    
    if !@popup or @popup.state == :done
      @popup = NotifyPopup.create( :msg => @notify_queue.shift )
    end
  end
  
  def got_reward( reward )
    #puts reward.msg
    @notify_queue << reward.msg
  end
  
  def create_reward( msg, var, limit )
    $reward_list << Reward.new(msg,var,limit)
  end
  
  def update_reward( var, amount=1 )
    $reward_list.each do |r|
      next if r.key != var or r.done?
      r.update(amount)
      got_reward(r) if r.done?
    end
  end
  
  def change_room( dir )
    ex = 50
    ey = 255
    rx = @room_x
    ry = @room_y

    case dir
      when :north
        ex = 325-10
        ey = 480-10
        ry-=1
      when :south
        ey = 40+20
        ex = 325-10
        ry+=1
      when :west
        ex = 610-10
        rx-=1
      when :east
        ex = 50+10
        rx+=1
    end
    
    @scroll = dir
    @scroll_steps = 60
    @player.input = {}
    vel = @direction_to_velocity[dir]
    @scroll_x = vel[0]
    @scroll_y = vel[1]
    
    
    @room_x = rx
    @room_y = ry
    @entry_x = ex
    @entry_y = ey
    
    
    msg = "the humanoid must not escape"
    @chicken_taunt_used = false
    if game_objects_of_class( Droid ).length > 0
      msg = "chicken fight like a robot"
      update_reward :chicken
      @chicken_taunt_used = true
    else
      # Bonus time! :D
      # All droids was killed, or killed themselves.
      bonus = @droids_in_room*10
      get_score bonus
      #show_message("#{bonus} points for clearing room")
    end
    $window.clear_speech
    droid_speech(msg)
    
    game_objects.each { |object| object.pause! if object.class != NotifyPopup }
  end

  def show_new_room
    
    game_objects.destroy_if { |gobj| gobj.class != NotifyPopup }  
    
    close_door = false
    
    GameObject.create( :image => 'floor.png', :x => 30, :y => 30, :zorder => 0, :center => 0)
    
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
      speed = 0.5
    when (3001..4500)
      color = Gosu::Color.new(0xFF77FF00)
      bullets = 3
      @pitch = 1.1
      speed = 0.5
    when (4501..6000)
      color = Gosu::Color.new(0xFFFF00FF)
      bullets = 4
      speed = 0.75
      @pitch = 1.2
    when (6001..8000)
      color = Gosu::Color.new(0xFFFFFF00)
      bullets = 5
      speed = 0.75
      @pitch = 1.3
    when (8001..10000)
      color = Gosu::Color.new(0xFFFFFFFF)
      bullets = 1
      supershot = true
      speed = 1.0
      @pitch = 1.4
    when (10001..12000)
      color = Gosu::Color.new(0xFF77FF00)
      bullets = 2
      supershot = true
      speed = 1.0
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

    roomid = @room_x.to_s + ":" + @room_y.to_s
    unless @visited_rooms[roomid]
      @visited_rooms[roomid] = true
      update_reward :rooms    
    end
        
    set_otto_timer( @droids_in_room )
  end
  
  def set_otto_timer( num_droids )
    delay = num_droids * 3
    @otto_timer = delay*1000
    #puts "Otto will appear at #{@otto_timer} (in #{delay} seconds, based on #{num_droids} droids)"    
  end
  
  def update
    #$window.caption = "FPS:#{$window.fps} - dt:#{$window.milliseconds_since_last_tick} - objects:#{current_game_state.game_objects.size}"
    
    @score_counter += 5 if @score_counter < @score
    
    update_popups
    
    if @scroll
      @scroll_steps -= 1
      if @scroll_steps <= 0
        show_new_room
        @scroll = nil
        @scroll_x = 0
        @scroll_y = 0
        return
      end
      
      # Depending on direction i @scroll, move all game objects in a certain direction
      game_objects.each do |game_object| 
        next if game_object.class == NotifyPopup
        game_object.x += @scroll_x
        game_object.y += @scroll_y
      end
    end
      
    super
    
    @otto_timer -= $window.dt if @otto_timer
    if @otto_timer and @otto_timer <= 0
      update_reward :otto
      droid_speech( "intruder alert intruder alert" )
      @otto_timer = nil
      Otto.create( :x => @entry_x, :y => @entry_y )
      #puts "Otto spawned"
    end
    
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
        pop_game_state( :setup => false )
        push_game_state( GameOver )
      end
    end
    

    @player = nil if @player and @player.dead?  # if player is dead, remove the last reference to it.    
    if !@player and @lives > 0
      @visited_rooms = {} # reset visited rooms, the rooms will look different now
      @lives -= 1
      #puts "Player lives left: #{@lives}"
      if @lives != 0
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
        @message_remove_pos = -@current_message.length*32
      end
    end
    
  end
  
  def draw
    #@background.draw( 25+@direction_to_velocity[@scroll][0],25+@direction_to_velocity[@scroll][1],0 ) 
    #@background.draw(30+@scroll_x*(60-@scroll_steps),30+@scroll_y*(60-@scroll_steps),0)
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
    # Player score
    @score_counter.to_s.rjust(6,"0").split("").each_with_index do |num, i|
      @font.draw( num, 670, 80+(i*70),200, 5,5)
    end
    [$window.scores[0][:score],@score_counter].max.to_s.rjust(6,"0").split("").each_with_index do |num, i|
      @font.draw( num, 740, 80+(i*70),200, 5,5)
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
