--[[
    привет зайкi coded by devirsaint 
    pui взят у enq и чутчут зафикшен а то он эррорил (пидарас)
]]

local assert, defer, error, getfenv, setfenv, getmetatable, setmetatable, ipairs,
pairs, next, pcall, rawequal, rawset, rawlen, readfile, require, select,
tonumber, tostring, type, unpack, xpcall =
    assert, defer, error, getfenv, setfenv, getmetatable, setmetatable, ipairs,
    pairs, next, pcall, rawequal, rawset, rawlen, readfile, require, select,
    tonumber, tostring, type, unpack, xpcall


local function mcopy(o)
    if type(o) ~= "table" then return o end
    local res = {}
    for k, v in pairs(o) do res[mcopy(k)] = mcopy(v) end
    return res
end

local table, math, string = mcopy(table), mcopy(math), mcopy(string)
local ui, client = mcopy(ui), mcopy(client)

--#endregion

--#region: globals

table.find = function(t, j)
    for k, v in pairs(t) do if v == j then return k end end
    return false
end
table.ifind = function(t, j) for i = 1, table.maxn(t) do if t[i] == j then return i end end end
table.qfind = function(t, j) for i = 1, #t do if t[i] == j then return i end end end
table.ihas = function(t, ...)
    local arg = { ... }
    for i = 1, table.maxn(t) do for j = 1, #arg do if t[i] == arg[j] then return true end end end
    return false
end

table.minn = function(t)
    local s = 0
    for i = 1, #t do
        if t[i] == nil then break end
        s = s + 1
    end
    return s
