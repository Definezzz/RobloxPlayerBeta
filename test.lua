-- [ Requirements ]
local pui = require("gamesense/pui")
local anti_aim = require 'gamesense/antiaim_funcs' or error("Missing antiaim funcs library");
local clipboard = require("gamesense/clipboard")
local csgo_weapons = require 'gamesense/csgo_weapons'
local ffi = require("ffi")
local uix = require "gamesense/uix"
local base64 = require("gamesense/base64")
local entity_lib = require("gamesense/entity")
local vector = require("vector")
local websockets = require "gamesense/websockets"
local http = require "gamesense/http"
local images = require 'gamesense/images'
local bit = require "bit"
local currantstate = 1
local should_swap = 0
_DEBUG = true

local bit = require "bit"

-- [ notifications func ]
local func = {
    split = function(inputstr, sep)
        sep = sep or "%s"
        local t = {}
        for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
            table.insert(t, str)
        end
        return t
    end,
    easeInOut = function(t)
        if t > 0.5 then
            return 4 * ((t - 1) ^ 3) + 1
        else
            return 4 * (t ^ 3)
        end
    end,
    rec = function(x, y, w, h, radius, color)
        radius = math.min(x / 2, y / 2, radius)
        local r, g, b, a = unpack(color)
        renderer.rectangle(x, y + radius, w, h - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y, w - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x + radius, y + h - radius, w - radius * 2, radius, r, g, b, a)
        renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
        renderer.circle(x - radius + w, y + radius, r, g, b, a, radius, 90, 0.25)
        renderer.circle(x - radius + w, y - radius + h, r, g, b, a, radius, 0, 0.25)
        renderer.circle(x + radius, y - radius + h, r, g, b, a, radius, -90, 0.25)
    end,
    rec_outline = function(x, y, w, h, radius, thickness, color)
        radius = math.min(w / 2, h / 2, radius)
        local r, g, b, a = unpack(color)
        if radius == 1 then
            renderer.rectangle(x, y, w, thickness, r, g, b, a)
            renderer.rectangle(x, y + h - thickness, w, thickness, r, g, b, a)
        else
            renderer.rectangle(x + radius, y, w - radius * 2, thickness, r, g, b, a)
            renderer.rectangle(x + radius, y + h - thickness, w - radius * 2, thickness, r, g, b, a)
            renderer.rectangle(x, y + radius, thickness, h - radius * 2, r, g, b, a)
            renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius * 2, r, g, b, a)
            renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
            renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, thickness)
            renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, -90, 0.25, thickness)
            renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25, thickness)
        end
    end,
    clamp = function(x, min, max)
        return x < min and min or x > max and max or x
    end
}

-- ??????? ??? ??????? ?????? ? ?????? ????? ?? ?????? ??????????? "$"
-- string - ???????? ??????
-- r, g, b, a - ???? ??? ???????
color_text = function(string, r, g, b, a)
    local accent = "\a" .. rgba_to_hex(r, g, b, a)
    local white = "\a" .. rgba_to_hex(255, 255, 255, a)

    local str = ""
    for i, s in ipairs(func.split(string, "$")) do
        -- ??????????? ????? ????? ? ????????? ?????? ?? ?????? ??????????? "$"
        str = str .. (i % 2 == (string:sub(1, 1) == "$" and 0 or 1) and white or accent) .. s
    end

    return str
end
-- [ end of notifications func ]

-- [ notifications ]
local notifications = {
    -- ??????? ??? ???????? ?????? ???????????
    -- string - ????? ???????????
    -- r, g, b - ???? ??????????? (?????????? RGB)
    new = function(string, r, g, b)
        -- ???????? ?????? ??????????? ? ?????????? ??? ? ??????? ???????????
        table.insert(
            g_vars.data,
            {
                time = globals.curtime(), -- ????? ???????? ???????????
                string = string, -- ????? ???????????
                color = {r, g, b, 255}, -- ???? ??????????? (? ????????????? 255)
                fraction = 0 -- ???? ?????????? ??????????? (?? ????????? 0)
            }
        )

        local time = 7 -- ?????, ? ??????? ???????? ??????????? ????????????

        -- ?????? ?? ?????? ??????????? ? ???????? ???????
        for i = #g_vars.data, 1, -1 do
            local notif = g_vars.data[i]
            -- ???? ?????????? ??????????? ????????? ???????????? ? ???????????
            -- ???????????? ??????, ??? ???????? ?????, ????????? ????? ???????????
            if #g_vars.data - i + 1 > g_vars.max_notifs and notif.time + time - globals.curtime() > 0 then
                notif.time = globals.curtime() - time
            end
        end
    end,
    -- ??????? ?????????? ???????????
    render = function()
        local x, y = client.screen_size()
        local to_remove = {}
        local Offset = 0

        -- ????????? ???????? ???????????
        local anim_params = {
            rounding = 4, -- ?????????? ???????????
            size = 3, -- ?????? ??????
            glow = 10, -- ????????????? ????????
            time = 3.5 -- ????? ????????
        }

        for i = 1, #g_vars.data do
            local notif = g_vars.data[i]

            if notif.time + anim_params.time - globals.curtime() > 0 then
                notif.fraction = func.clamp(notif.fraction + globals.frametime() / g_vars.animtime, 0, 1)
            else
                notif.fraction = func.clamp(notif.fraction - globals.frametime() / g_vars.animtime, 0, 1)
            end

            if notif.fraction <= 0 and notif.time + anim_params.time - globals.curtime() <= 0 then
                table.insert(to_remove, i)
            end

            local fraction = func.easeInOut(notif.fraction)

            local r, g, b, a = unpack(notif.color)
            local string = color_text(notif.string, r, g, b, a * fraction)

            local strw, strh = renderer.measure_text("", string)
            local strw2 = renderer.measure_text("b", "")

            local paddingx, paddingy = 7, anim_params.size
            local offsetY = 100

            Offset = Offset + (strh + paddingy * 2 + math.sqrt(anim_params.glow / 10) * 10 + 5) * fraction

            -- ??????? ??? ?????????? ????????
            glow_module(
                x / 2 - (strw + strw2) / 2 - paddingx,
                y - offsetY - strh / 2 - paddingy - Offset,
                strw + strw2 + paddingx * 2,
                strh + paddingy * 2,
                anim_params.glow,
                anim_params.rounding,
                {r, g, b, 45 * fraction},
                {25, 25, 25, 140 * fraction}
            )

            renderer.text(x / 2 + strw2 / 2, y - offsetY - Offset, 255, 255, 255, 255 * fraction, "c", 0, string)
        end

        -- ???????? ???????????, ??????? ????????? ????????
        for i = #to_remove, 1, -1 do
            table.remove(g_vars.data, to_remove[i])
        end
    end,
    clear = function()
        g_vars.data = {}
    end
}
-- ??????? ??? ?????????? ????
glow_module = function(x, y, w, h, width, rounding, accent, accent_inner)
    local thickness = 1
    local Offset = 1
    local r, g, b, a = unpack(accent)

    -- ???? ????? ?????? ??? ?????????? ?????
    if accent_inner then
        func.rec(x, y, w, h + 1, rounding, accent_inner)
    end

    for k = 0, width do
        local fraction = (k / width) ^ 2
        if a * fraction > 5 then
            local accent = {r, g, b, a * fraction}
            local rec_x = x + (k - width - Offset) * thickness
            local rec_y = y + (k - width - Offset) * thickness
            local rec_w = w - (k - width - Offset) * thickness * 2
            local rec_h = h + 1 - (k - width - Offset) * thickness * 2
            local rec_rounding = rounding + thickness * (width - k + Offset)
            func.rec_outline(rec_x, rec_y, rec_w, rec_h, rec_rounding, thickness, accent)
        end
    end
end

function rgba_to_hex(r, g, b, a)
    return string.format("%02x%02x%02x%02x", r, g, b, a)
end

local function lerp_color(c1, c2, t)
    local r = math.floor(c1[1] * (1 - t) + c2[1] * t + 0.5)
    local g = math.floor(c1[2] * (1 - t) + c2[2] * t + 0.5)
    local b = math.floor(c1[3] * (1 - t) + c2[3] * t + 0.5)
    local a = math.floor(c1[4] * (1 - t) + c2[4] * t + 0.5)

    return { r, g, b, a }
end
-- [ end of notifications ]

g_vars = 
{
    username = "User",
    sub ="lifetime",
    build = "free",
update = "??",
    accent = "A4FFCFFF",
    ref = {
        hiden = {
            aa_enable = ui.reference("AA", "anti-aimbot angles", "enabled"),
            pitch = ui.reference("AA", "anti-aimbot angles", "pitch"),
            pitch_value = select(2, ui.reference("AA", "anti-aimbot angles", "pitch")),
            yaw_base = ui.reference("AA", "anti-aimbot angles", "yaw base"),
            yaw = ui.reference("AA", "anti-aimbot angles", "yaw"),
            yaw_value = select(2, ui.reference("AA", "anti-aimbot angles", "yaw")),
            yaw_jitter = ui.reference("AA", "Anti-aimbot angles", "Yaw Jitter"),
            yaw_jitter_value = select(2, ui.reference("AA", "Anti-aimbot angles", "Yaw Jitter")),
            body_yaw = ui.reference("AA", "Anti-aimbot angles", "Body yaw"),
            body_yaw_value = select(2, ui.reference("AA", "Anti-aimbot angles", "Body yaw")),
            freestand_body_yaw = ui.reference("AA", "Anti-aimbot angles", "freestanding body yaw"),
            edgeyaw = ui.reference("AA", "anti-aimbot angles", "edge yaw"),
            freestand = {ui.reference("AA", "anti-aimbot angles", "freestanding")},
            roll = ui.reference("AA", "anti-aimbot angles", "roll"),
            slide = {ui.reference("AA", "other", "slow motion")},
            fakeduck = ui.reference("rage", "other", "duck peek assist"),
            fl_enable = {ui.reference("AA", "Fake lag", "Enabled")},
            slowmo_enable = {ui.reference("AA", "Other", "Slow motion")},
            lm1 = ui.reference("AA", "Other", "Leg movement"),
            os_aa = {ui.reference("AA", "Other", "On shot anti-aim")},
            fp = {ui.reference("AA", "Other", "Fake peek")},
            fl_amount = ui.reference("AA", "Fake lag", "Amount"),
            fl_variance = ui.reference("AA", "Fake lag", "Variance"),
            fl_limit = ui.reference("AA", "Fake lag", "Limit"),
        },
        damage = {ui.reference("RAGE", "Aimbot", "Minimum damage override")},
        quick_peek = {ui.reference("rage", "other", "quick peek assist")},
        doubletap = {ui.reference("rage", "aimbot", "double tap")},
        hideshots = {ui.reference("AA", "Other", "On shot anti-aim")},
        baim_key = ui.reference("RAGE", "Aimbot", "Force body aim"),
        safepoint = ui.reference("RAGE", "Aimbot", "Force safe point"),
        menu_color_ref = ui.reference("MISC", "Settings", "Menu color"),
    },   
    states = {
        [1] = "Global",
        [2] = "Standing",
        [3] = "Moving",
        [4] = "Air",
        [5] = "Air+",
        [6] = "Duck",
        [7] = "Fakelag",
        [8] = "Defensive",
    },
    defensive_states = {
        [2] = "Standing",
        [3] = "Moving",
        [4] = "Air",
        [5] = "Air+",
        [6] = "Duck",
    },
    is_connected = false,
    images_path = "csgo/materials/panorama/images/",
    connected_server = false,
    online_count = "awaiting",
    local_player = nil,
    animtime = 0.5,
    max_notifs = 6,
    data = {},
    manual_left_toggled = false,
    manual_right_toggled = false,
    mode = nil,
}

