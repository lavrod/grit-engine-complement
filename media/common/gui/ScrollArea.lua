------------------------------------------------------------------------------
--  Scroll bar
--
--  (c) 2014-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

--[[ Scrollbar for placing at the side of a window over some large content.

A rectangle with a smaller rectangle inside it.  Can be dragged by mouse or
changed out-of-band.  Calls scrollCallback to notify changes.
]]
hud_class `ScrollBar`
{
    size = vec(10, 10),
    texture = `/common/hud/CornerTextures/SquareFilledWhiteBorder.png`,
    cornered = true,
    initialContentSize = 100,
    initialContentOffset = 0,

    -- Horizontal (x) or vertical (y).
    type = 'y',

    themeColours = _current_theme.colours.scroll_bar,
    
    init = function (self)
        self.needsInputCallbacks = true
        self.needsResizedCallbacks = true

        -- When dragging, this records the mouse position at the time of click.
        self.inside = false
        self.barRelative = nil
        self.clickedMousePos = nil
        self.clickedContentOffset = nil
        self.contentSize = self.initialContentSize
        self.contentOffset = self.initialContentOffset

        -- The part that moves.
        self.bar = hud_object `/common/hud/Rect` {
            parent = self,
            size = self.size - vec(2, 2),
        }

        self:update()
    end,
    
    destroy = function (self)
    end,

    -- Set the scrollbar to a specific position (content offset).
    setOffset = function(self, offset)
        self.contentOffset = offset
        self:update()
    end,

    -- Move the scrollbar by the given amount.
    scrollBy = function(self, change)
        self.contentOffset = self.contentOffset + change
        self:update()
    end,

    -- Updates the colour of the bar and background according to mouse position / drag status.
    updateColour = function(self)

        if self.inside then
            self.colour = self.themeColours.backgroundHover
            self.bar.colour = self.themeColours.barHover
            if math.abs(self.barRelative) <= 1 then
                self.bar.colour = self.themeColours.barHoverBar
            end
        else
            self.colour = self.themeColours.background
            self.bar.colour = self.themeColours.bar
        end

        if self.clickedMousePos ~= nil then
            -- dragging
            self.bar.colour = self.themeColours.pressed
        end
    end,

    -- Updates the size and position of the bar so that it represents the window as a proportion of
    -- the content.  The bar is inactive if window_size >= contentSize.  Otherwise, the bar
    -- represents the window as it moves up and down relative to the content.  content_offset is the
    -- amount of scroll, i.e. it must be between 0 and (content - window_size).  It is ignored if
    -- window_size >= contentSize.
    update = function (self)
        local t = self.type
        local window_size = self.size[t]

        if window_size == 0 or window_size >= self.contentSize then
            self.bar.position = vec(0, 0)
            self.bar.size = self.size - vec(2, 2)
            self.contentOffset = 0
            self:scrollCallback(self.contentOffset)
            self:updateColour()
            return
        end

        -- Otherwise we've already returned.
        assert(self.contentSize > 0)

        -- Correct under-scroll.
        if self.contentOffset < 0 then
            self.contentOffset = 0
        end

        -- Correct over-scroll.  This can happen if the content or window size changes when we're
        -- scrolled to the bottom.
        if self.contentOffset > self.contentSize - window_size then
            self.contentOffset = self.contentSize - window_size
        end

        -- In pixels.
        local bar_size = window_size / self.contentSize * window_size

        -- Otherwise we've already returned.
        assert(bar_size < window_size)

        local bar_offset = self.contentOffset / self.contentSize * window_size 
        local bar_pos = bar_offset + bar_size / 2 - window_size / 2

        if self.type == 'x' then
            self.bar.size = vec(bar_size, self.size.y) - vec(2, 2)
            self.bar.position = vec(bar_pos, 0)
        else
            self.bar.size = vec(self.size.x, bar_size) - vec(2, 2)
            self.bar.position = vec(0, -bar_pos)
        end

        self:scrollCallback(self.contentOffset)
        self:updateColour()
    end,

    resizedCallback = function (self)
        self:update()
    end,

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        local t = self.type
        self.inside = inside
        self.mouseLocalPos = local_pos
        if inside then
            -- If between -1 and 1 then inside the bar.
            self.barRelative = (local_pos[t] - self.bar.position[t]) / (self.bar.size[t] / 2)
        else
            self.barRelative = nil
        end

        if self.clickedMousePos == nil then
            -- Not dragging.
            self:updateColour()
            return
        end

        local bar_change = self.mouseLocalPos[t] - self.clickedMousePos[t]

        local content_change = bar_change / self.size[t] * self.contentSize

        if t == 'x' then
            self.contentOffset = self.clickedContentOffset + content_change
        else
            self.contentOffset = self.clickedContentOffset - content_change
        end
        self:update()
    end,

    scrollCallback = function (self, new_offset)
    end,
    
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            local t = self.type
            if self.barRelative < -1 then
                if t == 'x' then
                    self.contentOffset = self.contentOffset - self.size.x
                else
                    self.contentOffset = self.contentOffset + self.size.y
                end
                self:update()
            elseif self.barRelative > 1 then
                if t == 'x' then
                    self.contentOffset = self.contentOffset + self.size.x
                else
                    self.contentOffset = self.contentOffset - self.size.y
                end
                self:update()
            else
                -- Clicked in the bar, start dragging.
                self.clickedMousePos = self.mouseLocalPos
                self.clickedContentOffset = self.contentOffset
            end
        elseif ev == "-left" then
            -- End dragging.
            -- If we weren't dragging, then these are no-ops.
            self.clickedMousePos = nil
            self.clickedContentOffset = nil
        end
        self:updateColour()
    end,
}


