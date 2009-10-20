class CreditState < Chingu::GameState
  
  def initialize( options = {} )
    super
    
    @deps = Chingu::GameObject.create( :image => "dev_deps.png", :x => 125, :y => 419, :rotation_center => :center_center)
    @ippa = Chingu::GameObject.create( :image => "dev_ippa.png", :x => 674, :y => 419, :rotation_center => :center_center)
    MenuTitleImage.create(:x => 400, :y => 50, :factor => 0.5, :silent => true)
    
    self.input = { :escape => :close }
    @ticks = 0
    
    @credits = [
      "BERZERK",
      "-------------",
      "A remake of the arcade game",
      "by Stern Electronics, 1980",
      "",
      "",
      "-- Code --",
      "<-- Deps and Ippa -->",
      "",
      "",
      "-- Sound effects --",
      "Deps and Ippa",
      "",
      "",
      "-- Music --",
      "Title screen:",
      "'sad robot'",
      "by pornophonique",
      "",
      "During gameplay:",
      "'Diablo'",
      "by Vate",
      "",
      "Pause screen:",
      "'Mario elevator music'",
      "by Nintendo",
      "(please don't sue us, kthnx)",
      "",
      "",
      "-- Tools used --",
      "Gosu",
      "A kick-ass graphics module",
      "for the Ruby language",
      "",
      "Chingu",
      "A kick-ass game framework",
      "by Ippa",
      "",
      "sfxr",
      "A kick-ass 8-bit sound effect",
      "generator by Dr Pepper",
      "",
      "",
      "",
      "No kittens was harmed during",
      "the development of this game!",
      "",
      "But countless of robots and",
      "humanoids were slain, often",
      "in silly ways. Just for fun! ^^",
      "",
      "Thanks for watching this rolling",
      "text, now get back in the game",
      "and kick some arse!"
    ]
    @scroll_y = 700
    @stop_scroll = -100-@credits.length*30
    @color = Color.new(0xFFFFFFFF)
    
  end
  
  def update
    super
    @ticks += 4
    ypos = 419-(Math::sin(@ticks.to_rad)*100).abs
    @deps.y = ypos
    @ippa.y = ypos
    
    @scroll_y -= 1
    self.close if @scroll_y <= @stop_scroll
  end
  
  def draw
    @credits.each_with_index do |line, i|
      ypos = @scroll_y+(i*30)
      center_percent = 1.0-(Gosu::distance(0,ypos, 0,300) / 300.0)
      center_percent = 0 if center_percent < 0
      @color.alpha = (center_percent*255).to_i
      $window.font.draw(line, 400 - $window.font.text_width(line)/2 , ypos, 300, 1,1, @color)
    end
    super
  end
  
  
end



