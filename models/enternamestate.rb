class EnterNameState < GameState
  
  def initialize( options = {})
    super
    
    @letters = %w[ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ]
    @selected = 0
    @name = ""
    
    self.input = { :left => :go_left, :right => :go_right, :space => :add, :backspace => :delete }
    @blip = false
    @blip_timer = 100
  end
  
  def go_left
    @selected += 1
    @selected = 0 if @selected >= @letters.length 
    Sound["menu_change.wav"].play($settings['sound'])
    
  end
  
  def go_right
    @selected -= 1
    @selected = @letters.length-1 if @selected < 0
    Sound["menu_change.wav"].play($settings['sound'])
    
  end
  
  def add
    Sound["menu_select.wav"].play($settings['sound'])
    
    @name << @letters[@selected]
    if @name.length == 3
      $player_name = @name
      pop_game_state( :setup => false )
      push_game_state( HighScoreState )
    end
  end
  
  def delete
    return if @name.length == 0
    Sound["menu_select.wav"].play($settings['sound'])
    @name = @name.chop
  end
  
  def draw
    super

    angle = -(@selected * 14)

    $window.gl do   
      @letters.each_with_index do |l,n|
        x = 400 + Math::sin((angle).to_rad)*300
        y = 350 + Math::cos((angle).to_rad)*50
        z = Math::cos(angle.to_rad)*50+50
        zp = z / 100.0
        s = 1.0+zp
        s = 5 if n == @selected
        p = 64+((zp) * 191).to_i
        col = Color.new( 255, p/2,p/2,p ) 
        $window.font.draw(l, x - $window.font.text_width(l,s)/2 ,y-(15*s), z , s,s, col)
        angle += 14
      end
    end
    
    @blip_timer -= $window.dt
    if @blip_timer < 0
      @blip_timer = 100
      @blip = !@blip
    end
    

    tmp = @name + (@blip ? "|" : "")
    $window.font.draw(tmp, 400-$window.font.text_width(@name+"|",10)/2,150,50, 10,10)
    
  end
  
end