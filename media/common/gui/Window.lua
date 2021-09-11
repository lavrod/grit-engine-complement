------------------------------------------------------------------------------
--  Window
--
--  (c) 2014-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- Handles title text and dragging of the window.
-- Needs to be its own class because we need to override mouseMoveCallback
-- which currently cannot be done at the object level...
hud_class `WindowTitleBar` {
    alpha = _current_theme.colours.window.titlebar_background_alpha,
    colour = _current_theme.colours.window.titlebar_background,
    cornered = true,
    texture = _gui_textures.window.titlebar,

    init = function(self)
        self.needsInputCallbacks = true
        -- Non-nil means we're dragging
        self.draggingPos = nil

        self.text = hud_object `/common/hud/Label` {
            size = vec(64, self.titleBarSize),
            font = `/common/fonts/Arial12`,
            alignment = 'LEFT',
            textColour = _current_theme.colours.window.titlebar_text,
            alpha = 0,
        }

        local title = self

        if self.showCloseButton ~= false then
            self.closeButton = gui.button({
                caption = "X",
                padding = vec(15, 2),
                cornered = true,
                texture = _gui_textures.window.closebtn,
                baseColour = _current_theme.colours.window.closebtn_base,
                hoverColour = _current_theme.colours.window.closebtn_hover,
                clickColour = _current_theme.colours.window.closebtn_pressed,
                captionBaseColour = vec(1, 1, 1),
                pressedCallback = function(self)
                    title:closeClicked()
                end,
            })
        end

        self.stack = hud_object `/common/hud/StackX` {
            parent = self,
            vec(2, 0),
            { content = self.text, expandX = true },
            self.closeButton,
            vec(2, 0),
        }

        self.needsResizedCallbacks = true
    end,

    resizedCallback = function(self, sz)
        self.stack.size = sz
        self.needsResizedCallbacks = false
        self.size = self.stack.size
        self.needsResizedCallbacks = true
    end,

    -- Returns the base position, offsets from which are signalled via updateWindowPosition.
    grabbedWindow = function(self)
        gge_error('Must override grabbedWindow')
        return vec(0, 0)
    end,

    updateWindowPosition = function(self, pos)
        gge_error('Must override updateWindowFunction')
    end,

    closeClicked = function(self)
        gge_error('Must override closeClicked')
    end,

    mouseMoveCallback = function(self, local_pos, screen_pos, inside)
        self.inside = inside
        if self.draggingPos ~= nil then
            self:updateWindowPosition(mouse_pos_abs - self.draggingPos)
        end
    end,

    buttonCallback = function(self, ev)
        if ev == "+left" and self.inside then
            self.draggingPos = mouse_pos_abs - self:grabbedWindow()
        elseif ev == "-left" then
            self.draggingPos = nil
        end
    end,

    setText = function(self, text)
        self.text:setValue(text)
    end,

    setFocus = function(self, v)
        if v then
            self.colour = _current_theme.colours.window.titlebar_background
            self.text.text.colour = _current_theme.colours.window.titlebar_text
        else
            self.colour = _current_theme.colours.window.titlebar_background_inactive
            self.text.text.colour = _current_theme.colours.window.titlebar_text_inactive
        end
    end,
}

-- Have content as a parameter.  Put content into contentArea.  contentArea has the border, etc, and
-- its size does not include the title bar.
-- updateChildrenSize resizes the title bar and content.
-- use label for title

