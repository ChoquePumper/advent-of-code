local GridMap; GridMap = {
    get = function(self, x,y)
        local row = self[y]
        if row then
            return row[x]
        end
        return nil
    end,
    getValuesSet = function(self)
        return self.values_set
    end,
    set = function(self, x,y, value)
        local row = self[y]
        if not row then
            row = {}
            self[y] = row
        end
        if not row[x] then self.values_set = self.values_set+1 end
        -- set value
        row[x] = value
    end,
    new = function()
        local self = {
            -- [-i ... +i] = rows
            values_set = 0, -- values that internally are not nil.
        }
        return setmetatable(self, GridMap)
    end
}
GridMap.__index = GridMap

local Cursor; Cursor = {
    move = function(self,x,y)
        assert(tonumber(x)) assert(tonumber(y))
        self.x = self.x + x
        self.y = self.y + y
    end,
    new = function(map)
        return setmetatable({
            map = map,
            x = 0, y = 0,
        }, Cursor)
    end,
}
Cursor.__index = Cursor