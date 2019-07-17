xivopeners_brd = {}

xivopeners_brd.supportedLevel = 80
xivopeners_brd.openerAbilities = {
    BurstShot = ActionList:Get(1, 16495),
    RefulgentArrow = ActionList:Get(1, 7409),
    IronJaws = ActionList:Get(1, 3560),
    Sidewinder = ActionList:Get(1, 3562),
    EmpyrealArrow = ActionList:Get(1, 3558),
    Barrage = ActionList:Get(1, 107),
    RagingStrikes = ActionList:Get(1, 101),
    Bloodletter = ActionList:Get(1, 110),
    Stormbite = ActionList:Get(1, 7407),
    CausticBite = ActionList:Get(1, 7406),
    WanderersMinuet = ActionList:Get(1, 3559),
    BattleVoice = ActionList:Get(1, 118),
    PitchPerfect = ActionList:Get(1, 7404),
    StraightShotReadyBuffID = 122,
    RagingStrikesBuffID = 125,
}

xivopeners_brd.openerInfo = {
    listOpeners = {"Recommended", "Compatibility"},
    currentOpenerIndex = 1,
}

xivopeners_brd.openers = {
    recommended = {
        xivopeners_brd.openerAbilities.RagingStrikes,
        xivopeners_brd.openerAbilities.Stormbite,
        xivopeners_brd.openerAbilities.Bloodletter,
        xivopeners_brd.openerAbilities.WanderersMinuet,
        xivopeners_brd.openerAbilities.CausticBite,
        xivopeners_brd.openerAbilities.EmpyrealArrow,
        xivopeners_brd.openerAbilities.BattleVoice, -- after this point it's either 3 burst shots, or RA procs if we get them
        xivopeners_brd.openerAbilities.BurstShot,
        xivopeners_brd.openerAbilities.BurstShot,
        xivopeners_brd.openerAbilities.BurstShot, -- The last castid will always be the same so we need it an additional time, also note that bard will need more checks due to RA procs interfering
        xivopeners_brd.openerAbilities.Barrage, -- need a check here for an RA proc, and use that instead
        xivopeners_brd.openerAbilities.RefulgentArrow,
        xivopeners_brd.openerAbilities.Sidewinder,
        xivopeners_brd.openerAbilities.BurstShot,
        xivopeners_brd.openerAbilities.Bloodletter,
        xivopeners_brd.openerAbilities.IronJaws,
        xivopeners_brd.openerAbilities.EmpyrealArrow
    },

    compatibility = {
        xivopeners_brd.openerAbilities.RagingStrikes,
        xivopeners_brd.openerAbilities.Stormbite,
        xivopeners_brd.openerAbilities.Bloodletter,
        xivopeners_brd.openerAbilities.CausticBite,
        xivopeners_brd.openerAbilities.WanderersMinuet,
        xivopeners_brd.openerAbilities.BattleVoice,
        xivopeners_brd.openerAbilities.BurstShot,
        xivopeners_brd.openerAbilities.EmpyrealArrow,
        xivopeners_brd.openerAbilities.BurstShot,
        xivopeners_brd.openerAbilities.BurstShot,
        xivopeners_brd.openerAbilities.Barrage,
        xivopeners_brd.openerAbilities.RefulgentArrow,
        xivopeners_brd.openerAbilities.Sidewinder,
        xivopeners_brd.openerAbilities.BurstShot,
        xivopeners_brd.openerAbilities.Bloodletter,
        xivopeners_brd.openerAbilities.IronJaws,
        xivopeners_brd.openerAbilities.EmpyrealArrow
    },
}

xivopeners_brd.abilityQueue = {}
xivopeners_brd.lastCastFromQueue = nil -- might need this for some more complex openers with conditions
xivopeners_brd.openerStarted = false

function xivopeners_brd.getOpener()
    if (xivopeners_brd.openerInfo.currentOpenerIndex == 1) then
        return xivopeners_brd.openers.recommended
    else
        return xivopeners_brd.openers.compatibility
    end
end

function xivopeners_brd.checkOpenerIds()
    for key, action in pairs(xivopeners_brd.getOpener()) do
        if (action == nil) then
            xivopeners.log("WARNING: Action at index " .. tostring(key) .. " was nil! The id is likely incorrect.")
        end
    end
end

function xivopeners_brd.openerAvailable()
    -- check cooldowns
    for _, action in pairs(xivopeners_brd.getOpener()) do
        if (action.cd >= 1.5) then return false end
    end
    return true
end

function xivopeners_brd.queueOpener()
    -- the only time this gets called is when the main script is toggled, so we can do more than just queue the opener
    -- empty queue first
    xivopeners_brd.abilityQueue = {}
    for _, action in pairs(xivopeners_brd.getOpener()) do
        xivopeners_brd.enqueue(action)
    end
    --    xivopeners.log("queue:")
    --    for _, v in pairs(xivopeners_brd.abilityQueue) do
    --        xivopeners.log(v.name)
    --    end
    xivopeners_brd.lastCastFromQueue = nil
    xivopeners_brd.openerStarted = false
end

