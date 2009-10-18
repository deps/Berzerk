class GameOver < Chingu::GameState
  def initialize(options = {})
    super
    self.input = { :space => :replay }
    Song["clapping.ogg"].play(false)    
    GameObject.create(:image => "nr1_humanoid_killer.bmp", :factor => 5, :x => $window.width/2, :y => $window.height/2)
  end
          
  def replay
    Song["clapping.ogg"].stop
    pop_game_state(:setup => false) ## Not sure how to get back to game from here? :)
  end
  
end