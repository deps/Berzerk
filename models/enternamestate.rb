class EnterNameState < GameState
  
  def initialize( options = {})
    super
       
  end
  
  def update
    super
    # TODO: write me! :P
    $player_name = "FOO"
    pop_game_state( :setup => false )
    push_game_state( HighScoreState )
  end
  
end