#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
#  Scrip_Original:       Valentine
#  Designer:             Quimera95
#  Idéia de:             Hitsuji
#  Alterações no Script: Komuto Takashi
#==============================================================================

class Sprite_HUD < Sprite
  
  def initialize
    super
    self.bitmap = Bitmap.new(300, 55)
    self.x = (Graphics.width / 2 - 120)
    self.y = Graphics.height - 90
    self.z = 100
    self.bitmap.font.size = 18
    self.bitmap.font.bold = true
    @base = Cache.picture('Base_HUD')
    @bars = Cache.picture('HUDBars')
		@xpbar = Cache.picture('XP')
    refresh
  end
  
  def refresh
    self.bitmap.clear
    self.bitmap.blt(7, 0, @base, Rect.new(0, 0, 300, 55))
    #draw_face
    draw_hpbar
    draw_mpbar
    draw_expbar
    draw_level
  end
=begin
  def draw_face
    face = Cache.face($game_actors[1].face_name)
    self.bitmap.blt(0, 1, face, Rect.new($game_actors[1].face_index % 4 * 96, $game_actors[1].face_index / 4 * 96, 96, 96))
  end
=end
  
  def draw_hpbar
    self.bitmap.blt(10, 7, @bars, Rect.new(0, 0, 117 * $game_actors[1].hp / $game_actors[1].mhp, 15))
    self.bitmap.draw_text(10, 7, 229, 18, Vocab::hp_a)
    self.bitmap.draw_text(40, 7, 229, 18, "#{$game_actors[1].hp}/#{$game_actors[1].mhp}")
  end
  
  def draw_mpbar
    self.bitmap.blt(185, 7, @bars, Rect.new(0, 26, 117 * $game_actors[1].mp / $game_actors[1].mmp, 15))
    self.bitmap.draw_text(188, 7, 229, 18, Vocab::mp_a)
    self.bitmap.draw_text(220, 7, 229, 18, "#{$game_actors[1].mp}/#{$game_actors[1].mmp}")
  end
  
  def draw_expbar
    self.bitmap.blt(10, 32, @xpbar, Rect.new(0, 0, 292 * $game_actors[1].now_exp / $game_actors[1].next_exp, 12))
    self.bitmap.draw_text(10, 30, 229, 18, Vocab::Exp)
    self.bitmap.draw_text(140, 30, 229, 18, "#{$game_actors[1].now_exp}/#{$game_actors[1].next_exp}")
  end
  
  def draw_level
		self.bitmap.draw_text(135, 7, 30, 18, Vocab::level_a)
    self.bitmap.draw_text(155, 7, 30, 18, $game_actors[1].level)
  end
  
end
