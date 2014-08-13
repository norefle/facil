--[[----------------------------------------------------------------------------
--- @file create.lua
--- @brief fácil's create command.
----------------------------------------------------------------------------]]--

local Core = require "facil.core"

local Template = require "facil.template.md"

local _M = {}

--- Creates new card
-- @param name Short descriptive name of card.
-- @retval true, string - on success, where string is the uuid of new card.
-- @retval nil, string - on error, where string contains detailed description.
function _M.create(name)
    if not name or "string" ~= type(name) then
        return nil, "Invalid argument."
    end

    local card = {}

    card.name = name
    card.id = Core.uuid.new()
    if not card.id then
        return nil, "Can't generate uuid for card."
    end

    card.time = os.time()

    local prefix, body = Core.splitId(card.id)
    local markdown, markdownErr
        = Core.createCardFile("cards", prefix, body, ".md", Template.value)
    if not markdown then
        return nil, markdownErr
    end

    --- @warning Platform (linux specific) dependent code.
    --- @todo Either replace with something more cross platform
    ---       or check OS before.
    os.execute("$EDITOR " .. markdown.name)

    local meta, metaErr
        = Core.createCardFile("meta", prefix, body, nil, Core.serializeMeta(card))
    if not meta then
        return nil, metaErr
    end

    local marker, markerErr = Core.createCardFile("boards", "backlog", card.id, nil, tostring(card.time))
    if not marker then
        return nil, markerErr
    end

    return true, card.id
end

return _M