local gui = pui.group("AA", "anti-aimbot angles")
local gui_fakelag = pui.group("AA", "fake lag")
local gui_other = pui.group("AA", "Other")
pui.accent = g_vars.accent
local gui_enable = gui:checkbox("\affd753FFErased", true)
local username = gui:label("Welcome, \affd753FFUser\r.")
local gui_switch = gui:combobox("\n", "Home", "Anti-Aimbot", "Visuals", "Misc")
local gui_groups = {
    home = {
       debug = _DEBUG and gui:label("\affd753FF< DEBUG MODE ENABLED >") or nil,


       scriptsettings_label = gui_fakelag:label("\affd753FFConfig \rSystem"),
       def_cfg_btn = gui_fakelag:button(
    "\affd753FFRecommended \rSettings",
    function()
                      -- ??????? ?????????? ? ??????? ? ???????? ??????????????? ????????
                client.color_log(167, 255, 166, string.format("[+]\0"))
                client.color_log(255, 255, 255, string.format(" Loaded Recommended Settings"))

                -- ????????? ??????????????? ????????? (? ?????? ?????? ?????? "? ???????")
                configs.import(
                   "W251bGwseyJtYW51YWxfbGVmdCI6WzEsMCwifiJdLCJmb3JjZV9kZWZlbnNpdmUiOlsiQWlyIiwiQWlyKyIsIn4iXSwiZmFzdF9sYWRkZXIiOnRydWUsIm1hbnVhbF9yaWdodCI6WzEsMCwifiJdLCJjb250ZXh0IjpbeyJ5YXdfYmFzZSI6IkF0IHRhcmdldHMiLCJwaXRjaCI6IkRvd24iLCJib2R5X3lhdyI6IkppdHRlciIsInlhd19qaXR0ZXJfb2Zmc2V0IjotMjcsInlhdyI6IjE4MCIsIm92ZXJyaWRlIjpmYWxzZSwieWF3X29mZnNldCI6MCwieWF3X29mZnNldF9yaWdodCI6MCwiYm9keV95YXdfdmFsdWUiOjE4MCwieWF3X29mZnNldF9sZWZ0IjowLCJ5YXdfaml0dGVyIjoiMy1XYXkiLCJ5YXdfbHJfZGVsYXkiOjEsInBpdGNoX3ZhbHVlIjowLCJ5YXdfZGVsYXllZCI6ZmFsc2V9LHsieWF3X2Jhc2UiOiJMb2NhbCB2aWV3IiwicGl0Y2giOiJPZmYiLCJib2R5X3lhdyI6Ik9mZiIsInlhd19qaXR0ZXJfb2Zmc2V0IjowLCJ5YXciOiJPZmYiLCJvdmVycmlkZSI6ZmFsc2UsInlhd19vZmZzZXQiOjAsInlhd19vZmZzZXRfcmlnaHQiOjAsImJvZHlfeWF3X3ZhbHVlIjowLCJ5YXdfb2Zmc2V0X2xlZnQiOjAsInlhd19qaXR0ZXIiOiJPZmYiLCJ5YXdfbHJfZGVsYXkiOjEsInBpdGNoX3ZhbHVlIjowLCJ5YXdfZGVsYXllZCI6ZmFsc2V9LHsieWF3X2Jhc2UiOiJBdCB0YXJnZXRzIiwicGl0Y2giOiJEb3duIiwiYm9keV95YXciOiJKaXR0ZXIiLCJ5YXdfaml0dGVyX29mZnNldCI6LTMwLCJ5YXciOiJMXC9SIiwib3ZlcnJpZGUiOnRydWUsInlhd19vZmZzZXQiOjAsInlhd19vZmZzZXRfcmlnaHQiOjEyLCJib2R5X3lhd192YWx1ZSI6MTgwLCJ5YXdfb2Zmc2V0X2xlZnQiOi05LCJ5YXdfaml0dGVyIjoiMy1XYXkiLCJ5YXdfbHJfZGVsYXkiOjMsInBpdGNoX3ZhbHVlIjowLCJ5YXdfZGVsYXllZCI6dHJ1ZX0seyJ5YXdfYmFzZSI6IkF0IHRhcmdldHMiLCJwaXRjaCI6IkRvd24iLCJib2R5X3lhdyI6IkppdHRlciIsInlhd19qaXR0ZXJfb2Zmc2V0IjotMjEsInlhdyI6IjE4MCIsIm92ZXJyaWRlIjp0cnVlLCJ5YXdfb2Zmc2V0IjowLCJ5YXdfb2Zmc2V0X3JpZ2h0IjowLCJib2R5X3lhd192YWx1ZSI6MTgwLCJ5YXdfb2Zmc2V0X2xlZnQiOjAsInlhd19qaXR0ZXIiOiIzLVdheSIsInlhd19scl9kZWxheSI6MSwicGl0Y2hfdmFsdWUiOjAsInlhd19kZWxheWVkIjpmYWxzZX0seyJ5YXdfYmFzZSI6IkF0IHRhcmdldHMiLCJwaXRjaCI6IkRvd24iLCJib2R5X3lhdyI6IkppdHRlciIsInlhd19qaXR0ZXJfb2Zmc2V0IjotMTIsInlhdyI6IjE4MCIsIm92ZXJyaWRlIjp0cnVlLCJ5YXdfb2Zmc2V0IjowLCJ5YXdfb2Zmc2V0X3JpZ2h0IjowLCJib2R5X3lhd192YWx1ZSI6MTgwLCJ5YXdfb2Zmc2V0X2xlZnQiOjAsInlhd19qaXR0ZXIiOiIzLVdheSIsInlhd19scl9kZWxheSI6MSwicGl0Y2hfdmFsdWUiOjAsInlhd19kZWxheWVkIjpmYWxzZX0seyJ5YXdfYmFzZSI6IkF0IHRhcmdldHMiLCJwaXRjaCI6IkRvd24iLCJib2R5X3lhdyI6Ik9wcG9zaXRlIiwieWF3X2ppdHRlcl9vZmZzZXQiOjIxLCJ5YXciOiIxODAiLCJvdmVycmlkZSI6dHJ1ZSwieWF3X29mZnNldCI6MCwieWF3X29mZnNldF9yaWdodCI6MCwiYm9keV95YXdfdmFsdWUiOjE4MCwieWF3X29mZnNldF9sZWZ0IjowLCJ5YXdfaml0dGVyIjoiT2ZmIiwieWF3X2xyX2RlbGF5IjoxLCJwaXRjaF92YWx1ZSI6MCwieWF3X2RlbGF5ZWQiOmZhbHNlfSx7Inlhd19iYXNlIjoiQXQgdGFyZ2V0cyIsInBpdGNoIjoiRG93biIsImJvZHlfeWF3IjoiT3Bwb3NpdGUiLCJ5YXdfaml0dGVyX29mZnNldCI6LTMwLCJ5YXciOiIxODAiLCJvdmVycmlkZSI6dHJ1ZSwieWF3X29mZnNldCI6MCwieWF3X29mZnNldF9yaWdodCI6MCwiYm9keV95YXdfdmFsdWUiOjE4MCwieWF3X29mZnNldF9sZWZ0IjowLCJ5YXdfaml0dGVyIjoiMy1XYXkiLCJ5YXdfbHJfZGVsYXkiOjEsInBpdGNoX3ZhbHVlIjowLCJ5YXdfZGVsYXllZCI6ZmFsc2V9LHsieWF3X2Jhc2UiOiJBdCB0YXJnZXRzIiwicGl0Y2giOiJDdXN0b20iLCJib2R5X3lhdyI6Ik9wcG9zaXRlIiwieWF3X2ppdHRlcl9vZmZzZXQiOjE4MCwieWF3IjoiMTgwIiwib3ZlcnJpZGUiOnRydWUsInlhd19vZmZzZXQiOjAsInlhd19vZmZzZXRfcmlnaHQiOjAsImJvZHlfeWF3X3ZhbHVlIjoxODAsInlhd19vZmZzZXRfbGVmdCI6MCwieWF3X2ppdHRlciI6IlJhbmRvbSIsInlhd19scl9kZWxheSI6MSwicGl0Y2hfdmFsdWUiOi00NSwieWF3X2RlbGF5ZWQiOmZhbHNlfV0sImFudGlicnV0ZWZvcmNlIjp0cnVlLCJhbnRpYiI6dHJ1ZSwiZnJlZXN0YW5kaW5nIjpbMSwwLCJ+Il0sInN0YXRlYW1vdW50Ijo0LCJhbnRpYnN0YXRlIjpbMjAsLTIwLC0yMCwyMF0sInN0YXRlIjoiQW50aS1icnV0ZWZvcmNlIn0seyJsb2dnaW5nX2N0IjpbIk9uIEhpdCIsIk9uIE1pc3MiLCJPbiBLbmlmZVwvTmFkZSIsIn4iXSwibmgiOiJJbmZvcm1hdGl2ZSIsImxvZ2dpbmdfY29uZCI6WyJDb25zb2xlIiwiTm90aWZpY2F0aW9ucyIsIn4iXSwibm90aWZpYyI6WyJPbiBLaWxsIiwiT24gRGVhdGgiLCJPbiBFbmVteSBEYW1hZ2UiLCJ+Il0sIndhdGVybWFya19jIjoiI0E3RkZDRkZGIiwibG9nZ2luZ19udCI6WyJPbiBIaXQiLCJPbiBNaXNzIiwiT24gS25pZmVcL05hZGUiLCJ+Il0sImxvZ2dpbmdib3hlcyI6ZmFsc2UsImxvZ2dpbmciOnRydWUsImJpbmRzX2NvbmQiOlsiRG91YmxldGFwIiwiT24tc2hvdCBhbnRpLWFpbSIsIkRhbWFnZSBPdmVycmlkZSIsIkZyZWVzdGFuZCIsIkZha2VkdWNrIiwiU2FmZXBvaW50IE92ZXJyaWRlIiwiQm9keSBBaW0gT3ZlcnJpZGUiLCJ+Il0sIndhdGVybWFyayI6ZmFsc2UsImxvZ2dpbmdib3hlc3NsaWRlciI6MjAsImluZGljcyI6dHJ1ZSwiaW5kaWNzX2NvbmQiOlsiTmFtZSIsIkJpbmRzIiwifiJdLCJsb2dnaW5nYm94ZXNfYyI6IiNGRkZGRkZGRiIsImVuYWJsZWRfbm90Ijp0cnVlLCJubSI6IkluZm9ybWF0aXZlIn0seyJkaXNhYmxlX2FkcyI6dHJ1ZSwiZW5hYmxlZF9jbGFudGFncyI6dHJ1ZSwidHJhc2h0YWxrX2NvbmRzIjpbIk9uIEtpbGwiLCJPbiBEZWF0aCIsIn4iXSwiYWxhcm0iOmZhbHNlLCJ0cmFzaHRhbGsiOnRydWV9XQ=="
                   )

                -- ??????? ??????????? ? ???????? ??????????????? ????????
                notifications.new(string.format("Loaded Recommended Settings"), 164, 255, 207)

                -- ????????????? ???????? ?????? ??????
                client.exec("play buttons/button10;")
    end
),
export_btn = gui_fakelag:button(
    "Export Settings",
    function()
        -- ???????????? ??????? ?????????
        configs.export()

        -- ??????? ?????????? ? ??????? ? ?????? ????????
        client.color_log(167, 255, 166, string.format("[+]\0"))
        client.color_log(255, 255, 255, string.format(" Exported Settings"))
-- ??????? ??????????? ? ?????????? ????????
        notifications.new(string.format("Exported $%s$'s Settings", g_vars.username), 164, 255, 207)
        -- ??????????? ???? ??? ??????? ?? ??????
        client.exec("play buttons/button10;")
    end
),
import_btn = gui_fakelag:button(
    "Import Settings",
    function()
        -- ???????????? ??????? ?????????
        configs.import()
-- ??????? ??????????? ? ?????????? ???????
        notifications.new(string.format("Imported Settings"), 164, 255, 207)
        client.color_log(167, 255, 166, string.format("[+]\0"))
        client.color_log(255, 255, 255, string.format(" Imported Settings"))

        -- ??????????? ???? ??? ??????? ?? ??????
        client.exec("play buttons/button10;")
    end
),

    },
    antiaim = {
        antib = gui_other:checkbox("Anti backstab"),
        fast_ladder = gui_other:checkbox("Fast ladder"),
        freestanding = gui_other:hotkey("Freestanding"),
        force_defensive = gui_other:multiselect("Force Defensive", "Standing", "Moving", "Air", "Air+", "Duck"),
        state = gui_fakelag:combobox("State", "Global", "Standing", "Moving", "Air", "Air+", "Duck", "Fakelag", "Defensive", "Anti-bruteforce"),
        manual_left = gui_other:hotkey("Manual left", false),
        manual_right = gui_other:hotkey("Manual right", false),
        antibruteforce = gui_fakelag:checkbox("Anti-bruteforce"),
        antibstate = {},
        context = {},
    },
    visuals = {
        enabled_not = gui_fakelag:checkbox("Enable Notifications"),
        notific = gui_fakelag:multiselect(
            "Notifications Modes",
            "On Trashtalk",
            "On Round Start",
            "On Round End",
            "On Kill",
            "On Death",
            "On Enemy Damage"
        ),
        loggingboxes = gui_other:checkbox("Enable Hitbox On Shot", {255, 255, 255, 255}),
        loggingboxesslider = gui_other:slider("Hitbox On Shot Timer", 5, 200, 20, true, "s", 0.1),
        logging = gui_fakelag:checkbox("Enable Aimbot Logging"),
        logging_cond = gui_fakelag:multiselect("Aimbot Logging Conditions", "Console", "Notifications"),
        logging_nt = gui_fakelag:multiselect("Aimbot Logging Notifications Conditions", "On Hit", "On Miss", "On Knife/Nade"),
        nh = gui_fakelag:combobox("Notifications On Hit Mode", "Informative", "Short", "Gamesense"),
        nm = gui_fakelag:combobox("Notifications On Miss Mode", "Informative", "Short", "Gamesense"),
        logging_ct = gui_fakelag:multiselect("Aimbot Logging Console Conditions", "On Hit", "On Miss", "On Knife/Nade"),
        indics = gui_fakelag:checkbox("Crosshair Indicators"),
        indics_cond = gui_fakelag:multiselect("Crosshair Indicators Modes", "Name", "State", "Binds"),
        binds_cond = gui_fakelag:multiselect("Binds Conditions", "Doubletap", "On-shot anti-aim", "Damage Override", "Freestand", "Fakeduck", "Safepoint Override", "Body Aim Override"),
        watermark = gui_fakelag:checkbox("Watermark", {167, 255, 207, 255}),
    },
    misc = {
        enabled_clantags = gui_fakelag:checkbox("Clan Tag Spammer"),
        --alarm = gui_fakelag:checkbox("Mega alarm"),
        trashtalk = gui_fakelag:checkbox("Trashtalk"),
        trashtalk_conds = gui_fakelag:multiselect("Trashtalk Conditions", "On Kill", "On Death"),
        disable_ads = gui_fakelag:checkbox("Disable server-side ads"),
    }
}


