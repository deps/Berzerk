
class HighScoreState < GameState
  
  def initialize( options = {} )
    super
    
    pos = $window.scores.position_by_score( $last_score )
    
    if pos and $player_name and $last_score
      messages = []
      $reward_list.each do |r|
        messages << r.msg if r.done?
      end
      $window.scores.add :name => $player_name, :score => $last_score, :text => messages.join(", ")
      mark_name = $player_name
      mark_score = $last_score
      $player_name = nil
      $player_score = nil
    end
    
    marked = false # Will be true if an entry matches the values in $player_name and $last_score

    MenuTitleImage.create(:x => 400, :y => 50, :factor => 0.5, :silent => true)

    $window.scores.each_with_index do |high_score, index|
      y = index * 40 + 150
      
      if high_score[:name] == mark_name and high_score[:score] == mark_score and !marked
        t = PulsatingText.create(high_score[:name], :x => 300, :y => y, :size => 40, :font => default_font_name())
        t.x -= t.width
        PulsatingText.create(high_score[:score], :x => 500, :y => y, :size => 40, :font => default_font_name())
        marked = true # Do not make any other entry flash, if it would look similar to this one
      else
        t = Text.create(high_score[:name], :x => 300, :y => y, :size => 40, :font => default_font_name())
        t.x -= t.width
        t = Text.create(high_score[:score], :x => 500, :y => y, :size => 40, :font => default_font_name())
      end
      
    end    
    
    self.input = { :space => :close, :escape => :close, :return => :close, :enter => :close }
    
  end
  
  def setup
    s = Song["sad robot.ogg"]
    s.volume = $settings['music']
    s.play(true)
  end
  
end


class PulsatingText < Text
  has_trait :timer, :effect
  #@@red = Color.new(0xFFFF0000)
  #@@green = Color.new(0xFF00FF00)
  #@@blue = Color.new(0xFF0000FF)
  
  def initialize(text, options = {})
    super(text, options)
    
    options = text  if text.is_a? Hash
    @pulse = options[:pulse] || false
    #self.rotation_center(:center)
    #every(20) { create_pulse }  unless @pulse
    @color = Color.new(0xFFFF0000)
    @inc = true
    every(20) { change_color }
    
    
  end
  
  def change_color
    if @inc
      @color.green += 5
      if @color.green >= 255
        @color.green = 255
        @inc = false
      end
    else
      @color.green -= 5
      if @color.green <= 0
        @color.green = 0
        @inc = true
      end
    end
  end
  
  # def create_pulse
  #   pulse = PulsatingText.create(@text, :x => @x, :y => @y, :height => @height, :pulse => true, :image => @image, :zorder => @zorder+1)
  #   colors = [@@red, @@green, @@blue]
  #   pulse.color = colors[rand(colors.size)].dup
  #   pulse.mode = :additive
  #   pulse.alpha -= 150
  #   pulse.scale_rate = 0.01
  #   pulse.fade_rate = -3 + rand(2)
  #   pulse.rotation_rate = rand(2)==0 ? 0.05 : -0.05
  # end
  #   
  # def update
  #   destroy if self.alpha == 0
  # end
  
end
