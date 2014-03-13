-------------------------------------------------
-- show me your _framerate
--
-- @author Pawkette ( pawkette.heals@gmail.com )
--[[
The MIT License (MIT)

Copyright (c) 2014 Pawkette

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
-------------------------------------------------

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
    self.label:SetFont( string.format( '%s|%d|soft-shadow-thin', [[_framerate/DejaVuSansMono.ttf]], 10 ) )

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
    else 
        self.color = colors.GOOD
    end

    self.label:SetText( string.format( 'FPS: %.1f', self.frame_rate ) )
    self.label:SetColor( self.color.r, self.color.g, self.color.b )
end

function Initialized( self )
    _FRAMERATE = _framerate:New( self )

    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_FPS", "Toggle _framerate")
end

function ToggleFramerate()
    if ( _FRAMERATE ) then
        local visible = _FRAMERATE.control:IsHidden()
        _FRAMERATE.control:SetHidden( not visible )
    end
end