gui_enable:override(true)

gui_groups.misc.disable_ads:set_callback(function(self)
    if g_vars.is_connected and self.value == true then
        --notifications.new(string.format("Adblock has been enabled"), 164, 255, 207)
        client.exec("con_filter_enable 1")
        client.exec("con_filter_text_out \"blocking\""); 
        client.exec("cl_server_graphic1_enable 0")
        client.exec("cl_server_graphic2_enable 0")
        cvar.net_blockmsg:set_string("CNETMsg_StringCmd")
    else
        --notifications.new(string.format("Adblock has been disabled"), 164, 255, 207)
        client.exec("con_filter_enable 1")
        client.exec("con_filter_text_out ''"); 
        client.exec("cl_server_graphic1_enable 1")
        client.exec("cl_server_graphic2_enable 1")
        cvar.net_blockmsg:set_int(0)
    end
end)

js = panorama.loadstring([[
   
    let entity_panels = {}
    let entity_data = {}
    let event_callbacks = {}
        let SLOT_LAYOUT = `
            <root>
                <Panel style="min-width: 3px; padding-top: 2px; padding-left: 0px;" scaling='stretch-to-fit-y-preserve-aspect'>
                    <Image id="smaller" textureheight="15" style="horizontal-align: center; opacity: 0.01; transition: opacity 0.1s ease-in-out 0.0s, img-shadow 0.12s ease-in-out 0.0s; overflow: noclip; padding: 3px 5px; margin: -3px -5px;"    />
                    <Image id="small" textureheight="17" style="horizontal-align: center; opacity: 0.01; transition: opacity 0.1s ease-in-out 0.0s, img-shadow 0.12s ease-in-out 0.0s; overflow: noclip; padding: 3px 5px; margin: -3px -5px;" />
                    <Image id="image" textureheight="21" style="opacity: 0.01; transition: opacity 0.1s ease-in-out 0.0s, img-shadow 0.12s ease-in-out 0.0s; padding: 3px 5px; margin: -3px -5px; margin-top: -5px;" />
                </Panel>
            </root>
        `
        let _DestroyEntityPanel = function (key) {
            let panel = entity_panels[key]
            if(panel != null && panel.IsValid()) {
                var parent = panel.GetParent()
                let musor = parent.GetChild(0)
                musor.visible = true
                if(parent.FindChildTraverse("id-sb-skillgroup-image") != null) {
                    parent.FindChildTraverse("id-sb-skillgroup-image").style.margin = "0px 0px 0px 0px"
                }
                panel.DeleteAsync(0.0)
            }
            delete entity_panels[key]
        }
        let _DestroyEntityPanels = function() {
            for(key in entity_panels){
                _DestroyEntityPanel(key)
            }
        }
        let _GetOrCreateCustomPanel = function(xuid) {
            if(entity_panels[xuid] == null || !entity_panels[xuid].IsValid()){
                entity_panels[xuid] = null
                let scoreboard_context_panel = $.GetContextPanel().FindChildTraverse("ScoreboardContainer").FindChildTraverse("Scoreboard") || $.GetContextPanel().FindChildTraverse("id-eom-scoreboard-container").FindChildTraverse("Scoreboard")
                if(scoreboard_context_panel == null){
                    _Clear()
                    _DestroyEntityPanels()
                    return
                }
                scoreboard_context_panel.FindChildrenWithClassTraverse("sb-row").forEach(function(el){
                    let scoreboard_el
                    if(el.m_xuid == xuid) {
                        el.Children().forEach(function(child_frame){
                            let stat = child_frame.GetAttributeString("data-stat", "")
                            if(stat == "rank")
                                scoreboard_el = child_frame.GetChild(0)
                        })
                        if(scoreboard_el) {
                            let scoreboard_el_parent = scoreboard_el.GetParent()
                            let custom_icons = $.CreatePanel("Panel", scoreboard_el_parent, "revealer-icon", {
                            })
                            if(scoreboard_el_parent.FindChildTraverse("id-sb-skillgroup-image") != null) {
                                scoreboard_el_parent.FindChildTraverse("id-sb-skillgroup-image").style.margin = "0px 0px 0px 0px"
                            }
                            scoreboard_el_parent.MoveChildAfter(custom_icons, scoreboard_el_parent.GetChild(1))
                            let prev_panel = scoreboard_el_parent.GetChild(0)
                            prev_panel.visible = false
                            let panel_slot_parent = $.CreatePanel("Panel", custom_icons, `icon`)
                            panel_slot_parent.visible = false
                            panel_slot_parent.BLoadLayoutFromString(SLOT_LAYOUT, false, false)
                            entity_panels[xuid] = custom_icons
                            return custom_icons
                        }
                    }
                })
            }
            return entity_panels[xuid]
        }
        let _UpdatePlayer = function(entindex, path_to_image) {
            if(entindex == null || entindex == 0)
                return
            entity_data[entindex] = {
                applied: false,
                image_path: path_to_image
            }
        }
        let _ApplyPlayer = function(entindex) {
            let xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(entindex)
            let panel = _GetOrCreateCustomPanel(xuid)
            if(panel == null)
                return
            let panel_slot_parent = panel.FindChild(`icon`)
            panel_slot_parent.visible = true
            let panel_slot = panel_slot_parent.FindChild("image")
            panel_slot.visible = true
            panel_slot.style.opacity = "1"
            panel_slot.SetImage(entity_data[entindex].image_path)
            return true
        }
        let _ApplyData = function() {
            for(entindex in entity_data) {
                entindex = parseInt(entindex)
                let xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(entindex)
                if(!entity_data[entindex].applied || entity_panels[xuid] == null || !entity_panels[xuid].IsValid()) {
                    if(_ApplyPlayer(entindex)) {
                        entity_data[entindex].applied = true
                    }
                }
            }
        }
        let _Create = function() {
            event_callbacks["OnOpenScoreboard"] = $.RegisterForUnhandledEvent("OnOpenScoreboard", _ApplyData)
            event_callbacks["Scoreboard_UpdateEverything"] = $.RegisterForUnhandledEvent("Scoreboard_UpdateEverything", function(){
                _ApplyData()
            })
            event_callbacks["Scoreboard_UpdateJob"] = $.RegisterForUnhandledEvent("Scoreboard_UpdateJob", _ApplyData)
        }
        let _Clear = function() { entity_data = {} }
        let _Destroy = function() {
            // ???????? 
            _Clear()
            _DestroyEntityPanels()
            for(event in event_callbacks){
                $.UnregisterForUnhandledEvent(event, event_callbacks[event])
                delete event_callbacks[event]
            }
        }
        return {
            create: _Create,
            destroy: _Destroy,
            clear: _Clear,
            update: _UpdatePlayer,
            destroy_panel: _DestroyEntityPanels
        }
]], "CSGOHud")()
js.create()

