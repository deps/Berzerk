class MainMenuState < Chingu::GameState
  
  def setup
    @font = Font.new($window, default_font_name, 30)
    @options = [ :start, :quit ]
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
    
    @menu_droid = MenuDroidImage.create(:x => 400, :y => 200)
    
    @amount_of_falling_droids = 8
    @amount_of_falling_droids.times do |nr|
      MenuDroid.create(:x => rand($window.width), :y => nr * 150 - 150)
    end
    
    @detonation_time = Time.now + (1+rand(3))
    
    @max_spoken_messages = 15
    @current_spoken = 0
    @next_spoken_message_time = Time.now + 30
    
  end
  
  def move_up
    @current -= 1
    @current = @options.length-1 if @current < 0
  end
  
  def move_down
    @current += 1
    @current = 0 if @current >= @options.length
  end

  def go
    met = "on_" + @options[@current].to_s
    self.send(met)
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
    
    if Time.now >= @next_spoken_message_time and @current_spoken < @max_spoken_messages
      @current_spoken += 1
      @next_spoken_message_time += 10
      file = "menu_#{@current_spoken}.wav"
      Sound[file].play
    end
    
  end
  
  def draw
    super
    
    #@menu_droid.draw_rot(400,200,300, (-5+rand(5))*@shake_amount )
    #@menu_title.draw_rot(400,300,300, 0)
    
    @options.each_with_index do |option, i|
      y = 400+(i*50)
      if i == @current
        $window.draw_quad( 0,y,@selected, 800,y,@selected, 800,y+30,@selected, 0,y+30,@selected )
      end
      @font.draw(option.to_s.capitalize, 200, y,0)
    end
  end
  
  
  # Menu options callbacks:
  
  def on_start
    push_game_state( PlayState )
  end
  
  def on_quit
    self.close
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


class MenuDroidImage < Chingu::GameObject
  has_trait :effect, :timer
  
  
  def initialize(options)
    super
    
    @image = Image["menu_droid.png"]
    @shake_amount = 0
    @rotation_center = :center_center
    
    @color.alpha = 0
    @fade_rate = 4
    @zorder = 400
    
    @white = Color.new(255,255,255,255)
    after(5000) { shake(3) ; MenuTitleImage.create(:x => 400, :y => 300) }
  end
  
  def shake(amount=1.0)
    @shake_amount = amount
    during(50) { @mode = :additive  }.then { @mode = :default }
  end
  
  def update
    super
    
    return if @color.alpha < 255
        
    if @shake_amount > 0
      @shake_amount -= 0.025
      @shake_amount = 0 if @shake_amount < 0
      @angle = (-5+rand(5))*@shake_amount
    end    
  end
  
  def draw
    if @mode == :additive
      5.times { super }
    else
      super
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
  end
  
  def draw
    if @mode == :additive
      5.times { super }
    else
      super
    end
  end
end