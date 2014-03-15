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

local CBM = CALLBACK_MANAGER
local ranges = { okay = 30, good = 60 }   
local strformat = string.format

local function clamp( val, min, max )
    return zo_max( zo_min( val, max ), min )
end

local _framerate        = ZO_Object:Subclass()
_framerate.colors       = setmetatable( {}, { __mode = 'kv' } )
_framerate.frame_rate   = 0
_framerate.last_time    = 0

function _framerate:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function _framerate:Initialize( control )
    self.control  = control
    self.label    = control:GetNamedChild( '_Label' )

    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( _, addon ) self:AddonLoaded( addon ) end )
end

function _framerate:AddonLoaded( addon )
    if ( addon ~= '_framerate' ) then
        return
    end

    CBM:RegisterCallback( '_FRAMERATE_COLORS_CHANGED', function( ... ) self:OnColorsChanged( ... ) end )
    CBM:RegisterCallback( '_FRAMERATE_FONT_CHANGED', function( ... ) self:OnFontChanged( ... ) end )

    CBM:FireCallbacks( '_FRAMERATE_LOADED' )
    self.control:SetHandler( 'OnUpdate', function( _, frameTime ) self:OnUpdate( frameTime ) end )
end

function _framerate:OnColorsChanged( good, okay, bad )
    self.colors = { bad, okay, good }
end

function _framerate:OnFontChanged( newFont )
    self.label:SetFont( newFont )
end

function _framerate:OnUpdate( frameTime )
    if ( frameTime - self.last_time < 0.5 ) then
        return
    end

    if ( GetFramerate() == self.frame_rate ) then
        return
    end

    self.last_time = frameTime
    
    self.frame_rate = GetFramerate()

    local level = 1
    if ( self.frame_rate >= ranges.good ) then
        level = 3 
    elseif ( self.frame_rate >= ranges.okay ) then
        level = 2
    end

    self.label:SetText( strformat( 'FPS: %.1f', self.frame_rate ) )
    self.label:SetColor( unpack( self.colors[ level ] ) )
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