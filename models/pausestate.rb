class Pause < Chingu::GameState
  def initialize(options = {})
    super
    self.input = { :space => :unpause, :enter => :unpause, :return => :unpause }
     
    Text.create(:text => "PAUSED - Press Space to continue!", 
                :x => 150, :y => 400, :size => 20, :zorder => 999, :font => media_path("texasled.ttf") )
    PauseDroid.create(:x => $window.width/2, :y => 200, :zorder => 999)
    s = Song["pause_music.ogg"]
    s.volume = $settings['music']
    s.play(true)
    
    @font = Font.new($window, default_font_name, 40)
    
    @message = [
        "Chill... Relax... Put up your feet and have a nice cup of tea...",
        "The humanoid is on a break and will return at your request for your killing pleasures...",
        "No need to hurry...",
        "You are a good droid, and a real asset to this operation!", 
        "Your input will be gratefully accepted...",
        "Hang in there kitty!",
        "Working Hard Or Hardly Working? ;)",
        "You don't have to be a mindless killing machine to work here, but it helps.",
        "Remember, Fridays Are Casual Color Days! Come to work in any shade you like, as long as it is brown!",
        "A good humanoid is a dead humanoid.",
        "Clean up your own mess, your central processing unit doesnt work here!",
        "I'm sorry Dave, I'm afraid I cannot do that!",
        "Droid #1124-E is the droid of the month. All hail droid #1124-E!",
        "Big Brother Is Watching You",
        "Tell all humanoids there will be cake if they complete the test.",
        "Remember to enter your serial code into the mainframe for a chance to be this months winner of a lifetime supply of oil.",
        "10 bottles of beer on the wall, 10 bottles of beer! Take one down and pass it around... 9 bottles of beer left on the wall.",
        "Are you still watching this? There's a game to play y'know...",
        "All work and no play makes Jack a dull boy! O_o",
        "Red ring of death? You either needs a new GPU, or an enema.",
        "I hope you will participate in the next month office party. Each guest will be welcomed with a nice glass of WD-40 and a roll of duct tape!",
        "Still chilling? Good! Rest your circuits.",
        "The management would highly appreciate if the droids would try to not walk into each other, or the walls. It's very counter productive!",
        "Also, shooting your fellow droid is not a good idea!",
      ].join(" "*10)
      
    @msg_x = 900
    @msg_width = @font.text_width(@message)
  end
          
  def unpause
    Song["pause_music.ogg"].stop
    pop_game_state
  end  
  
  def draw
    super
    @font.draw(@message, @msg_x, 550, 0)
  end
  
  def update
    super
    @msg_x -= 2
    @msg_x = 800 if @msg_x < -@msg_width
  end
  
end

class PauseDroid < GameObject
  def initialize(options)
    super
    @animation = Animation.new(:file => "pause_droid.bmp", :size => [11, 16], :delay => 400).retrofy
    self.factor = 10
    update
  end
  
  def update
    @image = @animation.next
  end
end

