local LAM = LibStub( 'LibAddonMenu-1.0' )
if ( not LAM ) then return end

local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end
LMP:Register( LMP.MediaType.FONT, 'DejaVu Sans Mono', [[_framerate/fonts/dejavusansmono.ttf]] )

local CBM = CALLBACK_MANAGER
local _framerateConfig = {}

local defaults = 
{
    font_face = 'DejaVu Sans Mono',
    font_size = '10',
    font_decoration = 'shadow',

    colors = 
    {
        bad     = { 255, 0, 0, 1 },
        okay    = { 255, 255, 0, 1 },
        good    = { 0, 255, 0, 1  } 
    }
}

local decorations = { 'none', 'soft-shadow-thin', 'soft-shadow-thick', 'shadow' }

function _framerateConfig:FormatFont( face, size, decoration )
    local format = '%s|%d'
    if ( decoration ~= 'none' ) then
        format = format .. '|%s'
    end

    return string.format( format, LMP:Fetch( LMP.MediaType.FONT, face ), size, decoration )
end

function _framerateConfig:OnLoaded()
    self.db             = ZO_SavedVars:NewAccountWide( 'FRAMERATE_DB', 1.0, nil, defaults )
    self.config_panel   = LAM:CreateControlPanel( '_framerate_config', '_framerate' )

    self:CreateConfig()

    self:OnColorsChanged()
    self:OnFontChanged()
end

function _framerateConfig:CreateConfig()
    LAM:AddHeader( self.config_panel, '_framerate_header_font', 'Font' )

    LAM:AddDropdown( self.config_panel, '_framerate_font', 'Font:', '',  LMP:List( LMP.MediaType.FONT ),
        function() return self.db.font_face end,
        function( face )
            self.db.font_face = face
            self:OnFontChanged() 
        end )

    LAM:AddSlider( self.config_panel, '_framerate_size', 'Size:', '', 8, 50, 1,
        function() return self.db.font_size end, 
        function( size ) 
            self.db.font_size = size
            self:OnFontChanged()
        end )

    LAM:AddDropdown( self.config_panel, '_framerate_decoration', 'Decoration:', '', decorations,
        function() return self.db.font_decoration end,
        function( deco ) 
            self.db.font_decoration = deco
            self:OnFontChanged()
        end )

    LAM:AddHeader( self.config_panel, '_framerate_header_colors', 'Colors' )

    LAM:AddColorPicker( self.config_panel, '_framerate_color_good', 'Good:', '', 
        function() return unpack( self.db.colors.good ) end,
        function( r, g, b, a )
            self.db.colors.good = { r,g,b,a }
            self:OnColorsChanged()
        end )

    LAM:AddColorPicker( self.config_panel, '_framerate_color_okay', 'Okay:', '', 
        function() return unpack( self.db.colors.okay ) end,
        function( r, g, b, a )
            self.db.colors.okay = { r,g,b,a }
            self:OnColorsChanged()
        end )

    LAM:AddColorPicker( self.config_panel, '_framerate_color_bad', 'Bad:', '', 
        function() return unpack( self.db.colors.bad ) end,
        function( r, g, b, a )
            self.db.colors.bad = { r,g,b,a }
            self:OnColorsChanged()
        end )
end

function _framerateConfig:OnColorsChanged()
    CBM:FireCallbacks( '_FRAMERATE_COLORS_CHANGED', self.db.colors.good, self.db.colors.okay, self.db.colors.bad )
end

function _framerateConfig:OnFontChanged()
    CBM:FireCallbacks( '_FRAMERATE_FONT_CHANGED', self:FormatFont( self.db.font_face, self.db.font_size, self.db.font_decoration ) )
end

CBM:RegisterCallback( '_FRAMERATE_LOADED', function() _framerateConfig:OnLoaded() end )