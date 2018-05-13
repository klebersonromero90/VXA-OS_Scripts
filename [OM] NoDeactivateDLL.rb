#------------------------------------------------------------------#
# ** NoDeactivateDLL + Komuro Mod.
# ** Não Pausa o Game.exe
#------------------------------------------------------------------#
module NoDeactivateDLL
	dll = DL.dlopen('System/NoDeactivate')
	Start = DL::CFunc.new(dll['Start'],DL::TYPE_VOID)
	InFocus = DL::CFunc.new(dll['InFocus'],DL::TYPE_INT)
end
module Graphics
	@inFocus = true
	def self.inFocus=(bool); @inFocus = bool; end
	def self.inFocus; @inFocus; end
end
module Graphics
	class << self
		alias update_again update
	end
	def self.update	
		if NoDeactivateDLL::InFocus.call([]) == 1
			self.inFocus = true
		else
			self.inFocus = false
		end
		update_again
	end
end
NoDeactivateDLL::Start.call([])
