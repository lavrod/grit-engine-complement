-- (c) David Cunningham 2017, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- Update the state of an analog output controlled via a digital ternary input (+1, -1, 0).
-- This is useful for controlling things like car steering using a keyboard.  A joystick
-- can map the value directly to the analog input but for a keyboard we have to smooth out the
-- input so the cont

if DigitalControl == nil then
    DigitalControl = {
    }
end

function DigitalControl.new(range, steer_rate, unsteer_rate, wrong_way_rate)
    local self = {
        -- The controlled value can vary between [-range, range].
        range = range or 10,

        -- rate at which the controlled value returns to 0
        unsteerRate = unsteer_rate or 1,
        -- rate at which the controlled value tends towards its desired state
        steerRate = steer_rate or 2,
        -- rate at which the controlled value tends towards its desired state if it is currently on the
        -- wrong side of 0
        wrongWayRate = wrong_way_rate or 4,

        -- Initial state
        state = 0,
    }
    return make_instance(self, DigitalControl, nil, nil, "DigitalControl")
end

function DigitalControl:pump(elapsed_secs, digital_input)

    local diff = (digital_input * self.range - self.state) / elapsed_secs

    --[[
    if math.abs(diff) < 0.001 then
        self.state = digital_input
        return digital_input
    end
    ]]

    local rate
    if digital_input == 1 then
        if self.state >= 0 then
            rate = self.steerRate
        else
            rate = self.wrongWayRate
        end
    elseif digital_input == 0 then
        rate = self.unsteerRate
    else -- digital_input == -1
        if self.state <= 0 then
            rate = self.steerRate
        else
            rate = self.wrongWayRate
        end
    end

    self.state = self.state + clamp(diff, -rate, rate) * elapsed_secs
    self.state = clamp(self.state, -self.range, self.range)

    return self.state
end
