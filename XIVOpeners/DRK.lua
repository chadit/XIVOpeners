xivopeners_drk = {}

xivopeners_drk.debug = false

xivopeners_drk.supportedLevel = 80
xivopeners_drk.openerAbilities = {
    Unmend = ActionList:Get(1, 3624),
    HardSlash = ActionList:Get(1, 3617),
    SyphonStrike = ActionList:Get(1, 3623),
    Souleater = ActionList:Get(1, 3632),
    EdgeofShadow = ActionList:Get(1, 16470),
    Plunge = ActionList:Get(1, 3640),
    BloodSpiller = ActionList:Get(1, 7392),
    AbyssalDrain = ActionList:Get(1, 3641),
    CarveandSpit = ActionList:Get(1, 3643),
    LivingShadow = ActionList:Get(1, 16472),
    SaltedEarth = ActionList:Get(1, 3639),
    TheBlackestNight = ActionList:Get(1, 7393),
    BloodWeapon = ActionList:Get(1, 3625),
    Delirium = ActionList:Get(1, 7390),
    -- Potion = 
}

xivopeners_drk.openerInfo = {
    listOpeners = {"Standard", "HighPing"},
    currentOpenerIndex = 1,
}

xivopeners_drk.openers = {
    standard = {
        xivopeners_drk.openerAbilities.BloodWeapon,
        xivopeners_drk.openerAbilities.HardSlash,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.SyphonStrike,
        -- xivopeners_drk.openerAbilities.Potion,
        xivopeners_drk.openerAbilities.Souleater,
        xivopeners_drk.openerAbilities.LivingShadow,
        xivopeners_drk.openerAbilities.HardSlash,
        xivopeners_drk.openerAbilities.SaltedEarth,
        xivopeners_drk.openerAbilities.Plunge,
        xivopeners_drk.openerAbilities.SyphonStrike,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.Delirium,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.CarveandSpit,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.AbyssalDrain,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.Plunge,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.Souleater
    },

    highPing = {
        xivopeners_drk.openerAbilities.BloodWeapon,
        xivopeners_drk.openerAbilities.HardSlash,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.SyphonStrike,
        -- xivopeners_drk.openerAbilities.Potion,
        xivopeners_drk.openerAbilities.Souleater,
        xivopeners_drk.openerAbilities.LivingShadow,
        xivopeners_drk.openerAbilities.HardSlash,
        xivopeners_drk.openerAbilities.SaltedEarth,
        xivopeners_drk.openerAbilities.Plunge,
        xivopeners_drk.openerAbilities.SyphonStrike,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.Delirium,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.CarveandSpit,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.AbyssalDrain,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.EdgeofShadow,
        xivopeners_drk.openerAbilities.Plunge,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.BloodSpiller,
        xivopeners_drk.openerAbilities.Souleater
    },
}

xivopeners_drk.abilityQueue = {}
xivopeners_drk.lastCastFromQueue = nil -- might need this for some more complex openers with conditions
xivopeners_drk.openerStarted = false
xivopeners_drk.lastcastid = 0
xivopeners_drk.lastcastid2 = 0

function xivopeners_drk.getOpener()
    if (xivopeners_drk.openerInfo.currentOpenerIndex == 1) then
        return xivopeners_drk.openers.standard
    else
        return xivopeners_drk.openers.highPing
    end
end

function xivopeners_drk.checkOpenerIds()
    for key, action in pairs(xivopeners_drk.getOpener()) do
        if (action == nil) then
            xivopeners.log("WARNING: Action at index " .. tostring(key) .. " was nil! The id is likely incorrect.")
        end
    end
end

function xivopeners_drk.openerAvailable()
    -- check cooldowns
    for _, action in pairs(xivopeners_drk.getOpener()) do
        if (action.cd >= 1.5) then return false end
    end
    return true
end

function xivopeners_drk.queueOpener()
    -- the only time this gets called is when the main script is toggled, so we can do more than just queue the opener
    -- empty queue first
    xivopeners_drk.abilityQueue = {}
    for _, action in pairs(xivopeners_drk.getOpener()) do
        xivopeners_drk.enqueue(action)
    end
    --    xivopeners.log("queue:")
    --    for _, v in pairs(xivopeners_drk.abilityQueue) do
    --        xivopeners.log(v.name)
    --    end
    xivopeners_drk.lastCastFromQueue = nil
    xivopeners_drk.openerStarted = false
end

