class GameOver < Chingu::GameState
  def initialize(options = {})
    super
    self.input = { :space => :replay }
    Song["clapping.ogg"].play(false)    
    GameObject.create(:image => "nr1_humanoid_killer.bmp", :factor => 5, :x => $window.width/2, :y => $window.height/2)
  end
          
  def replay
    Song["clapping.ogg"].stop
    pop_game_state( :setup => false )
    if $window.scores.position_by_score($last_score)
      push_game_state( EnterNameState )
    else
      push_game_state( HighScoreState )
    end
  end
  
end