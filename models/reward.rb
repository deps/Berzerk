
class Reward
  attr_reader :key, :msg
  
  def initialize( message, key, limit )
    @msg = message
    @key = key
    @limit = limit
    @amount = 0
  end
  
  def update( value )
    @amount += value
  end
  
  def done?
    @amount >= @limit 
  end
  
end