end
table.filter = function(t)
    local res = {}
    for i = 1, table.maxn(t) do if t[i] ~= nil then res[#res + 1] = t[i] end end
    return res
end
table.append = function(t, ...) for i, v in ipairs { ... } do table.insert(t, v) end end
table.copy = mcopy

local ternary = function(c, a, b) if c then return a else return b end end
local contend = function(func, callback, ...)
    local t = { pcall(func, ...) }
    if not t[1] then return type(callback) == "function" and callback(t[2]) or error(t[2], callback or 2) end
    return unpack(t, 2)
end

--#endregion

--#region: directory tools

local dirs = {
    execute = function(t, path, func)
        local p, k
        for _, s in ipairs(path) do
            k, p, t = s, t, t[s]
            if t == nil then return end
        end
        if p[k] then func(p[k]) end
    end,
    replace = function(t, path, value)
        local p, k
        for _, s in ipairs(path) do
            k, p, t = s, t, t[s]
            if t == nil then return end
        end
        p[k] = value
    end,
    find = function(t, path)
        local p, k
        for _, s in ipairs(path) do
            k, p, t = s, t, t[s]
            if t == nil then return end
        end
        return p[k]
    end,
}

dirs.pave = function(t, place, path)
    local p = t
    for i, v in ipairs(path) do
        if type(p[v]) == "table" then
            p = p[v]
        else
            p[v] = (i < #path) and {} or place
            p = p[v]
        end
    end
    return t
end

dirs.extract = function(t, path)
    if not path or #path == 0 then return t end
    local j = dirs.find(t, path)
    return dirs.pave({}, j, path)
end

--#endregion

local pui, pui_mt, methods_mt = {}, {}, {
    element = {}, group = {}
}

-- #endregion
--

--
-- #region : Elements

--#region: arguments

local elements = {
    button       = { type = "function", arg = 2, unsavable = true },
    checkbox     = { type = "boolean", arg = 1, init = false },
    color_picker = { type = "table", arg = 5 },
    combobox     = { type = "string", arg = 2, variable = true },
    hotkey       = { type = "table", arg = 3, enum = { [0] = "Always on", "On hotkey", "Toggle", "Off hotkey" } },
    label        = { type = "string", arg = 1, unsavable = true },
    listbox      = { type = "number", arg = 2, init = 0, variable = true },
    multiselect  = { type = "table", arg = 2, init = {}, variable = true },
    slider       = { type = "number", arg = 8 },
    textbox      = { type = "string", arg = 1, init = "" },
    string       = { type = "string", arg = 2, init = "" },
    unknown      = { type = "string", arg = 2, init = "" } -- new_string type
}

local weapons = { "Global", "G3SG1 / SCAR-20", "SSG 08", "AWP", "R8 Revolver", "Desert Eagle", "Pistol", "Zeus", "Rifle",
    "Shotgun", "SMG", "Machine gun" }

--#endregion

--#region: registry

local registry, ragebot, players = {}, {}, {}
do
    client.set_event_callback("shutdown", function()
        for k, v in next, registry do
            if v.__ref and not v.__rage then
                if v.overridden then ui.set(k, v.original) end
                ui.set_enabled(k, true)
                ui.set_visible(k, not v.__hidden)
            end
        end
        ragebot.cycle(function(active)
            for k, v in pairs(ragebot.context[active]) do
                if v ~= nil and registry[k].overridden then
                    ui.set(k, v)
                end
            end
        end, true)
    end)
    client.set_event_callback("pre_config_save", function()
        for k, v in next, registry do
            if v.__ref and not v.__rage and v.overridden then
                v.ovr_restore = { ui.get(k) }; ui.set(k, v.original)
            end
        end
        ragebot.cycle(function(active)
            for k, v in pairs(ragebot.context[active]) do if registry[k].overridden then
                    ragebot.cache[active][k] = ui.get(k); ui.set(k, v)
                end end
        end, true)
    end)
    client.set_event_callback("post_config_save", function()
        for k, v in next, registry do
            if v.__ref and not v.__rage and v.overridden then
                ui.set(k, unpack(v.ovr_restore)); v.ovr_restore = nil
            end
        end
        ragebot.cycle(function(active)
            for k, v in pairs(ragebot.context[active]) do
                if k ~= nil and ragebot.cache[active] ~= nil and ragebot.cache[active][k] ~= nil then
                    if registry[k].overridden then
                        ui.set(k, ragebot.cache[active][k]); ragebot.cache[active][k] = nil
                    end
                end
            end
        end, true)
    end)
end

--#endregion

--#region: elemence

local elemence = {}
do
    local callbacks = function(this, isref)
        if this.name == "Weapon type" and string.lower(registry[this.ref].tab) == "rage" then return ui.get(this.ref) end

        ui.set_callback(this.ref, function(self)
            if registry[self].__rage and ragebot.silent then return end
            for i = 0, #registry[self].callbacks, 1 do
                if type(registry[self].callbacks[i]) == "function" then registry[self].callbacks[i](this) end
            end
        end)

        if this.type == "button" then
            return
        elseif this.type == "color_picker" or this.type == "hotkey" then
            registry[this.ref].callbacks[0] = function(self) this.value = { ui.get(self.ref) } end
            return { ui.get(this.ref) }
        else
            registry[this.ref].callbacks[0] = function(self) this.value = ui.get(self.ref) end
            if this.type == "multiselect" then
                this.value = ui.get(this.ref)
                registry[this.ref].callbacks[1] = function(self)
                    registry[this.ref].options = {}
                    for i = 1, #self.value do registry[this.ref].options[self.value[i]] = true end
                end
                registry[this.ref].callbacks[1](this)
            end
            return ui.get(this.ref)
        end
    end

    elemence.new = function(ref, add)
        local self = {}; add = add or {}

        self.ref = ref
        self.name, self.type = ui.name(ref), ui.type(ref)

        --
        registry[ref] = registry[ref] or {
            type = self.type,
            ref = ref,
            tab = add.__tab,
            container = add.__container,
            __ref = add.__ref,
            __hidden = add.__hidden,
            __init = add.__init,
            __list = add.__list,
            __rage = add.__rage,
            __plist = add.__plist and not (self.type == "label" or self.type == "button" or self.type == "hotkey"),

            overridden = false,
            original = self.value,
            donotsave = add.__plist or false,
            callbacks = { [0] = add.__callback },
            events = {},
            depend = { [0] = { ref }, {}, {} },
        }

        registry[ref].self = setmetatable(self, methods_mt.element)
        self.value = callbacks(self, add.__ref)

        if add.__rage then
            methods_mt.element.set_callback(self, ragebot.memorize)
        end
        if registry[ref].__plist then
            players.elements[#players.elements + 1] = self
            methods_mt.element.set_callback(self, players.slot_update, true)
        end

        return self
    end

    elemence.group = function(...)
        return setmetatable({ ... }, methods_mt.group)
    end

    elemence.string = function(name, default)
        local this = {}

        this.ref = ui.new_string(name, default or "")
        this.type = "string"
        this[0] = { savable = true }

        return setmetatable(this, methods_mt.element)
    end

    elemence.features = function(self, args)
        do
            local addition
            local v, kind = args[1], type(args[1])

            if not addition and (kind == "table" or kind == "cdata") and not v.r then
                addition = "color"
                local r, g, b, a = v[1] or 255, v[2] or 255, v[3] or 255, v[4] or 255
                self.color = elemence.new(
                ui.new_color_picker(registry[self.ref].tab, registry[self.ref].container, self.name, r, g, b, a), {
                    __init = { r, g, b, a },
                    __plist = registry[self.ref].__plist
                })
            elseif not addition and (kind == "table" or kind == "cdata") and v.r then
                addition = "color"
                self.color = elemence.new(
                ui.new_color_picker(registry[self.ref].tab, registry[self.ref].container, self.name, v.r, v.g, v.b, v.a),
                    {
                        __init = { v.r, v.g, v.b, v.a },
                        __plist = registry[self.ref].__plist
                    })
            elseif not addition and kind == "number" then
                addition = "hotkey"
                self.hotkey = elemence.new(ui.new_hotkey(registry[self.ref].tab, registry[self.ref].container, self.name,
                    true, v, {
                    __init = v
                }))
            end
            registry[self.ref].depend[0][2] = addition and self[addition].ref
            registry[self.ref].__addon = addition
        end
        do
            registry[self.ref].donotsave = args[2] == false
        end
    end

    elemence.memorize = function(self, path, origin)
        if registry[self.ref].donotsave then return end

        if not elements[self.type].unsavable then
            dirs.pave(origin, self.ref, path)
        end

        if self.color then
            path[#path] = path[#path] .. "_c"
            dirs.pave(origin, self.color.ref, path)
        end
        if self.hotkey then
            path[#path] = path[#path] .. "_h"
            dirs.pave(origin, self.hotkey.ref, path)
        end
    end

    elemence.hidden_refs = {
        "Unlock hidden cvars", "Allow custom game events", "Faster grenade toss",
        "sv_maxunlag", "sv_maxusrcmdprocessticks", "sv_clockcorrection_msecs", -- m4kb12jk
    }

    --#region: depend

    local cases = {
        combobox = function(v)
            if v[3] == true then
                return v[1].value ~= v[2]
            else
                for i = 2, #v do
                    if v[1].value == v[i] then return true end
                end
            end
            return false
        end,
        listbox = function(v)
            if v[3] == true then
                return v[1].value ~= v[2]
            else
                for i = 2, #v do
                    if v[1].value == v[i] then return true end
                end
            end
            return false
        end,
        multiselect = function(v)
            return table.ihas(v[1].value, unpack(v, 2))
        end,
        slider = function(v)
            return v[2] <= v[1].value and v[1].value <= (v[3] or v[2])
        end,
    }

    local depend = function(v)
        local condition = false

        if type(v[2]) == "function" then
            condition = v[2](v[1])
        else
            local f = cases[v[1].type]
            if f then
                condition = f(v)
            else
                condition = v[1].value == v[2]
            end
        end

        return condition and true or false
    end

    elemence.dependant = function(owner, dependant, dis)
        local count = 0

        for i = 1, #owner do
            if depend(owner[i]) then count = count + 1 else break end
        end

        local allow, action = count >= #owner, dis and "set_enabled" or "set_visible"

        for i, v in ipairs(dependant) do ui[action](v, allow) end
    end

    --#endregion
end

--#endregion

--#region: utils

local utils = {}

do
    utils.rgb_to_hex = function(color)
        return string.format("%02X%02X%02X%02X", color[1], color[2], color[3], color[4] or 255)
    end

    utils.hex_to_rgb = function(hex)
        hex = hex:gsub("^#", "")
        return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16),
            tonumber(hex:sub(7, 8), 16) or 255
    end

    utils.gradient_text = function(text, colors, precision)
        local symbols, length = {}, #string.gsub(text, ".[\128-\191]*", "a")
        local s = 1 / (#colors - 1)
        precision = precision or 1

        local i = 0
        for letter in string.gmatch(text, ".[\128-\191]*") do
            i = i + 1

            local weight = i / length
            local cw = weight / s
            local j = math.ceil(cw)
            local w = (cw / j)
            local L, R = colors[j], colors[j + 1]

            local r = L[1] + (R[1] - L[1]) * w
            local g = L[2] + (R[2] - L[2]) * w
            local b = L[3] + (R[3] - L[3]) * w
            local a = L[4] + (R[4] - L[4]) * w

            symbols[#symbols + 1] = ((i - 1) % precision == 0) and ("\a%02x%02x%02x%02x%s"):format(r, g, b, a, letter) or
            letter
        end

        symbols[#symbols + 1] = "\aCDCDCDFF"

        return table.concat(symbols)
    end

    local gradients = function(col, text)
        local colors = {}; for w in string.gmatch(col, "\b%x+") do
            colors[#colors + 1] = { utils.hex_to_rgb(string.sub(w, 2)) }
        end
        if #colors > 0 then return utils.gradient_text(text, colors, #text > 8 and 2 or 1) end
    end

    utils.format = function(s)
        if type(s) == "string" then
            s = string.gsub(s, "\f<(.-)>", pui.macros)
            s = string.gsub(s, "[\v\r\t]", { ["\v"] = "\a" .. pui.accent, ["\r"] = "\aCDCDCDFF", ["\t"] = "    " })
            s = string.gsub(s, "([\b%x]-)%[(.-)%]", gradients)
        end
        return s
    end

    utils.unpack_color = function(...)
        local arg = { ... }
        local kind = type(arg[1])

        if kind == "table" or kind == "cdata" or kind == "userdata" then
            if arg[1].r then
                return { arg[1].r, arg[1].g, arg[1].b, arg[1].a }
            elseif arg[1][1] then
                return { arg[1][1], arg[1][2], arg[1][3], arg[1][4] }
            end
        end

        return arg
    end

    --#region: dispense

    local dispensers = {
        color_picker = function(args)
            args[1] = string.sub(utils.format(args[1]), 1, 117)

            if type(args[2]) ~= "number" then
                local col = args[2]
                args.n, args.req, args[2] = args.n + 3, args.req + 3, col.r
                table.insert(args, 3, col.g)
                table.insert(args, 4, col.b)
                table.insert(args, 5, col.a)
            end

            for i = args.req + 1, args.n do
                args.misc[i - args.req] = args[i]
            end

            args.data.__init = { args[2] or 255, args[3] or 255, args[4] or 255, args[5] or 255 }
        end,
        listbox = function(args, variable)
            args[1] = string.sub(utils.format(args[1]), 1, 117)
            for i = args.req + 1, args.n do
                args.misc[i - args.req] = args[i]
            end

            args.data.__init, args.data.__list = 0, not variable and args[2] or { unpack(args, 2, args.n) }
        end,
        combobox = function(args, variable)
            args[1] = string.sub(utils.format(args[1]), 1, 117)
            for i = args.req + 1, args.n do
                args.misc[i - args.req] = args[i]
            end

            args.data.__init, args.data.__list = not variable and args[2][1] or args[2],
                not variable and args[2] or { unpack(args, 2, args.n) }
        end,
        multiselect = function(args, variable)
            args[1] = string.sub(utils.format(args[1]), 1, 117)
            for i = args.req + 1, args.n do
                args.misc[i - args.req] = args[i]
            end

            args.data.__init, args.data.__list = {}, not variable and args[2] or { unpack(args, 2, args.n) }
        end,
        slider = function(args)
            args[1] = string.sub(utils.format(args[1]), 1, 117)

            for i = args.req + 1, args.n do
                args.misc[i - args.req] = args[i]
            end

            args.data.__init = args[4] or args[2]
        end,
        button = function(args)
            args[2] = args[2] or function() end
            args[1] = string.sub(utils.format(args[1]), 1, 117)
            args.n, args.data.__callback = 2, args[2]
        end
    }

    utils.dispense = function(key, raw, ...)
        local args, group, ctx = { ... }, {}, elements[key]

        if type(raw) == "table" then
            group[1], group[2] = raw[1], raw[2]
            group.__plist = raw.__plist
        else
            group[1], group[2] = raw, args[1]
            table.remove(args, 1)
        end

        args.n, args.data = table.maxn(args), {
            __tab = group[1],
            __container = group[2],
            __plist = group.__plist and true or nil
        }

        local variable = (ctx and ctx.variable) and type(args[2]) == "string"
        args.req, args.misc = not variable and ctx.arg or args.n, {}

        if dispensers[key] then
            dispensers[key](args, variable)
        else
            for i = 1, args.n do
                if type(args[i]) == "string" then
                    args[i] = string.sub(utils.format(args[i]), 1, 117)
                end

                if i > args.req then args.misc[i - args.req] = args[i] end
            end
            args.data.__init = ctx.init
        end

        return args, group
    end

    --#endregion
end

--#endregion

-- #endregion
--


-- #endregion -----------------------------------------------------------
--


-------------------------------------------------------------------------
-- #region :: pui


--
-- #region : pui

--#region: variables

pui.macros = setmetatable({}, {
    __newindex = function(self, key, value) rawset(self, tostring(key), value) end,
    __index = function(self, key) return rawget(self, tostring(key)) end
})

pui.accent, pui.menu_open = nil, ui.is_menu_open()

do
    local reference = ui.reference("MISC", "Settings", "Menu color")
    pui.accent = utils.rgb_to_hex { ui.get(reference) }
    local previous = pui.accent

    ui.set_callback(reference, function()
        local color = { ui.get(reference) }
        pui.accent = utils.rgb_to_hex(color)

        for idx, ref in next, registry do
            if ref.type == "label" and not ref.__ref then
                local new, count = string.gsub(ref.self.value, previous, pui.accent)
                if count > 0 then
                    ui.set(idx, new)
                    ref.self.value = new
                end
            end
        end
        previous = pui.accent
        client.fire_event("pui::accent_color", color)
    end)
end

client.set_event_callback("paint_ui", function()
    local state = ui.is_menu_open()
    if state ~= pui.menu_open then
        client.fire_event("pui::menu_state", state)
        pui.menu_open = state
    end
end)

--#endregion

--#region: features

pui.group = function(tab, container) return elemence.group(tab, container) end

pui.format = utils.format

pui.reference = function(tab, container, name)
    local found = { contend(ui.reference, 3, tab, container, name) }
    local total, hidden = #found, false

    -- done on purpose, don't blame me
    if string.lower(tab) == "misc" and string.lower(container) == "settings" then
        for i, v in ipairs(elemence.hidden_refs) do
            if string.find(name, "^" .. v) then
                hidden = true
                break
            end
        end
    end

    for i, v in ipairs(found) do
        found[i] = elemence.new(v, {
            __ref = true,
            __hidden = hidden or nil,
            __tab = tab,
            __container = container,
            __rage = container == "Aimbot" or nil,
        })
    end

    if total > 1 then
        local shift = 0
        for i = 1, total > 4 and total or 4, 2 do
            local m, j = i - shift, i + 1 - shift
            if found[j] and (found[j].type == "hotkey" or found[j].type == "color_picker") then
                local addition = found[j].type == "color_picker" and "color" or "hotkey"
                registry[found[m].ref].__addon, found[m][addition] = addition, found[j]

                table.remove(found, j)
                shift = shift + 1
            end
        end
        return unpack(found)
    else
        return found[1]
    end
end

pui.traverse = function(t, f, p)
    p = p or {}

    if type(t) == "table" and t.__name ~= "pui::element" and t[#t] ~= "~" then
        for k, v in next, t do
            local np = table.copy(p); np[#np + 1] = k
            pui.traverse(v, f, np)
        end
    else
        f(t, p)
    end
end

--#endregion

--#region: config system

do
    local save = function(config, ...)
        local packed = {}

        pui.traverse(dirs.extract(config, { ... }), function(ref, path)
            local value
            local etype = registry[ref].type

            if etype == "color_picker" then
                value = "#" .. utils.rgb_to_hex { ui.get(ref) }
            elseif etype == "hotkey" then
                local _, mode, key = ui.get(ref)
                value = { mode, key or 0 }
            else
                value = ui.get(ref)
            end

            if type(value) == "table" then value[#value + 1] = "~" end
            dirs.pave(packed, value, path)
        end)

        return packed
    end

    local load = function(config, package, ...)
        if not package then return end

        local packed = dirs.extract(package, { ... })
        pui.traverse(dirs.extract(config, { ... }), function(ref, path)
            local value, proxy = dirs.find(packed, path), registry[ref]
            local vtype, etype = type(value), proxy.type
            local object = elements[etype]

            if vtype == "string" and value:sub(1, 1) == "#" then
                value, vtype = { utils.hex_to_rgb(value) }, "table"
            elseif vtype == "table" and value[#value] == "~" then
                value[#value] = nil
            end

            if etype == "hotkey" and value and type(value[1]) == "number" then
                value[1] = elements.hotkey.enum[value[1]]
            end

            local s, r = pcall(function()
                if object and object.type == vtype then
                    if vtype == "table" and etype ~= "multiselect" then
                        ui.set(ref, unpack(value))
                        if etype == "color_picker" then methods_mt.element.invoke(proxy.self) end
                    else
                        ui.set(ref, value)
                    end
                else
                    if proxy.__init then ui.set(ref, proxy.__init) end
                end
            end)

            -- if not s then printf("failed to set %s to %s  [%s]", value, proxy.self, r) end
        end)
    end

    --
    local package_mt = {
        __type = "pui::package",
        __metatable = false,
        __call = function(self, raw, ...)
            return (type(raw) == "table" and load or save)(self[0], raw, ...)
        end,
        save = function(self, ...) return save(self[0], ...) end,
        load = function(self, ...) load(self[0], ...) end,
    }
    package_mt.__index = package_mt

    pui.setup = function(t)
        local package = { [0] = {} }
        pui.traverse(t, function(r, p) elemence.memorize(r, p, package[0]) end)
        return setmetatable(package, package_mt)
    end
end

--#endregion

-- #endregion
--

--
-- #region : methods

methods_mt.element = {
    __type = "pui::element",
    __name = "pui::element",
    __metatable = false,
    __eq = function(this, that) return this.ref == that.ref end,
    __tostring = function(self) return string.format('pui.%s[%d] "%s"', self.type, self.ref, self.name) end,
    __call = function(self, ...) if #{ ... } > 0 then ui.set(self.ref, ...) else return ui.get(self.ref) end end,

    --

    depend = function(self, ...)
        local arg = { ... }
        local disabler = arg[1] == true

        local depend = registry[self.ref].depend[disabler and 2 or 1]
        local this = registry[self.ref].depend[0]

        for i = (disabler and 2 or 1), table.maxn(arg) do
            local v = arg[i]
            if v then
                if v.__name == "pui::element" then v = { v, true } end
                depend[#depend + 1] = v

                local check = function() elemence.dependant(depend, this, disabler) end
                check()

                registry[v[1].ref].callbacks[#registry[v[1].ref].callbacks + 1] = check
            end
        end

        return self
    end,

    override = function(self, value)
        local is_hk = self.type == "hotkey"
        local ctx, wctx = registry[self.ref], ragebot.context[ragebot.ref.value]

        if value ~= nil then
            if not ctx.overridden then
                if is_hk then self.value = { ui.get(self.ref) } end
                if ctx.__rage then wctx[self.ref] = self.value else ctx.original = self.value end
            end
            ctx.overridden = true
            if is_hk then ui.set(self.ref, value[1], value[2]) else ui.set(self.ref, value) end
            if ctx.__rage then ctx.__ovr_v = value end
        else
            if ctx.overridden then
                local original = ctx.original
                if ctx.__rage then original, ctx.__ovr_v = wctx[self.ref], nil end
                if is_hk then
                    ui.set(self.ref, elements.hotkey.enum[original[2]], original[3] or 0)
                else
                    ui.set(self.ref, original)
                end
                ctx.overridden = false
            end
        end
    end,
    get_original = function(self)
        if registry[self.ref].__rage then
            if registry[self.ref].overridden then return ragebot.context[ragebot.ref.value][self.ref] else return self
                .value end
        else
            if registry[self.ref].overridden then return registry[self.ref].original else return self.value end
        end
    end,

    --

    set = function(self, ...)
        if self.type == "color_picker" then
            ui.set(self.ref, unpack(utils.unpack_color(...)))
            methods_mt.element.invoke(self)
        elseif self.type == "label" then
            local t = utils.format(...)
            ui.set(self.ref, t)
            self.value = t
        else
            ui.set(self.ref, ...)
        end
    end,
    get = function(self, value)
        if value and self.type == "multiselect" then
            return registry[self.ref].options[value] or false
        end
        return ui.get(self.ref)
    end,

    reset = function(self) if registry[self.ref].__init then ui.set(self.ref, registry[self.ref].__init) end end,

    update = function(self, t)
        ui.update(self.ref, t)
        registry[self.ref].__list = t

        local cap = #t - 1
        if ui.get(self.ref) > cap then ui.set(self.ref, cap) end
    end,
    get_list = function(self) return registry[self.ref].__list end,

    get_color = function(self)
        if registry[self.ref].__addon then return ui.get(self.color.ref) end
    end,
    set_color = function(self, ...)
        if registry[self.ref].__addon then methods_mt.element.set(self.color, ...) end
    end,
    get_hotkey = function(self)
        if registry[self.ref].__addon then return ui.get(self.hotkey.ref) end
    end,
    set_hotkey = function(self, ...)
        if registry[self.ref].__addon then methods_mt.element.set(self.hotkey, ...) end
    end,

    is_reference = function(self) return registry[self.ref].__ref or false end,
    get_type = function(self) return self.type end,
    get_name = function(self) return self.name end,

    set_visible = function(self, visible)
        ui.set_visible(self.ref, visible)
        if registry[self.ref].__addon then ui.set_visible(self[registry[self.ref].__addon].ref, visible) end
    end,
    set_enabled = function(self, enabled)
        ui.set_enabled(self.ref, enabled)
        if registry[self.ref].__addon then ui.set_enabled(self[registry[self.ref].__addon].ref, enabled) end
    end,

    set_callback = function(self, func, once)
        if once == true then func(self) end
        registry[self.ref].callbacks[#registry[self.ref].callbacks + 1] = func
    end,
    unset_callback = function(self, func)
        table.remove(registry[self.ref].callbacks, table.qfind(registry[self.ref].callbacks, func) or 0)
    end,
    invoke = function(self, ...)
        for i = 0, #registry[self.ref].callbacks do registry[self.ref].callbacks[i](self, ...) end
    end,

    set_event = function(self, event, func, condition)
        local slot = registry[self.ref]
        if condition == nil then condition = true end
        local is_cond_fn, latest = type(condition) == "function", nil
        slot.events[func] = function(this)
            local permission
            if is_cond_fn then permission = condition(this) else permission = this.value == condition end

            local action = permission and client.set_event_callback or client.unset_event_callback
            if latest ~= permission then
                action(event, func)
                latest = permission
            end
        end
        slot.events[func](self)
        slot.callbacks[#slot.callbacks + 1] = slot.events[func]
    end,
    unset_event = function(self, event, func)
        client.unset_event_callback(event, func)
        methods_mt.element.unset_callback(self, registry[self.ref].events[func])
        registry[self.ref].events[func] = nil
    end,

    get_location = function(self) return registry[self.ref].tab, registry[self.ref].container end,
}
methods_mt.element.__index = methods_mt.element

methods_mt.group = {
    __name = "pui::group",
    __metatable = false,
    __index = function(self, key) return rawget(methods_mt.group, key) or pui_mt.__index(self, key) end,
    get_location = function(self) return self[1], self[2] end
}

-- #endregion
--

--
-- #region : pui_mt, ragebot and plist handler

do
    for k, v in next, elements do
        v.fn = function(origin, ...)
            local args, group = utils.dispense(k, origin, ...)
            local this = elemence.new(
            contend(ui["new_" .. k], 3, group[1], group[2], unpack(args, 1, args.n < args.req and args.n or args.req)),
                args.data)

            elemence.features(this, args.misc)
            return this
        end
    end

    pui_mt.__name, pui_mt.__metatable = "pui::basement", false
    pui_mt.__index = function(self, key)
        if not elements[key] then return ui[key] end
        if key == "string" then return elemence.string end

        return elements[key].fn
    end
end


--#region: ragebot handler

ragebot = {
    ref = pui.reference("RAGE", "Weapon type", "Weapon type"),
    context = {},
    cache = {},
    silent = false,
}
do
    local previous, cycle_action = ragebot.ref.value, nil
    for i, v in ipairs(weapons) do ragebot.context[v], ragebot.cache[v] = {}, {} end

    local neutral = ui.reference("RAGE", "Aimbot", "Enabled")
    ui.set_callback(neutral, function()
        if not ragebot.silent then client.delay_call(0, client.fire_event, "pui::adaptive_weapon", ragebot.ref.value,
                previous) end
        if cycle_action then cycle_action(ragebot.ref.value) end
    end)

    ragebot.cycle = function(fn, mute)
        cycle_action = mute and fn or nil
        ragebot.silent = mute and true or false

        for i, v in ipairs(weapons) do
            ragebot.ref:override(v)
        end

        ragebot.ref:override()
        cycle_action, ragebot.silent = nil, false
    end

    ui.set_callback(ragebot.ref.ref, function(self)
        ragebot.ref.value = ui.get(self)

        if not ragebot.silent and previous ~= ragebot.ref.value then
            for i = 1, #registry[self].callbacks, 1 do registry[self].callbacks[i](ragebot.ref) end
        end

        previous = ragebot.ref.value
    end)

    ragebot.memorize = function(self)
        local ctx = ragebot.context[ragebot.ref.value]

        if registry[self.ref].overridden then
            if ctx[self.ref] == nil then
                ctx[self.ref] = self.value
                -- methods_mt.element.override(self, registry[self.ref].__ovr_v)
            end
        else
            if ctx[self.ref] then
                methods_mt.element.set(self, ctx[self.ref])
                ctx[self.ref] = nil
            end
        end
    end
end

--#endregion

--#region: plist handler

players = {
    elements = {}, list = {},
}
do
    --#region: stuff

    pui.plist = elemence.group("PLAYERS", "Adjustments")
    pui.plist.__plist = true

    local selected = 0
    local refs, slot = {
        list = pui.reference("PLAYERS", "Players", "Player list"),
        reset = pui.reference("PLAYERS", "Players", "Reset all"),
        apply = pui.reference("PLAYERS", "Adjustments", "Apply to all"),
    }, {}

    --#endregion

    --#region: slot metatable

    local slot_mt = {
        __type = "pui::player_slot",
        __metatable = false,
        __tostring = function(self)
            return string.format("pui::player_slot[%d] of %s", self.idx,
                methods_mt.element.__tostring(registry[self.ref].self))
        end,
        set = function(self, ...) -- don't mind
            local ctx, value = registry[self.ref], { ... }

            local is_colorpicker = ctx.type == "color_picker"
            if is_colorpicker then
                value = utils.unpack_color(...)
            end

            if self.idx == selected then
                ui.set(self.ref, unpack(value))
                if is_colorpicker then
                    methods_mt.element.invoke(ctx.self)
                end
            else
                self.value = is_colorpicker and value or unpack(value)
            end
        end,
        get = function(self, find)
            if find and registry[self.ref].type == "multiselect" then
                return table.qfind(self.value, find) ~= nil
            end

            if registry[self.ref].type ~= "color_picker" then
                return self.value
            else
                return unpack(self.value)
            end
        end,
    }
    slot_mt.__index = slot_mt

    --#endregion

    --#region: slots handling stuff

    players.traverse = function(fn) for i, v in ipairs(players.elements) do fn(v) end end

    slot = {
        select = function(idx)
            if not idx then return end
            for i, v in ipairs(players.elements) do
                methods_mt.element.set(v, v[idx].value)
            end
        end,
        add = function(idx)
            if not idx then return end
            for i, v in ipairs(players.elements) do
                local default = ternary(registry[v.ref].__init ~= nil, registry[v.ref].__init, v.value)
                v[idx], players.list[idx] = setmetatable({
                    ref = v.ref, idx = idx, value = default
                }, slot_mt), true
            end
        end,
        remove = function(idx)
            if not idx then return end
            for i, v in ipairs(players.elements) do
                v[idx], players.list[idx] = nil, nil
            end
        end,
    }

    players.slot_update = function(self)
        if self[selected] then
            self[selected].value = self.value
        else
            slot.add(selected)
        end
    end

    --#endregion

    --#region: callbacks

    local silent = false
    local update = function(e)
        selected = ui.get(refs.list.ref)

        local new, old = entity.get_players(), players.list
        local me = entity.get_local_player()

        for idx, v in next, old do
            if entity.get_classname(idx) ~= "CCSPlayer" then
                slot.remove(idx)
            end
        end

        for i, idx in ipairs(new) do
            if idx ~= me and not players.list[idx] and entity.get_classname(idx) == "CCSPlayer" then
                slot.add(idx)
            end
        end

        if not silent and not e.value then
            for i = #new, 1, -1 do
                if new[i] ~= me then
                    ui.set(refs.list.ref, new[i])
                    break
                end
            end
            client.update_player_list()
            silent = true
        else
            silent = false
        end

        slot.select(selected)
        client.fire_event("pui::plist_update", selected)
    end

    do
        local function once()
            update {}
            client.unset_event_callback("pre_render", once)
        end
        client.set_event_callback("pre_render", once)
    end
    methods_mt.element.set_callback(refs.list, update, true)
    client.set_event_callback("player_connect_full", update)
    client.set_event_callback("player_disconnect", update)
    client.set_event_callback("player_spawned", update)
    client.set_event_callback("player_spawn", update)
    client.set_event_callback("player_death", update)
    client.set_event_callback("player_team", update)

    --

    methods_mt.element.set_callback(refs.apply, function()
        players.traverse(function(v)
            for idx, _ in next, players.list do
                v[idx].value = v[selected].value
            end
        end)
    end)
    methods_mt.element.set_callback(refs.reset, function()
        players.traverse(function(v)
            for idx, _ in next, players.list do
                if idx == selected then
                    slot_mt.set(v[idx], registry[v.ref].__init)
                else
                    v[idx].value = registry[v.ref].__init
                end
            end
        end)
    end)

    --#endregion
end

local pui = setmetatable(pui, pui_mt)

local vector = require('vector')
local clipboard = require("gamesense/clipboard")
local base64 = require("gamesense/base64")
local adata = require("gamesense/antiaim_funcs")
local c_entity = require("gamesense/entity")
local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}

local main_massive_logs = {}
local for_rendering = {}


local new_label = panorama.loadstring([[
  var original = null;
  var new_label = null;

  var _Replace = function(new_text) {
    let dashboard = $.GetContextPanel().FindChildTraverse("HudTopLeft").FindChildTraverse("HudRadar");
    if (!dashboard) return;

    let dashboard_label = dashboard.FindChildTraverse("DashboardLabel");
    if (!dashboard_label) return;

    original = dashboard_label;
    original.text = new_text;
  };

  var _Restore = function() {
    if (original && original.IsValid()) {
      original.style.visibility = "visible";
    }

    if (new_label && new_label.IsValid()) {
      new_label.DeleteAsync(0.0);
    }

    original = null;
    new_label = null;
  };

  return {
    replace: _Replace,
    restore: _Restore
  };
]], "CSGOHud")()

local gratio = 1.6180339887
math.clamp = function (x, a, b) if a > x then return a elseif b < x then return b else return x end end
math.lerp = function (a, b, w)  return a + (b - a) * w  end

if(database.read("peremogaboiii.base") == nil) then
    local base = {
        name = {"empty config"},
        cfg = {""}
    }
    database.write("peremogaboiii.base", base)
end

local base = database.read("peremogaboiii.base")

local ref = {
    aimbot = pui.reference('RAGE', 'Aimbot', 'Enabled'),
	enabled = pui.reference("AA", "Anti-aimbot angles", "Enabled"),
	pitch = {pui.reference("AA", "Anti-aimbot angles", "pitch")},
	yawbase = pui.reference("AA", "Anti-aimbot angles", "Yaw base"),
	yaw = {pui.reference("AA", "Anti-aimbot angles", "Yaw") },
    fakeyawlimit = {pui.reference("AA", "Anti-aimbot angles", "Body yaw")},
    fsbodyyaw = pui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
    edgeyaw = pui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
    fakeduck = pui.reference("RAGE", "Other", "Duck peek assist"),
    safepoint = pui.reference("RAGE", "Aimbot", "Force safe point"),
	forcebaim = pui.reference("RAGE", "Aimbot", "Force body aim"),
	player_list = pui.reference("PLAYERS", "Players", "Player list"),
	reset_all = pui.reference("PLAYERS", "Players", "Reset all"),
	apply_all = pui.reference("PLAYERS", "Adjustments", "Apply to all"),
	load_cfg = pui.reference("Config", "Presets", "Load"),

    fl_enable = pui.reference("AA", "Fake lag", "Enabled"),
	fl_limit = pui.reference("AA", "Fake lag", "Limit"),
    fl_amount = pui.reference("AA", "Fake lag", "Amount"),
    fl_var = pui.reference("AA", "Fake lag", "Variance"),

	dt_limit = pui.reference("RAGE", "Aimbot", "Double tap fake lag limit"),

	quickpeek = pui.reference("RAGE", "Other", "Quick peek assist"),
	yawjitter = {pui.reference("AA", "Anti-aimbot angles", "Yaw jitter") },
	bodyyaw = {pui.reference("AA", "Anti-aimbot angles", "Body yaw") },
	freestand = {pui.reference("AA", "Anti-aimbot angles", "Freestanding") },
    roll = {pui.reference("AA", "Anti-aimbot angles", "Roll") },
	os = {pui.reference("AA", "Other", "On shot anti-aim") },
	slow = {pui.reference("AA", "Other", "Slow motion") },
	dt = {pui.reference("RAGE", "Aimbot", "Double tap")},
    dt = pui.reference("RAGE", "Aimbot", "Double tap"),
	hs = pui.reference("AA", "Other", "On shot anti-aim"),
	fakelag = pui.reference("AA", "Fake lag", "Enabled"),
    slow_motion = pui.reference("AA", "Other", "Slow motion"),
    menucol = pui.reference("MISC", "Settings", "Menu color"),
    mindmg = pui.reference("RAGE", "Aimbot", "Minimum damage override"),
    lmovement = pui.reference("AA", "Other", "Leg movement"),
    rage_cb = pui.reference("RAGE", "Aimbot", "Enabled"),
    fake_duck = pui.reference("RAGE","Other","Duck peek assist"),
}

local function normalize_yaw(val)
    if(val > 180) then
        val = val - 360
    elseif(val < -180) then
        val = val + 360
    end
    return val
end

local function calculate_angle(lpos, epos)
    local pos_diff = epos - lpos
    local angle = math.atan(pos_diff.y / pos_diff.x)
    angle = normalize_yaw(angle * 180 / math.pi)
    if pos_diff.x >= 0 then
        angle = normalize_yaw(angle + 180)
    end
    return angle
end

local lua = {
    conds = {"Global", "Standing", "Moving", "Slow-walking", "Jumping", "Jump-crouching", "Crouching", "Hidden"},
    conds_no_g = {"Standing", "Moving", "Slow-walking", "Jumping", "Jump-crouching", "Crouching"},
    ind_conds = {"Stand", "Move", "Slow-walk", "Jump", "Jump-crouch", "Crouch"},
    short_conds = {"[G]", "[S]", "[M]", "[SW]", "[J]", "[JC]", "[C]", "[H]"},
    hitgroup_mass = {'generic','head', 'chest', 'stomach','left arm', 'right arm','left leg', 'right leg','neck', 'generic', 'gear'},
}

function watermark_top_radar()
    local str = "Assembly.lua"
  
    new_label.replace(str)
end


local a_add = "\a3d4355FFa\r "
local m_add = "\a3d4355FFm\r "
local v_add = "\a3d4355FFv\r "
local aspect_table = {}

local function gcd(m, n)
	while m ~= 0 do
		m, n = math.fmod(n, m), m
	end

	return n
end

function aspect_ratio_table()
    local screen_width, screen_height = client.screen_size()
    for i = 1, 200 do
        local i2 = (200-i) * 0.01
		local divisor = gcd(screen_width * i2, screen_height)
		if screen_width * i2 / divisor < 100 or i2 == 1 then
			aspect_table[i] = screen_width * i2 / divisor .. ":" .. screen_height / divisor
		end
    end
end

aspect_ratio_table()

local cvar_opt_table = {
    "fog_enable",
    "r_dynamic",
    "r_drawtracers",
    "r_drawtracers_firstperson",
    "cl_foot_contact_shadows",
    "r_drawdecals",
    "func_break_max_pieces",
    "r_3dsky",
    "mat_bloomamount_rate",
    "r_updaterefracttexture",
    "r_lightinterp",
    "muzzleflash_light",
    "net_allow_multicast",
    "r_avglightmap",
    "rope_smooth",
    "rope_subdiv",
    "rope_wind_dist",
    "r_updaterefracttexture",
    "mat_yuv",
    "mat_bumpbasis",
    "mat_autoexposure_max",
}

local fps_cvar_values = {}

for i = 1, #cvar_opt_table do
    table.insert(fps_cvar_values, {cvar[cvar_opt_table[i]]:get_int(), cvar_opt_table[i]})
end

local fps_menu = {}

for i = 1, #fps_cvar_values do
    table.insert(fps_menu, fps_cvar_values[i][2])
end

local default_viewmodel_sets = {
    x = cvar.viewmodel_offset_x:get_float(),
    y = cvar.viewmodel_offset_y:get_float(),
    z = cvar.viewmodel_offset_z:get_float(),
    fov = cvar.viewmodel_fov:get_float(),
    active = false,
}

-- MENU --

pui.accent = "73769eFF"

local menu = {
    lbl1 = pui.label("AA", "Anti-aimbot angles", "Assembly \b73769eFF\b313847FF[diamond edition]"),
    lbl2 = pui.label("AA", "Anti-aimbot angles", "Release \v[experimental]"),
    enable = pui.checkbox("AA", "Anti-aimbot angles", "Enable lua"),
    tab = pui.combobox("AA", "Anti-aimbot angles", "tab", {"global", "rage & anti-aim", "visuals & miscellaneous", "configs"}),
    tab_fl = pui.combobox("AA", "Fake lag", "fl tab", {"fake lag", "binds"}),
    builder_or_phase = pui.combobox("AA", "Anti-aimbot angles", "anti-aim tab", {"Builder", "Phase"}),
    vis_or_misc = pui.combobox("AA", "Anti-aimbot angles", "vismisc", {"Miscellaneous", "Visuals"}),

    rage_aa_but = pui.button("AA", "Anti-aimbot angles", "Rage \v& \rAnti-aim", function() menu_seta("rage & anti-aim") end),

    visuals_but = pui.button("AA", "Anti-aimbot angles", "Visuals \v& \rMiscellaneous", function() menu_seta("visuals & miscellaneous") end),
    cfg_but = pui.button("AA", "Anti-aimbot angles", "Configs", function() menu_seta("configs") end),
    global_but = pui.button("AA", "Anti-aimbot angles", "Back to global", function() menu_seta("global") end),

    go_to_phase = pui.button("AA", "Anti-aimbot angles", "Go to phase-builder", function() menu_seta_phase("Phase") end),
    go_to_builder = pui.button("AA", "Anti-aimbot angles", "Go to builder", function() menu_seta_phase("Builder") end),

    go_to_misc = pui.button("AA", "Anti-aimbot angles", "Go to miscellaneous", function() menu_seta_vis("Miscellaneous") end),
    go_to_vis = pui.button("AA", "Anti-aimbot angles", "Go to visuals", function() menu_seta_vis("Visuals") end),

    fake_lag_but = pui.button("AA", "Fake lag", "Fake lag", function() menu_seta_fl("fake lag") end),
    bind_tab = pui.button("AA", "Fake lag", "Binds \v& \rYaw-overrides", function() menu_seta_fl("binds") end),

    fake_lag = {
        amount = pui.combobox("AA", "Fake lag", "Amount ", {"Dynamic", "Maximum", "Fluctuate"}),
        variance = pui.slider("AA", "Fake lag", "Variance ", 0, 100, 1, true, "%"),
        limit = pui.slider("AA", "Fake lag", "Limit ", 1, 15, 15),
    },

    state = pui.combobox("AA", "Anti-aimbot angles", "State", lua.conds),

    builder = {},
    phase_builder = {
        enable = pui.checkbox("AA", "Anti-aimbot angles", "Enable phase-builder"),
        phase_type = pui.combobox("AA", "Anti-aimbot angles", "Phase switch mode", {"Anti-bruteforce", "By time"}),
        anti_bruteforce = {
            reset = pui.multiselect("AA", "Anti-aimbot angles", "Reset anti-bruteforce on", {"Enemy death", "Round start", "Killing the enemy (by you)", "Time is running out", "Local dead"}),
            seconds_to_reset = pui.slider("AA", "Anti-aimbot angles", "Seconds to reset", 1, 14, 3, true, "s"),
        },
        phase_timer = {
            time_type = pui.combobox("AA", "Anti-aimbot angles", "Time size", {"Ticks", "Seconds"}),
            tick_switch = pui.slider("AA", "Anti-aimbot angles", "Ticks to switch", 1, 32, 2, true, "t"),
            second_switch = pui.slider("AA", "Anti-aimbot angles", "Seconds to switch", 1, 14, 2, true, "s"),
        },
        quantity = pui.slider("AA", "Anti-aimbot angles", "Quantity", 2, 10, 2),
        builder = {},
    },
    aa_options = {
        yaw_base = pui.checkbox("AA", "Fake lag", "At target"),
        hide_yaw_override = pui.checkbox("AA", "Fake lag", "Hide yaw-overrides"),
        manual_base = pui.combobox("AA", "Fake lag", "Manual base", {"None", "Left", "Backward", "Right", "Forward"}),
        left = pui.hotkey("AA", "Fake lag", "Left manual"),
        backward = pui.hotkey("AA", "Fake lag", "Backward manual"),
        right = pui.hotkey("AA", "Fake lag", "Right manual"),
        forward = pui.hotkey("AA", "Fake lag", "Forward manual"),
        static_on_manual = pui.checkbox("AA", "Fake lag", "Static yaw override"),
        funny_warmup = pui.checkbox("AA", "Fake lag", "Funny warmup"),
        freestand = pui.hotkey("AA", "Fake lag", "Freestand"),
        freestand_cond = pui.multiselect("AA", "Fake lag", "Freestand-work", lua.conds_no_g),
        defensive_always_on = pui.multiselect("AA", "Fake lag", "Always-on Double tap", lua.conds_no_g),
        defensive = pui.checkbox("AA", "Fake lag", "Defensive anti-aim enable"),
        safe_head = pui.checkbox("AA", "Fake lag", "Safe head"),
    },
    visuals = {
        indicators = pui.checkbox("AA", "Anti-aimbot angles", "Central indicators"),
        indicator_y = pui.slider("AA", "Anti-aimbot angles", "Indicators y", 0, 200, 35),
        logs = pui.checkbox("AA", "Anti-aimbot angles", "Logs"),
        logs_color1 = pui.color_picker("AA", "Anti-aimbot angles", "Accent color", 100,100,115,255),
        screen_logs = pui.checkbox("AA", "Anti-aimbot angles", "Screen logs"),
        screen_log_color = pui.color_picker("AA", "Anti-aimbot angles", "Screen color", 100,100,115,255),
        lbl3 = pui.label("AA", "Anti-aimbot angles", "Hit color"),
        logs_color2 = pui.color_picker("AA", "Anti-aimbot angles", "Hit color", 150,150,215,255),
        lbl4 = pui.label("AA", "Anti-aimbot angles", "Miss_color"),
        logs_color3 = pui.color_picker("AA", "Anti-aimbot angles", "Miss color", 150,100,100,255),
        aspect_ratio_type = pui.combobox("AA", "Anti-aimbot angles", "Aspect ratio mode", {"Disabled", "Normal", "Newcomer"}),
        normal_aspect_ratio = pui.slider("AA", "Anti-aimbot angles", "aspect ratio", 0, 200, 100, true, "%", 1, aspect_table),
        newcomer_aspect_ratio = pui.slider("AA", "Anti-aimbot angles", "aspect ratio ", 0, 200, 177, true, "", 0.01),
        slow_down = {
            enable = pui.checkbox("AA", "Anti-aimbot angles", "Slow down indicator"),
            color = pui.color_picker("AA", "Anti-aimbot angles", "Slow down color", 142, 165, 229, 85),
            x = pui.slider("AA", "Anti-aimbot angles", "Slow down x", 0, 10000, 1920 / 2, true, "px"),
            y = pui.slider("AA", "Anti-aimbot angles", "Slow down y", 0, 10000, 1080 / 2 - 300, true, "px"),
        },

        cvar_optimizer = pui.multiselect("AA", "Anti-aimbot angles", "Cvar optimizer", fps_menu),
        filter_console = pui.checkbox("AA", "Anti-aimbot angles", "Filterconsole"),
        viewmodel_enable = pui.checkbox("AA", "Anti-aimbot angles", "View model"),
        viewmodel = {
            x = pui.slider("AA", "Anti-aimbot angles", "Viewmodel x", -100, 100, cvar.viewmodel_offset_x:get_int() * 10, true, "", 0.1, true),
            y = pui.slider("AA", "Anti-aimbot angles", "Viewmodel y", -100, 100, cvar.viewmodel_offset_y:get_int() * 10, true, "", 0.1, true),
            z = pui.slider("AA", "Anti-aimbot angles", "Viewmodel z", -100, 100, cvar.viewmodel_offset_z:get_int() * 10, true, "", 0.1, true),
            fov = pui.slider("AA", "Anti-aimbot angles", "Viewmodel fov", 0, 120, cvar.viewmodel_fov:get_int()),
        },
    },
    misc = {
        dt_recharge = pui.checkbox("AA", "Anti-aimbot angles", "DT recharge"),
        fast_ladder = pui.checkbox("AA", "Anti-aimbot angles", "Fast ladder"),
        avoid_backstab = pui.checkbox("AA", "Anti-aimbot angles", "Avoid backstab"),
        teammate_whitelist = pui.checkbox("AA", "Anti-aimbot angles", "Allowing teammates shared-ESP"),
        debug = pui.checkbox("AA", "Anti-aimbot angles", "Debug"),
    },
    other = {
        animfix = pui.multiselect("AA", "Other", "Animbreakers!", {"Legs", "Jumping", "Dirty sprite"}),
        leg_breaker = pui.combobox("AA", "Other", "Leg breakers", {"Static", "Jitter", "Elusive", "Appallon"}),
        jumping = pui.combobox("AA", "Other", "Jumping", {"Static", "Jitter"}),
        sprite = pui.combobox("AA", "Other", "Body lean", {"Static", "By velocity", "Random"}),
    },
    cfg = {
        list = pui.listbox("AA", "Anti-aimbot angles", "Configs", base.name),
        name = pui.textbox("AA", "Anti-aimbot angles", "Config name"),
        load = pui.button("AA", "Anti-aimbot angles", "Load", function() load() end),
        saveing = pui.button("AA", "Anti-aimbot angles", "Save", function() save() end),
        create = pui.button("AA", "Anti-aimbot angles", "\v!\rCreate\v!", function() create() end),
        delete = pui.button("AA", "Anti-aimbot angles", "\v!\rDelete\v!", function() delete() end),
        import = pui.button("AA", "Anti-aimbot angles", "Import from clipboard", function() import() end),
        export = pui.button("AA", "Anti-aimbot angles", "Export to clipboard", function() export() end),
    },
}

for i = 1, 10 do
    menu.phase_builder.builder[i] = pui.slider("AA", "Anti-aimbot angles", "Modifier add #" .. i, -90, 90, 0)

    menu.phase_builder.builder[i]:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable, {menu.phase_builder.quantity, function() return i <= menu.phase_builder.quantity:get() end})
end

menu.builder_or_phase:set_visible(false)

menu.phase_builder.enable:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"})
menu.phase_builder.phase_type:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable)
menu.phase_builder.anti_bruteforce.reset:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable, {menu.phase_builder.phase_type, "Anti-bruteforce"})
menu.phase_builder.anti_bruteforce.seconds_to_reset:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable, {menu.phase_builder.phase_type, "Anti-bruteforce"}, {menu.phase_builder.anti_bruteforce.reset, function() return menu.phase_builder.anti_bruteforce.reset:get("Time is running out") end})
menu.phase_builder.phase_timer.time_type:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable, {menu.phase_builder.phase_type, "By time"})
menu.phase_builder.phase_timer.tick_switch:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable, {menu.phase_builder.phase_type, "By time"}, {menu.phase_builder.phase_timer.time_type, "Ticks"})
menu.phase_builder.phase_timer.second_switch:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable, {menu.phase_builder.phase_type, "By time"}, {menu.phase_builder.phase_timer.time_type, "Seconds"})
menu.phase_builder.quantity:depend(menu.enable, {menu.tab, "rage & anti-aim"}, {menu.builder_or_phase, "Phase"}, menu.phase_builder.enable)

menu.tab:set_visible(false)
menu.tab_fl:set_visible(false)

menu.fake_lag_but:depend(menu.enable, {menu.tab_fl, "binds"})
menu.bind_tab:depend(menu.enable, {menu.tab_fl, "fake lag"})
menu.fake_lag.amount:depend(menu.enable, {menu.tab_fl, "fake lag"})
menu.fake_lag.variance:depend(menu.enable, {menu.tab_fl, "fake lag"})
menu.fake_lag.limit:depend(menu.enable, {menu.tab_fl, "fake lag"})

menu.rage_aa_but:depend(menu.enable, {menu.tab, "global"})
menu.visuals_but:depend(menu.enable, {menu.tab, "global"})
menu.cfg_but:depend(menu.enable, {menu.tab, "global"})
menu.global_but:depend(menu.enable, {menu.tab, "global", true})

menu.cfg.list:depend(menu.enable, {menu.tab, "configs"})
menu.cfg.name:depend(menu.enable, {menu.tab, "configs"})
menu.cfg.load:depend(menu.enable, {menu.tab, "configs"})
menu.cfg.saveing:depend(menu.enable, {menu.tab, "configs"})
menu.cfg.create:depend(menu.enable, {menu.tab, "configs"})
menu.cfg.delete:depend(menu.enable, {menu.tab, "configs"})
menu.cfg.import:depend(menu.enable, {menu.tab, "configs"})
menu.cfg.export:depend(menu.enable, {menu.tab, "configs"})

local en = {menu.enable, true}
local menutab = {menu.tab, "rage & anti-aim"}
local vismisc = {menu.tab, "visuals & miscellaneous"}

menu.vis_or_misc:set_visible(false)

menu.go_to_phase:depend(en, menutab, aa_options, {menu.builder_or_phase, "Builder"})
menu.go_to_builder:depend(en, menutab, aa_options, {menu.builder_or_phase, "Phase"})
menu.state:depend(en, menutab, aa_options, {menu.builder_or_phase, "Builder"})

menu.aa_options.yaw_base:depend(en, {menu.tab_fl, "binds"})
menu.aa_options.hide_yaw_override:depend(en, {menu.tab_fl, "binds"})
menu.aa_options.manual_base:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.left:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.backward:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.right:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.forward:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.static_on_manual:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.funny_warmup:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.freestand:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.freestand_cond:depend(en, {menu.tab_fl, "binds"}, {menu.aa_options.hide_yaw_override, false})
menu.aa_options.defensive_always_on:depend(en, {menu.tab_fl, "binds"})
menu.aa_options.defensive:depend(en, {menu.tab_fl, "binds"})
menu.aa_options.safe_head:depend(en, {menu.tab_fl, "binds"})

menu.go_to_vis:depend(en, vismisc, {menu.vis_or_misc, "Miscellaneous"})
menu.go_to_misc:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})

menu.misc.dt_recharge:depend(en, vismisc, {menu.vis_or_misc, "Miscellaneous"})
menu.misc.fast_ladder:depend(en, vismisc, {menu.vis_or_misc, "Miscellaneous"})
menu.misc.avoid_backstab:depend(en, vismisc, {menu.vis_or_misc, "Miscellaneous"})
menu.misc.teammate_whitelist:depend(en, vismisc, {menu.vis_or_misc, "Miscellaneous"})
menu.misc.debug:depend(en, vismisc, {menu.vis_or_misc, "Miscellaneous"})

menu.visuals.cvar_optimizer:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})
menu.visuals.filter_console:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})
menu.visuals.viewmodel_enable:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})
menu.visuals.viewmodel.x:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.viewmodel_enable)
menu.visuals.viewmodel.y:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.viewmodel_enable)
menu.visuals.viewmodel.z:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.viewmodel_enable)
menu.visuals.viewmodel.fov:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.viewmodel_enable)

