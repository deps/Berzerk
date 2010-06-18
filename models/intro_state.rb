
class ScamState < Chingu::GameState
  
  
  def initialize(options = {})
    super
    

    Chingu::Text.create(:text => "This game is free!", :x => 100, :y => 250, :size => 40, :font => default_font_name())
    Chingu::Text.create(:text => "If you paid for this game, you have been scammed!", :x => 100, :y => 300, :size => 20, :font => default_font_name())
    
    @close_state = 5000
    self.input = { :space => :continue, :enter => :continue, :return => :continue}
  end
  
  def continue
    pop_game_state
    push_game_state MainMenuState
  end
  
  def setup
    $window.speak("coins detected in pocket")
  end
  
  def update
    $window.update_speech
  end
  
  
  
end


class IntroState < Chingu::GameState

  def initialize(options = {})
    super
    self.input = { :space => :continue, :enter => :continue, :return => :continue}
    @skull = GameObject.create(:image => "skull.png", :rotation_center => :top_left, :color => 0x00FFFFFF, :zorder => 2)
    @gradient = GameObject.create(:image => "gradient.png", :rotation_center => :top_left, :color => 0x00FFFFFF, :zorder => 1)
        
    @sweep = Song["intro.ogg"]
    @sweep.play
    
    Text.size = 120
    Text.font = media_path("game_over.ttf")
    @drop_text = Array.new
    @drop_text << Text.create("IPPA", :y => -600*4, :color => 0xFFFF0000, :stop_at => 100, :sound => "intro_1.wav", :falling => true)
    @drop_text << Text.create("& DEPS", :y => -700*4, :color => 0xFF00FF00, :stop_at => 200, :sound => "intro_2.wav", :falling => true)
    @drop_text << Text.create("GAMING", :y => -800*4, :color => 0xFF0000FF, :stop_at => 300, :sound => "intro_3.wav", :falling => true)
  end
    
  def finalize
    @sweep.stop if @sweep
  end
  
  def continue
    pop_game_state
    push_game_state ScamState
  end
  
  def update
    return
    @skull.alpha += 1
    @gradient.alpha += 1
    
    @drop_text.select { |text| text.options[:falling] }.each do |text|
      if text.y > text.options[:stop_at]
        Sound[text.options[:sound]].play(0.4)
        text.options[:falling] = false
        @sweep.stop if @sweep
      else
        text.y += 10
      end
    end
  end
  
end