function xivopeners_brd.updateActionUsed()
    -- this function is required for duplicate abilities, i would avoid using it unless absolutely neccessary
    if (xivopeners_brd.lastCastFromQueue) then
        --        xivopeners.log("Currentcast: " .. tostring(Player.castinginfo.castingid) .. ", LastCast: " .. xivopeners_brd.lastCastFromQueue.name)
        if (xivopeners_brd.lastCastFromQueue.casting and Player.castinginfo.castingid ~= xivopeners_brd.lastCastFromQueue.id) then
            xivopeners.log("Casted " .. xivopeners_brd.lastCastFromQueue.name)
            xivopeners_brd.lastCastFromQueue.casted = true
        elseif (Player.castinginfo.castingid == xivopeners_brd.lastCastFromQueue.id) then
            xivopeners.log("Currently casting " .. xivopeners_brd.lastCastFromQueue.name)
            xivopeners_brd.lastCastFromQueue.casting = true
        end
    end
end

function xivopeners_brd.processProcs(target)
    -- prepull RS
    if (xivopeners_brd.abilityQueue[1] == xivopeners_brd.openerAbilities.RagingStrikes and HasBuff(Player.id, xivopeners_brd.openerAbilities.RagingStrikesBuffID)) then
        xivopeners.log("Player already used raging strikes prepull, continue with opener")
        xivopeners_brd.dequeue()
    elseif (Player.gauge[2] >= 3 and xivopeners_brd.abilityQueue[1] ~= xivopeners_brd.openerAbilities.PitchPerfect) then
        -- don't want to dequeue here
        xivopeners.log("Using PP3 proc")
        xivopeners_brd.openerAbilities.PitchPerfect:Cast(target.id)
--    elseif (xivopeners_brd.abilityQueue[1] == xivopeners_brd.openerAbilities.BurstShot and HasBuff(Player.id, xivopeners_brd.openerAbilities.StraightShotReadyBuffID)) then
--        xivopeners.log("Using RA proc during BurstShot window")
--        xivopeners_brd.dequeue()
--        xivopeners_brd.enqueueNext(xivopeners_brd.openerAbilities.RefulgentArrow)
    end
end

function xivopeners_brd.main(event, tickcount)
    if (Player.level >= xivopeners_brd.supportedLevel) then
        local target = Player:GetTarget()
        if (not target) then return end

        if (not xivopeners_brd.openerAvailable() and not xivopeners_brd.openerStarted) then return end -- don't start opener if it's not available, if it's already started then yolo

        if (xivopeners_brd.openerStarted and next(xivopeners_brd.abilityQueue) == nil) then
            -- opener is finished, pass control to ACR
            xivopeners.log("Finished openers, handing control to ACR")
            xivopeners_brd.openerStarted = false
            if (xivopeners.running) then xivopeners.ToggleRun() end
            if (not FFXIV_Common_BotRunning) then
                ml_global_information.ToggleRun()
            end
            return
        end

        if (ActionList:IsCasting()) then return end

        xivopeners_brd.processProcs(target)
        xivopeners_brd.updateActionUsed()

        if (not xivopeners_brd.openerStarted) then
            -- technically, even if you use an ability from prepull, it should still work, since the next time this loop runs it'll jump to the elseif
            xivopeners.log("Starting opener")
            xivopeners_brd.openerStarted = true
            xivopeners_brd.useNextAction(target)
        elseif (xivopeners_brd.lastCastFromQueue == xivopeners_brd.openerAbilities.BurstShot) then
            if (xivopeners_brd.lastCastFromQueue.casted) then
                xivopeners.log("Dequeuing burst dupe")
                xivopeners_brd.dequeue()
            end
            xivopeners_brd.useNextAction(target)
        elseif (xivopeners_brd.lastCastFromQueue and Player.castinginfo.lastcastid == xivopeners_brd.lastCastFromQueue.id) then
            xivopeners.log("Dequeuing normal")
            xivopeners_brd.dequeue()
            xivopeners_brd.useNextAction(target)
        else
            xivopeners_brd.useNextAction(target)
        end

    end
end

function xivopeners_brd.enqueueNext(action)
    table.insert(xivopeners_brd.abilityQueue, 1, action)
end

function xivopeners_brd.enqueue(action)
    -- implementation of the queue can be changed later
    table.insert(xivopeners_brd.abilityQueue, action)
end

function xivopeners_brd.dequeue()
    xivopeners.log("Dequeing " .. xivopeners_brd.abilityQueue[1].name)
    xivopeners_brd.abilityQueue[1].casting = false
    xivopeners_brd.abilityQueue[1].casted = false
    if (xivopeners_brd.lastCastFromQueue) then
        xivopeners_brd.lastCastFromQueue.casting = false
        xivopeners_brd.lastCastFromQueue.casted = false
    end
    table.remove(xivopeners_brd.abilityQueue, 1)
end

function xivopeners_brd.useNextAction(target)
    -- do the actual opener
    -- the current implementation uses a queue system
    if (target and target.attackable and xivopeners_brd.abilityQueue[1]) then
        -- idk how to make it not spam console
        --xivopeners.log("Casting " .. xivopeners_brd.abilityQueue[1].name)
        xivopeners_brd.abilityQueue[1]:Cast(target.id)
        xivopeners_brd.lastCastFromQueue = xivopeners_brd.abilityQueue[1]
    end
end