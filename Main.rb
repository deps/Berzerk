require 'rubygems'
require 'opengl'
require 'Chingu'
include Gosu

def media_path(file)
  File.join($window.root, "media", file)  
end


#require File.join('models','map')
require_all('models')


class PlayState < Chingu::GameState
  
  def setup
    @pop_at = nil
    @room_x = 0
    @room_y = 0
        
    create_player
    
    @lives = 3
    
    self.input = { :escape => :exit }
    
    @player_pos = Chingu::Text.new(:text => "n/a", :x => 25, :y => 5 )
    
    # Original screenshot, used to compare with my walls
    @background = nil
    #@background = Gosu::Image.new($window, "media/debug.png")
  end
  
  
  def create_player( ex = 50, ey = 292, rx = 0, ry = 0, moving_dir = :none )
    @entry_x = ex
    @entry_y = ey
    
    @room.destroy if @room
    @room = Berzerk::Room.new( :roomx=>rx, :roomy => ry, :create_seed => (moving_dir == :none) )
    
    case moving_dir
      when :north
        @room.close(:south)
      when :south
        @room.close(:north)
      when :west
        @room.close(:east)
      when :east
        @room.close(:west)
    end
    
    @player = Player.create( :x => @entry_x, :y => @entry_y )
    
  end
  
  
  def change_room( dir )
    ex = 50
    ey = 255
    rx = @room_x
    ry = @room_y
    case dir
      when :north
        ex = 325
        ey = 490
        ry-=1
      when :south
        ey = 40
        ex = 325
        ry+=1
      when :west
        ex = 610
        rx-=1
      when :east
        ex = 50
        rx+=1
    end
    
    game_objects.remove_all
    
    create_player(ex,ey,rx,ry, dir)
    
    @room_x = rx
    @room_y = ry
    @entry_x = ex
    @entry_y = ey
  end
 
  
  def update
    super
    $window.caption = "FPS:#{$window.fps} - dt:#{$window.milliseconds_since_last_tick} - objects:#{current_game_state.game_objects.size}"
    
    if @player
      #@player_pos.text = "#{@player.x}, #{@player.y}"
      if @player.x <= 25
        change_room(:west)
      elsif @player.x >= 635
        change_room(:east)
      elsif @player.y <= 10
        change_room(:north)
      elsif @player.y >= 540
        change_room(:south)
      end
    end
    
    if @pop_at
      self.close if Time.now >= @pop_at
    end
    
    players = game_objects_of_class( Player )
    @player = nil if players.count == 0
    if !@player and @lives > 0
      @lives -= 1
      if @lives != 0
        puts "Player is alive again"
        create_player
      else
        @pop_at = Time.now + 2
        puts "Game Over at #{@pop_at} (is not #{Time.now})"
      end
    end
    
  end
  
  def draw
    
    @background.draw( 25,25,0, 2.5, 2.5 ) if @background
    
    super
    
    draw_hud
    
  end
  
  def draw_hud
    
    if @player
      @player_pos.draw
      
    end
  end
  
end



class Player < Chingu::GameObject
  has_trait :collision_detection
  has_trait :timer
  
  def initialize( options = {} )
    super 
    
    
    self.input = { :holding_left => :move_left, :holding_right => :move_right, :holding_up => :move_up, :holding_down => :move_down}
    
    @anim_file = Chingu::Animation.new(:file => media_path("player.png"), :width=>8, :height=>16, :bounce => true )
    @anim_file.retrofy
    
    @anim = {}
    @anim[:idle] = (0..0)
    @anim[:left] = (3..4)
    @anim[:right] = (1..2)
    @anim[:die] = (7..8)
    @moving = false
    
    @new_anim = nil
    use_animation(:idle)
    
    #@image = Image["player.png"]
    #@image.retrofy
    
    @factor_x = 2.5
    @factor_y = 2.5
    
    @lives = 3
    
    @entry_x = x
    @entry_y = y
    
    @bounding_box = Chingu::Rect.new([@x, @y, 8*@factor_x, 16*@factor_y])
    self.rotation_center(:top_left)
    
    
  end
  
  def use_animation( anim )
    return if anim == @current_animation 
    @current_animation = anim
    puts "Changing animation to #{anim}"
    new_anim = @anim_file.new_from_frames( @anim[anim] )
    @animation = new_anim
    if anim == :die
      @animation.delay = 25
    end
    @image = @animation.image
  end
  
  def update_animation
    return if frozen?
    @image = @animation.next!
  end
  
  def collide_with_wall
    return if @current_animation == :die
    self.input = {}
    use_animation(:die)
    
    after(1000) do 
      hide!
      spawn_gibs 
    end.then do
      after(3000) { destroy }
    end
    
  end
  
  def spawn_gibs
    puts "Pretend that blood and gore is everywhere. And some smoke"
  end
    
  def move_left
    move(-1,0)
    @new_anim = :left
  end
  
  def move_right
    move(1,0)
    @new_anim = :right
  end
  
  def move_up
    move(0,-1)
  end
  
  def move_down
    move(0,1)
  end
  
  def move( xoff, yoff )
    return if frozen?
    @moving = true
    ox = @x
    oy = @y
    @x+=xoff
    @y+=yoff
    each_collision(Berzerk::TileObject) do |player, tile|
      collide_with_wall
      return
    end
  end
  
  # def draw
  #   super
  #   $window.fill_rect(@bounding_box, Color.new(128,255,0,0))
  # end
  
  def update
    unless frozen?
      if @moving
        if @new_anim and @current_animation != :die
          use_animation(@new_anim)
          @new_anim = nil
        end
      #else
      #  use_animation(:idle) unless @current_animation == :die
      end
    end
  
    super
    
    update_animation if @moving
    @moving = false unless frozen?
    
  end
  
end


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