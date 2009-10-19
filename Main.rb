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
    
    @sample_queue = []
    @current_samples = []
    @current_word = nil
    @sample_speed = 1.0
    
    
    push_game_state( ScamState )
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