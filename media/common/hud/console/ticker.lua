hud_class `Ticker` {

    offset = vec(0, 0),
    height = 400;
    border = 4;
    bufferSize = 100;
    font = `/common/fonts/misc.fixed`;
    messageTime = 8;
    alpha = 0;
    textColour = vec(.75, .75, .75);

    init = function (self)
        self.buffer = self.buffer or {}
        self.timeBuffer = self.timeBuffer or {}
        self.text = hud_text_add(self.font)
        self.text.parent = self
        self.text.shadow = self.shadow
        self.text.letterTopColour = self.textColour
        self.text.letterBottomColour = self.textColour
        self.needsFrameCallbacks = true
        self.needsParentResizedCallbacks = true
    end;

    clear = function (self)
        self.buffer = {}
        self.timeBuffer = {}
        self:redraw()
    end,

    ticker_print = function (self, str)
        table.insert(self.buffer,1,str)
        table.insert(self.timeBuffer,1,gge_seconds())
        if #self.buffer>self.bufferSize then
                table.remove(self.buffer)
                table.remove(self.timeBuffer)
        end
        self:redraw()
    end;

    destroy = function (self)
    end;

    frameCallback = function (self, elapsed)
        if console ~= nil then
            console:poll()
        end
        local count = #self.buffer
        local needs_redraw = false
        local i = 1
        while i <= count do
            local time = self.timeBuffer[i]
            if gge_seconds() - time > self.messageTime then
                needs_redraw = true
                table.remove(self.buffer,i)
                table.remove(self.timeBuffer,i)
                i = i - 1
                count = count - 1
            end
            i = i + 1
        end
        if needs_redraw then
            self:redraw()
        end
    end;

    redraw = function (self)
        self.text:clear()
        for i = #self.buffer, 1, -1 do
            self.text:append(self.buffer[i])
            self.text:append("\n")
        end
        self.text.scroll = math.max(0, self.text.bufferHeight - self.text.size.y)
    end;

    recomputeSize = function (self)
        local psize 
        if self.parent == nil then
            psize = gfx_window_size()
        else
            psize = self.parent.size
        end
        self.size = vec(psize.x - self.offset.x, self.height)
        self.position = vec((psize.x + self.offset.x)/2, psize.y - self.height/2 - self.offset.y)
        self.text.textWrap = self.size - self.border * vec(2,2)
    end,

    setOffset = function (self, offset)
        self.offset = offset
        self:recomputeSize()
    end,

    parentResizedCallback = function (self, psize)
        self:recomputeSize()
    end;    
}
