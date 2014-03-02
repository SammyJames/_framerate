local ranges =
{
    OKAY = 30,
    GOOD = 60
}

local colors = 
{
    BAD = { r = 255, g = 0, b = 0 },
    OKAY = { r = 255, g = 255, b = 0 },
    GOOD = { r = 0, g = 255, b = 0 }    
}

local _framerate = ZO_Object:Subclass()
_framerate.color = colors.GOOD
_framerate.frame_rate = 0

function _framerate:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function _framerate:Initialize( control )
    self.control = control
    self.label = control:GetNamedChild( '_Label' )

    self.control:SetHandler( 'OnUpdate', function() self:OnUpdate() end )
end

function _framerate:OnUpdate()
    if ( GetFramerate() == self.frame_rate ) then
        return
    end
    
    self.frame_rate = GetFramerate()
    if ( self.frame_rate < ranges.OKAY ) then
        self.color = colors.BAD
    elseif ( self.frame_rate < ranges.GOOD ) then
        self.color = colors.OKAY
    end

    self.label:SetText( string.format( 'FPS: %.1f', self.frame_rate ) )
    self.label:SetColor( self.color.r, self.color.g, self.color.b )
end

function Initialized( self )
    _FRAMERATE = _framerate:New( self )
end