menu.other.animfix:depend(en)
menu.other.leg_breaker:depend(en, {menu.other.animfix, "Legs"})
menu.other.jumping:depend(en, {menu.other.animfix, "Jumping"})
menu.other.sprite:depend(en, {menu.other.animfix, "Dirty sprite"})

menu.aa_options.defensive:set_visible(false)
menu.visuals.indicators:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})
menu.visuals.indicator_y:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.indicators)
menu.visuals.logs:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})
menu.visuals.logs_color1:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.logs)
menu.visuals.screen_logs:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.logs)
menu.visuals.screen_log_color:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.logs)
menu.visuals.lbl3:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.logs)
menu.visuals.logs_color2:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.logs)
menu.visuals.lbl4:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.logs)
menu.visuals.logs_color3:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.logs)
menu.visuals.aspect_ratio_type:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})
menu.visuals.normal_aspect_ratio:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, {menu.visuals.aspect_ratio_type, "Normal"})
menu.visuals.newcomer_aspect_ratio:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, {menu.visuals.aspect_ratio_type, "Newcomer"})
menu.visuals.slow_down.enable:depend(en, vismisc, {menu.vis_or_misc, "Visuals"})
menu.visuals.slow_down.color:depend(en, vismisc, {menu.vis_or_misc, "Visuals"}, menu.visuals.slow_down.enable)
menu.visuals.slow_down.x:set_visible(false)
menu.visuals.slow_down.y:set_visible(false)

