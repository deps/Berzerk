
class OptionState < Chingu::GameState
  
  def initialize(options={})
    super
    
    @widgets = []
    
    @widgets << WToggle.create( :x => 100, :y => 50, :text => "Delayed droid explosion", :default => $settings['delayed_droid'], :key => 'delayed_droid' )
    @widgets << WToggle.create( :x => 100, :y => 80, :text => "Not so evil Otto", :default => $settings['mortal_otto'], :key => 'mortal_otto' )




    @widgets << WButton.create( :x => 100, :y => 500, :text => "Confirm", :action => :save_and_quit)
    @widgets << WButton.create( :x => 100, :y => 530, :text => "Cancel", :action => :close)
    
    @selected = 0
    @widgets[0].select
    
    self.input = { 
      :escape => :close,
      :up => :move_up,
      :down => :move_down,
      :left => :activate_left,
      :right => :activate_right,
    }
    
  end
  
  def move_up
    @widgets[@selected].unselect
    @selected -= 1
    @selected = @widgets.length-1 if @selected < 0
    @widgets[@selected].select
  end
  
  def move_down
    @widgets[@selected].unselect
    @selected += 1
    @selected = 0 if @selected >= @widgets.length
    @widgets[@selected].select
  end
  
  def activate_left
    @widgets[@selected].activate(:left => true)
  end
  
  def activate_right
    @widgets[@selected].activate(:right => true)
  end
  
  def save_and_quit
    # Save settings
    @widgets.each do |w|
      $settings[w.key] = w.get_setting if w.key
    end
    puts $settings.to_yaml
    close
  end
  
  
end


class Option < Chingu::GameObject
  
  attr_reader :key
  
  def initialize( options = {} )
    super
    self.factor = $window.factor
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


class WToggle < Option
  
  def initialize( options = {} )
    super
    @value = options[:default] || false
    @states = Chingu::Animation.new( :file => "onoff.png", :size => [16,8])
    @image = @states[ @value ? 1 : 0 ]
  end

  def activate( options = {} )
    @value = !@value
    @image = @states[ @value ? 1 : 0 ]
  end
  
  def draw
    super
    $window.font.draw( @text, @x + 20*@factor_x , @y-5, 0)
  end
  
  def get_setting
    @value
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