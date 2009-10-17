class MainMenuState < Chingu::GameState
  
  def setup
    @font = Font.new($window, default_font_name, 30)
    @options = [ :start, :quit ]
    @current = 0
    @selected = Color.new(255,0,0,128)
    
    self.input = { 
      :escape => :exit,
      :up => :move_up,
      :down => :move_down,
      :space => :go,
      :enter => :go,
    }
    
  end

  def move_up
    @current -= 1
    @current = @options.length-1 if @current < 0
  end
  
  def move_down
    @current += 1
    @current = 0 if @current >= @options.length
  end

  def go
    met = "on_" + @options[@current].to_s
    self.send(met)
  end

  def draw
    @options.each_with_index do |option, i|
      y = 300+(i*50)
      if i == @current
        $window.draw_quad( 0,y,@selected, 800,y,@selected, 800,y+30,@selected, 0,y+30,@selected )
      end
      @font.draw(option.to_s.capitalize, 200, y,0)
    end
  end
  
  
  # Menu options callbacks:
  
  def on_start
    push_game_state( PlayState )
  end
  
  def on_quit
    self.close
  end
  
end