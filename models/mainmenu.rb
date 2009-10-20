

class ScamState < Chingu::GameState
  
  
  def initialize(options = {})
    super
    
    
    Chingu::Text.create(:text => "This game is free!", :x => 100, :y => 250, :factor_x => 2, :factor_y => 2)
    Chingu::Text.create(:text => "If you paid for this game, you have been scammed!", :x => 100, :y => 300, :factor_x => 1.5, :factor_y => 1.5)
    
    @close_state = 5000
    self.input = { :space => :continue }
  end
  
  def continue
    pop_game_state
    push_game_state MainMenuState
  end
  
  def update
    @close_state -= $window.dt
    continue if @close_state <= 0
  end
  
  
  
end


class MainMenuState < Chingu::GameState
  
  def initialize(options = {})
    super

    @options = [ :start, :credits, :quit ]
    @current = 0
    @selected = Color.new(255,0,0,128)
    
    self.input = { 
      :escape => :exit,
      :up => :move_up,
      :down => :move_down,
      :space => :go,
      :enter => :go,
      :return => :go
    }
        
    
    @detonation_time = Time.now + (1+rand(3))
        
  end
  
  def setup
    @menu_droid = nil
    @game_objects.destroy_all

    @amount_of_falling_droids = 8
    @amount_of_falling_droids.times do |nr|
      MenuDroid.create(:x => rand($window.width), :y => nr * 150 - 150)
    end
    
    @menu_droid = MenuDroidImage.create(:x => 400, :y => 200)

    @max_spoken_messages = 15
    @current_spoken = 0
    @next_spoken_message_time = 30000    


    @bg_music = Song["sad robot.ogg"]
    @bg_music.volume = 0.1
    @bg_music.play(true)
  end
  
    
  def move_up
    @current -= 1
    @current = @options.length-1 if @current < 0
    Sound["menu_change.wav"].play(0.3)
  end
  
  def move_down
    @current += 1
    @current = 0 if @current >= @options.length
    Sound["menu_change.wav"].play(0.3)
  end

  def go
    met = "on_" + @options[@current].to_s
    self.send(met)
    Sound["menu_select.wav"].play(0.3)
  end

  def update
    super
    if MenuDroid.size < @amount_of_falling_droids
      MenuDroid.create(:x => rand($window.width), :y => -200)
    end
    
    if Time.now > @detonation_time
      @detonation_time = Time.now + (1+rand(3))
      Explosion.create( :x => rand(800), :y => rand(600), :silent => true)
      @menu_droid.shake
      #Sound["small_explosion.wav"].play(0.3)
    end
    
    @next_spoken_message_time -= $window.dt
    if @next_spoken_message_time < 0 and @current_spoken < @max_spoken_messages
      @current_spoken += 1
      @next_spoken_message_time += 10000
      file = "menu_#{@current_spoken}.wav"
      Sound[file].play
    end
    
  end
  
  def draw
    super
        
    @options.each_with_index do |option, i|
      y = 400+(i*50)
      if i == @current
        $window.draw_quad( 0,y,@selected, 800,y,@selected, 800,y+30,@selected, 0,y+30,@selected )
      end
      $window.font.draw(option.to_s.capitalize, 200, y,0)
    end
  end
  
  
  # Menu options callbacks:
  
  def on_start
    push_game_state( PlayState )
  end
  
  def on_quit
    self.close
  end
  
  def on_credits
    push_game_state( CreditState )
  end
  
end


class MenuDroid < Chingu::GameObject
  has_trait :velocity
  
  def initialize(options)
    super
    
    colors = [0xFFFFFF00, 0xFFFF0000, 0xFF7777FF, 0xFF77FF00]
    @color = Gosu::Color.new(colors[rand(colors.size)])
    @color.alpha = 60
    
    @full_animation = Chingu::Animation.new(:file => "droid.bmp", :size => [11,16], :delay => 300).retrofy
    @animation = @full_animation[0..5]  # Pick out the scanning-frames
    self.factor = $window.factor * 2 
    @rotation_rate = (rand-0.5)/2
    self.velocity_y = 0.5 + rand*2
    self.factor += self.velocity_y*2
    
    update
  end
  
  def update
    @image = @animation.next
    @angle += @rotation_rate
    
    destroy if @y > $window.height + 200
  end
end


module Chingu
  class Animation
    attr_accessor :step
  end
end

class MenuDroidImage < Chingu::GameObject
  has_trait :effect, :timer
  
  
  def initialize(options)
    super
    
    Sample["droid_appear.wav"].play(0.3)
    
    @color = Gosu::Color.new(0xFF0000FF)
    
    @full_animation = Chingu::Animation.new(:file => "droid.bmp", :size => [11,8], :delay => 300).retrofy
    @full_animation.step = 2
    @animation = @full_animation[0..10]  # Pick out the scanning-frames
    
    @image = @animation.next
    self.factor = $window.factor * 15
    
    @shake_amount = 0
    @rotation_center = :center_center
    
    @factor 
    
    @color.alpha = 0
    @fade_rate = 4
    @zorder = 400
    
    after(2500) { shake(3) ; MenuTitleImage.create(:x => 400, :y => 300) }
  end
  
  def shake(amount=1.0)
    @shake_amount = amount
  end
  
  def update
    super
    
    @image = @animation.next
    
    
    #return if @color.alpha < 255
        
    if @shake_amount > 0
      @shake_amount -= 0.025
      @shake_amount = 0 if @shake_amount < 0
      @angle = (-5+rand(5))*@shake_amount
    end    
  end
  
  
  
end


class MenuTitleImage < Chingu::GameObject
  has_trait :timer
  
  def initialize(options)
    super
    
    @image = Image["menu_title.png"]
    @rotation_center = :center_center
    @mode = :additive
    @color = Color.new(255,255,255,255)
    after(250) { @mode = :default }
    @zorder = 400
    Sound["explosion.wav"].play(0.3) unless options[:silent]
  end
  
  def draw
    if @mode == :additive
      5.times { super }
    else
      super
    end
  end
end