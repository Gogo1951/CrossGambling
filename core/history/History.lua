local CG = CrossGambling

CG.History = {}
local History = CG.History

local function getLog(self)
    self.db.global.auditLog = self.db.global.auditLog or {}
    return self.db.global.auditLog
end

function History:LogDebt(loserName, winnerName, amount)
    local log = getLog(CG)
    table.insert(log, {
        timestamp   = time(),
        action      = "debt",
        loser       = loserName,
        winner      = winnerName,
        amount      = amount,
    })
end

function History:LogJoinStats(mainname, altname, statsAdded, deathrollStatsAdded)
    local log = getLog(CG)
    table.insert(log, {
        action                = "joinStats",
        mainname              = mainname,
        altname               = altname,
        statsAdded            = statsAdded,
        deathrollStatsAdded   = deathrollStatsAdded,
        timestamp             = time(),
    })
end

function History:LogUnjoinStats(mainname, altname, pointsRemoved, deathrollStatsRemoved)
    local log = getLog(CG)
    table.insert(log, {
        action                  = "unjoinStats",
        mainname                = mainname,
        altname                 = altname,
        pointsRemoved           = pointsRemoved,
        deathrollStatsRemoved   = deathrollStatsRemoved,
        timestamp               = time(),
    })
end

function History:LogUpdateStat(player, oldAmount, addedAmount, newAmount)
    local log = getLog(CG)
    table.insert(log, {
        action      = "updateStat",
        player      = player,
        oldAmount   = oldAmount,
        addedAmount = addedAmount,
        newAmount   = newAmount,
        timestamp   = time(),
    })
end

function CG:auditMerges()
    local log = getLog(self)
    if #log == 0 then
        self:Print("No audit log entries found.")
        return
    end

    self:Print("-- Audit Log --")
    for i, entry in ipairs(log) do
        if entry.action == "updateStat" then
            self:Print(string.format(
                "%d. [%s] Updated stats for %s: old=%d, added=%d, new=%d",
                i, entry.timestamp, entry.player,
                entry.oldAmount, entry.addedAmount, entry.newAmount
            ))
        elseif entry.action == "joinStats" then
            self:Print(string.format(
                "%d. [%s] Joined alt '%s' to main '%s' with %d stats and %d deathroll stats",
                i, entry.timestamp, entry.altname, entry.mainname,
                entry.statsAdded or 0, entry.deathrollStatsAdded or 0
            ))
        elseif entry.action == "unjoinStats" then
            self:Print(string.format(
                "%d. [%s] Unjoined alt '%s' from main '%s', points subtracted: %d, deathroll: %d",
                i, entry.timestamp, entry.altname, entry.mainname,
                entry.pointsRemoved or 0, entry.deathrollStatsRemoved or 0
            ))
        elseif entry.action == "debt" then
            self:Print(string.format(
                "%d. [%s] %s owed %s %d gold",
                i, entry.timestamp, entry.loser, entry.winner, entry.amount
            ))
        end
    end
end

function CG:clearHistory()
    self.db.global.auditLog = {}
    self:Print("Audit log cleared.")
end

function CG:historyCount()
    local log = getLog(self)
    self:Print(string.format("Audit log has %d entries.", #log))
end
