
class OptionState < Chingu::GameState
  
  def initialize(options={})
    super
    
    @widgets = []
    
    @widgets << WSlider.create( :x => 100, :y => 200, :text => "Sound effects", :key => 'sound' )
    @widgets << WSlider.create( :x => 100, :y => 300, :text => "Music", :key => 'music' )
    @widgets << WSlider.create( :x => 100, :y => 400, :text => "Robot speech", :key => 'robot' )

    @widgets << WButton.create( :x => 100, :y => 500, :text => "Return", :action => :save_and_quit)
    
    @selected = 0
    @widgets[0].select
    
    self.input = { 
      :escape => :close,
      :up => :move_up,
      :down => :move_down,
      :left => :dec_volume,
      :right => :inc_volume,
      :space => :activate,
      :return => :activate,
      :enter => :activate
    }
    
  end
  
  def move_up
    @widgets[@selected].unselect
    @selected -= 1
    @selected = @widgets.length-1 if @selected < 0
    @widgets[@selected].select
    Sound["menu_change.wav"].play($settings['sound'])
    
  end
  
  def move_down
    @widgets[@selected].unselect
    @selected += 1
    @selected = 0 if @selected >= @widgets.length
    @widgets[@selected].select
    Sound["menu_change.wav"].play($settings['sound'])
    
  end
  
  def dec_volume
    @widgets[@selected].activate(:left => true)
  end
  
  def inc_volume
    @widgets[@selected].activate(:right => true)
  end
  
  def activate
    @widgets[@selected].activate
  end
  
  
  def save_and_quit
    # Save settings
    # Collect them
    @widgets.each do |w|
      $settings[w.key] = w.get_setting if w.key
    end
    
    # TODO: save to file
    
    close
  end
  
  
  def preview_sound
    Sound["laser.wav"].play( $settings['sound'] )
  end
  
  def preview_music
    s = Song::current_song
    return unless s
    #s.pause
    s.volume = $settings['music']
    #s.play
  end
  
  def preview_robot
    $window.clear_speech
    $window.speak("attack the humanoid")
  end
  
  def update
    $window.update_speech
  end
  
end


class Option < Chingu::GameObject
  
  attr_reader :key
  
  def initialize( options = {} )
    super
    self.factor = $window.object_factor
    @text = options[:text]
    rotation_center(:top_left)
    @selected = false
    @bgcol = Color.new(255,0,0,128)
    @key = options[:key]
  end
  
  def activate( options = {} )
    
  end
  
  def draw
    super if @image
    $window.draw_quad( 0,@y-5,@bgcol, 800,@y-5,@bgcol, 800,@y+25,@bgcol, 0,@y+25,@bgcol ) if @selected
  end
    
  def get_setting
    nil
  end
  
  def select
    @selected = true
  end
  
  def unselect
    @selected = false
  end
  
end


class WButton < Option
  def initialize( options = {} )
    super
    @message = options[:action]
  end
  
  def draw
    super
    $window.font.draw( @text, @x, @y-5, 0)
  end
  
  def activate( options = {} )
    @parent.send(@message)
  end
  
end


class WSlider < Option
  def initialize( options = {} )
    super
    @value = $settings[@key]
  end
  
  def get_setting
    @value
  end

  def activate( options = {} )
    return if options.length == 0
    @value -= 0.1 if options[:left]
    @value += 0.1 if options[:right]
    @value = 0 if @value < 0.0
    @value = 1.0 if @value > 1.0
    $settings[@key] = @value
    @parent.send("preview_#{@key}")
  end
  
  def draw
    super
    $window.font.draw( "#{@text}: #{(@value*100).to_i}%", @x, @y-5, 0)    
  end
  
end