local function get_players()
    local players = {}
    local player_resource = entity.get_player_resource()

    for i = 1, globals.maxplayers() do
        repeat
            if entity.get_prop(player_resource, "m_bConnected", i) == 0 then
                break
            else
                local flags = entity.get_prop(i, "m_fFlags")
                if not flags then
                    break
                end

                if bit.band(flags, 512) == 512 then
                    break
                end
            end

            players[#players + 1] = i
        until true
    end

    return players
end


connect = function()
    websockets.connect("ws://77.91.66.75:8765", {
        open = function(ws)
            socket = ws
            g_vars.connected_server = true
            if _DEBUG then
                print("connected")
            end
            ws:send(entity.get_steam64(entity.get_local_player()))
        end,

        message = function(ws, data)
            if _DEBUG then
                print("server said - "..data)
            end
            info = data
        end,

        close = function (ws, code, reason, was_clean)
            if _DEBUG then
                print("closed connection!")
                print(reason)   
            end
            g_vars.connected_server = false
        end
    })
end
stateamount = 0
gui_groups.antiaim.add_state = gui_fakelag:button("Add state", function()
    stateamount = stateamount + 1
    gui_groups.antiaim.antibstate[stateamount] = gui_fakelag:slider("Yaw add+ ["..stateamount.."]", -90, 89, 0); 
    gui_groups.antiaim.antibstate[stateamount]:depend({gui_groups.antiaim.state, "Anti-bruteforce"}, {gui_switch, "Anti-Aimbot"})
end)
gui_groups.antiaim.remove_state = gui_fakelag:button("Remove state", function()
    gui_groups.antiaim.antibstate[stateamount]:set_visible(false)
    table.remove(gui_groups.antiaim.antibstate, stateamount)
    stateamount = stateamount - 1
end)

gui_groups.antiaim.add_state:depend({gui_groups.antiaim.state, "Anti-bruteforce"}, {gui_switch, "Anti-Aimbot"})
gui_groups.antiaim.remove_state:depend({gui_groups.antiaim.state, "Anti-bruteforce"}, {gui_switch, "Anti-Aimbot"})

local function switch(value)
    return function(cases)
      local f = cases[value]
      if (f) then
        f()
      end
    end
end
last_sim_time = 0
defensive_until = 0
sideval = 0  
local three_way_val = 0
-- local c_antiaim = {}
local c_antiaim = {
    last_sim_time = 0,
    defensive_until = 0,


    chocking = function(cmd)
        return cmd.allow_send_packet == false or cmd.chokedcommands > 1
    end,

    get_defensive_state = function (self)
        local tickcount = globals.tickcount();
        local local_player = entity.get_local_player();
        local sim_time = toticks(entity.get_prop(local_player, "m_flSimulationTime"));

        local sim_diff = sim_time - last_sim_time;

        if sim_diff < 0 then
            defensive_until = tickcount + math.abs(sim_diff) - toticks(client.latency());
        end

        last_sim_time = sim_time;

        return defensive_until > tickcount;
    end,

    get_side = function (i)
        if(gui_groups.antiaim.context[i].yaw_delayed:get()) then
            invert_state = globals.tickcount() % gui_groups.antiaim.context[i].yaw_lr_delay:get()*2 > gui_groups.antiaim.context[i].yaw_lr_delay:get()-1
            sideval = invert_state and gui_groups.antiaim.context[i].yaw_offset_left:get() or gui_groups.antiaim.context[i].yaw_offset_right:get() 
        else
            balls = math.floor(entity.get_prop(g_vars.local_player, "m_flPoseParameter", 11) * 120 - 60)
            if (balls < 0 or gui_groups.antiaim.context[i].yaw_jitter:get() == "Off") then
            sideval = gui_groups.antiaim.context[i].yaw_offset_left:get()
            elseif (balls > 0 and gui_groups.antiaim.context[i].yaw_jitter:get() ~= "Off") then
                sideval = gui_groups.antiaim.context[i].yaw_offset_right:get()
            end
        end
        return sideval
    end,

    calculate_3way = function (i)
        three_way_val = 0
        switch(globals.tickcount() % 3) {
            [0] = function()
                    three_way_val = 0 - gui_groups.antiaim.context[i].yaw_jitter_offset:get()
                    ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
            -- print(three_way_val)
            end,
            [1] = function ()
                    three_way_val = 0
                    ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
            -- print(three_way_val)
            end,
            [2] = function ()
                three_way_val = three_way_val + gui_groups.antiaim.context[i].yaw_jitter_offset:get()
                ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
                three_way_val = 0
         end,
    }
    end,

    calculate_5way = function (i)    
        three_way_val = 0    
        switch(globals.tickcount() % 5) {
            [0] = function()
                    three_way_val = 0 - gui_groups.antiaim.context[i].yaw_jitter_offset:get()
                    ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
            end, 
            [1] = function ()
                    three_way_val = 0 + gui_groups.antiaim.context[i].yaw_jitter_offset:get()
                    ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
          
            end,
            [2] = function ()
                three_way_val = three_way_val + (gui_groups.antiaim.context[i].yaw_jitter_offset:get() / 2)
                ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
               
            end,
            [3] = function ()
                three_way_val = three_way_val - (gui_groups.antiaim.context[i].yaw_jitter_offset:get() / 2)
                ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
                
            end,
            [4] = function ()
                three_way_val = 0 - (gui_groups.antiaim.context[i].yaw_jitter_offset:get() / 2)
                ui.set(g_vars.ref.hiden.yaw_jitter_value, three_way_val) 
                
                three_way_val = 0
            end,
    }
    end,
    setup_context = function()
        for i = 1, 8 do
            gui_groups.antiaim.context[i] = {
                override = gui_fakelag:checkbox("Override"),
                pitch = gui_fakelag:combobox("Pitch", "Off", "Down", "Up", "Minimal", "Custom"), 
                pitch_value = gui_fakelag:slider("Custom value", -89, 89, 0); 
                yaw_base = gui_fakelag:combobox("Yaw base", "Local view", "At targets"),
                yaw = gui_fakelag:combobox("Yaw", "Off", "180", "Spin", "180 z", "L/R"),
                yaw_offset = gui_fakelag:slider("Yaw offset", -180, 180, 0),
                yaw_delayed = gui_fakelag:checkbox("Delayed"),
                yaw_lr_delay = gui_fakelag:slider("Delay", 1, 20, 0, true, "t");
                yaw_offset_left = gui_fakelag:slider("Yaw offset left", -180, 180, 0),
                yaw_offset_right = gui_fakelag:slider("Yaw offset right", -180, 180, 0),
                yaw_jitter = gui_fakelag:combobox("Yaw Jitter", "Off", "Offset", "Center", "Random", "Skitter", "3-Way", "5-Way"),
                yaw_jitter_offset = gui_fakelag:slider("Yaw jitter offset", -180, 180, 0),
                body_yaw = gui_fakelag:combobox("Body yaw", "Off", "Opposite", "Jitter", "Static"),
                body_yaw_value = gui_fakelag:slider("Yaw jitter offset", -180, 180, 0)
            }
        end
    end,
}

c_antiaim.force_defensive = function(cmd)

    local state = c_antiaim.get_state(cmd)
    local condition = gui_groups.antiaim.force_defensive:get(g_vars.defensive_states[state])    
    if(condition or state == 8) then
        cmd.force_defensive = true
    else
        cmd.force_defensive = false
    end
end

c_antiaim.get_state = function (cmd)
    local velocity_x = entity.get_prop(g_vars.local_player, "m_vecVelocity[0]") 
    local velocity_y = entity.get_prop(g_vars.local_player, "m_vecVelocity[1]")
    local velocity_z = entity.get_prop(g_vars.local_player, "m_vecVelocity[2]")
    local duckamount = entity.get_prop(g_vars.local_player, "m_flDuckAmount")
    local tickbase  = entity.get_prop(g_vars.local_player, "m_nTickBase")
    local old_tickbase = 0
    local fakelag =
    not ((ui.get(g_vars.ref.doubletap[1]) and ui.get(g_vars.ref.doubletap[2])) or
    (ui.get(g_vars.ref.hideshots[1]) and ui.get(g_vars.ref.hideshots[2])))
    
    if math.abs(velocity_x) < 1 and math.abs(velocity_y) < 1 then
        state = 2 --standing
    end

    if math.abs( velocity_x ) > 3 or math.abs(velocity_y) > 3 then
        state = 3 --moving
    end

    if math.abs( velocity_z ) > 0 and duckamount == 0 then
        state = 4 --air
    end

    if math.abs( velocity_z ) > 0 and duckamount > 0 then
        state = 5 --air+
    end

    if duckamount == 1 and velocity_z == 0 then
        state = 6 --duck
    end 

    if fakelag == true then
        state = 7 --fakelag
    end
    
    if c_antiaim.get_defensive_state(cmd) then
        state = 8 --defensive
    end

    return state
end
-- pizdec
c_antiaim.anti_backstab = function() 
    if gui_groups.antiaim.antib:get() then
        if not client.current_threat() then return end
        local threat = vector(entity.get_origin(client.current_threat()))
        local dist = vector(entity.get_origin(entity.get_local_player())):dist(threat)
        local weapon = entity.get_player_weapon(client.current_threat())
        if not weapon then
            return
        end
        if dist < 200 and csgo_weapons(weapon)['name'] == "Knife" then
            ui.set(g_vars.ref.hiden.yaw, "Off") 
        end
    end
end

renderer.rounded_rectangle = function(x, y, w, h, r, g, b, a, radius)
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
end

-- renderer.rounded_blur = function(x, y, w, h, a, amount, radius)
--     y = y + radius
--     local data_circle = {
--         {x + radius, y, 180},
--         {x + w - radius, y, 90},
--         {x + radius, y + h - radius * 2, 270},
--         {x + w - radius, y + h - radius * 2, 0},
--     }

--     local data = {
--         {x + radius, y, w - radius * 2, h - radius * 2},
--         {x + radius, y - radius, w - radius * 2, radius},
--         {x + radius, y + h - radius * 2, w - radius * 2, radius},
--         {x, y, radius, h - radius * 2},
--         {x + w - radius, y, radius, h - radius * 2},
--     }

--     for _, data in next, data_circle do
--         renderer.circle(data[1], data[2], 0, 0, 0, 255, radius, data[3], 0.25)
--     end

--     for _, data in next, data do
--         renderer.blur(data[1], data[2], data[3], data[4],a,amount)
--     end
-- end


-- [ fast ladder ]
c_antiaim.fast_ladder = function(cmd)
    if not gui_groups.antiaim.fast_ladder:get() then
         return
     end
     local lp = entity.get_local_player()
     if not lp then return end
     if entity.get_prop(lp, 'm_MoveType') == 9 then
         if cmd.in_forward == 1 or cmd.in_back == 1 then
             cmd.in_moveleft = cmd.in_back;
             cmd.in_moveright = cmd.in_back == 1 and 0 or 1;
     
             if cmd.sidemove == 0 then
                 cmd.yaw = cmd.yaw + 45;
             end
     
             if cmd.sidemove > 0 then
                 cmd.yaw = cmd.yaw - 1;
             end
     
             if cmd.sidemove < 0 then
                 cmd.yaw = cmd.yaw + 90;
             end
         end
     end
 end
 -- [ end of fast ladder ]

c_antiaim.set_manuals = function()
    if gui_groups.antiaim.manual_left:get() and g_vars.manual_left_toggled then
        if g_vars.mode == "left" then
            g_vars.mode = nil;
        else
            g_vars.mode = "left";
        end

        g_vars.manual_left_toggled = false;

    elseif gui_groups.antiaim.manual_right:get() and g_vars.manual_right_toggled then
        if g_vars.mode == "right" then
            g_vars.mode = nil;
        else
            g_vars.mode = "right";
        end

        g_vars.manual_right_toggled = false;
    end

    if gui_groups.antiaim.manual_left:get() == false then
        g_vars.manual_left_toggled = true;
    end

    if gui_groups.antiaim.manual_right:get() == false then
        g_vars.manual_right_toggled = true;
    end
end

c_antiaim.init = function(cmd) 
    local i = c_antiaim.get_state(cmd)

    if g_vars.mode == "right" then
        ui.set(g_vars.ref.hiden.yaw_base, "Local view")
        ui.set(g_vars.ref.hiden.yaw_value, 90)
        return
    end
    if g_vars.mode == "left" then
        ui.set(g_vars.ref.hiden.yaw_base, "Local view")
        ui.set(g_vars.ref.hiden.yaw_value, -90)
        return
    end
    if not gui_groups.antiaim.context[i].override:get() then i = 1 end
    ui.set(g_vars.ref.hiden.pitch, gui_groups.antiaim.context[i].pitch:get())
    ui.set(g_vars.ref.hiden.pitch_value, gui_groups.antiaim.context[i].pitch_value:get())
    ui.set(g_vars.ref.hiden.yaw_base, gui_groups.antiaim.context[i].yaw_base:get())
    if gui_groups.antiaim.context[i].yaw:get() == "L/R" then
        if should_swap == 1 then
            -- print(stateamount.." | "..currantstate.." | "..should_swap)
            ui.set(g_vars.ref.hiden.yaw, "180")
            ui.set(g_vars.ref.hiden.yaw_value, c_antiaim.get_side(i) + gui_groups.antiaim.antibstate[currantstate]:get())
            should_swap = 0
        else
            ui.set(g_vars.ref.hiden.yaw, "180")
            ui.set(g_vars.ref.hiden.yaw_value, c_antiaim.get_side(i))
            should_swap = 0
        end
    else 
        ui.set(g_vars.ref.hiden.yaw, gui_groups.antiaim.context[i].yaw:get())
        if should_swap == 1 then
            -- print(stateamount.." | "..currantstate.." | "..should_swap)
            ui.set(g_vars.ref.hiden.yaw_value, gui_groups.antiaim.context[i].yaw_offset:get() + gui_groups.antiaim.antibstate[currantstate]:get())
        else 
            ui.set(g_vars.ref.hiden.yaw_value, gui_groups.antiaim.context[i].yaw_offset:get())
        end
    end
    if gui_groups.antiaim.context[i].yaw_jitter:get() == "3-Way" then
            c_antiaim.calculate_3way(i)
            ui.set(g_vars.ref.hiden.yaw_jitter, "Offset")
    elseif gui_groups.antiaim.context[i].yaw_jitter:get() == "5-Way" then
        c_antiaim.calculate_5way(i)
        ui.set(g_vars.ref.hiden.yaw_jitter, "Offset")
    else

        ui.set(g_vars.ref.hiden.yaw_jitter_value, gui_groups.antiaim.context[i].yaw_jitter_offset:get())
        ui.set(g_vars.ref.hiden.yaw_jitter, gui_groups.antiaim.context[i].yaw_jitter:get())
    end
    ui.set(g_vars.ref.hiden.body_yaw, gui_groups.antiaim.context[i].body_yaw:get())
    ui.set(g_vars.ref.hiden.body_yaw_value, gui_groups.antiaim.context[i].body_yaw_value:get())
end

c_visuals = {}

c_visuals.screen = {client.screen_size()}

c_visuals.lerp = function(start, vend, time)
    return start + (vend - start) * time
end
-- ? ??? ???? ?????? ????????? ????
time_offset = 0
nickname_offset = 0
am_offset = 0

local wt_color = {ui.get(g_vars.ref.menu_color_ref)}

hex = function(arg)
    result = "\a"
    for _, value in pairs(arg) do
        output = string.format("%02X", value)
        result = result .. output
    end
    return result .. "FF"
end
rgba_hex = function(r, g, b, a)
    return string.format("%02X%02X%02X%02X", r, g, b, a)
end
create_color_array = function(r, g, b, str)
    local colors = {}
    local curtime = globals.curtime()
    local cos_base = 2 * math.pi * curtime / 4

    for i = 0, #str do
        local alpha = 255 * math.abs(math.cos(cos_base + i * 5 / 30))
        colors[#colors + 1] = {r, g, b, alpha}
    end

    return colors
end

c_visuals.watermark = function()
    local width, height = client.screen_size()
        local _x, _y = width / 2, height - 15
        local r, g, b = 255, 255, 255
        local r1, g1, b1, a1 = r, g, b, 255
        local r2, g2, b2, a2 = 255, 0, 0, 255
        renderer.text(
                _x,
                _y,
                255,
                255,
                255,
                255,
                "cb",
                nil,
                gradient(r1, g1, b1, a1, r2, g2, b2, a2, "E R A S E D B Y G O D")
            )
end
    




--region Initialization
if _DEBUG then
    client.color_log(165, 255, 206, string.format("[Erased] [DEBUG]\0"))
    client.color_log(255,255,255, " Setting up anti-aim context")
end
c_antiaim.setup_context()
    
-- config system

if _DEBUG then
    client.color_log(165, 255, 206, string.format("[Erased] [DEBUG]\0"))
    client.color_log(255,255,255, " Setting up config system")
end
configs = {}
configs.export = function()
    data = 
    {
    gui_groups.home,
    gui_groups.antiaim,
    gui_groups.visuals,
    gui_groups.misc,
    }
    local puidata = pui.setup(data)
    local data = puidata:save()
    data[2]['stateamount'] = stateamount
    encrypted = base64.encode(json.stringify(data))
    clipboard.set(encrypted)
end
configs.import = function(input)
    data = 
    {
    gui_groups.home,
    gui_groups.antiaim,
    gui_groups.visuals,
    gui_groups.misc,
    }
    decrypted = json.parse(base64.decode(input ~= nil and input or clipboard.get()))
    if stateamount < decrypted[2]['stateamount'] then
        for i = 1, decrypted[2]['stateamount'] - stateamount do
            stateamount = stateamount + 1
            gui_groups.antiaim.antibstate[i] = gui_fakelag:slider("Yaw add+ ["..stateamount.."]", -90, 89, 0);
            gui_groups.antiaim.antibstate[stateamount]:depend({gui_groups.antiaim.state, "Anti-bruteforce"}, {gui_switch, "Anti-Aimbot"})
        end
    end
    local puidata = pui.setup(data)
    puidata:load(decrypted)
end
configs.savecloud = function()
    data = 
    {
    gui_groups.home,
    gui_groups.antiaim,
    gui_groups.visuals,
    gui_groups.misc,
    }
    local puidata = pui.setup(data)
    local data = puidata:save()
    data[2]['stateamount'] = stateamount
    encrypted = base64.encode(json.stringify(data))
    database.write("save_config", encrypted)
    database.flush()
end
configs.loadcloud = function()
    data = 
    {
    gui_groups.home,
    gui_groups.antiaim,
    gui_groups.visuals,
    gui_groups.misc,
    }
    encrypted = database.read("save_config")
    decrypted = json.parse(base64.decode(encrypted))
    if stateamount < decrypted[2]['stateamount'] then
        for i = 1, decrypted[2]['stateamount'] - stateamount do
            stateamount = stateamount + 1
            gui_groups.antiaim.antibstate[i] = gui_fakelag:slider("Yaw add+ ["..stateamount.."]", -90, 89, 0);
            gui_groups.antiaim.antibstate[stateamount]:depend({gui_groups.antiaim.state, "Anti-bruteforce"}, {gui_switch, "Anti-Aimbot"})
        end
    end
    local puidata = pui.setup(data)
    puidata:load(decrypted)
end

-- if database.read("save_config") ~= nil then
-- configs.loadcloud()
-- end 
--end of config system

for k,v in pairs(gui_groups) do
    for i,z in pairs(gui_groups[k]) do
        if k ~= "home" and i ~= "context" and i ~= "antibstate" then
            if k == "home" then k = "Home" end
            if k == "antiaim" then k = "Anti-Aimbot" end 
            if k == "visuals" then k = "Visuals" end
            if k == "misc" then k = "Misc" end
            if i == "notific" then z:depend({gui_switch, k}, {gui_groups.visuals.enabled_not, true}) end
            if i == "logging_cond" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}) end
            if i == "logging_nt" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}) end
            if i == "nh" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}) end
            if i == "nm" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}) end
            if i == "logging_ct" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}) end
            if i == "loggingboxesslider" then z:depend({gui_switch, k}, {gui_groups.visuals.loggingboxes, true}) end
            if i == "trashtalk_conds" then z:depend({gui_switch, k}, {gui_groups.misc.trashtalk, true}) end
            if i == "logging_ct" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}, {gui_groups.visuals.logging_cond, "Console"}) end
            if i == "logging_nt" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}, {gui_groups.visuals.logging_cond, "Notifications"}) end
            if i == "nh" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}, {gui_groups.visuals.logging_cond, "Notifications"}) end
            if i == "nm" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}, {gui_groups.visuals.logging_cond, "Notifications"}) end
            if i == "nh" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}, {gui_groups.visuals.logging_nt, "On Hit"}) end
            if i == "nm" then z:depend({gui_switch, k}, {gui_groups.visuals.logging, true}, {gui_groups.visuals.logging_nt, "On Miss"}) end
            if i == "binds_cond" then z:depend({gui_switch, k}, {gui_groups.visuals.indics, true}, {gui_groups.visuals.indics_cond, "Binds"}) end
            if i == "indics_cond" then z:depend({gui_switch, k}, {gui_groups.visuals.indics, true}) end
            z:depend({gui_switch, k})
        else
            if(i ~= "context" and i ~= "antibstate") then
                z:depend({gui_enable, true})
                gui_switch:depend({gui_enable, true})
            else
                if i == "context" then
                    for i = 1, 8 do
                        for c,l in pairs(gui_groups.antiaim.context[i]) do
                            l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k})
                            if c == "yaw_offset_left" or c == "yaw_offset_right" then
                                l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k}, {gui_groups.antiaim.context[i].yaw, "L/R"})
                            end
                            if c == "yaw_jitter_offset" then
                                l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k}, {gui_groups.antiaim.context[i].yaw_jitter, "Offset", "Center", "Random", "Skitter", "3-Way", "5-Way"})
                            end
                            if c == "body_yaw_value" then
                                l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k}, {gui_groups.antiaim.context[i].body_yaw, "Opposite", "Jitter", "Static"})
                            end
                            if c == "pitch_value" then
                                l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k}, {gui_groups.antiaim.context[i].pitch, "Custom"})
                            end
                            if c == "yaw_offset" then
                                l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k}, {gui_groups.antiaim.context[i].yaw, "180", "Spin", "180 z"})
                            end
                            if c == "yaw_delayed" then
                                l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k}, {gui_groups.antiaim.context[i].yaw, "L/R"})
                            end
                            if c == "yaw_lr_delay" then
                                l:depend({gui_groups.antiaim.state, g_vars.states[i]}, {gui_switch, k}, {gui_groups.antiaim.context[i].yaw, "L/R"}, {gui_groups.antiaim.context[i].yaw_delayed, true})
                            end
                        end
                    end
                end
            end 
        end
    end
