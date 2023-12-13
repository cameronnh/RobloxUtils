-- ClientTouched
-- poolcreep
-- November 10, 2023

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ClientTouched = {}
ClientTouched.__index = ClientTouched

--[[
    Returns: ClientTouched
    Description: Constructor for ClientTouched.
    Paremeters
        - item: BasePart | Model,
        - callback: () -> () (Calls when the client has touched item passed.)
        - debounce: number? (Optional debounce for callbacks.)
]]

function ClientTouched.new(item: BasePart | Model, callback: () -> (), debounce: number?): {}
    local self = setmetatable({
        connections = {},
        callback = callback,
        debounce = debounce,
        timeNeeded = 0
    }, ClientTouched)

    if (not item:IsA("BasePart")) and (not item:IsA("Model")) then
        warn("ClientTouched can only be used for BaseParts and Models")
        warn(debug.traceback())

        self:Destroy()
        return
    end

    local destroyConnection: RBXScriptConnection = item.Destroying:Connect(function(): ()
        self:Destroy()
    end)

    table.insert(self.connections, destroyConnection)

    if item:IsA("BasePart") then
        self:_getTouched(item)
        return self
    end

    for _: number, part: BasePart? in item:GetDescendants() do
        if not part:IsA("BasePart") then
            continue
        end

        self:_getTouched(part)
    end

    return self
end

--[[
    Returns: ()
    Description: Cleans touch connections and destroys.
]]

function ClientTouched:Destroy(): ()
    if self.connections then
        for _: number, connection: RBXScriptConnection in self.connections do
            connection:Disconnect()
            connection = nil
        end

        table.clear(self.connections)
    end

    setmetatable(self, nil)
end

function ClientTouched:_getTouched(part: BasePart): ()
    if part.CanTouch == false then
        return
    end

    local newTouch: RBXScriptConnection = part.Touched:Connect(function(otherPart: BasePart): ()
        local character: Model = LocalPlayer.Character

        if not character then
            return
        end

        if not otherPart:IsDescendantOf(character) then
            return
        end

        if self.debounce then
            if os.clock() < self.timeNeeded then
                return
            end

            self.timeNeeded = os.clock() + self.debounce
        end

        self.callback()
    end)

    table.insert(self.connections, newTouch)
end

return ClientTouched