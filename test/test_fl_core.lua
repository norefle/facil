--[[----------------------------------------------------------------------------
--- @file test_fl_core.lua
--- @brief Unit test for fl core module configuration.
----------------------------------------------------------------------------]]--

describe("fácil", function()
    local fl -- Main module of fácil.
    local core -- -- Core module of fácil.
    local lfs -- LuaFileSystem

    before_each(function()
        -- Load and configure fácil module.
        fl = require "facil"
        core = require "facil.core"
        lfs = require "lfs"
    end)

    after_each(function()
        -- Unload fácil's modules.
        fl = nil
        core = nil
        package.loaded["facil"] = nil
        package.loaded["facil.core"] = nil
        package.loaded["facil.create"] = nil
        package.loaded["facil.init"] = nil
        package.loaded["facil.status"] = nil

        lsf = nil
    end)

    it("has VERSION", function()
        assert.has(fl.VERSION)
        assert.is.equal(fl.VERSION, "0.0.1")
    end)

    it("has NAME", function()
        assert.has(fl.NAME)
        assert.is.equal(fl.NAME, "fácil")
    end)

    it("core module returns current directory contained .fl", function()
        local currentdir = lfs.currentdir
        local dir = lfs.dir
        local attributes = lfs.attributes

        lfs.currentdir = function() return "/xyz/current" end
        lfs.attributes = function() return "directory" end
        lfs.dir = function()
            local iterator = function(ignore, previous)
                if "init" == previous then
                    return ".git"
                elseif ".git" == previous then
                    return ".fl"
                else
                    return nil
                end
            end

            return iterator, nil, "init"
        end

        assert.is.equal("/xyz/current/.fl", core.getRootPath())

        lfs.attributes = attributes
        lfs.dir = dir
        lfs.current = currentdir
    end)

    it("core module returns parent directory contained .fl", function()
        local currentdir = lfs.currentdir
        local dir = lfs.dir
        local attributes = lfs.attributes

        lfs.currentdir = function() return "/xyz/parent/current" end
        lfs.attributes = function() return "directory" end
        lfs.dir = function(path)
            local iterator = function(ignore, previous)
                if "init" == previous then
                    return ".git"
                elseif ".git" == previous then
                    if "/xyz/parent" == path then
                        return ".fl"
                    else
                        return "not.fl"
                    end
                else
                    return nil
                end
            end

            return iterator, nil, "init"
        end

        assert.is.equal("/xyz/parent/.fl", core.getRootPath())

        lfs.attributes = attributes
        lfs.dir = dir
        lfs.current = currentdir
    end)

    it("core module returns parent path", function()
        assert.is.equal("/xyz/parent", core.getParent("/xyz/parent/current"))
    end)

    it("core module returns nil for parent path in case of root path", function()
        local dir, descr = core.getParent("/zyx")
        assert.is.falsy(dir)
        assert.is.equal("There is no parent dir for: /zyx", descr)

        dir, descr = core.getParent("/xzy/")
        assert.is.falsy(dir)
        assert.is.equal("There is no parent dir for: /xzy/", descr)
    end)
end)