for i = 1, (#lua.conds - 1) do
    local dobavok = "\a3d4355FF" .. lua.short_conds[i] .. "\r "
    local dobavok_d = "\a3d4355FF" .. lua.short_conds[i] .. " [D]\r "
    menu.builder[i] = {
        enable = pui.checkbox("AA", "Anti-aimbot angles", "\a3d4355FF" .. lua.conds[i] .. "\r State enable"),
        pitch = pui.combobox("AA", "Anti-aimbot angles", dobavok .. "Pitch", {"Off", "Down", "Up"}),
        yaw_default = pui.slider("AA", "Anti-aimbot angles", dobavok .. "Yaw-offset", -180, 180, 0),
        yaw_add = pui.combobox("AA", "Anti-aimbot angles", dobavok .. "Yaw-add", {"Off", "Left & right"}),
        yaw_left = pui.slider("AA", "Anti-aimbot angles", dobavok .. "Yaw-add left", -180, 180, 0),
        yaw_right = pui.slider("AA", "Anti-aimbot angles", dobavok .. "Yaw-add right", -180, 180, 0),
        yaw = pui.combobox("AA", "Anti-aimbot angles", dobavok .. "Yaw", {"Center", "Slow", "Advanced skitter"}),
        yaw_center = pui.slider("AA", "Anti-aimbot angles", "\n" .. "\a00000000" .. lua.conds[i] .. "Yaw", -180, 180, 0),
        yaw_randomize = pui.slider("AA", "Anti-aimbot angles", dobavok .. "Randomize", 0, 100, 0, 1, "%"),
        double_tick_update = pui.checkbox("AA", "Anti-aimbot angles", dobavok .. "Double tick-update"),
        tick_update = pui.slider("AA", "Anti-aimbot angles", dobavok .. "Tick-update", 0, 14, 2),
        tick_update_second = pui.slider("AA", "Anti-aimbot angles", dobavok .. "Tick-update second", 0, 14, 2),
        body_yaw = pui.combobox("AA", "Anti-aimbot angles", dobavok .. "Body yaw", {"Off", "Jitter", "Smart", "Opposite"}),
        body_yaw_degree = pui.slider("AA", "Anti-aimbot angles", dobavok .. "Fake yaw", -180, 180, 0),
        defensive = pui.checkbox("AA", "Anti-aimbot angles", dobavok .. "Defensive aa"),
        d_pitch = pui.combobox("AA", "Anti-aimbot angles", dobavok_d .. "Pitch", {"Static", "Lerp", "Random", "Jitter", "Sway"}),
        d_pitch_degree = pui.slider("AA", "Anti-aimbot angles", "\n" .. "\a00000000" .. lua.conds[i] .. dobavok_d .. "pitch degree", -89, 89, 50),
        d_yaw = pui.combobox("AA", "Anti-aimbot angles", dobavok_d .. "Yaw", {"Forward", "Spin", "Slow spin", "180 z", "Sideways", "Random", "Sin", "Flick"}),
        d_tick_update = pui.slider("AA", "Anti-aimbot angles", dobavok_d .. "Tick-update", 0, 14, 2),
        d_offset = pui.slider("AA", "Anti-aimbot angles", dobavok_d .. "Defensive yaw-offset", -180, 180, 0),
    }
    if i ~= 1 and i ~= 8 then
        menu.builder[i].enable:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"})
    else
        menu.builder[i].enable:set_visible(false)
    end
    menu.builder[i].pitch:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable)
    menu.builder[i].yaw_default:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable)
    menu.builder[i].yaw:depend(en,menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable)
    menu.builder[i].double_tick_update:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, {menu.builder[i].yaw, "Slow"})
    menu.builder[i].tick_update:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, {menu.builder[i].yaw, "Slow"})
    menu.builder[i].tick_update_second:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, {menu.builder[i].yaw, "Slow"}, menu.builder[i].double_tick_update)
    menu.builder[i].yaw_center:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, {menu.builder[i].yaw, "Off", true})
    menu.builder[i].yaw_randomize:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, {menu.builder[i].yaw, "Off", true})
    menu.builder[i].yaw_add:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable)
    menu.builder[i].yaw_left:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, {menu.builder[i].yaw_add, "Left & right"})
    menu.builder[i].yaw_right:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, {menu.builder[i].yaw_add, "Left & right"})
    menu.builder[i].body_yaw:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable)
    menu.builder[i].body_yaw_degree:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, menu.builder[i].enable, {menu.builder_or_phase, "Builder"}, {menu.builder[i].body_yaw, "Jitter"})
    menu.builder[i].defensive:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, menu.aa_options.defensive)
    menu.builder[i].d_pitch:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, menu.aa_options.defensive, menu.builder[i].defensive)
    menu.builder[i].d_pitch_degree:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, menu.aa_options.defensive, menu.builder[i].defensive, {menu.builder[i].d_pitch, "Static"})
    menu.builder[i].d_yaw:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, menu.aa_options.defensive, menu.builder[i].defensive)
    menu.builder[i].d_tick_update:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, menu.aa_options.defensive, menu.builder[i].defensive, {menu.builder[i].d_yaw, "Sideways"})
    menu.builder[i].d_offset:depend(en, menutab, aa_options, {menu.state, lua.conds[i]}, {menu.builder_or_phase, "Builder"}, menu.builder[i].enable, menu.aa_options.defensive, menu.builder[i].defensive)
end

function menu_seta_vis(val)
    menu.vis_or_misc:set(val)
end

function menu_seta_phase(val)
    menu.builder_or_phase:set(val)
end

function menu_seta_fl(val)
    menu.tab_fl:set(val)
end

function menu_seta(val)
    menu.tab:set(val)
end

-- MENU END

function viewmodel_set()
    if menu.visuals.viewmodel_enable:get() and menu.enable:get() then
        if default_viewmodel_sets.active == false then
            default_viewmodel_sets.x = cvar.viewmodel_offset_x:get_float()
            default_viewmodel_sets.y = cvar.viewmodel_offset_y:get_float()
            default_viewmodel_sets.z = cvar.viewmodel_offset_z:get_float()
            default_viewmodel_sets.fov = cvar.viewmodel_fov:get_float()
            default_viewmodel_sets.active = true
        end
        client.set_cvar("viewmodel_offset_x", menu.visuals.viewmodel.x:get() / 10)
        client.set_cvar("viewmodel_offset_y", menu.visuals.viewmodel.y:get() / 10)
        client.set_cvar("viewmodel_offset_z", menu.visuals.viewmodel.z:get() / 10)
        client.set_cvar("viewmodel_fov", menu.visuals.viewmodel.fov:get())
    else
        default_viewmodel_sets.active = false
        client.set_cvar("viewmodel_offset_x", default_viewmodel_sets.x)
        client.set_cvar("viewmodel_offset_y", default_viewmodel_sets.y)
        client.set_cvar("viewmodel_offset_z", default_viewmodel_sets.z)
        client.set_cvar("viewmodel_fov", default_viewmodel_sets.fov)
    end
end

menu.visuals.viewmodel_enable:set_callback(function() viewmodel_set() end)
menu.visuals.viewmodel.x:set_callback(function() viewmodel_set() end)
menu.visuals.viewmodel.y:set_callback(function() viewmodel_set() end)
menu.visuals.viewmodel.z:set_callback(function() viewmodel_set() end)
menu.visuals.viewmodel.fov:set_callback(function() viewmodel_set() end)

function fps_opt()
    if not menu.enable:get() then return end
    for i = 1, #fps_cvar_values do
        if menu.visuals.cvar_optimizer:get(fps_cvar_values[i][2]) then
            cvar[fps_cvar_values[i][2]]:set_int(0)
        else
            cvar[fps_cvar_values[i][2]]:set_int(fps_cvar_values[i][1])
        end
    end
end

function filter_console()
    if not menu.enable:get() then return end
    if menu.visuals.filter_console:get() then
        cvar.con_filter_enable:set_int(1)
        cvar.con_filter_text:set_string("IrWL5106TZZKNFPz4P4Gl3pSN?J370f5hi373ZjPg%VOVh6lN")
        client.exec("con_filter_enable 1")
    else
        cvar.con_filter_enable:set_int(0)
        cvar.con_filter_text:set_string("")
        client.exec("con_filter_enable 0")
    end
end

local en_debug = {menu.enable, function(self) if self:get() then return true else return false end end}
local deb_debug = menu.misc.debug

function set_menu_builder()
    if ui.is_menu_open() then
        if menu.enable:get() then
            if menu.misc.debug:get() then
                state = true
            else
                state = false
            end
        else
            state = true
        end
        ref.fl_enable:set_visible(state)
        ref.fl_limit:set_visible(state)
        ref.fl_amount:set_visible(state)
        ref.fl_var:set_visible(state)
        ref.enabled:set_visible(state)
        ref.pitch[1]:set_visible(state)
        ref.pitch[2]:set_visible(state)
        ref.yawbase:set_visible(state)
        ref.yaw[1]:set_visible(state)
        ref.yaw[2]:set_visible(state)
        ref.fakeyawlimit[1]:set_visible(state)
        ref.fakeyawlimit[2]:set_visible(state)
        ref.fsbodyyaw:set_visible(state)
        ref.edgeyaw:set_visible(state)
        ref.yawjitter[1]:set_visible(state)
        ref.yawjitter[2]:set_visible(state)
        ref.freestand[1]:set_visible(state)
        ref.roll[1]:set_visible(state)
    end
end

client.set_event_callback("shutdown", function()
    ref.enabled:set_visible(true)
    ref.pitch[1]:set_visible(true)
    ref.pitch[2]:set_visible(true)
    ref.yawbase:set_visible(true)
    ref.yaw[1]:set_visible(true)
    ref.yaw[2]:set_visible(true)
    ref.fakeyawlimit[1]:set_visible(true)
    ref.fakeyawlimit[2]:set_visible(true)
    ref.fsbodyyaw:set_visible(true)
    ref.edgeyaw:set_visible(true)
    ref.yawjitter[1]:set_visible(true)
    ref.yawjitter[2]:set_visible(true)
    ref.freestand[1]:set_visible(true)
    ref.roll[1]:set_visible(true)
end)

local manu = {
    left = false,
    backward = false,
    right = false,
    forward = false,
    leftdump = 0,
    backwarddump = 0,
    rightdump = 0,
    forwarddump = 0,
}

function manualing()
    if(menu.aa_options.left:get()) then
        if manu.leftdump <= 2 then
            manu.leftdump = manu.leftdump + 1
        end
    else
        manu.leftdump = 0
    end
    if(menu.aa_options.backward:get()) then
        if manu.backwarddump <= 2 then
            manu.backwarddump = manu.backwarddump + 1
        end
    else
        manu.backwarddump = 0
    end
    if(menu.aa_options.right:get()) then
        if manu.rightdump <= 2 then
            manu.rightdump = manu.rightdump + 1
        end
    else
        manu.rightdump = 0
    end
    if(menu.aa_options.forward:get()) then
        if manu.forwarddump <= 2 then
            manu.forwarddump = manu.forwarddump + 1
        end
    else
        manu.forwarddump = 0
    end
    local poisk = math.huge
    local minsh = 0
    for i = 1, 4 do
        if(i == 1) then
            val = manu.leftdump
        elseif(i == 2) then
            val = manu.backwarddump
        elseif(i == 3) then
            val = manu.rightdump
        elseif(i == 4) then
            val = manu.forwarddump
        end
        if(val < poisk and val ~= 0) then
            poisk = val
            minsh = i
        end
    end
    if(minsh ~= 0) then
        if(poisk == 1) then
            if(minsh == 1) then
                if(menu.aa_options.manual_base:get() ~= "Left") then
                    menu.aa_options.manual_base:set("Left")
                elseif(menu.aa_options.manual_base:get() == "Left") then
                    menu.aa_options.manual_base:set("None")
                end
            elseif(minsh == 2) then
                if(menu.aa_options.manual_base:get() ~= "Backward") then
                    menu.aa_options.manual_base:set("Backward")
                elseif(menu.aa_options.manual_base:get() == "Backward") then
                    menu.aa_options.manual_base:set("None")
                end
            elseif(minsh == 3) then
                if(menu.aa_options.manual_base:get() ~= "Right") then
                    menu.aa_options.manual_base:set("Right")
                elseif(menu.aa_options.manual_base:get() == "Right") then
                    menu.aa_options.manual_base:set("None")
                end
            elseif(minsh == 4) then
                if(menu.aa_options.manual_base:get() ~= "Forward") then
                    menu.aa_options.manual_base:set("Forward")
                elseif(menu.aa_options.manual_base:get() == "Forward") then
                    menu.aa_options.manual_base:set("None")
                end
            end
        end
    end
end