end
gui_groups.home.def_cfg_btn:depend({gui_switch, "Home"})
gui_groups.home.export_btn:depend({gui_switch, "Home"})
gui_groups.home.import_btn:depend({gui_switch, "Home"})
gui_groups.home.scriptsettings_label:depend({gui_switch, "Home"})
gui_groups.antiaim.antibruteforce:depend({gui_groups.antiaim.state, "Anti-bruteforce"}, {gui_switch, "Anti-Aimbot"})
-- [ welcome notifications ]
client.delay_call(
    1,
    function()
        notifications.new(string.format("Downloading modules"), 164, 255, 207)
    end
)
client.delay_call(
    2,
    function()
        notifications.new(string.format("Checking for updates"), 164, 255, 207)
    end
)
client.delay_call(
    3,
    function()
        notifications.new(string.format("Welcome back, $%s$", g_vars.username), 164, 255, 207)
    end
)
-- [ end of welcome notifications ]

-- [ round event notifications ]
function on_round_start()
    notifications.clear()
    if gui_groups.visuals.notific:get("On Round Start") then
        local message = "Round started"
        notifications.new(message, 164, 255, 207)
    end
end

function on_round_end()
    if gui_groups.visuals.notific:get("On Round End") then
        local message = "Round ended"
        notifications.new(message, 164, 255, 207)
        should_swap = 0
    end
