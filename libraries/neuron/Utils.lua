local utils = {}

function utils.diffTable(t1, t2)
    -- Verifica se ambos os parâmetros são tabelas
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return true  -- Um deles não é uma tabela, logo, são diferentes
    end

    -- Verifica se têm tamanhos diferentes
    if #t1 ~= #t2 then
        return true  -- Se os tamanhos são diferentes, as tabelas são diferentes
    end

    -- Percorre todos os elementos da primeira tabela
    for k, v in pairs(t1) do
        if type(v) == "table" and type(t2[k]) == "table" then
            -- Se o valor é uma tabela, faz a comparação recursiva
            if diffTable(v, t2[k]) then
                return true  -- Encontrou diferença em uma sub-tabela
            end
        elseif v ~= t2[k] then
            return true  -- Encontrou um valor diferente
        end
    end

    -- Percorre todos os elementos da segunda tabela para detectar chaves extras
    for k, v in pairs(t2) do
        if t1[k] == nil then
            return true  -- A segunda tabela tem uma chave que a primeira não tem
        end
    end

    return false  -- As tabelas são iguais
end

function utils.getiter(x)
    if type(x) == "table" and x[1] ~= nil then
        return ipairs
    elseif type(x) == "table" then
        return pairs
    end
    error("expected table", 3)
end

function utils.clear(t)
    local iter = utils.getiter(t)
    for k in iter(t) do
        t[k] = nil
    end
    return t
end

local serialize

local serialize_map = {
    [ "boolean" ] = tostring,
    [ "nil" ] = tostring,
    [ "string" ] = function(v) return string.format("%q", v) end,
    [ "number" ] = function(v)
        if      v ~=  v     then return  "0/0"      --  nan
        elseif  v ==  1 / 0 then return  "1/0"      --  inf
        elseif  v == -1 / 0 then return "-1/0" end  -- -inf
        return tostring(v)
    end,
    [ "table" ] = function(t, stk)
        stk = stk or {}
        if stk[t] then error("circular reference") end
        local rtn = {}
        stk[t] = true
        for k, v in pairs(t) do
            rtn[#rtn + 1] = "[" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
        end
        stk[t] = nil
        return "{" .. table.concat(rtn, ",") .. "}"
    end
}

setmetatable(serialize_map, {
    __index = function(_, k) error("unsupported serialize type: " .. k) end
})

serialize = function(x, stk)
    return serialize_map[type(x)](x, stk)
end

function utils.serialize(x)
    return serialize(x)
end

return utils