function fast_ladder(cmd, lp)
    local pitch, yaw = client.camera_angles()
    if (entity.get_prop(lp, "m_MoveType") == 9) then
        cmd.yaw = math.floor(cmd.yaw + 0.5)
        cmd.roll = 0
        if cmd.forwardmove > 0 then
            if pitch < 45 then
                cmd.pitch = 89
                cmd.in_moveright = 1
                cmd.in_moveleft = 0
                cmd.in_forward = 0
                cmd.in_back = 1
                if cmd.sidemove == 0 then
                    cmd.yaw = cmd.yaw + 90
                end
                if cmd.sidemove < 0 then
                    cmd.yaw = cmd.yaw + 150
                end
                if cmd.sidemove > 0 then
                    cmd.yaw = cmd.yaw + 30
                end
            end 
        end
        if cmd.forwardmove < 0 then
            cmd.pitch = 89
            cmd.in_moveleft = 1
            cmd.in_moveright = 0
            cmd.in_forward = 1
            cmd.in_back = 0
            if cmd.sidemove == 0 then
                cmd.yaw = cmd.yaw + 90
            end
            if cmd.sidemove > 0 then
                cmd.yaw = cmd.yaw + 150
            end
            if cmd.sidemove < 0 then
                cmd.yaw = cmd.yaw + 30
            end
        end
    end
end


function aspect_ratio()
    if menu.visuals.aspect_ratio_type:get() ~= "Disabled" and menu.enable:get() then
        if menu.visuals.aspect_ratio_type:get() == "Normal" then
            local mult = menu.visuals.normal_aspect_ratio:get() * 0.01
            mult = 2 - mult
            local screen_width, screen_height = client.screen_size()
            local aspectratio_value = (screen_width * mult) / screen_height
        
            if mult == 1 then
                aspectratio_value = 0
            end
            client.set_cvar("r_aspectratio", tonumber(aspectratio_value))
        else
            local mult = menu.visuals.newcomer_aspect_ratio:get() * 0.01
            client.set_cvar("r_aspectratio", mult)
        end
    else
        client.set_cvar("r_aspectratio", 0)
    end
end

local indacfg = pui.setup({menu.builder, menu.aa_options, menu.misc, menu.visuals, menu.phase_builder, menu.fake_lag, menu.other})

function load()
    local val = menu.cfg.list:get() + 1
    indacfg:load(base.cfg[val])
    print("Loaded")
end

function save()
    local val = menu.cfg.list:get() + 1
    local nameindabox = menu.cfg.name:get()
    if nameindabox ~= "" then
        base.name[val] = nameindabox
    end
    base.cfg[val] = indacfg:save()
    database.write("peremogaboiii.base", base)
    menu.cfg.list:update(base.name)
    print("Saved")
end

function create()
    local nameindabox = menu.cfg.name:get()
    if(nameindabox == "") then
        name = "new config"
    else
        name = nameindabox
    end

    table.insert(base.name, name)
    table.insert(base.cfg, indacfg:save())
    database.write("peremogaboiii.base", base)
    menu.cfg.list:update(base.name)
    print("Created")
end