hud_class `ScrollArea` {
    size = vec(200, 100),
    scrollBarWidth = 12,

    colour = _current_theme.colours.file_explorer.background,
    
    -- Whether or not to allow scrolling.  At least one of these must be true.
    scrollX = true,
    scrollY = true,

    -- Override this to specify the content object.
    content = nil,

    -- When the content is too small to require scrolling, show the bars anyway.
    alwaysShowBars = true,
    
    init = function (self)
        assert(self.scrollX or self.scrollY)

        self.needsInputCallbacks = true
        self.needsResizedCallbacks = true

        self.content.parent = self
        self.content.zOrder = 1

        -- Number of pixels the content is scrolled by (left and up).
        self.offset = vec(0, 0)
        
        self.barX = hud_object `ScrollBar` {
            parent = self,
            type = "x",
            zOrder = 3,
            size = vec(self.size.x, self.scrollBarWidth),
            scrollCallback = function(scroll_self, new_offset)
                self:updateOffset(vec(new_offset, self.offset.y))
            end,
        }
        self.barY = hud_object `ScrollBar` {
            parent = self,
            type = "y",
            zOrder = 3,
            size = vec(self.scrollBarWidth, self.size.y),
            scrollCallback = function(scroll_self, new_offset)
                self:updateOffset(vec(self.offset.x, new_offset))
            end,
        }

        self:update()
    end,

    -- Called when our size is updated externally.
    resizedCallback = function (self)
        self:update()
    end,

    -- Called when our size, content size, or any of our settings are changed.
    update = function (self)
        local sz = self.size

        local csz = self.content.size

        local using_x, using_y = false, false
        if self.alwaysShowBars then
            using_x = self.scrollX
            using_y = self.scrollY
        else
            if self.scrollX and csz.x > sz.x then
                using_x = true
            end 
            if self.scrollY and csz.y > sz.y then
                using_y = true
            end 
            if self.scrollX and using_y and csz.x > sz.x - self.scrollBarWidth then
                -- Activation of y scrollbar makes less width available.
                using_x = true
            end
            if self.scrollY and using_x and csz.y > sz.y - self.scrollBarWidth then
                -- Activation of x scrollbar makes less height available.
                using_y = true
            end
        end
        local window_width, window_height = sz.x, sz.y
        local x_bar_offset_x, y_bar_offset_y = 0, 0
        if using_x then
            window_height = window_height - self.scrollBarWidth
            y_bar_offset_y = self.scrollBarWidth / 2
        end
        if using_y then
            window_width = window_width - self.scrollBarWidth
            x_bar_offset_x = -self.scrollBarWidth / 2
        end
        self.windowSize = vec(window_width, window_height)

        self.barX.enabled = using_x
        self.barX.size = vec(window_width, self.scrollBarWidth)
        self.barX.position = vec(x_bar_offset_x, -window_height / 2)
        self.barX.contentSize = csz.x

        self.barY.enabled = using_y
        self.barY.size = vec(self.scrollBarWidth, window_height)
        self.barY.position = vec(window_width / 2, y_bar_offset_y)
        self.barY.contentSize = csz.y

        self.barX:update()  -- Updates for new size as well as contentSize.
        self.barY:update()  -- Updates for new size as well as contentSize.
        
    end,

    updateOffset = function (self, new_offset)
        self.offset = new_offset
        self.content.position = -new_offset + (self.content.size - self.size) / 2 
        -- Flip vertical dimension, since fully scrolled up means the content is at its lowest
        -- point.
        self.content.position = self.content.position * vec(1, -1)
        self:scrollCallback(self.offset)
    end,

    setOffset = function (self, new_offset)
        self.barX:setOffset(new_offset.x)
        self.barY:setOffset(new_offset.y)
    end,
    
    mouseMoveCallback = function (self, local_pos, screen_pos, inside, inside_children)
        -- Do nothing.
        self.inside = inside_children
    end,

    buttonCallback = function (self, ev)
        if ev == "+up" then
            if self.inside then
                self.barY:scrollBy(-30)
            end
        elseif ev == "+down" then
            if self.inside then
                self.barY:scrollBy(30)
            end
        end
    end,

    scrollCallback = function (self)
    end,
}
