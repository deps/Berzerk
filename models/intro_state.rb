class IntroState < Chingu::GameState
  #has_trait :timer, :effect
  def initialize(options = {})
    super
    self.input = { :space => :pop_game_state, :esc => :pop_game_state }
    @skull = GameObject.create(:image => "skull.png", :rotation_center => :top_left, :color => 0x00FFFFFF, :zorder => 2)
    @gradient = GameObject.create(:image => "gradient.png", :rotation_center => :top_left, :color => 0x00FFFFFF, :zorder => 1)
    
    # remove when new chingu comes out
    #@skull.rotation_center(:top_left)
    #@gradient.rotation_center(:top_left)
    
    @sweep = Song["intro.ogg"]
    @sweep.play
    
    Text.size = 120
    Text.font = "media/game_over.ttf"
    @drop_text = Array.new
    @drop_text << Text.create("IPPA", :y => -600*4, :color => 0xFFFF0000, :stop_at => 100, :sound => "intro_1.wav", :falling => true)
    @drop_text << Text.create("& DEPS", :y => -700*4, :color => 0xFF00FF00, :stop_at => 200, :sound => "intro_2.wav", :falling => true)
    @drop_text << Text.create("GAMING", :y => -800*4, :color => 0xFF0000FF, :stop_at => 300, :sound => "intro_3.wav", :falling => true)
  end
  
  def update
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