function delete()
    local val = menu.cfg.list:get() + 1
    if(val ~= 1 or #base.name > 1) then
        table.remove(base.name, val)
        table.remove(base.cfg, val)
    end

    database.write("peremogaboiii.base", base)
    menu.cfg.list:update(base.name)
    print("Deleted")
end

function import()
    local cfg = clipboard.get()
    indacfg:load(json.parse(base64.decode(cfg)))
    print("Imported")
end

function export()
    clipboard.set(base64.encode(json.stringify(indacfg:save())))
    print("Exported")
end

menu.builder[1].enable:set(true)

local player = {
    get_velocity = function(ent)
        return vector(entity.get_prop(ent, "m_vecVelocity")):length()
    end,

    get_vec_velocity = function(ent)
        return vector(entity.get_prop(ent, "m_vecVelocity"))
    end,

    in_air = function(_ent)
        local flags = entity.get_prop(_ent, "m_fFlags")

        if bit.band(flags, 1) == 0 then
            return true
        end
        
        return false
    end,

    in_duck = function(_ent)
        local flags = entity.get_prop(_ent, "m_fFlags")
        
        if bit.band(flags, 4) == 4 then
            return true
        end
        
        return false
    end,

    is_real = function(_ent)
        if(_ent ~= nil and entity.is_alive(_ent)) then
            return true
        else
            return false
        end
    end,

    dist_2d = function(_ent, other_player)
        if _ent ~= nil and other_player ~= nil then
            local x, y = entity.get_origin(_ent)
            local x2, y2 = entity.get_origin(other_player)
            if x ~= nil and y ~= nil and x2 ~= nil and y2 ~= nil then
                local dist = math.sqrt((x - x2)^2 + (y - y2)^2)
                return dist
            else
                return math.huge
            end
        else
            return math.huge
        end
    end,
}

local times_to_tick = function(val)
    return globals.tickinterval() * val
end

local lp_data = {
    jumping = false,
    ground = false,
    in_speed = false,
    weapon = 0,
    pos = vector(),
    left_desync_vec = vector(),
    right_desync_vec = vector(),
    slow_down = 0,
    server_side_head_pos = vector(),
}

local target_data = {
    pos = vector(),
    speed = 0,
    weapon = 0,
    en_num = 0,
}

local ind = {
    alpha = 0,
    pulse = {
        alpha = 0,
        toggle = false,
    },
    dt_alpha = 0,
    dt_state = "",
    dt_charge_alpha = 0,
    dt_wait_alpha = 0,
    scoped = {
        name = 0,
        state = 0,
        state_name = "MENU",
        doubletap = 0,
        freestand = 0,
        hideshots = 0,
    },
    hide_state = "READY",
    zoomed = false,
    tickbase = 0,
    fr_alpha = 0,
    ideal_pick = 0,
    hide_alpha = 0,
    hide_charging_alpha = 0,
    hide_ready_alpha = 0,
    fixed = false,
}

local slow_down_ind = {
    alpha = 0,
    val = 0,
    fixed = false,
    drugging = false,
    drug = false,
    addxm = 0,
    addym = 0,
    calpha = 0,
}

function update_data(cmd, lp, target)
    lp_data.ground = bit.band(entity.get_prop(lp, "m_fFlags"), 1) == 1
    lp_data.jumping = cmd.in_jump == 1
    lp_data.in_speed = bit.band(cmd.buttons, 131072) > 0
    lp_data.weapon = entity.get_classname(entity.get_prop(lp, "m_hActiveWeapon"))
    lp_data.pos = vector(entity.get_prop(lp, "m_vecOrigin"))
    lp_data.slow_down = entity.get_prop(lp, "m_flVelocityModifier") * 100
    if globals.chokedcommands() == 0 then
        lp_data.server_side_head_pos = vector(lp_data.pos.x, lp_data.pos.y, lp_data.pos.z + 70)
    end
    if target then
        target_data.pos = vector(entity.get_prop(target, "m_vecOrigin"))
        target_data.speed = vector(player.get_velocity(target))
        target_data.weapon = entity.get_classname(entity.get_prop(target, "m_hActiveWeapon"))
        target_data.en_num = target
    else
        target_data.en_num = nil
    end
end

function body_freestand(lp)
    if not player.is_real(lp) or not target_data.en_num then
        return
    end
    local l_velo = player.get_vec_velocity(lp)
    local e_velo = player.get_vec_velocity(target_data.en_num)
    local time_extra = times_to_tick(12)
    local l_pos = vector(lp_data.pos.x + l_velo.x * time_extra / 3, lp_data.pos.y + l_velo.y * time_extra / 3, lp_data.pos.z)
    local e_pos = vector(target_data.pos.x + e_velo.x * time_extra, target_data.pos.y + e_velo.y * time_extra, target_data.pos.z)
    local angle_to_enemy = calculate_angle(lp_data.pos, e_pos)
    lp_data.left_desync_vec = vector(l_pos.x + math.cos(math.rad(angle_to_enemy - 90)) * 35, l_pos.y + math.sin(math.rad(angle_to_enemy - 90)) * 35, l_pos.z + 45)
    lp_data.right_desync_vec = vector(l_pos.x + math.cos(math.rad(angle_to_enemy + 90)) * 35, l_pos.y + math.sin(math.rad(angle_to_enemy + 90)) * 35, l_pos.z + 45)
    local first_ent, damage_left = client.trace_bullet(target_data.en_num, e_pos.x, e_pos.y, e_pos.z, lp_data.left_desync_vec.x, lp_data.left_desync_vec.y, lp_data.left_desync_vec.z, true)
    local secon_ent, damage_right = client.trace_bullet(target_data.en_num, e_pos.x, e_pos.y, e_pos.z, lp_data.right_desync_vec.x, lp_data.right_desync_vec.y, lp_data.right_desync_vec.z, true)
    if damage_right > damage_left then
        return "right"
    elseif damage_right < damage_left then
        return "left"
    else
        return "none"
    end
end

function get_side_by_crosshair(cmd, lp)
    if not player.is_real(lp) or not target_data.en_num then
        return "none"
    end
    local e_pos = target_data.pos
    if not lp_data.pos or not e_pos then return false end
    local angle_to_enemy = calculate_angle(lp_data.pos, e_pos)
    local x_cam, y_cam = client.camera_angles()
    local angle = math.floor(normalize_yaw(y_cam - angle_to_enemy))
    if angle > 0 then
        return "left"
    else
        return "right"
    end
end

player.get_state = function(cmd, ent)
    local states = {
        {
            index = 6,
            condition = "crouching",
            work = function()
                return (lp_data.jumping == false and lp_data.ground == true) and cmd.in_duck == 1 or ref.fakeduck:get()
            end,
        },
        {
            index = 5,
            name = "jump-crouching",
            work = function() 
                return (lp_data.jumping == true or lp_data.ground == false) and cmd.in_duck == 1
            end,
        },
        {
            index = 4,
            name = "jumping",
            work = function() 
                return (lp_data.jumping == true or lp_data.ground == false) and cmd.in_duck == 0
            end,
        },
        {
            index = 3,
            name = "slow-walking",
            work = function() 
                return lp_data.in_speed
            end,
        },
        {
            index = 2,
            name = "moving",
            work = function() 
                return vector(entity.get_prop(ent, 'm_vecVelocity')):length2d() > 3 and bit.band(entity.get_prop(ent, "m_fFlags"), 1) == 1
            end,
        },
        {
            index = 1,
            name = "standing",
            work = function() 
                return vector(entity.get_prop(ent, 'm_vecVelocity')):length2d() < 3 
            end,
        },
    }
    for i, condition in ipairs(states) do
        if condition.work() then
            return condition.index
        end
    end
    return 0
end

local avoid_backstab = function(lp, enemy)
    if not enemy or entity.is_dormant(enemy) then
        return
    end;
    local enemy_origin = { entity.get_origin(target_data.en_num) }
    local enemy_view = { entity.get_prop(target_data.en_num, "m_vecViewOffset") }
    local eye_pos = { client.eye_position() }
    local random_wraith_shit = { enemy_origin[1] + enemy_view[1], enemy_origin[2] + enemy_view[2], enemy_origin[3] + enemy_view[3] }
    local dist = { math.abs(random_wraith_shit[1] - eye_pos[1]), math.abs(random_wraith_shit[2] - eye_pos[2]), math.abs(random_wraith_shit[3] - eye_pos[3]) }
    local l2dist = math.abs(dist[1] + dist[2])
    if l2dist > 425 then
        return
    end;
    local lp_velo = { entity.get_prop(lp, 'm_vecVelocity') }
    local enemy_velo = { entity.get_prop(target_data.en_num, 'm_vecVelocity') }
    local extra_tick = times_to_tick(16)
    local extra_pos = { eye_pos[1] + lp_velo[1] * extra_tick, eye_pos[2] + lp_velo[2] * extra_tick, eye_pos[3] + lp_velo[3] * extra_tick }
    local extra_enemy_pos = { random_wraith_shit[1] + enemy_velo[1] * extra_tick, random_wraith_shit[2] + enemy_velo[2] * extra_tick, random_wraith_shit[3] + enemy_velo[3] * extra_tick }
    local L571, L572 = client.trace_line(lp, extra_pos[1], extra_pos[2], extra_pos[3], extra_enemy_pos[1], extra_enemy_pos[2], extra_enemy_pos[3])
    local L573, L574 = client.trace_line(lp, extra_enemy_pos[1], extra_enemy_pos[2], extra_enemy_pos[3], extra_pos[1], extra_pos[2], extra_pos[3])
    local L575, L576 = client.trace_line(lp, eye_pos[1], eye_pos[2], eye_pos[3], random_wraith_shit[1], random_wraith_shit[2], random_wraith_shit[3])
    local L577, L578 = client.trace_line(lp, eye_pos[1], eye_pos[2], eye_pos[3], enemy_origin[1], enemy_origin[2], enemy_origin[3])
    local L579 = L572 == enemy or L571 == 1;
    local L580 = L574 == lp or L573 == 1;
    local L581 = L576 == enemy or L575 == 1;
    local L582 = L578 == enemy or L577 == 1;
    local enemies_weapon = target_data.weapon
    if enemies_weapon == "CKnife" and (L579 or L580 or L581 or L582) then
        return true
    end
    return false
end

local ram = {
    yaw = 0,
    manual_base = 0,
    aa_tickrate = 0,
    jitter = false,
    yaw_add = 0,
    inverted = false,
    random_add = 0,
    last_sim_time = 0,
    tick_def_off = 0,
    spin = 0,
    defensive_until = 0,
    defensive_work = false,
    pitch_min = -45,
    pitch_max = 45,
    anti_aim = {
        pitch = 0,
        yaw = 0,
        manual = 0,
        jitter = 0,
        add = 0,
        fake = 0,
        freestand = false,
        cheat_yaw = "Off",
        cheat_jitter = 0,
        cheat_body = "Off",
        random_add = 0,
        at_target = false,
        jitter_update = false,
        freestand_active = false,
        force_defensive = false,
        fl_limit = 14,
        jit_tick_left = 0,
        jit_tick_right = 0,
        fsbodyyaw = 0,
        side = false,
    },
    phase_add = 0,
    phase = 0,
    def_jitter = false,
    manual_active = 0,
    tickbase = 0,
    defensive = {
        pitch_update = false,
        pitch_phase = 0,
        local_side = "left",
    },
    anti_bruteforce = {
        last_shot = 0,
        count = 0,
        timer = 0,
    },
}

local wat_render = vector()

local function get_closest_point(A, B, P)
    a_to_p = vector(P.x - A.x, P.y - A.y, P.z - A.z)
    a_to_b = vector(B.x - A.x, B.y - A.y, B.z - A.z)

    atb2 = a_to_b.x^2 + a_to_b.y^2 + a_to_b.z^2

    atp_dot_atb = a_to_p.x*a_to_b.x + a_to_p.y*a_to_b.y + a_to_p.z*a_to_b.z
    t = atp_dot_atb / atb2
    
    return vector(A.x + a_to_b.x*t, A.y + a_to_b.y*t, A.z + a_to_b.z*t)
end

local desync = 0
local max = 0
local modifier = 0

function is_freestand(lp)
    if not lp or not target_data.en_num then return false end
    local e_pos = target_data.pos
    if not lp_data.pos or not e_pos then return false end
    local angle_to_enemy = calculate_angle(lp_data.pos, e_pos)
    local local_yaw = entity.get_prop(lp, "m_flLowerBodyYawTarget")
    local angle = math.floor(normalize_yaw(local_yaw - angle_to_enemy))
    if angle <= -89 and angle >= -91 or angle >= 89 and angle <= 91 then
        return true
    else
        return false
    end
end

local function yaw_manager(side, left, right)
    return side and left or (side and 0 or right)
end

local function normalize_pitch(val)
    if(val > 89) then
        val = val - 89 * 2
    elseif(val < -89) then
        val = val + 89 * 2
    end
    return val
end

function builder(cmd, state, tab, avoid_backstabing, lp, safehead, side_flick)
    local tickrate = globals.tickcount() - entity.get_prop(lp, "m_flSimulationTime") * 64
    local doubletap_ref = ref.dt:get() and ref.dt:get_hotkey()
    local charge_check = entity.get_prop(lp, "m_nTickBase") - globals.tickcount()
    if menu.enable:get() then
        local overlap = adata.get_overlap(true)
        local fl = entity.get_prop(lp, "m_nTickBase") - globals.tickcount()
        local is_freestanding = is_freestand(lp) and menu.aa_options.freestand_cond:get(lua.conds_no_g[state]) and menu.aa_options.freestand:get() and menu.aa_options.manual_base:get() == "None"
        ram.tickbase = fl < 0
        ram.spin = ram.spin + 20
        if ram.spin % 360 == 0 then
            ram.spin = 0
        end
        if menu.misc.fast_ladder:get() then
            fast_ladder(cmd, lp)
        end
        if menu.aa_options.left:get() or menu.aa_options.right:get() or menu.aa_options.backward:get() or menu.aa_options.forward:get() then
            ram.manual_active = 1
        end
        if ram.manual_active ~= 0 then
            manualing()
            ram.manual_active = ram.manual_active + 1
        end
        if ram.manual_active == 3 then
            ram.manual_active = 0
        end
        if menu.aa_options.defensive_always_on:get(lua.conds_no_g[state]) then
            ram.anti_aim.force_defensive = true
        else
            ram.anti_aim.force_defensive = false
        end
        if globals.curtime() * 64 < ram.defensive_until and ram.tickbase and menu.aa_options.defensive:get() and tab.defensive:get() then
            ram.defensive_work = true
        else
            ram.defensive_work = false
        end
        if globals.chokedcommands() == 0 then
            ram.aa_tickrate = ram.aa_tickrate + 1
            if tab.yaw:get() == "Slow" and not ram.defensive_work then
                if tab.double_tick_update:get() then
                    if ram.jitter then 
                        if ram.anti_aim.jit_tick_right ~= 0 then
                            ram.anti_aim.jit_tick_right = 0
                        end
                        ram.anti_aim.jit_tick_left = ram.anti_aim.jit_tick_left + 1
                        if ram.anti_aim.jit_tick_left >= (tab.tick_update:get() + 1) then
                            ram.jitter = not ram.jitter
                        end
                    else
                        if ram.anti_aim.jit_tick_left ~= 0 then
                            ram.anti_aim.jit_tick_left = 0
                        end
                        ram.anti_aim.jit_tick_right = ram.anti_aim.jit_tick_right + 1
                        if ram.anti_aim.jit_tick_right >= (tab.tick_update_second:get() + 1) then
                            ram.jitter = not ram.jitter
                        end
                    end
                else
                    if ram.anti_aim.jit_tick_left ~= 0 then
                        ram.anti_aim.jit_tick_left = 0
                        ram.anti_aim.jit_tick_right = 0
                    end
                    if ram.aa_tickrate % (tab.tick_update:get() + 1) == 0 then
                        ram.jitter = not ram.jitter
                    end
                end
            else
                ram.jitter = not ram.jitter
            end
            if menu.phase_builder.enable:get() then
                if menu.phase_builder.phase_type:get() == "Anti-bruteforce" then
                    if (globals.curtime() > (ram.anti_bruteforce.last_shot / 64) + menu.phase_builder.anti_bruteforce.seconds_to_reset:get()) and menu.phase_builder.anti_bruteforce.reset:get("Time is running out") then
                        if menu.visuals.logs:get() and ram.anti_bruteforce.count ~= 0 then
                            local ar, ag, ab = menu.visuals.logs_color1:get()
                            client.color_log(ar, ag, ab, "[Anti-bruteforce] reset due to time")
                        end
                        if menu.visuals.screen_logs:get() and ram.anti_bruteforce.count ~= 0 then
                            table.insert(for_rendering, 1, {text = "[Assembly] Anti-bruteforce reset due to timer", alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
                        end
                        ram.anti_bruteforce.count = 0
                    end
                    if ram.anti_bruteforce.count == 0 then
                        ram.phase_add = 0
                    else
                        ram.phase_add = menu.phase_builder.builder[ram.anti_bruteforce.count]:get()
                    end
                else
                    if menu.phase_builder.phase_timer.time_type:get() == "Ticks" then
                        timer = ram.aa_tickrate
                        switch_checker = menu.phase_builder.phase_timer.tick_switch:get()
                    else
                        timer = globals.curtime()
                        switch_checker = menu.phase_builder.phase_timer.second_switch:get()
                    end
                    quantity = menu.phase_builder.quantity:get()
                    ram.phase = math.ceil(timer / switch_checker) % (quantity + 1)
                    if ram.phase ~= 0 then
                        ram.phase_add = menu.phase_builder.builder[ram.phase]:get()
                    else
                        ram.phase_add = 0
                    end
                end
            elseif not ram.phase_add == 0 then
                ram.phase_add = 0
            end
        end
        if ram.jitter ~= ram.anti_aim.jitter_update then
            ram.anti_aim.random_add = client.random_int(tab.yaw_randomize:get() * -0.5, tab.yaw_randomize:get() * 0.5)
            ram.anti_aim.jitter_update = ram.jitter
        end
        if not menu.aa_options.defensive:get() or not ram.defensive_work then
            if menu.aa_options.manual_base:get() == "None" then
                ram.anti_aim.manual = 0
                ram.anti_aim.at_target = menu.aa_options.yaw_base:get()
            else
                ram.anti_aim.at_target = false
                if menu.aa_options.manual_base:get() == "Backward" then
                    ram.anti_aim.manual = 0
                elseif menu.aa_options.manual_base:get() == "Left" then
                    ram.anti_aim.manual = -90
                elseif menu.aa_options.manual_base:get() == "Right" then
                    ram.anti_aim.manual = 90
                elseif menu.aa_options.manual_base:get() == "Forward" then
                    ram.anti_aim.manual = 180
                end
            end
            if tab.pitch:get() == "Off" then
                ram.anti_aim.pitch = 0
            elseif tab.pitch:get() == "Down" then
                ram.anti_aim.pitch = 89
            elseif tab.pitch:get() == "Up" then
                ram.anti_aim.pitch = -89
            end
            if (menu.aa_options.manual_base:get() ~= "None" or is_freestanding) and menu.aa_options.static_on_manual:get() then
                ram.anti_aim.cheat_yaw = "Off"
                ram.anti_aim.add = 0
                ram.anti_aim.yaw = 0
                ram.anti_aim.jitter = 0
                if menu.aa_options.manual_base:get() == "Backward" then
                    ram.anti_aim.cheat_body = "Static"
                    ram.anti_aim.fake = 0
                else
                    ram.anti_aim.cheat_body = "Static"
                    ram.anti_aim.fake = -180
                end
            elseif tab.yaw:get() == "Center" and tab.yaw_add:get() == "Off" and tab.body_yaw:get() ~= "Smart" then
                ram.anti_aim.cheat_yaw = "Center"
                ram.anti_aim.add = 0
                ram.anti_aim.yaw = tab.yaw_default:get()
                ram.anti_aim.jitter = tab.yaw_center:get() + ram.anti_aim.random_add + ram.phase_add
                if tab.body_yaw:get() == "Jitter" then
                    ram.anti_aim.cheat_body = "Jitter"
                    ram.anti_aim.fake = tab.body_yaw_degree:get()
                elseif tab.body_yaw:get() == "Opposite" then
                    ram.anti_aim.cheat_body = "Opposite"
                    ram.anti_aim.fake = 0
                else
                    ram.anti_aim.cheat_body = "Static"
                    ram.anti_aim.fake = 0
                end
            elseif tab.yaw:get() ~= "Off" then
                ram.anti_aim.cheat_yaw = "Off"
                if tab.yaw_add:get() ~= "Off" then
                    ram.anti_aim.add = (not ram.jitter) and tab.yaw_left:get() or tab.yaw_right:get()
                else
                    ram.anti_aim.add = 0
                end
                if tab.yaw:get() == "Advanced skitter" then
                    ram.anti_aim.yaw = tab.yaw_default:get() + client.random_int(math.min(tab.yaw_center:get() + ram.phase_add - ((tab.yaw_center:get() + ram.phase_add) * 2)), tab.yaw_center:get() + ram.phase_add) + ram.anti_aim.random_add
                else
                    ram.anti_aim.yaw = tab.yaw_default:get() + (ram.jitter and (tab.yaw_center:get() + ram.phase_add) / 2 or (tab.yaw_center:get() + ram.phase_add) / -2) + ram.anti_aim.random_add
                end
                ram.anti_aim.jitter = 0
                if tab.body_yaw:get() == "Jitter" then
                    ram.anti_aim.cheat_body = "Static"
                    ram.anti_aim.fake = ram.jitter and tab.body_yaw_degree:get() or tab.body_yaw_degree:get() * -1
                elseif tab.body_yaw:get() == "Smart" then
                    max = overlap * (fl < 2 and 30 or 60)
                    modifier = normalize_yaw(ram.anti_aim.add + ram.anti_aim.yaw)
                    desync = modifier * gratio - (max * (ram.jitter and 1 or -1))
                    ram.anti_aim.cheat_body = "Static"
                    if ram.jitter then 
                        desync = math.abs(desync)
                    else
                        desync = math.abs(desync) * -1
                    end
                    ram.anti_aim.fake = math.floor(math.clamp(desync, -180, 180))
                elseif tab.body_yaw:get() == "Opposite" then
                    ram.anti_aim.cheat_body = "Opposite"
                    ram.anti_aim.fake = 0
                else
                    ram.anti_aim.cheat_body = "Static"
                    ram.anti_aim.fake = 0
                end
            else
                ram.anti_aim.cheat_yaw = "Off"
                ram.anti_aim.add = 0
                ram.anti_aim.yaw = tab.yaw_default:get()
                ram.anti_aim.jitter = 0
                ram.anti_aim.cheat_body = "Static"
                ram.anti_aim.fake = 0
            end
            ram.pitch_min = -89
            ram.anti_aim.fsbodyyaw = false
            ram.anti_aim.side = nil
            if ram.defensive.pitch_update == true then
                ram.defensive.pitch_phase = ram.defensive.pitch_phase + 1
                ram.defensive.pitch_update = false
            end
        else
            ram.anti_aim.cheat_yaw = "Off"
            ram.anti_aim.add = 0
            ram.anti_aim.jitter = 0
            ram.anti_aim.cheat_body = "Static"
            ram.anti_aim.manual = 0
            ram.anti_aim.at_target = true
            ram.anti_aim.fsbodyyaw = false
            if tab.d_pitch:get() ~= "Lerp" then
                ram.pitch_min = -89
            end
            if globals.chokedcommands() == 0 then
                if tab.d_pitch:get() == "Lerp" then
                    ram.pitch_min = math.lerp(ram.pitch_min, ram.pitch_max, globals.curtime() * 6 % 2 - 1)
                    ram.anti_aim.pitch = math.clamp(ram.pitch_min, -89, 89)
                elseif tab.d_pitch:get() == "Static" then
                    ram.anti_aim.pitch = tab.d_pitch_degree:get()
                elseif tab.d_pitch:get() == "Jitter" then
                    ram.anti_aim.pitch = ram.aa_tickrate % 2 == 0 and -80 or -60
                elseif tab.d_pitch:get() == "Random" then
                    ram.anti_aim.pitch = yaw_manager(ram.jitter, client.random_int(10, -89), client.random_int(-89, 10))
                elseif tab.d_pitch:get() == "Sway" then
                    ram.defensive.pitch_update = true
                    local sway_time = 12
                    ram.anti_aim.pitch = (math.abs(globals.tickcount() % 50 + 1 - 25) - 12.5) * 2
                    if ram.anti_aim.pitch >= 89 then
                        ram.anti_aim.pitch = 89
                    elseif ram.anti_aim.pitch <= -89 then
                        ram.anti_aim.pitch = -89
                    end
                end
                if tab.d_yaw:get() == "Forward" then
                    ram.anti_aim.yaw = 180 + tab.d_offset:get()
                    ram.anti_aim.fake = 180
                elseif tab.d_yaw:get() == "Spin" then
                    ram.anti_aim.yaw = globals.tickcount() % 18 * 20 + tab.d_offset:get()
                    ram.anti_aim.fake = 180
                elseif tab.d_yaw:get() == "180 z" then
                    ram.anti_aim.fake = 180
                    if globals.tickcount() % 18 <= 9 then
                        ram.anti_aim.yaw = globals.tickcount() % 9 * 20 + tab.d_offset:get() - 90
                    else
                        ram.anti_aim.yaw = math.abs(9 - globals.tickcount() % 9) * 20 + tab.d_offset:get() - 90
                    end
                elseif tab.d_yaw:get() == "Slow spin" then
                    ram.anti_aim.yaw = globals.tickcount() % 60 * 6 + tab.d_offset:get()
                    ram.anti_aim.fake = 180
                elseif tab.d_yaw:get() == "Sideways" then
                    if ram.aa_tickrate % (tab.d_tick_update:get() + 1) == 0 then
                        ram.def_jitter = not ram.def_jitter
                    end
                    ram.anti_aim.yaw = (ram.def_jitter and 90 or -90) + tab.d_offset:get()
                    ram.anti_aim.fake = ram.def_jitter and 180 or -180
                elseif tab.d_yaw:get() == "Random" then    
                    ram.anti_aim.yaw = math.random(-180, 180)
                    ram.anti_aim.fake = 180
                elseif tab.d_yaw:get() == "Sin" then
                    ram.anti_aim.yaw = math.sin(globals.servertickcount() / 10 * 4) * 90 + tab.d_offset:get()
                    ram.anti_aim.fake = 180
                elseif tab.d_yaw:get() == "Flick" then
                    if side_flick  == "right" then
                        ram.anti_aim.yaw = 90 + tab.d_offset:get()
                    elseif side_flick  == "left" then
                        ram.anti_aim.yaw = -90 - tab.d_offset:get()
                    else
                        ram.anti_aim.yaw = (cmd.sidemove > 0 and 90 or -90) + tab.d_offset:get()
                        ram.anti_aim.fake = cmd.sidemove > 0 and 180 or -180
                    end
                    if globals.tickcount() % 12 == 0 then
                        ram.anti_aim.yaw = ram.anti_aim.yaw * -1
                    end
                end
            end
        end
        if menu.aa_options.freestand_cond:get(lua.conds_no_g[state]) and menu.aa_options.freestand:get() and menu.aa_options.manual_base:get() == "None" then
            ram.anti_aim.freestand = true
        else
            ram.anti_aim.freestand = false
        end
        if state == 7 then
            ram.anti_aim.freestand = false
            ram.anti_aim.yaw = ram.anti_aim.yaw * -1 + 180
            ram.anti_aim.at_target = false
        end
        if safehead then
            ram.anti_aim.pitch = 89
            ram.anti_aim.cheat_yaw = "Off"
            ram.anti_aim.add = 0
            ram.anti_aim.yaw = 0
            ram.anti_aim.jitter = 0
            ram.anti_aim.cheat_body = "Static"
            ram.anti_aim.fake = 0
            ram.anti_aim.manual = 0
            ram.anti_aim.at_target = true
        end
        if avoid_backstabing then
            ram.anti_aim.pitch = 89
            ram.anti_aim.cheat_yaw = "Off"
            ram.anti_aim.add = 0
            ram.anti_aim.yaw = 180
            ram.anti_aim.jitter = 0
            ram.anti_aim.cheat_body = "Static"
            ram.anti_aim.fake = 180
            ram.anti_aim.manual = 0
            ram.anti_aim.at_target = true
        end
        if ref.hs:get_hotkey() and not (ref.fakeduck:get() or ref.dt:get_hotkey()) then
            ram.anti_aim.fl_limit = 1
        else
            ram.anti_aim.fl_limit = menu.fake_lag.limit:get()
        end
        if menu.aa_options.funny_warmup:get() then
            if (entity.get_prop(entity.get_game_rules(), "m_bWarmupPeriod") == 1) then
                ram.anti_aim.cheat_yaw = "Off"
                ram.anti_aim.add = 0
                ram.anti_aim.yaw = globals.tickcount() % 18 * 20 - 180
                ram.anti_aim.jitter = 0
                ram.anti_aim.cheat_body = "Static"
                ram.anti_aim.fake = 0
                ram.anti_aim.manual = 0
                ram.anti_aim.at_target = false
                ram.anti_aim.pitch = 0
            end
        end
    else
        ref.enabled:set(true)
        ref.yawbase:set("At targets")
        ref.yaw[1]:set("180")
        ref.yaw[2]:set(180)
        ref.pitch[1]:set("Default")
        ref.bodyyaw[1]:set("Static")
        ref.bodyyaw[2]:set(0)
        ref.pitch[1]:set("Off")
        ref.yawjitter[1]:set("Off")
        ref.fsbodyyaw:set(false)
        ref.edgeyaw:set(false)
        ref.freestand[1]:set(false)
    end
    if(globals.chokedcommands() == 0 and lp ~= nil and entity.is_alive(lp)) then
        tickbase = entity.get_prop(lp, "m_nTickBase") - globals.tickcount()
    end
end

local was_disabled = true
local shot_tick = 0
local ticking = 0

function aa_setting(cmd)
    if not menu.enable:get() then return end
    local yaw = math.floor(normalize_yaw(ram.anti_aim.add + ram.anti_aim.yaw + ram.anti_aim.manual))
    if ref.fl_enable:get() ~= true then
        ref.fl_enable:set(true)
        ref.fl_enable:set_hotkey("Always on")
    end
    if ref.fl_amount:get() ~= menu.fake_lag.amount:get() then
        ref.fl_amount:set(menu.fake_lag.amount:get())
    end
    if ref.fl_var:get() ~= menu.fake_lag.variance:get() then
        ref.fl_var:set(menu.fake_lag.variance:get())
    end
    if ref.fsbodyyaw:get() ~= ram.anti_aim.fsbodyyaw then
        ref.fsbodyyaw:set(ram.anti_aim.fsbodyyaw)
    end
    if ref.yaw[1]:get() ~= "180" then
        ref.yaw[1]:set(180)
    end
    if ref.yaw[2]:get() ~= math.floor(yaw) then
        ref.yaw[2]:set(math.floor(yaw))
    end
    if ref.pitch[1]:get() ~= "Custom" then
        ref.pitch[1]:set("Custom")
    end
    if ref.pitch[2]:get() ~= math.floor(ram.anti_aim.pitch) then
        ref.pitch[2]:set(math.floor(ram.anti_aim.pitch))
    end
    if ref.bodyyaw[1]:get() ~= ram.anti_aim.cheat_body then
        ref.bodyyaw[1]:set(ram.anti_aim.cheat_body)
    end
    if ref.fl_limit:get() ~= ram.anti_aim.fl_limit then
        ref.fl_limit:set(ram.anti_aim.fl_limit)
    end
    local fake = math.clamp(ram.anti_aim.fake, -180, 180)
    if ref.bodyyaw[2]:get() ~= fake then
        ref.bodyyaw[2]:set(fake)
    end
    if ref.yawjitter[1]:get() ~= ram.anti_aim.cheat_yaw then
        ref.yawjitter[1]:set(ram.anti_aim.cheat_yaw)
    end
    if ref.yawjitter[2]:get() ~= math.floor(ram.anti_aim.jitter) then
        ref.yawjitter[2]:set(normalize_yaw(math.floor(ram.anti_aim.jitter)))
    end
    if (ref.yawbase:get() == "At targets") ~= ram.anti_aim.at_target then
        if ram.anti_aim.at_target then
            ref.yawbase:set("At targets")
        else
            ref.yawbase:set("Local view")
        end
    end
    if ram.anti_aim.freestand_active ~= ram.anti_aim.freestand then
        if ram.anti_aim.freestand then
            ref.freestand[1]:set(true)
            ref.freestand[1]:set_hotkey("Always On")
        else
            ref.freestand[1]:set(false)
            ref.freestand[1]:set_hotkey("On hotkey")
        end
        ram.anti_aim.freestand_active = ram.anti_aim.freestand
    end
    local doubletap_ref = ref.dt:get() and ref.dt:get_hotkey() and not ref.fake_duck:get()
    if doubletap_ref then
        if globals.chokedcommands() == 0 then
            if ref.quickpeek:get_hotkey() and ref.quickpeek:get() and ram.tickbase then 
                ind.dt_state = "IDEAL PICK"
            elseif ram.tickbase and not ref.fakeduck:get() then
                ind.dt_state = "READY"
            elseif globals.tickcount() % 16 > 4 or ref.fakeduck:get() then
                ind.dt_state = "WAIT"
            end
        end
    else
        ind.dt_state = "WAIT"
    end
    if ram.tickbase or not ref.hs:get_hotkey() then
        ind.hide_state = "READY"
    else
        ind.hide_state = "CHARGING"
    end
    if ram.anti_aim.force_defensive and ram.tickbase then
        if globals.chokedcommands() == 0 then
            if globals.tickcount() % 16 <= 1 then
                cmd.force_defensive = true
                ram.defensive_until = globals.curtime() * 64 + 12
            end
        end
        if globals.tickcount() % 16 <= 12 then
            ind.dt_state = "ACTIVE"
            ind.hide_state = "ACTIVE"
        end
        if ref.quickpeek:get_hotkey() and ref.quickpeek:get() then 
            ind.dt_state = "IDEAL PICK"
        end
    end
end

function charging(lp)
    if menu.misc.dt_recharge:get() then
        if(globals.chokedcommands() == 0 and lp ~= nil and entity.is_alive(lp)) then
            tickbase = entity.get_prop(lp, "m_nTickBase") - globals.tickcount()
        end
        local doubletap_ref = ref.dt:get() and ref.dt:get_hotkey() and not ref.fake_duck:get()
        if not doubletap_ref then
            was_disabled = true
        end
        if tickbase == nil then return end
        if (doubletap_ref or ref.hs:get_hotkey()) and tickbase > 0 and was_disabled then
            ref.aimbot:override(false)
            was_disabled = false
            ticking = 0
        else
            local lp_weapon = entity.get_player_weapon(lp)
            if lp_weapon ~= nil then
                local weapon_id = bit.band(entity.get_prop(entity.get_player_weapon(lp), "m_iItemDefinitionIndex"), 0xFFFF)
                if weapon_id == 64 then
                    ref.aimbot:override(true)
                    if ticking <= 2 then
                        ticking = ticking + 1
                    end
                    if ticking <= 1 then
                        ref.aimbot:override(false)
                    else
                        ref.aimbot:override(true)
                    end
                else
                    ref.aimbot:override(true)
                end
            end
        end
    end
end

function aim_hit(e)
    if(menu.visuals.logs:get()) and main_massive_logs[e.id] ~= nil then
        local sht_info = main_massive_logs[e.id]
        local ar, ag, ab = menu.visuals.logs_color1:get()
        local r, g, b = menu.visuals.logs_color2:get()
        local hitgroup = sht_info.hitbox
        local tname = entity.get_player_name(sht_info.target)
        local dmg = sht_info.damage
        local bt = sht_info.backtrack
        local ht = math.floor(sht_info.hitchance)
        local test_frst = "Hit \0"
        local realdmg = sht_info.target_hp - entity.get_prop(sht_info.target, "m_iHealth")
        if entity.get_prop(sht_info.target, "m_iHealth") <= 0 then
            if menu.visuals.screen_logs:get() then
                table.insert(for_rendering, 1, {text = "[Assembly] killed " .. tname .. " in the " .. hitgroup, alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
            end
            client.color_log(ar, ag, ab, "damage given to \0")
            client.color_log(r, g, b, tname .. "\0")
            client.color_log(ar, ag, ab, "'s \0")
            client.color_log(r, g, b, hitgroup .. " \0")
            client.color_log(ar, ag, ab, "~ \0")
            client.color_log(r, g, b, dmg .. " \0")
        else
            if menu.visuals.screen_logs:get() then
                table.insert(for_rendering, 1, {text = "[Assembly] damage given to " .. tname .. " for " .. realdmg .. " (" .. dmg .. ")", alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
            end
            client.color_log(ar, ag, ab, "damage given to \0")
            client.color_log(r, g, b, tname .. "\0")
            client.color_log(ar, ag, ab, "'s \0")
            client.color_log(r, g, b, hitgroup .. " \0")
            client.color_log(ar, ag, ab, "~ \0")
            client.color_log(r, g, b, realdmg .. " (" .. dmg .. ") \0")
        end
        client.color_log(ar, ag, ab, "(hc: \0")
        client.color_log(r, g, b, ht .. "% \0")
        client.color_log(ar, ag, ab, "~ bt:\0 ")
        client.color_log(r, g, b, bt .. "\0")
        client.color_log(ar, ag, ab, " ~ rhp:\0 ")
        client.color_log(r, g, b, entity.get_prop(sht_info.target, "m_iHealth") .. "\0")
        client.color_log(ar, ag, ab, ")")
        main_massive_logs = {}
    end
end

function aim_miss(e)
    if(menu.visuals.logs:get()) and main_massive_logs[e.id] ~= nil then
        local ar, ag, ab = menu.visuals.logs_color1:get()
        local r, g, b = menu.visuals.logs_color3:get()
        local sht_info = main_massive_logs[e.id]
        local reason = e.reason
        local tname = entity.get_player_name(sht_info.target)
        local hitbox = sht_info.hitbox
        local bt = sht_info.backtrack
        local dmg = sht_info.damage
        local ht = math.floor(sht_info.hitchance)
        client.color_log(ar, ag, ab, "missed in \0")
        client.color_log(r, g, b, tname .. "'s \0")
        client.color_log(r, g, b, hitbox .. "\0")
        client.color_log(ar, ag, ab, " due to \0")
        client.color_log(r, g, b, reason .. " \0")
        client.color_log(ar, ag, ab, "(hc: \0")
        client.color_log(r, g, b, ht .. "% \0")
        client.color_log(ar, ag, ab, " ~ dmg: \0")
        client.color_log(r, g, b, dmg .. " \0")
        client.color_log(ar, ag, ab, " ~ bt: \0")
        client.color_log(r, g, b, bt .. "\0")
        client.color_log(ar, ag, ab, ")")
        if menu.visuals.screen_logs:get() then
            table.insert(for_rendering, 1, {text = "[Assembly] missed in " .. tname .. "'s " .. hitbox ..  " for " .. dmg, alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
        end
        main_massive_logs = {}
    end
end

function reset_tick()
    ram.aa_tickrate = 1
    ram.tick_def_off = 0
end

function aim_fire(e)
    local tickrate = client.get_cvar("cl_cmdrate") or 64
    local ticks = globals.tickcount() - e.tick
    main_massive_logs[e.id] = {
        hitbox = hitgroup_names[e.hitgroup + 1],
        damage = e.damage,
        backtrack = ticks,
        target = e.target,
        hitchance = e.hit_chance,
        target_hp = entity.get_prop(e.target, "m_iHealth"),
    }
    reset_tick()
end

function set_on()
    local players = entity.get_players(false)
    local lp = entity.get_local_player()
    if #players > 1 then
        for i, player in ipairs(players) do
            team_num_p = entity.get_prop(player, "m_iTeamNum")
            team_num_lp = entity.get_prop(lp, "m_iTeamNum")
            if team_num_lp == team_num_p and menu.misc.teammate_whitelist:get() then
                plist.set(player, "Allow shared ESP updates", true)
            else
                plist.set(player, "Allow shared ESP updates", false)
            end
        end
    end
end

local render = {
    text = function(x, w, r, g, b, a, flags, max_width, texting)
        renderer.text(x, w, r, g, b, a, flags, max_width, texting)
    end,
    measure_text = function(flags, texting)
        if(renderer.measure_text("-", "oh shit") == renderer.measure_text(flags, "oh shit")) then
            texting = string.upper(texting)
        end
        return renderer.measure_text(flags, texting)
    end,
    rounded_rectangle = function(x, y, w, h, r, g, b, a, radius)
        y = y + radius
        local data_circle = {
            {x + radius, y, 180},
            {x + w - radius, y, 90},
            {x + radius, y + h - radius * 2, 270},
            {x + w - radius, y + h - radius * 2, 0},
        }
    
        local data = {
            {x + radius, y, w - radius * 2, h - radius * 2},
            {x + radius, y - radius, w - radius * 2, radius},
            {x + radius, y + h - radius * 2, w - radius * 2, radius},
            {x, y, radius, h - radius * 2},
            {x + w - radius, y, radius, h - radius * 2},
        }
    
        for _, data in next, data_circle do
            renderer.circle(data[1], data[2], r, g, b, a, radius, data[3], 0.25)
        end
    
        for _, data in next, data do
            renderer.rectangle(data[1], data[2], data[3], data[4], r, g, b, a)
        end
    end,
    rounded_outline = function(x, y, w, h, r, g, b, a, thickness, radius)
        renderer.rectangle(x + radius, y, w - radius * 2, thickness, r, g, b, a)
        renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius * 2, r, g, b, a)
        renderer.rectangle(x, y + radius, thickness, h - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + h - thickness, w - radius * 2, thickness, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
        renderer.circle_outline(x - radius + w, y + radius, r, g, b, a, radius, 270, 0.25, thickness)
        renderer.circle_outline(x + radius, y - radius + h, r, g, b, a, radius, 90, 0.25, thickness)
        renderer.circle_outline(x - radius + w, y - radius + h, r, g, b, a, radius, 0, 0.25, thickness)
    end,
}

function render_logs()
    if menu.visuals.screen_logs:get() then
        local add_y = 0
        local const_x, const_y = client.screen_size()
        local x, y = const_x / 2, const_y / 2 + const_y / 4
        local r, g, b, a = menu.visuals.screen_log_color:get()
        if #for_rendering >= 1 then
            for i, log in ipairs(for_rendering) do
                log.alpha = math.lerp(log.alpha, ((globals.curtime() * 64 - log.tick < 64 * 4) or i > 5) and 255 or 0, 0.02)
                local y2 = 0
                local y3 = 0
                local y = const_y / 2 + 230
                y2 = y + add_y
                y3 = const_y - y2
                y = const_y - y3 * log.alpha / 255
                local sizex, sizey = render.measure_text(flags, log.text)
                render.rounded_rectangle(x - sizex / 2 - 10, y + add_y - 10, sizex + 20, sizey + 10, 0,0,0, a * 205 * log.alpha / 255 / 255, 8)
         --       render.rounded_outline(x - sizex / 2 - 10, y + add_y - 10, sizex + 20, sizey + 10, r, g, b, a * 255 * log.alpha / 255 / 255, 2, 8)
                renderer.circle(x - sizex / 2 + 15 + log.randomize + (255 - log.alpha) / 5,  y + add_y - 10, r, g, b, log.alpha, 2, 0, 1)
                renderer.circle_outline(x - sizex / 2 + 15 + log.randomize + (255 - log.alpha) / 5,  y + add_y - 10, r, g, b, log.alpha, 4, 0, 1, 1)
                if log.randomize > 50 then
                    renderer.circle(x - sizex / 2 - 10,  y + add_y + log.randomize / 20 - (255 - log.alpha) / 25.5 - 5, r, g, b, log.alpha, 3, 0, 1)
                    renderer.circle_outline(x - sizex / 2 - 10,  y + add_y + log.randomize / 20 - (255 - log.alpha) / 25.5 - 5, r, g, b, log.alpha, 6, 0, 1, 1)
                else
                    renderer.circle(x + sizex / 2 + 10,  y + add_y + log.randomize / 20 + log.alpha / 25.5, r, g, b, log.alpha, 3, 0, 1)
                    renderer.circle_outline(x + sizex / 2 + 10,  y + add_y + log.randomize / 20 + log.alpha / 25.5, r, g, b, log.alpha, 6, 0, 1, 1)
                end
                renderer.circle_outline(x + sizex / 2 - 25 + (255 - log.alpha) / 10,  y + add_y + sizey, r, g, b, log.alpha, 3, 0, 1, 2)
                renderer.circle(x - sizex / 2 + 105 - log.randomize,  y + add_y + sizey + 2, r, g, b, log.alpha, 2, 0, 1)
                renderer.circle_outline(x - sizex / 2 + 105 - log.randomize,  y + add_y + sizey + 2, r, g, b, log.alpha, 5, 0, 1, 2)
                render.text(x, y + add_y, 255, 255, 255, log.alpha, "c", 0, log.text)
                add_y = add_y + (20) * log.alpha / 255
                if((globals.curtime() * 64 - log.tick > 64 * 6 and y + add_y > const_y - 25) or y + add_y > const_y + 25) then
                    table.remove(for_rendering, i)
                end
            end
        end
    end
end

function watermark()
    local x, y = client.screen_size()
    local Assembly_exp_width = render.measure_text("", "Assembly experimental")
    local Assembly_width = render.measure_text("", "Assembly ")
    render.text(x / 2 - Assembly_exp_width / 2, y - 25, 200, 200, 230, 200, "", 0, "Assembly")
    render.text(x / 2 - Assembly_exp_width / 2 + Assembly_width, y - 25, 200, 100, 100, 200, "", 0, "experimental")
end

local anim = {}

local math_hundred_floor = function(valu)
    return (math.floor(valu * 100) / 100)
end

anim.default = function(tog, val, towhat, speed, if_not_tog)
    local wanted_frametime = 80
    local current_frametime = 1 / globals.frametime()
    local percent = wanted_frametime / current_frametime
    if(tog) then
        if(towhat == 255) then
            if(val > 235) then
                val = 255
            else
                if(val < towhat) then
                    val = val + globals.frametime() * speed * 1.5 * 64
                end
                if(val > towhat) then
                    val = val - globals.frametime() * speed * 1.5 * 64
                end
            end
        else
            if(math.floor(val / 10) == math.floor(towhat / 10)) then
                val = towhat
            else
                if(val < towhat) then
                    val = val + globals.frametime() * speed * 2 * 64
                end
                if(val > towhat) then
                    val = val - globals.frametime() * speed * 2 * 64
                end
            end
        end
    else
        if(math_hundred_floor(val) <= math_hundred_floor(if_not_tog)) then
            val = if_not_tog
        end
        if(math_hundred_floor(val) > if_not_tog) then
            val = val - speed * percent
        end
    end
    return math.floor(val)
end

function indicators(lp)
    --гетается экран
    local x, y = client.screen_size()
    --проверки на наличие и живность локалплеера и открытие менюшки
    if not (lp and entity.is_alive(lp)) and not ui.is_menu_open() then return end
    --проверка на даблтап
    local doubletap_ref = ref.dt:get() and ref.dt:get_hotkey()
    --проверка на зум
    if(lp ~= nil and entity.is_alive(lp)) then
        if(entity.get_prop(lp, "m_bIsScoped") == 1) then
            ind.zoomed = true
        else
            ind.zoomed = false
        end
    else
        ind.zoomed = false
    end
    if not lp then
        ind.scoped.state_name = "MENU"
    end
    --стейт даблтапа чтоб красиво было
    if ind.dt_state ~= "" then
        ind.add_state = " " .. ind.dt_state
    else
        ind.add_state = ""
    end
    --получается ширина всех надписей
    local x_Assembly_lua = render.measure_text("-", "Assembly.LUA")
    local x_state = render.measure_text("-", ind.scoped.state_name)
    local x_dt = render.measure_text("-", "DT" .. ind.add_state)
    local x_rapid = render.measure_text("-", "DT ")
    local hideshots = render.measure_text("-", "AAOS " .. ind.hide_state)
    local x_hide = render.measure_text("-", "AAOS ")
    local x_freestand = render.measure_text("-", "DIRECTION")
    --сдвиг справа-налево в зависимости от скопа умноженный на 100 чтоб math.lerp хорошо работал
    ind.scoped.name = math.ceil(math.lerp(ind.scoped.name, ind.zoomed and 0 or (x_Assembly_lua + 10) * 100, 0.05))
    ind.scoped.state = math.ceil(math.lerp(ind.scoped.state, ind.zoomed and 0 or (x_state + 10) * 100, 0.05))
    ind.scoped.doubletap = math.ceil(math.lerp(ind.scoped.doubletap, ind.zoomed and 0 or (x_dt + 10) * 100, 0.05))
    ind.scoped.freestand = math.ceil(math.lerp(ind.scoped.freestand, ind.zoomed and 0 or (x_freestand + 10) * 100, 0.05))
    ind.scoped.hideshots = math.ceil(math.lerp(ind.scoped.hideshots, ind.zoomed and 0 or (hideshots + 10) * 100, 0.05))
    --отдвиг игрека и фикс ибо мне лень
    y_s = y / 2 + menu.visuals.indicator_y:get() - 35
    --рендер аннести + даймонд
    render.text(x / 2 - ind.scoped.name / 100 / 2 + 5, y_s + 35, 255, 255, 255, 225, "-", 0, "Assembly.LUA")
    --рендер мувинг стендинг джампинг крч кондишна
    render.text(x / 2 - ind.scoped.state / 100 / 2 + 5, y_s + 45, 255, 255, 255, 225, "-", 0, ind.scoped.state_name)
    --прозрачность биндов
    ind.dt_alpha = math.ceil(math.lerp(ind.dt_alpha, (doubletap_ref and 255 or 0) * 100, 0.1))
    ind.hide_alpha = math.ceil(math.lerp(ind.hide_alpha, (ref.hs:get_hotkey() and not doubletap_ref and 255 or 0) * 100, 0.1))
    ind.fr_alpha = math.ceil(math.lerp(ind.fr_alpha, (menu.aa_options.freestand:get() and 255 or 0) * 100, 0.1))
    --прозрачность стейтов дт
    ind.ideal_pick = anim.default(ind.dt_state == "IDEAL PICK", ind.ideal_pick, 255, 15, 0)
    ind.dt_charge_alpha = anim.default(ind.dt_state == "READY" or ind.dt_state == "ACTIVE", ind.dt_charge_alpha, 255, 15, 0)
    ind.dt_wait_alpha = anim.default(ind.dt_state == "WAIT", ind.dt_wait_alpha, 255, 15, 0)
    --прозрачность стейтов оншотов
    ind.hide_charging_alpha = anim.default(ind.hide_state == "CHARGING", ind.hide_charging_alpha, 255, 15, 0)
    ind.hide_ready_alpha = anim.default(ind.hide_state ~= "CHARGING", ind.hide_ready_alpha, 255, 15, 0)
    --адд игрик чтоб бинды смещались а не на одном месте рендерились
    local add_y = 0
    if math.ceil(ind.dt_alpha) > 0 then -- проверка на прозрачность чтоб не рендерить лишний раз чего попало
        --рендер даблтапа
        render.text(x / 2 - ind.scoped.doubletap / 100 / 2 + 5 + x_rapid, y_s + 55, 240, 200, 50, ind.dt_alpha / 100 * 225 / 255, "-", 0, string.sub("IDEAL PICK", 1, math.floor(string.len("IDEAL PICK") * ind.ideal_pick / 255) + 0.5))
        render.text(x / 2 - ind.scoped.doubletap / 100 / 2 + 5, y_s + 55, 255, 255, 255, ind.dt_alpha / 100 * 225 / 255, "-", 0, "DT ")
        if ind.dt_state == "ACTIVE" then --цвета стейта
            rm, gm, bm = 211, 255, 50
        else
            rm, gm, bm = 150, 255, 150
        end
        render.text(x / 2 - ind.scoped.doubletap / 100 / 2 + 5 + x_rapid, y_s + 55, rm, gm, bm, ind.dt_alpha / 100 * ind.dt_charge_alpha / 255 * 225 / 255, "-", 0, string.sub(ind.dt_state == "ACTIVE" and "ACTIVE" or "READY", 1, math.floor(string.len(ind.dt_state == "ACTIVE" and "ACTIVE" or "READY") * ind.dt_charge_alpha / 255) + 0.5))
        render.text(x / 2 - ind.scoped.doubletap / 100 / 2 + 5 + x_rapid, y_s + 55, 255, 15, 15, ind.dt_alpha / 100 * ind.dt_wait_alpha / 255 * 225 / 255, "-", 0, string.sub("WAIT", 1, math.floor(string.len("WAIT") * ind.dt_wait_alpha / 255) + 0.5))
        add_y = add_y + 10 * math.ceil(ind.dt_alpha) / 100 / 255
    end
    if math.ceil(ind.hide_alpha) > 0 then
        --рендер оншотов, аналогично дт
        render.text(x / 2 - ind.scoped.hideshots / 100 / 2 + 5, y_s + 55, 255, 255, 255, ind.hide_alpha / 100 * 225 / 255, "-", 0, "AAOS ")
        render.text(x / 2 - ind.scoped.hideshots / 100 / 2 + 5 + x_hide, y_s + 55, 255, 15, 15, ind.hide_alpha / 100 * 225 / 255 * ind.hide_charging_alpha / 255, "-", 0, string.sub("CHARGING", 1, math.floor(string.len("CHARGING") * ind.hide_charging_alpha / 255) + 0.5))
        if ind.hide_state == "ACTIVE" then
            rh, gh, bh = 211, 255, 50
        else
            rh, gh, bh = 150, 255, 150
        end
        render.text(x / 2 - ind.scoped.hideshots / 100 / 2 + 5 + x_hide, y_s + 55, rh, gh, bh, ind.hide_alpha / 100 * 225 / 255 * ind.hide_ready_alpha / 255, "-", 0, string.sub(ind.hide_state == "ACTIVE" and "ACTIVE" or "READY", 1, math.floor(string.len(ind.dt_state == "ACTIVE" and "ACTIVE" or "READY") * ind.hide_ready_alpha / 255) + 0.5))
        add_y = add_y + 10 * math.ceil(ind.hide_alpha) / 100 / 255
    end
    if math.ceil(ind.fr_alpha) > 0 then
        --рендер фристенда
        render.text(x / 2 - ind.scoped.freestand / 100 / 2 + 5, y_s + 55 + math.floor(add_y), 255, 255, 255, ind.fr_alpha / 100 * 225 / 255, "-", 0, string.sub("DIRECTION", 1, math.floor(string.len("DIRECTION") * ind.fr_alpha / 255 / 100) + 1))
    end
end

function slow_down(lp)
    local x = menu.visuals.slow_down.x
    local y = menu.visuals.slow_down.y
    if not player.is_real(lp) then
        slow_down_ind.val = 100
    else
        slow_down_ind.val = lp_data.slow_down
    end
    slow_down_ind.alpha = math.ceil(math.lerp(slow_down_ind.alpha, ((lp_data.slow_down < 100 and player.is_real(lp)) or ui.is_menu_open()) and 255 * 100 or 0, 0.1))
    local xsize, ysize = render.measure_text("", "Slowed down: 100 %")
    local mx, my = ui.mouse_position()
    xsize = xsize * 2
    if(slow_down_ind.alpha > 0) then
        local acr, acb, acg, aca = menu.visuals.slow_down.color:get()
        render.rounded_rectangle(x:get() - xsize / 2, y:get(), xsize, 6, 15,15,15, slow_down_ind.alpha / 255 * 100 / 100, 2)
        render.rounded_rectangle(x:get() - xsize / 2 + 1, y:get() + 1, (xsize - 2) / 100 * math.floor(slow_down_ind.val), 4, acr, acb, acg, slow_down_ind.alpha / 100, 2)
        render.text(x:get(), y:get() - ysize, 255,255,255, slow_down_ind.alpha / 100, "c", 0, "Slowed down: " .. math.floor(slow_down_ind.val) .. "%")
    end
    
    if(ui.is_menu_open()) then
        if(client.key_state(0x01)) then
            if(mx > x:get() - 50 and mx < x:get() + 50 and my > y:get() - 14 and my < y:get() + 24) then
                slow_down_ind.drugging = true
            end
        else
            slow_down_ind.drugging = false
        end
    else
        slow_down_ind.drugging = false
    end

    slow_down_ind.calpha = math.ceil(math.lerp(slow_down_ind.calpha, (mx > x:get() - 50 and mx < x:get() + 50 and my > y:get() - 24 and my < y:get() + 24) and 255 * 100 or 0, 0.1))
    
    if(slow_down_ind.calpha > 0) then
        render.text(x:get(), y:get() + ysize * 2 - 4, 255,255,255, slow_down_ind.alpha * slow_down_ind.calpha / 255 / 100 / 100, "c", 0, "Click RMB to centralize this indicator")
    end
    if(mx > x:get() - 50 and mx < x:get() + 50 and my > y:get() - 24 and my < y:get() + 24) then
        local scrx, scry = client.screen_size()
        if(client.key_state(0x02)) then
            x:set(scrx / 2)
        end
    end

    if(slow_down_ind.drug ~= slow_down_ind.drugging) then
        slow_down_ind.addxm = mx - x:get()
        slow_down_ind.addym = my - y:get()
        slow_down_ind.drug = slow_down_ind.drugging
    end
    if(slow_down_ind.drugging) then
        if(mx - slow_down_ind.addxm < 0) then
            x:set(0)
        else
            x:set(mx - slow_down_ind.addxm)
        end
        if(mx - slow_down_ind.addym < 0) then
            y:set(0)
        else
            y:set(my - slow_down_ind.addym)
        end
    end
end

function paint()
    set_menu_builder()
    watermark()
    if not menu.enable:get() then return end
    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then
        for_rendering = {}
    end
    if menu.visuals.screen_logs:get() then
        render_logs()
    end
    if menu.visuals.slow_down.enable:get() then
        slow_down(lp)
        if slow_down_ind.fixed ~= false then
            slow_down_ind.fixed = false
        end
    else
        if slow_down_ind.fixed ~= true then
            slow_down_ind = {
                alpha = 0,
                val = 0,
                fixed = true,
                drugging = false,
                drug = false,
                calpha = 0,
            }
        end
    end
    if menu.visuals.indicators:get() then
        indicators(lp)
        if ind.fixed ~= false then
            ind.fixed = false
        end
    else
        if ind.fixed ~= true then
            ind = {
                alpha = 0,
                pulse = {
                    alpha = 0,
                    toggle = false,
                },
                dt_alpha = 0,
                dt_state = "",
                dt_charge_alpha = 0,
                dt_wait_alpha = 0,
                scoped = {
                    name = 0,
                    state = 0,
                    state_name = "MENU",
                    doubletap = 0,
                    freestand = 0,
                    hideshots = 0,
                },
                hide_state = "READY",
                zoomed = false,
                tickbase = 0,
                fr_alpha = 0,
                ideal_pick = 0,
                hide_alpha = 0,
                hide_charging_alpha = 0,
                hide_ready_alpha = 0,
                fixed = true,
            }
        end
    end
    watermark_top_radar()
end


aspect_ratio()
menu.enable:set_callback(aspect_ratio)
menu.visuals.aspect_ratio_type:set_callback(aspect_ratio)
menu.visuals.normal_aspect_ratio:set_callback(aspect_ratio)
menu.visuals.newcomer_aspect_ratio:set_callback(aspect_ratio)

client.set_event_callback("paint_ui", paint)

client.set_event_callback("aim_miss", aim_miss)
client.set_event_callback("aim_hit", aim_hit)
client.set_event_callback("aim_fire", aim_fire)

function reset()
    for_rendering = {}
end

client.set_event_callback("round_prestart", reset)

function setup_commanding(cmd)
    if not menu.enable:get() then return end
    local lp = entity.get_local_player()
    update_data(cmd, lp, client.current_threat())
    local state = player.get_state(cmd, lp)
    ind.scoped.state_name = menu.aa_options.manual_base:get() == "None" and ("-" .. string.upper(lua.ind_conds[player.get_state(cmd, lp)]) .. "-") or ("-" .. string.upper(menu.aa_options.manual_base:get()) .. "-")
    local avoid_backstabing = false
    local safe_head = false
    local side_flick = "none"
    if menu.misc.avoid_backstab:get() then
        if target_data.en_num ~= nil then
            avoid_backstabing = avoid_backstab(lp, target_data.en_num)
        end
    end
    if(menu.builder[state + 1].enable:get()) then
        tab = menu.builder[state + 1]
    else
        tab = menu.builder[1]
    end
    if menu.aa_options.safe_head:get() then
        if lp_data.jumping or not lp_data.ground then
            if lp_data.weapon == "CKnife" or lp_data.weapon == "CWeaponTaser" then
                safe_head = true
            end
        end
    end
    if menu.aa_options.defensive:get() then
        side_flick = get_side_by_crosshair(cmd, lp)
    end
    builder(cmd, state, tab, avoid_backstabing, lp, safe_head, side_flick)
    aa_setting(cmd)
    charging(lp)
end

function pre_rendering()
    if #menu.other.animfix:get() == 0 then return end
    if not menu.enable:get() then return end
    lp = entity.get_local_player()
    if lp == nil or not entity.is_alive(lp) then return end
    local local_index = c_entity.new(lp)
    local local_anim_state = local_index:get_anim_state()
    if menu.other.animfix:get("Legs") then
        if menu.other.leg_breaker:get() == "Static" then
            entity.set_prop(lp, "m_flPoseParameter", 1, 0)
        elseif menu.other.leg_breaker:get() == "Jitter" then
            if globals.tickcount() % 3 <= 1 then
                entity.set_prop(lp, "m_flPoseParameter", 1, 0)
            end
        elseif menu.other.leg_breaker:get() == "Elusive" then
            entity.set_prop(lp, "m_flPoseParameter", client.random_int(360-90, 360) / 360, 0)
        else
            entity.set_prop(lp, "m_flPoseParameter", client.random_int(350, 370) / 360, 7)
            entity.set_prop(lp, "m_flPoseParameter", 1, 0)
        end
    end
    if menu.other.animfix:get("Jumping") then
        if menu.other.jumping:get() == "Static" then
            entity.set_prop(lp, "m_flPoseParameter", 1, 6)
        else
            entity.set_prop(lp, "m_flPoseParameter", client.random_int(0, 10) / 10, 6)
        end
    end
    if menu.other.animfix:get("Dirty sprite") then
        local self_anim_overlay = local_index:get_anim_overlay(12)
        if not self_anim_overlay then return end
        if menu.other.sprite:get() == "Static" then
            self_anim_overlay.weight = 1
        elseif menu.other.sprite:get() == "By velocity" then
            self_anim_overlay.weight = player.get_velocity(lp) / 30
        else
            self_anim_overlay.weight = client.random_int(0, 10) / 3
        end
    end
end

function round_start()
    if not menu.enable:get() then return end
    set_on()
    reset_tick()
    reset()
    if menu.phase_builder.phase_type:get() == "Anti-bruteforce" and menu.phase_builder.enable:get() and menu.phase_builder.anti_bruteforce.reset:get("Round start") then
        ram.anti_bruteforce.count = 0
    end
end

function enemy_death(e)
    if not menu.enable:get() then return end
    local lp = entity.get_local_player()
    local killer = client.userid_to_entindex(e.attacker)
    local died = client.userid_to_entindex(e.userid)
    if died == lp and menu.phase_builder.anti_bruteforce.reset:get("Local dead") then
        if menu.phase_builder.phase_type:get() == "Anti-bruteforce" and menu.phase_builder.enable:get() then
            if menu.visuals.screen_logs:get() and ram.anti_bruteforce.count ~= 0 then
                table.insert(for_rendering, 1, {text = "[Assembly] Anti-bruteforce reset due to local dead", alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
            end
            ram.anti_bruteforce.count = 0
            return
        end
    end
    if tonumber(killer) == tonumber(lp) and entity.is_enemy(died) then
        if menu.phase_builder.phase_type:get() == "Anti-bruteforce" and menu.phase_builder.enable:get() and menu.phase_builder.anti_bruteforce.reset:get("Killing the enemy (by you)") then
            if menu.visuals.screen_logs:get() and ram.anti_bruteforce.count ~= 0 then
                table.insert(for_rendering, 1, {text = "[Assembly] Anti-bruteforce reset due to killing the enemy", alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
            end
            if menu.visuals.logs:get() and ram.anti_bruteforce.count ~= 0 then
                local ar, ag, ab = menu.visuals.logs_color1:get()
                client.color_log(ar, ag, ab, "[Anti-bruteforce] reset due to killing the enemy")
            end
            ram.anti_bruteforce.count = 0
            return
        end
    end
    if entity.is_enemy(died) then
        if menu.phase_builder.phase_type:get() == "Anti-bruteforce" and menu.phase_builder.enable:get() and menu.phase_builder.anti_bruteforce.reset:get("Enemy death") then
            if menu.visuals.logs:get() and ram.anti_bruteforce.count ~= 0 then
                local ar, ag, ab = menu.visuals.logs_color1:get()
                client.color_log(ar, ag, ab, "[Anti-bruteforce] reset due to enemy death")
            end
            if menu.visuals.screen_logs:get() and ram.anti_bruteforce.count ~= 0 then
                table.insert(for_rendering, 1, {text = "[Assembly] Anti-bruteforce reset due to enemy death", alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
            end
            ram.anti_bruteforce.count = 0
            return
        end
    end
end

function impact_anti_brute(e)
    local lp = entity.get_local_player()
    local enemy = client.userid_to_entindex(e.userid)
    if entity.is_dormant(enemy) or not entity.is_enemy(enemy) then
        return
    end
    local l_pos = lp_data.server_side_head_pos
    local e_head_x, e_head_y, e_head_z = entity.hitbox_position(enemy, 1)
    local e_pos = vector(e_head_x, e_head_y, e_head_z)
    local shot_pos = vector(e.x, e.y, e.z)

    local closest_point = get_closest_point(e_pos, shot_pos, l_pos)
    
    local delta = math.sqrt((l_pos.x - closest_point.x)^2 + (l_pos.y - closest_point.y)^2 + (l_pos.z - closest_point.z)^2)
    if delta < 100 then
        if ram.anti_bruteforce.last_shot ~= globals.tickcount() then
            if ram.anti_bruteforce.count == 0 then
                if menu.visuals.logs:get() then
                    local ar, ag, ab = menu.visuals.logs_color1:get()
                    client.color_log(ar, ag, ab, "[Anti-bruteforce] activated ~ target: " .. entity.get_player_name(enemy))
                end
                if menu.visuals.screen_logs:get() then
                    table.insert(for_rendering, 1, {text = "[Assembly] Anti-bruteforce activated ~ target: " .. entity.get_player_name(enemy), alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
                end
            else
                if menu.visuals.logs:get() then
                    local ar, ag, ab = menu.visuals.logs_color1:get()
                    client.color_log(ar, ag, ab, "[Anti-bruteforce] phase switched due to enemy shot")
                end
                if menu.visuals.screen_logs:get() then
                    table.insert(for_rendering, 1, {text = "[Assembly] Anti-bruteforce phase switched", alpha = 0, add_y = 0, tick = globals.curtime() * 64, randomize = math.random(0, 100)})
                end
            end

            if ram.anti_bruteforce.count + 1 > menu.phase_builder.quantity:get() then
                ram.anti_bruteforce.count = 1
            else
                ram.anti_bruteforce.count = ram.anti_bruteforce.count + 1
            end
        end
        ram.anti_bruteforce.last_shot = globals.tickcount()
    end
    wat_render = closest_point
end

client.set_event_callback("bullet_impact", impact_anti_brute)

client.set_event_callback('pre_render', pre_rendering)
menu.visuals.filter_console:set_callback(filter_console)
filter_console()
menu.visuals.cvar_optimizer:set_callback(fps_opt)
fps_opt()
menu.misc.teammate_whitelist:set_callback(set_on)
client.set_event_callback("setup_command", setup_commanding)
client.set_event_callback('round_start', round_start)
client.set_event_callback('player_death', enemy_death)