hud_class `Window` {

    alpha = 0,
    contentAreaAlpha = _current_theme.colours.window.background_alpha,

    zOrder = 0,
    showCloseBtn = true,
    resizeable = true,
    title = "Window",

    minSize = vec2(150, 150),
    size = vec2(512, 400),
    titleBarSize = 24,

    init = function(self)

        self.needsInputCallbacks = true

        self.draggingPos = vec2(0, 0)
        self.originalSize = vec2(0, 0)
        self.originalPos = vec2(0, 0)

        local window = self

        self.titleBar = hud_object `WindowTitleBar` {
            showCloseButton = self.showCloseButton,
            titleBarSize = self.titleBarSize,
            updateWindowPosition = function(self, pos)
                window.position = pos
            end,
            grabbedWindow = function(self)
                window_focus_grab(window)
                return window.position
            end,
            closeClicked = function(self)
                window:closeClicked()
            end,
        }
        self:setTitle(self.title)

        self.contentArea = hud_object `/common/hud/Rect` {
            size = self.minSize - vec(0, self.titleBarSize),
            alpha = self.contentAreaAlpha,
            cornered = true,
            texture = _gui_textures.window.border,
        }

        self.stackY = hud_object `/common/hud/StackY` {
            parent = self,
            {
                content = self.titleBar,
                expandX = true,
            },
            {
                content = self.contentArea,
                expandX = true,
                expandY = true,
            },
        }

        -- Let it now expand to the given size.
        self.stackY.size = self.size

        self.needsResizedCallbacks = true
    end,

    destroy = function(self)
        -- Nothing to do.
    end,

    resizedCallback = function(self)
        self.stackY.size = self.size
        self.needsResizedCallbacks = false
        self.size = self.stackY.size
        self.needsResizedCallbacks = true
    end,

    closeClicked = function(self)
        self.enabled = false
    end,

    buttonCallback = function(self, ev)
        if ev == "+left" then
            if self.inside then
                window_focus_grab(self)
            end
            if self.resizeable then
                local mp = mouse_pos_abs
                local dpos = self.derivedPosition
                local size = self.size

                if mp.x > dpos.x + size.x/2 -15 and mp.x < dpos.x + size.x/2 and
                mp.y > dpos.y - size.y/2 and mp.y < dpos.y - size.y/2 +15 then
                    -- bottom right
                    self.right_resizer_dragging = true
                    self.draggingPos =  mp
                    self.originalSize = size
                    self.originalPos = self.position
                elseif mp.x > dpos.x - size.x/2 and mp.x < dpos.x - size.x/2+15 and
                mp.y > dpos.y - size.y/2 and mp.y < dpos.y - size.y/2 +15 then
                    -- top left
                    self.left_resizer_dragging = true
                    self.draggingPos =  mp
                    self.originalSize = size
                    self.originalPos = self.position
                end
            end
        elseif ev == "-left" then
            self.right_resizer_dragging = false
            self.left_resizer_dragging = false
            self.draggingPos = vec2(0, 0)
            self.originalSize = vec2(0, 0)
            self.originalPos = vec2(0, 0)
        end
    end,

    mouseMoveCallback = function(self, local_pos, screen_pos, inside)
        self.inside = inside

        local max_size = self.maxSize or gge_gfx_window_size()

        if self.right_resizer_dragging then
            local wsize = vec2(self.originalSize.x + (-self.draggingPos.x + mouse_pos_abs.x), self.originalSize.y - (-self.draggingPos.y + mouse_pos_abs.y))

            self.size = vec2(math.clamp(wsize.x, self.minSize.x, max_size.x), math.clamp(wsize.y, self.minSize.y, max_size.y))
            self.position = vec2(self.originalPos.x - (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))

        elseif self.left_resizer_dragging then
            local wsize = vec2(self.originalSize.x - (-self.draggingPos.x + mouse_pos_abs.x), self.originalSize.y - (-self.draggingPos.y + mouse_pos_abs.y))

            self.size = vec2(math.clamp(wsize.x, self.minSize.x, max_size.x), math.clamp(wsize.y, self.minSize.y, max_size.y))
            self.position = vec2(self.originalPos.x + (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))
        end
    end,

    setTitle = function(self, name)
        self.titleBar:setText(name)
    end,

    setFocus = function(self, v)
        self.titleBar:setFocus(v)
        self.zOrder = v and 1 or 0
    end,
}

WindowClass = gge_hud_class_get(`Window`)

_windows = {}

-- TODO: replace parameters by a single table
function gui.window(w_title, pos, res, w_size, w_min_size, w_max_size, w_bk_colour, w_bk_alpha)
    local t_window = {}

    if type(w_title) == "table" then
        t_window = hud_object `Window` (w_title)
    else
        t_window = hud_object `Window` {
            title = w_title;
            parent = hud_centre;
            position = pos;
            resizeable = res;
            size = w_size;
            min_size = w_min_size;
            colour = w_bk_colour or _current_theme.colours.window.background;
            alpha = w_bk_alpha or 1;
        }
    end
    -- t_window.enabled = false
    _windows[#_windows+1] = t_window
    return t_window
end

window_focus = window_focus
function window_focus_grab(wnd)
    if window_focus == wnd then
        return
    end
    if window_focus ~= nil and not window_focus.destroyed then
        window_focus:setFocus(false)
    end
    window_focus = wnd
    wnd:setFocus(true)
end

function window_open(wnd)
    wnd.enabled = true
    window_focus_grab(wnd)
end