function xivopeners_drk.updateLastCast()
--    xivopeners.log(tostring(xivopeners_drk.lastcastid) .. ", " .. tostring(xivopeners_drk.lastcastid2) .. ", " .. tostring(Player.castinginfo.lastcastid))
    if (xivopeners_drk.lastcastid == -1) then
        -- compare the real castid and see if it changed, if it did, update from -1
        if (xivopeners_drk.lastcastid2 ~= Player.castinginfo.castingid) then
            xivopeners.log("cast changed")
            xivopeners_drk.lastcastid = Player.castinginfo.castingid
            xivopeners_drk.lastcastid2 = Player.castinginfo.castingid
        end
    elseif (xivopeners_drk.lastcastid ~= Player.castinginfo.castingid) then
        xivopeners_drk.lastcastid = Player.castinginfo.castingid
        xivopeners_drk.lastcastid2 = Player.castinginfo.castingid
    end
end

function xivopeners_drk.drawCall(event, tickcount)
    if (xivopeners_drk.debug) then
        GUI:Text("lastcastid")
        GUI:NextColumn()
        GUI:InputText("##xivopeners_drk_lastcastid_display", tostring(xivopeners_drk.lastcastid))

        GUI:NextColumn()
        GUI:Text("lastcastid2")
        GUI:NextColumn()
        GUI:InputText("##xivopeners_drk_lastcastid2_display", tostring(xivopeners_drk.lastcastid2))

        GUI:NextColumn()
        GUI:Text("lastcastid_o")
        GUI:NextColumn()
        GUI:InputText("##xivopeners_drk_lastcastid_original_display", tostring(Player.castinginfo.lastcastid))

        GUI:NextColumn()
        GUI:Text("castingid")
        GUI:NextColumn()
        GUI:InputText("##xivopeners_drk_castingid", tostring(Player.castinginfo.castingid))

        if (xivopeners_drk.abilityQueue[1]) then
            GUI:NextColumn()
            GUI:Text("queue[1]")
            GUI:NextColumn()
            GUI:InputText("##xivopeners_drk_queue[1]", xivopeners_drk.abilityQueue[1].name)
        end

        if (xivopeners_drk.lastCastFromQueue) then
            GUI:NextColumn()
            GUI:Text("lastCastFromQueue")
            GUI:NextColumn()
            GUI:InputText("##xivopeners_drk_lastcastfromqueue", xivopeners_drk.lastCastFromQueue.name)
        end
    end
end

function xivopeners_drk.main(event, tickcount)
    if (Player.level >= xivopeners_drk.supportedLevel) then
        local target = Player:GetTarget()
        if (not target) then return end

        if (not xivopeners_drk.openerAvailable() and not xivopeners_drk.openerStarted) then return end -- don't start opener if it's not available, if it's already started then yolo

        if (xivopeners_drk.openerStarted and next(xivopeners_drk.abilityQueue) == nil) then
            -- opener is finished, pass control to ACR
            xivopeners.log("Finished openers, handing control to ACR")
            xivopeners_drk.openerStarted = false
            if (xivopeners.running) then xivopeners.ToggleRun() end
            if (not FFXIV_Common_BotRunning) then
                ml_global_information.ToggleRun()
            end
            return
        end

        if (ActionList:IsCasting()) then return end

        xivopeners_drk.updateLastCast()

        if (not xivopeners_drk.openerStarted) then
            -- technically, even if you use an ability from prepull, it should still work, since the next time this loop runs it'll jump to the elseif
            xivopeners.log("Starting opener")
            xivopeners_drk.openerStarted = true
            xivopeners_drk.useNextAction(target)
        elseif (xivopeners_drk.lastCastFromQueue and xivopeners_drk.lastcastid == xivopeners_drk.lastCastFromQueue.id) then
            xivopeners_drk.lastcastid = -1
            if (xivopeners_drk.lastCastFromQueue) then
                xivopeners_drk.dequeue()
            end
            xivopeners_drk.useNextAction(target)
        else
            xivopeners_drk.useNextAction(target)
        end

    end
end

function xivopeners_drk.enqueueNext(action)
    table.insert(xivopeners_drk.abilityQueue, 1, action)
end

function xivopeners_drk.enqueue(action)
    -- implementation of the queue can be changed later
    table.insert(xivopeners_drk.abilityQueue, action)
end

function xivopeners_drk.dequeue()
    xivopeners.log("Dequeing " .. xivopeners_drk.abilityQueue[1].name)
    table.remove(xivopeners_drk.abilityQueue, 1)
end

function xivopeners_drk.useNextAction(target)
    -- do the actual opener
    -- the current implementation uses a queue system
    if (target and target.attackable and xivopeners_drk.abilityQueue[1]) then
        xivopeners_drk.abilityQueue[1]:Cast(target.id)
            xivopeners_drk.lastCastFromQueue = xivopeners_drk.abilityQueue[1]
    end
end