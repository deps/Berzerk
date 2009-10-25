require 'rubygems'
require 'opengl'
require 'chingu'
#require '../chingu/lib/chingu'
include Gosu
include Chingu

require_all('models')

class Game < Chingu::Window
  attr_reader :factor, :font, :metalfont, :scores
  
  def initialize(width = 800, height = 600, fullscreen = false, update_interval = 16.666666)
    super
    
    load_settings
    
    #
    # TODO: Put user / password in a .gitignored file
    #
    @scores = HighScoreList.load_remote(:game_id => 2, 
                                        :user => "berzerk", 
                                        :password => "droidlove", 
                                        :size => 10)
                                        
    # Make sure we have 10 scores to begin with (if the score file was missing or similar)
    if @scores[0] == nil
      10.times do |i|
        @scores << { :name => "BZR", :score => (i+1)*50}
      end
    end
    $last_score = 0
    $player_name = nil
    
    @factor = 2.5   # set new objects factor to $window.factor when they initialize, see droid.rb
    
    @sample_queue = []
    @current_samples = []
    @current_word = nil
    @sample_speed = 1.0
        
    @metalfont = Chingu::Animation.new(:file => "metalfont.png", :size => [32,32]).retrofy  
    @directions_to_xy = { :north => [0, -1], :east => [1, 0], :south => [0, 1], :west => [-1, 0] }
    @font_letters = ('A'..'Z').to_a + [' ','.'] + ('0'..'9').to_a + ['!','(',')',',','"','?','*','-']

    # Normal font used elsewhere
    @font = Font.new($window, default_font_name, 30)

    push_game_state( ScamState )
    push_game_state( IntroState )
  end
  
  #
  # Takes a Hash (e.g. :north => true, :east => true } and returns [x, y]
  #
  def directions_to_xy(directions = nil)
    x, y = 0, 0
    return [x,y]  unless directions
    directions.each do |direction, boolean|
      if boolean
        x += @directions_to_xy[direction][0]
        y += @directions_to_xy[direction][1]
      end
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
  
  
  # Load saved settings, or use default ones
  def load_settings
    # Default
    $settings = {}
    $settings['sound'] = 0.3
    $settings['music'] = 0.1
    $settings['robot'] = 0.7
  end
  
  def update
    super
    close if current_parent == self
  end
  
  def speak( message, pitch = 1.0 )
    @sample_speed = pitch
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
      #@sample_speed = 0.90 + rand(0.20)
    end
    
    if @current_word == nil
      @current_word = Sound[@current_samples.shift].play($settings['robot'], @sample_speed)
    else
      unless @current_word.playing?
        @current_word = nil
      end
    end
    
  end  
  
  def clear_speech( everything = true )
    if everything
      @current_word.stop if @current_word
      @current_word = nil
      @current_samples = []
    end
    @sample_queye = []
  end
  
end

g = Game.new( 800,600, false )
g.show

