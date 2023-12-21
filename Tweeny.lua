local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local currentTweens: {[string]: {tween: Tween, conn: RBXScriptConnection}} = {}

local function clean(id: string)
    currentTweens[id].tween:Cancel()
    currentTweens[id].tween:Destroy()
    currentTweens[id].conn:Disconnect()

    table.clear(currentTweens[id])
    currentTweens[id] = nil
end

return function (instance: any, tweeninfo: TweenInfo, props: {any}, callback: () -> ()?)
    local id: string = instance:GetAttribute("Tweener_Id")

    if not id then
        id = HttpService:GenerateGUID()
        instance:SetAttribute("Tweener_Id", id)
    end

    if currentTweens[id] then
        clean(id)
    end

    local newTween: Tween = TweenService:Create(instance, tweeninfo, props)
    newTween:Play()

    local newConn: RBXScriptConnection
    newConn = newTween.Completed:Once(function()
        clean(id)

        if not callback then
            return
        end

        callback()
    end)

    currentTweens[id] = {tween = newTween, conn = newConn}
end
