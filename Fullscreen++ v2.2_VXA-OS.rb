#=========================================================================== 
# Fullscreen++ v2.2 for VX and VXace by Zeus81
# Free for non commercial and commercial use
# Licence : http://creativecommons.org/licenses/by-sa/3.0/
# Contact : zeusex81@gmail.com
# (fr) Manuel d'utilisation : http://pastebin.com/raw.php?i=1TQfMnVJ
# (en) User Guide           : http://pastebin.com/raw.php?i=EgnWt9ur
#-------------------------------------------------------------------------
# Modificado por: Komuro Takashi para o Projeto VXA-OS
#-------------------------------------------------------------------------
#=========================================================================== 
$imported ||= {}
$imported[:Zeus_Fullscreen] = __FILE__
class << Graphics
	#---------------------------------------------#
  Gdi32    = DL.dlopen('gdi32')
	User32   = DL.dlopen('user32')
	Kernel32 = DL.dlopen('kernel32')
	#---------------------------------------------#
	# KOMURO WIN32API to DL
	#---------------------------------------------#
  	# USER32
	#---------------------------------------------#
	UpdateWindow              = DL::CFunc.new(  User32['UpdateWindow'        ], DL::TYPE_LONG)
	FindWindow		  = DL::CFunc.new(  User32['FindWindow'          ], DL::TYPE_LONG)
	CreateWindowEx		  = DL::CFunc.new(  User32['CreateWindowEx'      ], DL::TYPE_LONG)
	GetSystemMetrics          = DL::CFunc.new(  User32['GetSystemMetrics'    ], DL::TYPE_LONG)
	ShowWindow		  = DL::CFunc.new(  User32['ShowWindow'          ], DL::TYPE_LONG)
	GetDC                     = DL::CFunc.new(  User32['GetDC'               ], DL::TYPE_LONG)
	FillRect		  = DL::CFunc.new(  User32['FillRect'            ], DL::TYPE_LONG)
	GetClientRect             = DL::CFunc.new(  User32['GetClientRect'       ], DL::TYPE_LONG)
	GetWindowRect             = DL::CFunc.new(  User32['GetWindowRect'       ], DL::TYPE_LONG)
	ReleaseDC	          = DL::CFunc.new(  User32['ReleaseDC'           ], DL::TYPE_LONG)
	SetWindowLong             = DL::CFunc.new(  User32['SetWindowLong'       ], DL::TYPE_LONG)
	SetWindowPos              = DL::CFunc.new(  User32['SetWindowPos'        ], DL::TYPE_LONG)
	SystemParametersInfo      = DL::CFunc.new(  User32['SystemParametersInfo'], DL::TYPE_LONG)
	#---------------------------------------------#
	# GDI32
	#---------------------------------------------#
	CreateSolidBrush  = DL::CFunc.new(  Gdi32['CreateSolidBrush'       ], DL::TYPE_LONG)
	DeleteObject	  = DL::CFunc.new(  Gdi32['DeleteObject'           ], DL::TYPE_LONG)
	#---------------------------------------------#
	# KERNEL32
	#---------------------------------------------#
	GetPrivateProfileString   = DL::CFunc.new( Kernel32['GetPrivateProfileString'  ], DL::TYPE_LONG)
	WritePrivateProfileString = DL::CFunc.new( Kernel32['WritePrivateProfileString'], DL::TYPE_LONG)
	#---------------------------------------------#
  unless method_defined?(:zeus_fullscreen_update)
		HWND     = FindWindow.call([
				DL::CPtr["RGSS Player"].to_i,
				0
		])
    BackHWND = CreateWindowEx.call([
				0x08000008,
				DL::CPtr['Static'].to_i,
				DL::CPtr[''].to_i,
				0x80000000,
			  0,0,0,0,0,0,0,0		
		])
		alias zeus_fullscreen_resize_screen resize_screen
    alias zeus_fullscreen_update        update
  end
private
  def initialize_fullscreen_rects
    @borders_size    ||= borders_size
    @fullscreen_rect ||= screen_rect
    @workarea_rect   ||= workarea_rect
  end
	
  def borders_size
    GetClientRect.call([HWND,DL::CPtr[wrect = [0, 0, 0, 0].pack('l4')].to_i])
		GetClientRect.call([HWND,DL::CPtr[crect = [0, 0, 0, 0].pack('l4')].to_i])
		wrect, crect = wrect.unpack('l4'), crect.unpack('l4')
    Rect.new(0, 0, wrect[2]-wrect[0]-crect[2], wrect[3]-wrect[1]-crect[3])
  end
	
  def screen_rect
    Rect.new(0, 0, GetSystemMetrics.call([0]), GetSystemMetrics.call([1]))
  end
	
  def workarea_rect
    SystemParametersInfo.call([0x30, 0, DL::CPtr[rect = [0, 0, 0, 0].pack('l4')], 0])
    rect = rect.unpack('l4')
    Rect.new(rect[0], rect[1], rect[2]-rect[0], rect[3]-rect[1])
  end
	
  def hide_borders() SetWindowLong.call([HWND, -16, 0x14000000]) end
  def show_borders() SetWindowLong.call([HWND, -16, 0x14CA0000]) end
  def hide_back()    ShowWindow.call([BackHWND, 0])              end
  
	def show_back
    ShowWindow.call([BackHWND, 3])
    UpdateWindow.call([BackHWND])
    dc    = GetDC.call([BackHWND])
    rect  = [0, 0, @fullscreen_rect.width, @fullscreen_rect.height].pack('l4')
    brush = CreateSolidBrush.call([0])
		FillRect.call([dc,DL::CPtr[rect].to_i,brush])
		ReleaseDC.call([BackHWND, dc])
    DeleteObject.call([brush])
  end
