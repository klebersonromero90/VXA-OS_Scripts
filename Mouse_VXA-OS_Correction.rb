#==============================================================================
# ** Mouse
#------------------------------------------------------------------------------
#  Autor: Cidiomar
#  Modifield: Komuro
#==============================================================================

class Mouse
  
  attr_reader :object, :type
  
  def left_click?;         @triggered[1];   end
  def right_click?;        @triggered[2];   end
  def left_press?;         @pressed[1];     end
  def right_press?;        @pressed[2];     end
  def left_release?;       @released[1];    end
  def right_release?;      @released[2];    end
  def left_repeat?;        @repeated[1];    end
  def right_press?;        @repeated[2];    end
  def double_left_click?;  @dbl_lclick;     end
  def double_right_click?; @dbl_rclick;     end
  
  typedef 'unsigned long HCURSOR'
  dll = 'System/VXAOS.dll'
	#-------Komuro DL
	VXAOS = DL.dlopen('System/VXAOS.dll')
	Mouse__update    = DL::CFunc.new(VXAOS['Mouse__update'], DL::TYPE_INT)
  Mouse__getPos    = DL::CFunc.new(VXAOS['Mouse__getPos'], DL::TYPE_LONG)
	Mouse__getOldPos = DL::CFunc.new(VXAOS['Mouse__getOldPos'], DL::TYPE_LONG)
	#-------
	Mouse__setup = c_function dll, 'void Mouse__setup(struct RArray*, struct RArray*, struct RArray*, void *)'
  
  def initialize
    @triggered = Input.triggered
    @pressed = Input.pressed
    @released = Input.released
    @repeated = Input.repeated
    @last_lclick = Time.now
    @last_rclick = Time.now
    @dbl_lclick = false
    @dbl_rclick = false
    Mouse__setup.call(@triggered, @pressed, @released, @repeated)
    @cursor_sprite = ::Sprite.new
    @cursor_sprite.bitmap = Cache.system('Cursor')
    @cursor_sprite.z = 999
    @item_sprite = ::Sprite.new
    @item_sprite.bitmap = Bitmap.new(24, 24)
    @item_sprite.z = @cursor_sprite.z - 1
    @type = Constants::MOUSE_TYPE_NONE
    @object = nil
    update
  end
	
	def set_item(object, type)
    @object = object
    @type = type
    @item_sprite.bitmap.clear
    if @object
      bitmap = Cache.system('Iconset')
      rect = Rect.new(@object.icon_index % 16 * 24, @object.icon_index / 16 * 24, 24, 24)
      @item_sprite.bitmap.blt(0, 0, bitmap, rect)
    end
  end
  
  def update
    Mouse__update.call([])
    @pos = [0, 0].pack('l2')
		#----
		@posfix = DL::CPtr[@pos].to_i
    #----
		@old_pos = [0, 0].pack('l2')
		#----
		@oldposfix = DL::CPtr[@old_pos].to_i
    #----
		Mouse__getPos.call([@posfix])
    Mouse__getOldPos.call([@oldposfix])
		#----
    @pos = @pos.unpack('l2')
    @old_pos = @old_pos.unpack('l2')
    @dbl_lclick = false
    @dbl_rclick = false
		positon_mouse_
    if left_click?
      t_diff = Time.now - @last_lclick
      if t_diff < 0.5 && @last_pos == @pos
        @dbl_lclick = true
      else
        @last_lclick = Time.now
        @last_pos = @pos
      end
    elsif right_click?
      t_diff = Time.now - @last_rclick
      if t_diff < 0.5 && @last_pos == @pos
        @dbl_rclick = true
      else
        @last_rclick = Time.now
        @last_pos = @pos
      end
    end
    @cursor_sprite.x, @cursor_sprite.y = *@pos
    @item_sprite.x = @cursor_sprite.x - 13
    @item_sprite.y = @cursor_sprite.y - 13
		update_drag
  end
	
	def positon_mouse_
		@pos = [
			(Configs::SCREEN_W.to_f / 640) * @pos[0],
			(Configs::SCREEN_H.to_f / 480) * @pos[1]
		]
		@old_pos = [
			(Configs::SCREEN_W.to_f / 640) * @old_pos[0],
			(Configs::SCREEN_H.to_f / 480) * @old_pos[1]
		]
	end

  def update_drag
    return if left_press? || !@object
    set_item(nil, Constants::MOUSE_TYPE_NONE)
  end
  
  def x;        @pos[0];           end
  def y;        @pos[1];           end
  def pos;      @pos.dup;          end
  def old_x;    @old_pos[0];       end
  def old_y;    @old_pos[1];       end
  def old_pos;  @old_pos.dup;      end
  def moved?;   @pos != @old_pos;  end
  
  def tile
    x = (($game_map.display_x * 32 + self.x) / 32).to_i
    y = (($game_map.display_y * 32 + self.y) / 32).to_i
    return x, y
  end
  
end
