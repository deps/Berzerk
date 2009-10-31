



class MainMenuState < Chingu::GameState
  
  def initialize(options = {})
    super

    @options = [ :start, :highscores, :credits, :options, :quit ]
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
    @bg_music.volume = $settings['music']
    @bg_music.play(true)
  end
  
    
  def move_up
    @current -= 1
    @current = @options.length-1 if @current < 0
    Sound["menu_change.wav"].play($settings['sound'])
  end
  
  def move_down
    @current += 1
    @current = 0 if @current >= @options.length
    Sound["menu_change.wav"].play($settings['sound'])
  end

  def go
    met = "on_" + @options[@current].to_s
    self.send(met)
    Sound["menu_select.wav"].play($settings['sound'])
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
    end
    
    @next_spoken_message_time -= $window.dt
    if @next_spoken_message_time < 0 and @current_spoken < @max_spoken_messages
      @current_spoken += 1
      @next_spoken_message_time += 10000
      file = "menu_#{@current_spoken}.wav"
      Sound[file].play($settings['sound'])
    end
    
  end
  
  def draw
    super
        
    @options.each_with_index do |option, i|
      y = 380+(i*40)
      if i == @current
        $window.draw_quad( 0,y,@selected, 800,y,@selected, 800,y+30,@selected, 0,y+30,@selected )
      end
      $window.font.draw(option.to_s.capitalize, 400-$window.font.text_width(option.to_s.capitalize)/2, y,0)
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
  
  def on_options
    push_game_state( OptionState)
  end
  
  def on_highscores
    push_game_state( HighScoreState )
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
    
    Sample["droid_appear.wav"].play($settings['sound'])
    
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
    @mode = :additive unless options[:silent]
    @color = Color.new(255,255,255,255)
    after(250) { @mode = :default }
    @zorder = 400
    Sound["explosion.wav"].play($settings['sound']) unless options[:silent]
  end
  
  def draw
    if @mode == :additive
      5.times { super }
    else
      super
    end
  end
end