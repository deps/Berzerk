
class HighScoreState < GameState
  
  def initialize( options = {} )
    super
    
    pos = $window.scores.position_by_score( $last_score )
    
    if pos and $player_name and $last_score
       $window.scores.add :name => $player_name, :score => $last_score
       $window.scores.save
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
        PulsatingText.create(high_score[:name], :x => 300, :y => y, :size => 40)
        PulsatingText.create(high_score[:score], :x => 500, :y => y, :size => 40)
        marked = true # Do not make any other entry flash, if it would look similar to this one
      else
        t = Text.create(high_score[:name], :x => 300, :y => y, :size => 40)
        t.rotation_center( :center_center )
        t = Text.create(high_score[:score], :x => 500, :y => y, :size => 40)
        t.rotation_center( :center_center )
      end
      
    end    
    
    self.input = { :space => :close, :escape => :close, :return => :close, :enter => :close }
    
  end
  
end


class PulsatingText < Text
  has_trait :timer, :effect
  @@red = Color.new(0xFFFF0000)
  @@green = Color.new(0xFF00FF00)
  @@blue = Color.new(0xFF0000FF)
  
  def initialize(text, options = {})
    super(text, options)
    
    options = text  if text.is_a? Hash
    @pulse = options[:pulse] || false
    self.rotation_center(:center_center)
    every(20) { create_pulse }   if @pulse == false
  end
  
  def create_pulse
    pulse = PulsatingText.create(@text, :x => @x, :y => @y, :height => @height, :pulse => true, :image => @image, :zorder => @zorder+1)
    colors = [@@red, @@green, @@blue]
    pulse.color = colors[rand(colors.size)].dup
    pulse.mode = :additive
    pulse.alpha -= 150
    pulse.scale_rate = 0.01
    pulse.fade_rate = -3 + rand(2)
    pulse.rotation_rate = rand(2)==0 ? 0.05 : -0.05
  end
    
  def update
    destroy if self.alpha == 0
  end
  
end
