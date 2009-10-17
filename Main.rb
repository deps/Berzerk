require 'rubygems'
require 'opengl'
require 'chingu'
#require '../chingu/lib/chingu'
include Gosu
include Chingu

require_all('models')

class Game < Chingu::Window
  attr_reader :factor
  
  def initialize
    super
    @factor = 2.5   # set new objects factor to $window.factor when they initialize, see droid.rb
    
    push_game_state( MainMenuState )
  end

  def update
    super
    close if current_parent == self
  end
  
end


g = Game.new
g.show