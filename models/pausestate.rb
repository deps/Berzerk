class Pause < Chingu::GameState
  def initialize(options = {})
    super
    self.input = { :space => :unpause }
     
    Text.create(:text => "PAUSED - Press Space to continue!", 
                :x => 150, :y => 400, :size => 20, :zorder => 999, :font => media_path("texasled.ttf") )
    PauseDroid.create(:x => $window.width/2, :y => 200, :zorder => 999)
    Song["pause_music.ogg"].play
  end
          
  def unpause
    Song["pause_music.ogg"].stop
    pop_game_state(:setup => false)
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

