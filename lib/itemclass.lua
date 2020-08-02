Item = {}

function Item:getName()
    return self.name
end

function Item:getAmount()
    return self.amount
end

function Item:isChanged()
    return self.changed
end

function Item:setAmount(amount)
    self.amount = amount
    self.changed = true
end

function Item:isDrawn()
    self.changed = false
end

function Item:new(name, amount)
    local o = {
        name = name,
        amount = amount,
        limit = limit,
        changed = true,
        precursor = item or nil

    }
    setmetatable(o, {__index = Item})

    return o
    
end

return Item
