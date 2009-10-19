require 'rubygems'
require 'opengl'
require 'chingu'
#require '../chingu/lib/chingu'
include Gosu
include Chingu

require_all('models')

class Game < Chingu::Window
  attr_reader :factor, :metalfont
  
  def initialize
    super
    @factor = 2.5   # set new objects factor to $window.factor when they initialize, see droid.rb
    
    @sample_queue = []
    @current_samples = []
    @current_word = nil
    @sample_speed = 1.0
    
    @metalfont = Chingu::Animation.new(:file => "metalfont.png", :size => [32,32]).retrofy  
    @directions_to_xy = { :north => [0, -1], :east => [1, 0], :south => [0, 1], :west => [-1, 0] }
    @font_letters = ('A'..'Z').to_a + [' ','.'] + ('0'..'9').to_a + ['!','(',')',',','"','?','*','-']

    push_game_state( ScamState )
  end
  
  #
  # Takes a Hash (e.g. :north => true, :east => true } and returns [x, y]
  #
  def directions_to_xy(directions = nil)
    x, y = 0, 0
    return [x,y]  unless directions
    
    directions.select { |key, value| value == true }.each do |direction, boolean|
      x += @directions_to_xy[direction][0]
      y += @directions_to_xy[direction][1]
    end
    return [x,y]
  end
  
  # This method turns a string into an array with the corrensponding index values for the
  # bitmap font inside @metalfont
  # See PlayState#draw_hud for an example of how to use it
  def string_to_index(msg)
    arr = []
    msg.split("").each do |l|
      i = @font_letters.index(l)
      if i
        arr << i
      else
        arr << 42
      end
    end
    arr
  end
  
  def update
    super
    close if current_parent == self
  end
  
  def speak( message )
    words = message.split(" ")
    samples = []
    words.each do |w|
      samples << "word_#{w}.wav"
    end
    
    @sample_queue << samples
  end  
  
  def update_speech
    if @current_samples.empty? and @current_word == nil
      return if @sample_queue.length == 0
      @current_samples = @sample_queue.shift
      @sample_speed = 0.90 + rand(0.20)
    end
    
    if @current_word == nil
      @current_word = Sound[@current_samples.shift].play(0.3, @sample_speed)
    else
      unless @current_word.playing?
        @current_word = nil
      end
    end
    
  end  
  
end


g = Game.new
g.show