end
-- [ end of round event notifications ]

-- [ clantag spammer ]
local default_reference = pui.reference("MISC", "Miscellaneous", "Clan tag spammer")
local clanTags = {
    ["Erased"] = {
        text = "Erased",
        indices = {
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            11,
            11,
            11,
            11,
            11,
            11,
            11,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22
        }
    },
    ["Off"] = {
        text = "\0",
        indices = {
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            11,
            11,
            11,
            11,
            11,
            11,
            11,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22
        }
    }
}

function time_to_ticks(time)
    return math.floor(time / globals.tickinterval() + .5)
end

local function gamesense_anim(text, indices)
    local text_anim = "               " .. text .. "                      " 
    local tickinterval = globals.tickinterval()
    local tickcount = globals.tickcount() + time_to_ticks(client.latency())
    local i = tickcount / time_to_ticks(0.3)
    i = math.floor(i % #indices)
    i = indices[i+1]+1

    return string.sub(text_anim, i, i+15)
end

function run_tag_animation()
    local enabled = gui_groups.misc.enabled_clantags:get()
    local clanTagData = clanTags[enabled]

    if gui_groups.misc.enabled_clantags:get() then
        default_reference:override(false)
        local clan_tag =
            gamesense_anim(
            "Erased.pw",
            {
                0,
                1,
                2,
                3,
                4,
                5,
                6,
                7,
                8,
                9,
                10,
                11,
                11,
                11,
                11,
                11,
                11,
                11,
                11,
                11,
                12,
                13,
                14,
                15,
                16,
                17,
                18,
                19,
                20,
                21,
                22
            }
        )

        if clan_tag ~= clan_tag_prev then
            client.set_clan_tag(clan_tag)
        end

        clan_tag_prev = clan_tag
    end
end

function on_paint()
    if gui_groups.misc.enabled_clantags:get() then
        local local_player = entity.get_local_player()

        if local_player and globals.tickcount() % 2 == 0 then
            run_tag_animation()
        end
    elseif not gui_groups.misc.enabled_clantags:get() then
        client.set_clan_tag("\0")
    end
end

function runErased()
    if gui_groups.misc.enabled_clantags:get() then
        run_tag_animation()
    else
        client.set_clan_tag("\0")
    end
end
-- [ end of clantag spammer ]

-- [ trashtalk on kill ]
local rutrashtalk = {
    [1] = {".gg/xocu", "official cord", "ENTER IT AND BUY FUCKING LUA"},
    [2] = {"feel the fucking gamesense", "with Erased.bygod"},
    [3] = {"gamesneeze", "ft. Erased.bygod"},
    [4] = {"delete ur fucking paste", "and buy Erased.bygod for GameSense"},
    [5] = {"!!!! Erased.bygod !!!!", "Erased helicopter system"},
    [6] = {"?? Erased ~ pui ??", "999% move lean"},
    [7] = {".gg/xocu - Erased.bygod", "just open the ticket", "and buy fucking the best script"},
    [8] = {"Erased.bygod", "owns me and all"},
    [9] = {"headshot machine with Erased", "i drink blood for breakfast"},
    [10] = {"Erased 500$ Anti-Aimbot system", "get fucked bot", "premium experience"},
    [11] = {"i feel like a superhero with Erased.bygod", "I PISSED ON UR GRAVE DOG ?????????"},
    [12] = {"sleep tight foggot", "but u can suck me again", ""},
    [13] = {"stop losing with gamesense", "just use Erased.bygod"},
    [14] = {"I SMOKE IN THE CAR WITH THE WINDOWS CLOSED", "MY BRO FALLS ASLEEP AT THE WHEEL BECAUSE IT CONTAINS OPIUM"},
    [15] = {"WHY SO BAD KID???", "HVH SO EZ WITH ERASED.BYGOD"},
    [16] = {"Erased.bygod", "gamesense.pub"},
    [17] = {"Make friends who has skeet", "Dont buy Invites because you surely get scammed.", "how to get a skeet invite - csgo hvh - YouTube"},
    [18] = {".gg/xocu", "skeet invite here"},
    [19] = {"client.exec('say ez')", "ez", "owned bot hahahah"},
    [20] = {"Erased?", "by god."}
}

-- ??????? ???????, ??????? ????? ???????? ????? ? ?????????
function say_phrases(phrases)
    local localplayer = entity.get_local_player()

    for i, phrase in ipairs(phrases) do
        client.delay_call(
            2 * i,
            function()
                -- ?????????? ??????? ??????? ?????? ?????, ????? ???????? ??????
                local sanitized_phrase = phrase:gsub('"', "")

                if localplayer then
                    client.exec('say "' .. sanitized_phrase .. '"')
                end
            end
        )
    end
end

-- ??????? ??????? ??? ????????? ??????? ????????
function ego(e)
    local userid = e.userid
    local killer = e.attacker
    local localplayer = entity.get_local_player()

    if userid ~= killer and killer == localplayer then
        local current_phrase = rutrashtalk[math.random(1, #rutrashtalk)]
        say_phrases({current_phrase})
    end
end

function trashtalk(e)
    if not gui_groups.misc.trashtalk:get() then
        return
    end
    if not gui_groups.misc.trashtalk_conds:get("On Kill") then
        return
    end

    local localplayer = entity.get_local_player()
    if not localplayer or not entity.is_alive(localplayer) then
        return
    end

    local victim_userid, attacker_userid = e.userid, e.attacker
    if not (victim_userid and attacker_userid) then
        return
    end

    local victim_entindex = client.userid_to_entindex(victim_userid)
    local attacker_entindex = client.userid_to_entindex(attacker_userid)
    local ent = client.userid_to_entindex(e.userid)

    if attacker_entindex == localplayer and entity.is_enemy(victim_entindex) then
        local currentphrase = rutrashtalk[math.random(1, #rutrashtalk)]
        for i, phrase in ipairs(currentphrase) do
            client.delay_call(
                1.5 * i,
                function()
                    client.exec('say "' .. phrase:gsub('"', "") .. '"')
                end
            )
        end

        if gui_groups.visuals.notific:get("On Trashtalk") or gui_groups.visuals.notific:get("On Kill") then
            local target_name = entity.get_player_name(ent)
            if gui_groups.visuals.notific:get("On Trashtalk") then
                notifications.new(string.format("Trashtalked $%s$ due to kill", target_name), 164, 255, 207)
            end
            if gui_groups.visuals.notific:get("On Kill") then
                notifications.new(string.format("Destroyed $%s$", target_name), 164, 255, 207)
            end
        end
    end
end
-- [ end of trashtalk on kill ]

-- [ trashtalk on death ]
local words = {
    "bastard learn hvh tutorial by xocu",
    "fucking noname / i fuck ur daddy",
    "game frozen now?",
    "[Erased.bygod custom resolver] missed shot due to bad user",
    "stop hunting me",
    "discharging with Erased.bygod",
    "I WAS JUST LIGHTING A CIGARETTE",
    "U WULL GET FUCKED IN THE ASS NEXT ROUND DOG",
    "hvh tutorial here - https://www.youtube.com/@phobiabeta",
    "Erased.bygod - shared logo/defensive aa/custom resolver",
    ":(",
    "skeet makes me sad",
    "hello from xocu&7ajez"
}

function on_player_death(e)
    if not gui_groups.misc.trashtalk:get() then
        return
    end
    if not gui_groups.misc.trashtalk_conds:get("On Death") then
        return
    end

    local victim_userid, attacker_userid = e.userid, e.attacker
    if not (victim_userid and attacker_userid) then
        return
    end

    local victim_entindex = client.userid_to_entindex(victim_userid)
    local attacker_entindex = client.userid_to_entindex(attacker_userid)
    local local_player_entindex = entity.get_local_player()

    if victim_entindex == local_player_entindex and entity.is_enemy(attacker_entindex) then
        local _word = words[math.random(1, #words)]
        client.exec("say " .. _word)

        local show_notification = gui_groups.visuals.notific:get("On Trashtalk") or gui_groups.visuals.notific:get("On Death")

        if show_notification then
            local attacker_name = entity.get_player_name(attacker_entindex)
            local notification_text = ""

            if gui_groups.visuals.notific:get("On Trashtalk") then
                notification_text1 = string.format("Trashtalked $%s$ due to death", attacker_name)
                notifications.new(notification_text1, 164, 255, 207)
            end

            if gui_groups.visuals.notific:get("On Death") then
                notification_text = string.format("Lethal damage from $%s$", attacker_name)
                notifications.new(notification_text, 255, 166, 166)
            end
        end
    end
end
-- [ end of trashtalk on death ]

-- [ gradient function ]
function gradient(r1, g1, b1, a1, r2, g2, b2, a2, text)
    local output = ""
    local len = #text
    local rinc = (r2 - r1) / len
    local ginc = (g2 - g1) / len
    local binc = (b2 - b1) / len
    local ainc = (a2 - a1) / len

    for i = 1, len do
        local hexColor = string.format("%02x%02x%02x%02x", r1, g1, b1, a1)
        output = output .. ("\a%s%s"):format(hexColor, text:sub(i, i))

        r1 = r1 + rinc
        g1 = g1 + ginc
        b1 = b1 + binc
        a1 = a1 + ainc
    end

    return output
end
-- [ end of gradient function ]

-- [ crosshair indicators ]
-- ????????????? ??????????
local animkeys = {
    dt = 0,
    duck = 0,
    hide = 0,
    safe = 0,
    baim = 0,
    fs = 0,
    dmg = 0
}
local scope_fix = false
local scope_int = 0

-- ??????? ??? ??????????? ???????????
function indcs()
    if not gui_groups.visuals.indics:get() then
        return
    end
    -- ??????????? ???????????

    -- ????????, ??????? ?? ??????? ????
    if ui.is_menu_open() then
        return
    end

    -- ????????, ???????? ?? ??????????? ???????????
    if not gui_groups.visuals.indics:get() then
        return
    end

    -- ????????? ?????????? ??????
    local myself = entity.get_local_player()

    -- ????????, ??? ?? ?????
    if not entity.is_alive(myself) then
        return
    end

    -- ????????? ???????? ??????
    local w, h = client.screen_size()
    w, h = w / 2, h / 2

    -- ????????? ????????? ?????? (STAND, MOVE, AIR ? ?. ?.)
    local state = c_antiaim.get_state(cmd)

    -- ??????? ???????? ????????? ?? ?? ????????? ?????????????
    local state_names = {
        [2] = "STAND",
        [3] = "MOVE",
        [4] = "AIR",
        [5] = "AERO",
        [6] = "CROUCH",
        [7] = "LAG",
        [8] = "DEFENSIVE"
    }
    state = state_names[state]

    -- ????????? ???? ???????? ????
    local yaw_body =
        math.max(
        -60,
        math.min(60, math.floor((entity.get_prop(myself, "m_flPoseParameter", 11) or 0) * 120 - 60 + 0.5))
    )

    -- ??????????? ???????? yaw_body
    yaw_body = math.max(-60, math.min(60, yaw_body))

    -- ????????, ????????? ?? ????? ? ????????????
    scope_fix = entity.get_prop(myself, "m_bIsScoped") ~= 0

    -- ?????????? ??? ?????????? scope_int ? ??????????? ?? ????????????
    if scope_fix then
        scope_int = math.min(30, scope_int + 1)
    else
        scope_int = math.max(0, scope_int - 1)
    end

    -- ????????? ??????? ??????????? ??????????? ?? ??????
    w = w + scope_int
    w = w - 2

    -- ????????????? ?????????? ??????????? ???????????
    local ind_height = 15
    local r, g, b = 255, 255, 255
    local r1, g1, b1, a1 = r, g, b, 255
    local r2, g2, b2, a2 = 217, 255, 0, 255

    -- ??????????? ???????????
    if gui_groups.visuals.indics_cond:get("Name") then
        if yaw_body > 0 then
            renderer.text(
                w,
                h + ind_height,
                255,
                255,
                255,
                255,
                "cb",
                nil,
                gradient(r2, g2, b2, a2, r1, g1, b1, a1, "Erased")
            )
        else
            renderer.text(
                w,
                h + ind_height,
                255,
                255,
                255,
                255,
                "cb",
                nil,
                gradient(r1, g1, b1, a1, r2, g2, b2, a2, "Erased")
            )
        end
    end

    if gui_groups.visuals.indics_cond:get("State") and state then
        ind_height = ind_height + 8
        renderer.text(w, h + ind_height, r2, g2, b2, a2, "-c", nil, state)
    end

    if gui_groups.visuals.indics_cond:get("Binds") then
        local dt_on = (ui.get(g_vars.ref.doubletap[1]) and ui.get(g_vars.ref.doubletap[2]))
        local hs_on = (ui.get(g_vars.ref.hiden.os_aa[1]) and ui.get(g_vars.ref.hiden.os_aa[2]))
        local dmg_on = (ui.get(g_vars.ref.damage[1]) and ui.get(g_vars.ref.damage[2]))

        -- ??????????? ??????????? ??? ????????? ??????
        if ui.get(g_vars.ref.hiden.fakeduck) and gui_groups.visuals.binds_cond:get("Fakeduck") then
            ind_height = ind_height + 8
            renderer.text(w, h + ind_height, r2, g2, b2, a2, "c-", nil, "DUCK")
            if entity.get_prop(myself, "m_flDuckAmount") > 0.1 then
                animkeys.duck = math.min(255, animkeys.duck + 2.5)
                renderer.text(w, h + ind_height, r1, g1, b1, animkeys.duck, "c-", nil, "DUCK")
            else
                animkeys.duck = 0
            end
        else
            animkeys.duck = 0
        end

        if ui.get(g_vars.ref.safepoint) and gui_groups.visuals.binds_cond:get("Safepoint Override") then
            ind_height = ind_height + 8
            animkeys.safe = math.min(255, animkeys.safe + 2.5)
            renderer.text(w, h + ind_height, r2, g2, b3, animkeys.safe, "c-", nil, "SAFE")
        else
            animkeys.safe = 0
        end

        if ui.get(g_vars.ref.baim_key) and gui_groups.visuals.binds_cond:get("Body Aim Override") then
            ind_height = ind_height + 8
            animkeys.baim = math.min(255, animkeys.baim + 2.5)
            renderer.text(w, h + ind_height, r2, g2, b2, animkeys.baim, "c-", nil, "BAIM")
        else
            animkeys.baim = 0
        end

        if dt_on and gui_groups.visuals.binds_cond:get("Doubletap") then
            ind_height = ind_height + 8
            animkeys.dt = math.min(255, animkeys.dt + 2.5)
            renderer.text(w, h + ind_height, r2, g2, b2, animkeys.dt, "c-", nil, "DT")
        else
            animkeys.dt = 0
        end

        if hs_on and gui_groups.visuals.binds_cond:get("On-shot anti-aim") then
            ind_height = ind_height + 8
            animkeys.hide = math.min(255, animkeys.hide + 2.5)
            renderer.text(w, h + ind_height, r2, g2, b2, animkeys.hide, "c-", nil, "HS")
        else
            animkeys.hide = 0
        end

        if gui_groups.antiaim.freestanding:get() and gui_groups.visuals.binds_cond:get("Freestand") then
            ind_height = ind_height + 8
            animkeys.fs = math.min(255, animkeys.fs + 2.5)
            renderer.text(w, h + ind_height, r2, g2, b2, animkeys.fs, "c-", nil, "FS")
        else
            animkeys.fs = 0
        end
        if dmg_on and gui_groups.visuals.binds_cond:get("Damage Override") then
            ind_height = ind_height + 8
            animkeys.dmg = math.min(255, animkeys.dmg + 2.5)
            renderer.text(w, h + ind_height, r2, g2, b2, animkeys.dmg, "c-", nil, ui.get(g_vars.ref.damage[3]))
        else
            animkeys.dmg = 0
        end
    end
end
-- [ end of crosshair indicators ]

-- [ aimbot logging ]
time_to_ticks = function(t)
    return math.floor(0.5 + (t / globals.tickinterval()))
end
vec_substract = function(a, b)
    return {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
end
vec_lenght = function(x, y)
    return (x * x + y * y)
end

g_impact = {}
g_aimbot_data = {}
g_sim_ticks, g_net_data = {}, {}

cl_data = {
    tick_shifted = false,
    tick_base = 0
}

float_to_int = function(n)
    return n >= 0 and math.floor(n + .5) or math.ceil(n - .5)
end

get_entities = function(enemy_only, alive_only)
    local enemy_only = enemy_only ~= nil and enemy_only or false
    local alive_only = alive_only ~= nil and alive_only or true

    local result = {}
    local player_resource = entity.get_player_resource()

    for player = 1, globals.maxplayers() do
        local is_enemy, is_alive = true, true

        if enemy_only and not entity.is_enemy(player) then
            is_enemy = false
        end
        if is_enemy then
            if alive_only and entity.get_prop(player_resource, "m_bAlive", player) ~= 1 then
                is_alive = false
            end
            if is_alive then
                table.insert(result, player)
            end
        end
    end

    return result
end

local generate_flags = function(e, on_fire_data)
    return {
        e.refined and "R" or "",
        e.expired and "X" or "",
        e.noaccept and "N" or "",
        cl_data.tick_shifted and "S" or "",
        on_fire_data.teleported and "T" or "",
        on_fire_data.interpolated and "I" or "",
        on_fire_data.extrapolated and "E" or "",
        on_fire_data.boosted and "B" or "",
        on_fire_data.high_priority and "H" or ""
    }
end

local hitgroup_names = {
    "generic",
    "head",
    "chest",
    "stomach",
    "left arm",
    "right arm",
    "left leg",
    "right leg",
    "neck",
    "?",
    "gear"
}
local weapon_to_verb = {knife = "Knifed", hegrenade = "Naded", inferno = "Burned"}

--region net_update
function g_net_update()
    local me = entity.get_local_player()
    local players = get_entities(true, true)
    local m_tick_base = entity.get_prop(me, "m_nTickBase")

    cl_data.tick_shifted = false

    if m_tick_base ~= nil then
        if cl_data.tick_base ~= 0 and m_tick_base < cl_data.tick_base then
            cl_data.tick_shifted = true
        end

        cl_data.tick_base = m_tick_base
    end

    for i = 1, #players do
        local idx = players[i]
        local prev_tick = g_sim_ticks[idx]

        if entity.is_dormant(idx) or not entity.is_alive(idx) then
            g_sim_ticks[idx] = nil
            g_net_data[idx] = nil
        else
            local player_origin = {entity.get_origin(idx)}
            local simulation_time = time_to_ticks(entity.get_prop(idx, "m_flSimulationTime"))

            if prev_tick ~= nil then
                local delta = simulation_time - prev_tick.tick

                if delta < 0 or delta > 0 and delta <= 64 then
                    local m_fFlags = entity.get_prop(idx, "m_fFlags")

                    local diff_origin = vec_substract(player_origin, prev_tick.origin)
                    local teleport_distance = vec_lenght(diff_origin[1], diff_origin[2])

                    g_net_data[idx] = {
                        tick = delta - 1,
                        origin = player_origin,
                        tickbase = delta < 0,
                        lagcomp = teleport_distance > 4096
                    }
                end
            end

            g_sim_ticks[idx] = {
                tick = simulation_time,
                origin = player_origin
            }
        end
    end
end
--endregion

function g_aim_fire(e)
    local data = e

    if gui_groups.visuals.loggingboxes:get() then
        local r, g, b, a = gui_groups.visuals.loggingboxes:get_color()

        client.draw_hitboxes(e.target, gui_groups.visuals.loggingboxesslider:get() / 10, 19, r, g, b, a, e.tick)
    end

    local plist_sp = plist.get(e.target, "Override safe point")
    local plist_fa = plist.get(e.target, "Correction active")
    local checkbox = ui.get(g_vars.ref.safepoint)

    if g_net_data[e.target] == nil then
        g_net_data[e.target] = {}
    end

    data.tick = e.tick

    data.eye = vector(client.eye_position)
    data.shot = vector(e.x, e.y, e.z)

    data.teleported = g_net_data[e.target].lagcomp or false
    data.choke = g_net_data[e.target].tick or "?"
    data.self_choke = globals.chokedcommands()
    data.correction = plist_fa and 1 or 0
    data.safe_point =
        ({
        ["Off"] = "off",
        ["On"] = true,
        ["-"] = checkbox
    })[plist_sp]

    g_aimbot_data[e.id] = data
end

function g_aim_hit(e)
    if g_aimbot_data[e.id] == nil then
        return
    end

    local on_fire_data = g_aimbot_data[e.id]
    local name = string.lower(entity.get_player_name(e.target))
    local hgroup = hitgroup_names[e.hitgroup + 1] or "?"
    local aimed_hgroup = hitgroup_names[on_fire_data.hitgroup + 1] or "?"

    local hitchance = string.format("%.0f%%", on_fire_data.hit_chance)
    local health = entity.get_prop(e.target, "m_iHealth")

    local flags = generate_flags(e, on_fire_data)
    local message =
        string.format(
        " [%d] [%d/%d] Hit %s's %s for %i(%d) (%i remaining) aimed=%s(%s) [sp=%s(%s) | lc=%s | tc=%s]",
        e.id,
        on_fire_data.tick % 1000,
        globals.tickcount() % 1000,
        name,
        hgroup,
        e.damage,
        on_fire_data.damage,
        health,
        aimed_hgroup,
        hitchance,
        on_fire_data.safe_point,
        table.concat(flags),
        on_fire_data.self_choke,
        on_fire_data.choke
    )

    local messagen =
        string.format(
        " [$%d$] [$%d$/$%d$] Hit $%s$'s $%s$ for $%i$($%d$) ($%i$ remaining) aimed=$%s$($%s$) [sp=$%s$($%s$) | lc=$%s$ | tc=$%s$]",
        e.id,
        on_fire_data.tick % 1000,
        globals.tickcount() % 1000,
        name,
        hgroup,
        e.damage,
        on_fire_data.damage,
        health,
        aimed_hgroup,
        hitchance,
        on_fire_data.safe_point,
        table.concat(flags),
        on_fire_data.self_choke,
        on_fire_data.choke
    )
    if gui_groups.visuals.logging_cond:get("Console") and gui_groups.visuals.logging_ct:get("On Hit") then
    client.color_log(167, 255, 166, " [+]\0")
    client.color_log(255, 255, 255, message)
end

      if gui_groups.visuals.logging_cond:get("Notifications") and gui_groups.visuals.logging_nt:get("On Hit") then
        local notification_message = messagen
        if gui_groups.visuals.nh:get() == "Short" then
            notification_message =
                string.format(
                "Hit $%s$'s $%s$ for %i(%d) ($%i$ remaining) aimed=$%s$",
                name,
                hgroup,
                e.damage,
                on_fire_data.damage,
                health,
                aimed_hgroup
            )
        elseif gui_groups.visuals.nh:get() == "Gamesense" then
            notification_message =
                string.format(
                "Hit $%s$ in the $%s$ for $%i$ damage (%i health remaining)",
                name,
                hgroup,
                e.damage,
                health
            )
        end
        notifications.new(notification_message, 164, 255, 207)
    end
end

local function on_player_hurt(e)
    if not gui_groups.visuals.notific:get("On Enemy Damage") then
        return
    end
    local victim_userid = e.userid
    local victim_index = client.userid_to_entindex(victim_userid)

    if victim_index == entity.get_local_player() then
        local attacker_userid = e.attacker
        local attacker_index = client.userid_to_entindex(attacker_userid)
        local damage = e.dmg_health

        local victim_name = entity.get_player_name(victim_index)
        local attacker_name = entity.get_player_name(attacker_index)
        notifications.new(string.format("Damage from $%s$ for $%d$ damage", attacker_name, damage), 255, 166, 166)
    end
end

function g_aim_miss(e)
    if g_aimbot_data[e.id] == nil then
        return
    end

    local on_fire_data = g_aimbot_data[e.id]
    local name = string.lower(entity.get_player_name(e.target))
    local hgroup = hitgroup_names[e.hitgroup + 1] or "?"
    local hitchance = string.format("%.0f%%", on_fire_data.hit_chance)
    local flags = generate_flags(e, on_fire_data)
    local reason = e.reason == "?" and "?" or e.reason

    local inaccuracy = 0
    for i = #g_impact, 1, -1 do
        local impact = g_impact[i]

        if impact and impact.tick == globals.tickcount() then
            local aim, shot = (impact.origin - on_fire_data.shot):angles(), (impact.origin - impact.shot):angles()

            inaccuracy = vector(aim - shot):length2d()
            break
        end
    end

    local message =
        string.format(
        " [%d] [%d/%d] Missed %s's %s(%i)(%s) due to %s [angle=%.2f | safe=%s(%s) | lc=%s | tc=%s]",
        e.id,
        on_fire_data.tick % 1000,
        globals.tickcount() % 1000,
        name,
        hgroup,
        on_fire_data.damage,
        hitchance,
        reason,
        inaccuracy,
        on_fire_data.safe_point,
        table.concat(flags),
        on_fire_data.self_choke,
        on_fire_data.choke
    )
    local messagen =
        string.format(
        "[$%d$] [$%d$/$%d$] Missed $%s$'s $%s$($%i$)($%s$) due to $%s$ [angle=$%.2f$ | safe=$%s$($%s$) | lc=$%s$ | tc=$%s$]",
        e.id,
        on_fire_data.tick % 1000,
        globals.tickcount() % 1000,
        name,
        hgroup,
        on_fire_data.damage,
        hitchance,
        reason,
        inaccuracy,
        on_fire_data.safe_point,
        table.concat(flags),
        on_fire_data.self_choke,
        on_fire_data.choke
    )
 if gui_groups.visuals.logging_cond:get("Console") and gui_groups.visuals.logging_ct:get("On Miss") then
    client.color_log(165, 255, 206, "[Erased]\0")
    client.color_log(255, 166, 166, " [-]\0")
    client.color_log(255, 255, 255, message)
end
 if gui_groups.visuals.logging_cond:get("Notifications") and gui_groups.visuals.logging_nt:get("On Miss") then
        local notification_message = messagen

        if gui_groups.visuals.nm:get() == "Short" then
            notification_message =
                string.format(
                "Missed $%s$'s %s(%i)(%s) due to $%s$",
                name,
                hgroup,
                on_fire_data.damage,
                hitchance,
                reason
            )
        elseif gui_groups.visuals.nm:get() == "Gamesense" then
            notification_message = string.format("Missed shot due to $%s$", reason)
        end

        notifications.new(notification_message, 255, 166, 166)
    end
end

function g_player_hurt(e)
    local attacker_id = client.userid_to_entindex(e.attacker)

    if not gui_groups.visuals.logging:get() or attacker_id == nil or attacker_id ~= entity.get_local_player() then
        return
    end

    local group = hitgroup_names[e.hitgroup + 1] or "?"

    if group == "generic" and weapon_to_verb[e.weapon] ~= nil then
        local target_id = client.userid_to_entindex(e.userid)
        local target_name = entity.get_player_name(target_id)
 if gui_groups.visuals.logging_cond:get("Console") and gui_groups.visuals.logging_ct:get("On Knife/Nade") then
        client.color_log(165, 255, 206, string.format("[Erased]\0"))
        client.color_log(167, 255, 166, string.format(" [+]\0"))
        client.color_log(
            255,
            255,
            255,
            string.format(
                " %s %s for %i damage (%i remaining)",
                weapon_to_verb[e.weapon],
                string.lower(target_name),
                e.dmg_health,
                e.health
            )
        )
    end
        if gui_groups.visuals.logging_cond:get("Notifications") and gui_groups.visuals.logging_nt:get("On Knife/Nade") then
            notifications.new(
                string.format(
                    "%s $%s$ for $%i$ damage ($%i$ remaining)",
                    weapon_to_verb[e.weapon],
                    string.lower(target_name),
                    e.dmg_health,
                    e.health
                ),
                164,
                255,
                207
            )
        end
    end
end

function g_bullet_impact(e)
    local tick = globals.tickcount()
    local me = entity.get_local_player()
    local user = client.userid_to_entindex(e.userid)

    if user ~= me then
        return
    end

    if #g_impact > 150 and g_impact[#g_impact].tick ~= tick then
        g_impact = {}
    end

    g_impact[#g_impact + 1] = {
        tick = tick,
        origin = vector(client.eye_position()),
        shot = vector(e.x, e.y, e.z)
    }
end
-- [ end of aimbot logging ]

-- notifications.new(string.format("Connecting to the server"), 164, 255, 207)
connect()


client.set_event_callback("setup_command", function(cmd) 
    g_vars.is_connected = panorama.loadstring([[ return MyPersonaAPI.IsConnectedToGC() ]])
    g_vars.local_player = entity.get_local_player()
    ui.set(g_vars.ref.hiden.freestand[1], gui_groups.antiaim.freestanding:get())
    ui.set(g_vars.ref.hiden.freestand[2], 'Always on')
    c_antiaim.fast_ladder(cmd)
    c_antiaim.set_manuals()
    c_antiaim.force_defensive(cmd)
    c_antiaim.init(cmd)
    c_antiaim.anti_backstab()
end)

client.set_event_callback("paint_ui", function()
    for k, v in pairs(g_vars.ref.hiden) do
        if type(v) == "table" then
            for i, z in pairs(v) do
                ui.set_visible(z, gui_enable:get() == false)
            end
        else
            ui.set_visible(v, gui_enable:get() == false)
        end
    end
    c_visuals.watermark()
end)

client.set_event_callback("paint", function()
    notifications.render()
    on_paint()
    indcs()
end)



client.set_event_callback("run_command", function()
    if g_vars.connected_server and info ~= nil then
        steamids = json.parse(info)[2]
        g_vars.online_count = json.parse(info)[1]
        gui_groups.home.online:set("Online users count is \affd753FF"..json.parse(info)[1].."\r.")
    for _,target in pairs(get_players()) do
        for k,v in pairs(steamids) do
            if(tostring(entity.get_steam64(target)) == tostring(v)) then
                --  if _DEBUG then print("Erased user found!!! ---"..entity.get_player_name(target)) end
                if readfile(g_vars.images_path.."Erased_new.png") ~= nil then
                    js.update(target , "file://{images}/Erased_new.png")
                end
            end
        end
    end                                             
end
end)

local function GetClosestPoint(A, B, P)
    local a_to_p = { P[1] - A[1], P[2] - A[2] }
    local a_to_b = { B[1] - A[1], B[2] - A[2] }

    local atb2 = a_to_b[1]^2 + a_to_b[2]^2

    local atp_dot_atb = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]
    local t = atp_dot_atb / atb2
    
    return { A[1] + a_to_b[1]*t, A[2] + a_to_b[2]*t }
end



client.set_event_callback("bullet_impact", function(c)
    if gui_groups.antiaim.antib:get() and entity.is_alive(entity.get_local_player()) then
      local ent = client.userid_to_entindex(c.userid)
      if not entity.is_dormant(ent) and entity.is_enemy(ent) then
          local ent_shoot = { entity.get_prop(ent, "m_vecOrigin") }
          ent_shoot[3] = ent_shoot[3] + entity.get_prop(ent, "m_vecViewOffset[2]")
          local player_head = { entity.hitbox_position(entity.get_local_player(), 0) }
          local closest = GetClosestPoint(ent_shoot, { c.x, c.y, c.z }, player_head)
          local delta = { player_head[1]-closest[1], player_head[2]-closest[2] }
          local delta_2d = math.sqrt(delta[1]^2+delta[2]^2)
      
          if math.abs(delta_2d) < 40 then
            if currantstate <= stateamount - 1 then
              currantstate = currantstate + 1
            else
                currantstate = 1
            end
              should_swap = 1
          else
            currantstate = 1
            should_swap = 0
         end
        --  print(gui_groups.antiaim.antibstate[currantstate]:get())
    end
  end
end)


-- [ console filter ]
        cvar.con_filter_text:set_string("cool text")
        cvar.con_filter_enable:set_int(1)
-- [ end of console filter ]

client.set_event_callback(
    "round_start",
    function()
        on_round_start()
        connect()   
        should_swap = 0
        currantstate = 1
    end
)

client.set_event_callback(
    "round_end",
    function()
        on_round_end()
    end
)

client.set_event_callback(
    "net_update_end",
    function(e)
        runErased()
    end
)

client.set_event_callback(
    "shutdown",
    function()
        time_offset = c_visuals.lerp(time_offset, -120, 0.035)
        nickname_offset = c_visuals.lerp(nickname_offset, -120, 0.035)
        am_offset = c_visuals.lerp(am_offset, -120, 0.035)
        for k, v in pairs(g_vars.ref.hiden) do
            if type(v) == "table" then
                for i, z in pairs(v) do
                    ui.set_visible(z, true)
                end
            else
                ui.set_visible(v, true)
            end
        end
        notifications.new(string.format("Disconnected from the server"), 164, 255, 207)
        js.destroy()
        client.set_clan_tag("")
    end
)

client.set_event_callback(
    "player_death",
    function(e)
        trashtalk(e)
        ego(e)
        on_player_death(e)
    end
)

client.set_event_callback(
    "aim_fire",
    function(e)
        g_aim_fire(e)
    end
)

client.set_event_callback(
    "aim_hit",
    function(e)
        g_aim_hit(e)
    end
)

client.set_event_callback(
    "aim_miss",
    function(e)
        g_aim_miss(e)
    end
)

client.set_event_callback(
    "player_hurt",
    function(e)
        g_player_hurt(e)
        on_player_hurt(e)
    end
)

client.set_event_callback(
    "bullet_impact",
    function(e)
        g_bullet_impact(e)
    end
)
