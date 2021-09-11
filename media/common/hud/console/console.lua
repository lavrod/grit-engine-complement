

hud_class `Console` {

    promptPrefix = "lua> ";

    alpha = 0.9;
    border = 4;
    colour = vec(0.1, 0.1, 0.1);
    --texture = `/common/hud/CornerTextures/SquareFilledWhiteBorder.png`;
    --cornered = true;

    textColour = vec(.75, .75, .75);
    bufferSize = 10000;
    cmdBufferSize = 1000;
    font = `/common/fonts/misc.fixed`;
    messageTime = 8;

    init = function (self)
        self.buffer = self.buffer or {}

        self.pinToBottom = true


        self.text = gge_hud_text_add(self.font)
        self.text.shadow = self.shadow
        self.text.parent = self
        self.text.letterTopColour = self.textColour
        self.text.letterBottomColour = self.textColour

        self.prompt = gge_hud_text_add(self.font)
        self.prompt.shadow = self.shadow
        self.prompt.parent = self
        self.prompt.colour = self.textColour
        self.prompt.text = self.promptPrefix

        self.cursor = gge_hud_text_add(self.font)
        self.cursor.shadow = self.shadow
        self.cursor.parent = self
        self.cursor.colour = self.textColour
        self.cursor.text = "|"
        self.cursor.zOrder = 7
        self.cmdBuffer = self.cmdBuffer or {}
        self.cmdBufferPos = 0

        self.promptBefore = ""
        self.promptAfter = ""

        self.needsFrameCallbacks = true
        self.needsInputCallbacks = true
        self.needsResizedCallbacks = true

        self.lastCompletionsList = nil
        self.lastCompletionIndex = 0

    end;

    console_print = function (self, str)
        table.insert(self.buffer,1,str)
        if #self.buffer>self.bufferSize then
                table.remove(self.buffer)
        end
        self:redraw()
    end;

    clear = function (self)
        self.buffer = {}
        self:redraw()
    end;

    exec = function (self, cmd)
        self:recordCommand(cmd)
        self:execute(cmd)
    end;

    setEnabled = function (self, v)
        self.enabled = v
        ticker.enabled = not v
    end;

    setFocus = function (self, v)
    end;

    destroy = function (self)
    end;

    poll = function (self)
        local str = gge_console_poll()
        if #str > 0 then
            str = str:sub(1,-2) -- cut off \n
            self:console_print(str)
            ticker:ticker_print(str)
        end
    end;

    frameCallback = function (self, elapsed)
        -- blinking cursor
        if hud_focus ~= self then
            self.cursor.enabled = false
        else
            local state = (gge_seconds() % 0.5) / 0.5
            self.cursor.enabled = state < 0.66
        end

        self:poll()
    end;

    redraw = function (self)
        self.text:clear()
        for i = #self.buffer, 1, -1 do
            if i < #self.buffer then self.text:append("\n") end
            self.text:append(self.buffer[i])
        end
        if self.pinToBottom then
            self.text.scroll = self.text.bufferHeight - math.floor(self.text.size.y)
        end
    end;

    resizedCallback = function (self)

        local font_height = gge_gfx_font_line_height(self.font)

        self.text.textWrap = self.size - self.border * vec(2,2) - vec(0,font_height)
        self.text.position = vec(0,font_height/2)

        self.prompt.textWrap = vec(self.size.x - self.border * 2, font_height)
        self.prompt.position = vec(0, -self.size.y/2 + self.border + font_height/2)

        self:redraw()
        self:positionCursor()
    end;


    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;

    cmd = function (self)
        return self.promptBefore .. self.promptAfter
    end;

    recordCommand = function (self, cmd)
        cmd = cmd or self:cmd()
        if cmd:len() > 0 and cmd ~= self.cmdBuffer[1] then
            table.insert(self.cmdBuffer,1,cmd)
            -- chop top if too long
            if #self.cmdBuffer > self.cmdBufferSize then
                    table.remove(self.cmdBuffer,#self.cmdBuffer+1)
            end
        end
    end;

    buttonCallback = function (self, ev)

        local ev2 = (ev:sub(1,1) == '+' or ev:sub(1,1)=='=') and ev:sub(2) or nil

        if ev2 == "left" then
            if self.inside then  
                hud_focus_grab(self)
            end
        end

        if hud_focus ~= self then
            return
        end

        local reset_completions = true

        if ev2 == "Return" then
            -- scroll to bottom to see execution
            self.text.scroll = math.ceil(self.text.bufferHeight - self.text.size.y)
            self.pinToBottom = true

            self:recordCommand()
            self:execute()
            -- the above can execute arbitrary code, which can involve destroying the console... test for that!
            -- note, this is especially common with things like gge_include "common/init.lua"
            if self.destroyed then return end

            self.cmdBufferPos = 0
            self.promptBefore = ""
            self.promptAfter = ""
        elseif ev2 == "BackSpace" then
            self.promptBefore = self.promptBefore:sub(1,self.promptBefore:len()-1)
        elseif ev2 == "Delete" then
            self.promptAfter = self.promptAfter:sub(2)
        elseif ev2 == "Left" then
            if self.promptBefore:len() > 0 then
                self.promptAfter = self.promptBefore:sub(-1)..self.promptAfter
                self.promptBefore = self.promptBefore:sub(1,-2)
            end
        elseif ev2 == "Right" then
            if self.promptAfter:len() > 0 then
                self.promptBefore = self.promptBefore .. self.promptAfter:sub(1,1)
                self.promptAfter = self.promptAfter:sub(2)
            end
        elseif gge_input_filter_pressed("Ctrl") and ev2 == "d" then
            self.promptAfter = self.promptAfter:sub(2)
        elseif gge_input_filter_pressed("Ctrl") and ev2 == "a" then
            self.promptBefore, self.promptAfter = "", self.promptBefore..self.promptAfter
        elseif gge_input_filter_pressed("Ctrl") and ev2 == "e" then
            self.promptBefore, self.promptAfter = self.promptBefore..self.promptAfter, ""
        elseif gge_input_filter_pressed("Ctrl") and ev2 == "w" then
            self.promptBefore = self.promptBefore:gsub(" [^ ]* ?$"," ")
        elseif gge_input_filter_pressed("Ctrl") and ev2 == "k" then
            gge_set_clipboard(self.promptAfter)
            self.promptAfter = ""
        elseif gge_input_filter_pressed("Ctrl") and (ev2 == "y" or ev2 == "v") then
            local str = gge_get_clipboard()
            self.promptBefore = self.promptBefore .. str
        elseif ev:sub(1,1) == ":" then
            self.cmdBufferPos = 0
            self.promptBefore = self.promptBefore .. ev:sub(2)
        elseif ev2=="Up" then
            if self.cmdBufferPos == 0 and self:cmd():len() > 0 then
                self:recordCommand()
                self.cmdBufferPos = 1
            end
            if self.cmdBuffer[self.cmdBufferPos+1] ~= nil then
                self.cmdBufferPos = self.cmdBufferPos + 1
            end
            self.promptBefore = self.cmdBuffer[self.cmdBufferPos] or ""
            self.promptAfter = ""
        elseif ev2=="Down" then
            if self.cmdBufferPos == 0 then
                self:recordCommand()
                self.promptBefore = ""
                self.promptAfter = ""
            elseif self.cmdBufferPos > 0 then
                self.cmdBufferPos = self.cmdBufferPos - 1
                self.promptBefore = self.cmdBuffer[self.cmdBufferPos] or ""
                self.promptAfter = ""
            end
        elseif ev2=="Home" then
            self.text.scroll = math.floor(-self.size.y/2)
            self.pinToBottom = false
        elseif ev2=="End" then
            self.text.scroll = math.ceil(self.text.bufferHeight - self.text.size.y)
            self.pinToBottom = true
        elseif ev2=="PageUp" then
            self.text.scroll = math.floor(math.max(self.text.scroll - self.size.y/2, -self.size.y/2))
            self.pinToBottom = false
        elseif ev2=="up" then
            self.text.scroll = math.floor(math.max(self.text.scroll - 8, -8))
            self.pinToBottom = false
        elseif ev2=="down" then
            self.text.scroll = self.text.scroll + 8
            if self.text.scroll > self.text.bufferHeight - math.floor(self.text.size.y) then
                self.text.scroll = math.ceil(self.text.bufferHeight - self.text.size.y)
                self.pinToBottom = true
            end
        elseif ev2=="PageDown" then
            self.text.scroll = self.text.scroll + math.floor(self.size.y/2)
            if self.text.scroll > self.text.bufferHeight - math.floor(self.text.size.y) then
                self.text.scroll = math.ceil(self.text.bufferHeight - self.text.size.y)
                self.pinToBottom = true
            end
        elseif gge_input_filter_pressed("Ctrl") and ev2 == "Space" then
            self:autocomplete()
            reset_completions = false
        end
        self.prompt.text = self.promptPrefix..self.promptBefore..self.promptAfter
        self:positionCursor()
        
        if reset_completions and ev:sub(1,1) == ':' then
            self.lastCompletionList = nil
            self.lastCompletionIndex = 0
        end
    end;

    positionCursor = function (self)
        local tw = gge_gfx_font_text_width(self.font, self.promptPrefix .. self.promptBefore)
        self.cursor.position = vec(-self.size.x/2 + self.border + tw, self.prompt.position.y)
    end;

    execute = function (self, str)
        str = str or self:cmd()

        gge_print(self.promptPrefix .. str)
        self:poll()

        -- Parses and compile the string.
        -- Note that using '@' as the chunk name means an empty filename, i.e. '@' indicates a file,
        -- and the lack of anything afterwards makes it the empty filename.
        -- This causes gge_current_dir() to think it's a lua file in the root directory, which is what
        -- we want for strings typed on the console!
        local f, err
        f = loadstring("return "..str, '@')
        if f == nil then
            f, err = loadstring(str, '@')
        end

        if f == nil then
            if err:sub(1,4) == ":1: " then
                err = err:sub(5)
            end
            gge_print(BOLD..YELLOW.."Syntax error: "..err)
            return
        end
        -- to execute, use coroutine to remove irrelevent lines from stacktrace
        local coro = coroutine.create(function ()
            (function (status, ...)
                -- use this closure to collect return values from xpcall.
                -- if call not successful, do nothing as the error handler would have fixed our woes.
                if status then
                    -- call was successful
                    if select("#",...) > 0 then
                        gge_print(...)
                    end
                end
            end)(xpcall(f,--[[gge_error_handler]]function(msg)
                local level = 0
                if type(msg)=="table" then
                    level, msg = unpack(msg)
                end
                if msg:sub(1,4) == ":1: " then
                    msg = msg:sub(5)
                end
                gge_print(BOLD..RED..msg)

                level = level + 1 -- error handler, i.e. this code here
                local tb = debug.traceback(nil, level)
                local frames = string.split(tb, '\n')
                -- strip coroutine.create closure param
                frames[#frames] = nil
                -- strip xpcall
                frames[#frames] = nil
                -- strip string entered on console line
                frames[#frames] = nil
                -- skip first line, it says "stack trace:"
                table.remove(frames, 1)
                -- skip next line, it typically provides no more information than the error message, and the line number
                -- points to this console function
                table.remove(frames, 1)
                for _, frame in ipairs(frames) do
                    gge_print(RED..frame)
                end
            end))
        end)
        coroutine.resume(coro)
    end;

    autocomplete = function (self)
        --incremental upon last result
        if self.lastCompletionList then
            local i = self.lastCompletionIndex + 1
            if i > #self.lastCompletionList then --loop around
                i = 1
            end
            self.promptBefore = self.promptBefore:gsub(self.lastCompletionList[self.lastCompletionIndex].."$", self.lastCompletionList[i])
            self.lastCompletionIndex = i
            return
        end

        local splits = {}
        for m in self.promptBefore:gmatch("[^\\.:]+")  do
            splits[#splits+1] = m
        end
        if self.promptBefore:find("[\\.:]$") then
            splits[#splits+1] = ""
        end
        
        local parent = _G

        for i,v in ipairs(splits) do
            if i == #splits then
                local completionList = {}
                for k in pairs(parent) do
                    if v == "" or k:find(v, 1, true) == 1 then
                        completionList[#completionList+1] = k
                    end
                end

                if #completionList == 0 then
                    return
                end

                table.sort(completionList)

                self.lastCompletionList = completionList

                for ii, completion in ipairs(completionList) do
                    if v == "" then
                        --first suggestion if the last character was . or :
                        self.promptBefore = self.promptBefore .. completion
                        self.lastCompletionIndex = ii
                        return
                    end
                    if completion ~= v then
                        self.promptBefore = self.promptBefore:gsub(v.."$", completion)
                        self.lastCompletionIndex = ii
                        return
                    end
                end
            end

            local c = rawget(parent, v)
            if (not c) or (type(c) ~= "table") then
                return
            end
            parent = c
        end
    end;
}