#|||||||||||||||||||||||||||||||||||||||||||#	
#_______Redimenciona_Janela_Game____________#	
#|||||||||||||||||||||||||||||||||||||||||||#	
  def resize_window(w, h)
    if @fullscreen
      x, y, z = (@fullscreen_rect.width-w)/2, (@fullscreen_rect.height-h)/2, -1
    else
      w += @borders_size.width
      h += @borders_size.height
      x = @workarea_rect.x + (@workarea_rect.width  - w) / 2
      y = @workarea_rect.y + (@workarea_rect.height - h) / 2
      z = -2
    end
    SetWindowPos.call([HWND, z, x, y, w, h, 0])
  end
public
#|||||||||||||||||||||||||||||||||||||||||||#	
#_______Carregar_Configurações_Modo_Tela____#
#|||||||||||||||||||||||||||||||||||||||||||#	
  def load_fullscreen_settings
    buffer = [].pack('x256')
    section = 'Fullscreen++'
    filename = './Game.ini'
    get_option = Proc.new do |key, default_value|
      l = GetPrivateProfileString.call([
					DL::CPtr[section].to_i,
					DL::CPtr[key].to_i,
					DL::CPtr[default_value].to_i,
					DL::CPtr[buffer].to_i,
					buffer.size,
					DL::CPtr[filename].to_i
			])
			buffer[0, l]
    end
		#_______Se_nao_haver_configuracao_coloca_a_padrão________________#
    @fullscreen       = get_option.call('Fullscreen'     , '0') == '1'
    @fullscreen_ratio = get_option.call('FullscreenRatio', '0').to_i
    @windowed_ratio   = get_option.call('WindowedRatio'  , '1').to_i
		#________________________________________________________________#
    fullscreen? ? fullscreen_mode : windowed_mode
  end
#|||||||||||||||||||||||||||||||||||||||||||#	
#_______Salvar_Configurações_Modo_Tela______#
#|||||||||||||||||||||||||||||||||||||||||||#	
  def save_fullscreen_settings
    section = 'Fullscreen++'
    filename = './Game.ini'
    set_option = Proc.new do |key, value|
			WritePrivateProfileString.call([
				DL::CPtr[section].to_i,
				DL::CPtr[key].to_i,
				DL::CPtr[value.to_s].to_i,
				DL::CPtr[filename].to_i
			])
    end
		#____________Salva_Ultima_Configuração_Modo_Tela___________#
    set_option.call('Fullscreen'     , @fullscreen ? '1' : '0')
    #Evita Erro de Renderização
		set_option.call('FullscreenRatio', 0)
		set_option.call('WindowedRatio'  , @windowed_ratio)
		#__________________________________________________________#
  end
#|||||||||||||||||||||||||||||||||||||||||#	
#_________Esta_Em_Modo_Tela_Cheia_?_______#
#|||||||||||||||||||||||||||||||||||||||||#	
  def fullscreen?;    @fullscreen;  end
#|||||||||||||||||||||||||||||||||||||||||||||||#	
#___Altera_Entre_Modo_Tela_Cheia_E_Modo_Janela__#
#|||||||||||||||||||||||||||||||||||||||||||||||#	
  def toggle_fullscreen
    fullscreen? ? windowed_mode : fullscreen_mode
  end
#||||||||||||||||||||||||||||||||||#	
#_______Modo_Tela_Cheia____________#
#||||||||||||||||||||||||||||||||||#	
  def fullscreen_mode
    initialize_fullscreen_rects
    show_back
    hide_borders
    @fullscreen = true
    self.ratio += 0
  end
#||||||||||||||||||||||||||||||||||#	
#_______Modo_Janela________________#
#||||||||||||||||||||||||||||||||||#	
  def windowed_mode
    initialize_fullscreen_rects
    hide_back
    show_borders
    @fullscreen = false
    self.ratio += 0
  end
#||||||||||||||||||||||||||||||||||||||||||||||||||||#	
  def ratio
    @fullscreen ? @fullscreen_ratio : @windowed_ratio
  end
#||||||||||||||||||||||||||||||||||||||||||||||||||||#	
  def ratio=(r)
    initialize_fullscreen_rects
    r = 0 if r < 0
    if @fullscreen
      @fullscreen_ratio = r
      w_max, h_max = @fullscreen_rect.width, @fullscreen_rect.height
    else
      @windowed_ratio = r
			w_max = Configs::SCREEN_WIDTH - @borders_size.width - 32
			h_max = Configs::SCREEN_HEIGHT - @borders_size.height - 32
    end
    if r == 0
      w, h = w_max, w_max * height / width
      h, w = h_max, h_max * width / height if h > h_max
    else
			w, h = Configs::SCREEN_WIDTH, Configs::SCREEN_HEIGHT
      return self.ratio = 0 if w > w_max or h > h_max
    end
    resize_window(w, h)
    save_fullscreen_settings
  end
#|||||||||||||||||||||||||||||||||||||||||||||||||#	
#_____________Metodo_de_Atualização_______________#
#|||||||||||||||||||||||||||||||||||||||||||||||||#	
  def update
    zeus_fullscreen_update
    toggle_fullscreen if Input.trigger?(Input::F5)
  end
#|||||||||||||||||||||||||||||||||||||||||||||||||#	
#____________Novo_Redimencionar_Tela______________#
#|||||||||||||||||||||||||||||||||||||||||||||||||#	
  def resize_screen(width, height)
    zeus_fullscreen_resize_screen(width, height)
    self.ratio += 0 # refresh window size
  end
end
#|||||||||||||||||||||||||||||||||||||||||||||||||#	
#____________Carrega as conf. no Game.ini_________#
#|||||||||||||||||||||||||||||||||||||||||||||||||#	
Graphics.load_fullscreen_settings
