require 'rubygems'
require 'opengl'
require 'Chingu'
include Gosu

def media_path(file)
  File.join($window.root, "media", file)  
end


#require File.join('models','map')
require_all('models')







class Game < Chingu::Window
  def initialize
    super
    
    push_game_state( PlayState )
  end
  
  def update
    super
    close if current_parent == self
  end
  
end


g = Game.new
g.show