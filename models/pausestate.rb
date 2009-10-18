class Pause < Chingu::GameState
  def initialize(options = {})
    super
    self.input = { :space => :unpause }
     
    Text.create(:text => "PAUSED - Press Space to continue!", 
                :x => 150, :y => 400, :size => 20, :zorder => 999, :font => media_path("texasled.ttf") )
    PauseDroid.create(:x => $window.width/2, :y => 200, :zorder => 999)
    Song["pause_music.ogg"].play
    
    @font = Font.new($window, default_font_name, 40)
    
    @message = "Chill... Relax... Put up your feet and have a nice cup of tea... The humanoid is on a break and will return at your request for your killig pleasures... No need to hurry... You are a good droid, and a real asset to this operation! Your input will be gratefully accepted... Hang in there kitty! Working Hard Or Hardly Working? You don't have to be a mindless killing machine to work here, but it helps."
    @msg_x = 900
    @msg_width = @font.text_width(@message)
  end
          
  def unpause
    Song["pause_music.ogg"].stop
    pop_game_state(:setup => false)
  end  
  
  def draw
    super
    @font.draw(@message, @msg_x, 550, 0)
  end
  
  def update
    super
    @msg_x -= 2
    @msg_x = 800 if @msg_x < -@msg_width
  end
  
end

class PauseDroid < GameObject
  def initialize(options)
    super
    @animation = Animation.new(:file => "pause_droid.bmp", :size => [11, 16], :delay => 400).retrofy
    self.factor = 10
    update
  end
  
  def update
    @image = @animation.next
  end
end

