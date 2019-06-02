local Item = require("itemClass")

local Product = {}
setmetatable(Product, {__index = Item})
local ProductList = {}

function Product:getLimit()
    return self.limit
end

function Product:setLimit(limit)
    self.limit = limit
    self.changed = true
end

function Product:getList()
    return ProductList
end

function Product:new(name, amount, limit, item)
    local o = {
        name = name,
        amount = amount,
        limit = limit,
        changed = true,
        precursor = item or nil
    }
    setmetatable(o,{__index = Product})
    table.insert(ProductList, o)
    return o

end

return Product