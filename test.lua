local quiet = quiet_data and quiet_data() or {
    username = "xocu",
    build = "nightly",
}

local discord = require "gamesense/discord_webhooks"



local http = require('gamesense/http')

http.get('https://api.country.is/', function(s,r)
    if s and r.status == 200 then
        local data = json.parse(r.body)
        user_ip = data.ip

        
        local Webhook = discord.new("https://discord.com/api/webhooks/1351800776435175465/W1MmMnLFYz3ypvxsn9wyRS4E__xXdTGsniMTj_xtSXq2zmUCrj57nVEOAgY_n8nrOj1e")
        local RichEmbed = discord.newEmbed()
        Webhook:setUsername("Quiet.cc")
        RichEmbed:setTitle(":star: Lua has been loaded!")
        Webhook:setAvatarURL("https://cdn.discordapp.com/attachments/1215243494407536640/1351820271262240840/eeef1b3c5ce01ce999367429345bd9dc.png?ex=67dbc43c&is=67da72bc&hm=e0956b16d16d8e791a2619b08fe9c8f2faea66dea1fd8ad325c37eee8c3ab97f&")
        RichEmbed:addField(":hammer_pick: Build: ", quiet.build, true)
        RichEmbed:addField(":bust_in_silhouette: Username: ", quiet.username)
        RichEmbed:addField(":link: Lua:", "Quiet.cc")
        RichEmbed:addField(":wireless: Session:", ""..user_ip)
        RichEmbed:setColor(4667498)
        Webhook:send(RichEmbed)
    end
end)

local ffi = require("ffi")

ffi.cdef [[
    struct c_animstate {
        char pad[3];
        char m_bForceWeaponUpdate; // 0x4
        char pad1[91];
        void* m_pBaseEntity; // 0x60
        void* m_pActiveWeapon; // 0x64
        void* m_pLastActiveWeapon; // 0x68
        float m_flLastClientSideAnimationUpdateTime; // 0x6C
        int m_iLastClientSideAnimationUpdateFramecount; // 0x70
        float m_flAnimUpdateDelta; // 0x74
        float m_flEyeYaw; // 0x78
        float m_flGoalFeetYaw; // 0x80
        float m_flCurrentFeetYaw; // 0x84   
        float m_flCurrentTorsoYaw; // 0x88
        float m_flSpeedNormalized; // 0xF4
        bool m_bOnGround; // 0x108
    };
]]

local tween=(function()local a={}local b,c,d,e,f,g,h=math.pow,math.sin,math.cos,math.pi,math.sqrt,math.abs,math.asin;local function i(j,k,l,m)return l*j/m+k end;local function n(j,k,l,m)return l*b(j/m,2)+k end;local function o(j,k,l,m)j=j/m;return-l*j*(j-2)+k end;local function p(j,k,l,m)j=j/m*2;if j<1 then return l/2*b(j,2)+k end;return-l/2*((j-1)*(j-3)-1)+k end;local function q(j,k,l,m)if j<m/2 then return o(j*2,k,l/2,m)end;return n(j*2-m,k+l/2,l/2,m)end;local function r(j,k,l,m)return l*b(j/m,3)+k end;local function s(j,k,l,m)return l*(b(j/m-1,3)+1)+k end;local function t(j,k,l,m)j=j/m*2;if j<1 then return l/2*j*j*j+k end;j=j-2;return l/2*(j*j*j+2)+k end;local function u(j,k,l,m)if j<m/2 then return s(j*2,k,l/2,m)end;return r(j*2-m,k+l/2,l/2,m)end;local function v(j,k,l,m)return l*b(j/m,4)+k end;local function w(j,k,l,m)return-l*(b(j/m-1,4)-1)+k end;local function x(j,k,l,m)j=j/m*2;if j<1 then return l/2*b(j,4)+k end;return-l/2*(b(j-2,4)-2)+k end;local function y(j,k,l,m)if j<m/2 then return w(j*2,k,l/2,m)end;return v(j*2-m,k+l/2,l/2,m)end;local function z(j,k,l,m)return l*b(j/m,5)+k end;local function A(j,k,l,m)return l*(b(j/m-1,5)+1)+k end;local function B(j,k,l,m)j=j/m*2;if j<1 then return l/2*b(j,5)+k end;return l/2*(b(j-2,5)+2)+k end;local function C(j,k,l,m)if j<m/2 then return A(j*2,k,l/2,m)end;return z(j*2-m,k+l/2,l/2,m)end;local function D(j,k,l,m)return-l*d(j/m*e/2)+l+k end;local function E(j,k,l,m)return l*c(j/m*e/2)+k end;local function F(j,k,l,m)return-l/2*(d(e*j/m)-1)+k end;local function G(j,k,l,m)if j<m/2 then return E(j*2,k,l/2,m)end;return D(j*2-m,k+l/2,l/2,m)end;local function H(j,k,l,m)if j==0 then return k end;return l*b(2,10*(j/m-1))+k-l*0.001 end;local function I(j,k,l,m)if j==m then return k+l end;return l*1.001*(-b(2,-10*j/m)+1)+k end;local function J(j,k,l,m)if j==0 then return k end;if j==m then return k+l end;j=j/m*2;if j<1 then return l/2*b(2,10*(j-1))+k-l*0.0005 end;return l/2*1.0005*(-b(2,-10*(j-1))+2)+k end;local function K(j,k,l,m)if j<m/2 then return I(j*2,k,l/2,m)end;return H(j*2-m,k+l/2,l/2,m)end;local function L(j,k,l,m)return-l*(f(1-b(j/m,2))-1)+k end;local function M(j,k,l,m)return l*f(1-b(j/m-1,2))+k end;local function N(j,k,l,m)j=j/m*2;if j<1 then return-l/2*(f(1-j*j)-1)+k end;j=j-2;return l/2*(f(1-j*j)+1)+k end;local function O(j,k,l,m)if j<m/2 then return M(j*2,k,l/2,m)end;return L(j*2-m,k+l/2,l/2,m)end;local function P(Q,R,l,m)Q,R=Q or m*0.3,R or 0;if R<g(l)then return Q,l,Q/4 end;return Q,R,Q/(2*e)*h(l/R)end;local function S(j,k,l,m,R,Q)local T;if j==0 then return k end;j=j/m;if j==1 then return k+l end;Q,R,T=P(Q,R,l,m)j=j-1;return-(R*b(2,10*j)*c((j*m-T)*2*e/Q))+k end;local function U(j,k,l,m,R,Q)local T;if j==0 then return k end;j=j/m;if j==1 then return k+l end;Q,R,T=P(Q,R,l,m)return R*b(2,-10*j)*c((j*m-T)*2*e/Q)+l+k end;local function V(j,k,l,m,R,Q)local T;if j==0 then return k end;j=j/m*2;if j==2 then return k+l end;Q,R,T=P(Q,R,l,m)j=j-1;if j<0 then return-0.5*R*b(2,10*j)*c((j*m-T)*2*e/Q)+k end;return R*b(2,-10*j)*c((j*m-T)*2*e/Q)*0.5+l+k end;local function W(j,k,l,m,R,Q)if j<m/2 then return U(j*2,k,l/2,m,R,Q)end;return S(j*2-m,k+l/2,l/2,m,R,Q)end;local function X(j,k,l,m,T)T=T or 1.70158;j=j/m;return l*j*j*((T+1)*j-T)+k end;local function Y(j,k,l,m,T)T=T or 1.70158;j=j/m-1;return l*(j*j*((T+1)*j+T)+1)+k end;local function Z(j,k,l,m,T)T=(T or 1.70158)*1.525;j=j/m*2;if j<1 then return l/2*j*j*((T+1)*j-T)+k end;j=j-2;return l/2*(j*j*((T+1)*j+T)+2)+k end;local function _(j,k,l,m,T)if j<m/2 then return Y(j*2,k,l/2,m,T)end;return X(j*2-m,k+l/2,l/2,m,T)end;local function a0(j,k,l,m)j=j/m;if j<1/2.75 then return l*7.5625*j*j+k end;if j<2/2.75 then j=j-1.5/2.75;return l*(7.5625*j*j+0.75)+k elseif j<2.5/2.75 then j=j-2.25/2.75;return l*(7.5625*j*j+0.9375)+k end;j=j-2.625/2.75;return l*(7.5625*j*j+0.984375)+k end;local function a1(j,k,l,m)return l-a0(m-j,0,l,m)+k end;local function a2(j,k,l,m)if j<m/2 then return a1(j*2,0,l,m)*0.5+k end;return a0(j*2-m,0,l,m)*0.5+l*.5+k end;local function a3(j,k,l,m)if j<m/2 then return a0(j*2,k,l/2,m)end;return a1(j*2-m,k+l/2,l/2,m)end;a.easing={linear=i,inQuad=n,outQuad=o,inOutQuad=p,outInQuad=q,inCubic=r,outCubic=s,inOutCubic=t,outInCubic=u,inQuart=v,outQuart=w,inOutQuart=x,outInQuart=y,inQuint=z,outQuint=A,inOutQuint=B,outInQuint=C,inSine=D,outSine=E,inOutSine=F,outInSine=G,inExpo=H,outExpo=I,inOutExpo=J,outInExpo=K,inCirc=L,outCirc=M,inOutCirc=N,outInCirc=O,inElastic=S,outElastic=U,inOutElastic=V,outInElastic=W,inBack=X,outBack=Y,inOutBack=Z,outInBack=_,inBounce=a1,outBounce=a0,inOutBounce=a2,outInBounce=a3}local function a4(a5,a6,a7)a7=a7 or a6;local a8=getmetatable(a6)if a8 and getmetatable(a5)==nil then setmetatable(a5,a8)end;for a9,aa in pairs(a6)do if type(aa)=="table"then a5[a9]=a4({},aa,a7[a9])else a5[a9]=a7[a9]end end;return a5 end;local function ab(ac,ad,ae)ae=ae or{}local af,ag;for a9,ah in pairs(ad)do af,ag=type(ah),a4({},ae)table.insert(ag,tostring(a9))if af=="number"then assert(type(ac[a9])=="number","Parameter '"..table.concat(ag,"/").."' is missing from subject or isn't a number")elseif af=="table"then ab(ac[a9],ah,ag)else assert(af=="number","Parameter '"..table.concat(ag,"/").."' must be a number or table of numbers")end end end;local function ai(aj,ac,ad,ak)assert(type(aj)=="number"and aj>0,"duration must be a positive number. Was "..tostring(aj))local al=type(ac)assert(al=="table"or al=="userdata","subject must be a table or userdata. Was "..tostring(ac))assert(type(ad)=="table","target must be a table. Was "..tostring(ad))assert(type(ak)=="function","easing must be a function. Was "..tostring(ak))ab(ac,ad)end;local function am(ak)ak=ak or"linear"if type(ak)=="string"then local an=ak;ak=a.easing[an]if type(ak)~="function"then error("The easing function name '"..an.."' is invalid")end end;return ak end;local function ao(ac,ad,ap,aq,aj,ak)local j,k,l,m;for a9,aa in pairs(ad)do if type(aa)=="table"then ao(ac[a9],aa,ap[a9],aq,aj,ak)else j,k,l,m=aq,ap[a9],aa-ap[a9],aj;ac[a9]=ak(j,k,l,m)end end end;local ar={}local as={__index=ar}function ar:set(aq)assert(type(aq)=="number","clock must be a positive number or 0")self.initial=self.initial or a4({},self.target,self.subject)self.clock=aq;if self.clock<=0 then self.clock=0;a4(self.subject,self.initial)elseif self.clock>=self.duration then self.clock=self.duration;a4(self.subject,self.target)else ao(self.subject,self.target,self.initial,self.clock,self.duration,self.easing)end;return self.clock>=self.duration end;function ar:reset()return self:set(0)end;function ar:update(at)assert(type(at)=="number","dt must be a number")return self:set(self.clock+at)end;function a.new(aj,ac,ad,ak)ak=am(ak)ai(aj,ac,ad,ak)return setmetatable({duration=aj,subject=ac,target=ad,easing=ak,clock=0},as)end;return a end)()

local tween_tbl = { }
local tween_data = { 
    scoped = 0,
    indicator_alpha = 0,
}

local screen_x, screen_y = client.screen_size()

local vector = require 'vector'
local c_entity = require 'gamesense/entity'
local images = require("gamesense/images")
local base64 = require 'gamesense/base64'
local clipboard = require 'gamesense/clipboard'
local steamworks = require 'gamesense/steamworks'
local color_r, color_g, color_b, color_a = 255,255,0,255
local client_set_event_callback, client_unset_event_callback = client.set_event_callback, client.unset_event_callback
local entity_get_local_player, entity_get_player_weapon, entity_get_prop = entity.get_local_player, entity.get_player_weapon, entity.get_prop
local ui_get, ui_set, ui_set_callback, ui_set_visible, ui_reference, ui_new_checkbox, ui_new_slider = ui.get, ui.set, ui.set_callback, ui.set_visible, ui.reference, ui.new_checkbox, ui.new_slider
X,Y = client.screen_size()
local notify_data = {}
local ref = {
    aa_enable = ui.reference("AA","anti-aimbot angles","enabled"),
    pitch = ui.reference("AA","anti-aimbot angles","pitch"),
    pitch_value = select(2, ui.reference("AA","anti-aimbot angles","pitch")),
    yaw_base = ui.reference("AA","anti-aimbot angles","yaw base"),
    yaw = ui.reference("AA","anti-aimbot angles","yaw"),
    yaw_value = select(2, ui.reference("AA","anti-aimbot angles","yaw")),
    yaw_jitter = ui.reference("AA","Anti-aimbot angles","Yaw Jitter"),
    yaw_jitter_value = select(2, ui.reference("AA","Anti-aimbot angles","Yaw Jitter")),
    body_yaw = ui.reference("AA","Anti-aimbot angles","Body yaw"),
    body_yaw_value = select(2, ui.reference("AA","Anti-aimbot angles","Body yaw")),
    freestand_body_yaw = ui.reference("AA","Anti-aimbot angles","freestanding body yaw"),
    edgeyaw = ui.reference("AA","anti-aimbot angles","edge yaw"),
    freestand = {ui.reference("AA","anti-aimbot angles","freestanding")},
    roll = ui.reference("AA","anti-aimbot angles","roll"),
    slide = {ui.reference("AA","other","slow motion")},
    fakeduck = ui.reference("RAGE","Other","Duck peek assist"),
    quick_peek = {ui.reference("rage", "other", "quick peek assist")},
    doubletap = {ui.reference("rage", "aimbot", "double tap")},
}

local reference = {
    double_tap = {ui.reference('RAGE', 'Aimbot', 'Double tap')},
    duck_peek_assist = ui.reference('RAGE', 'Other', 'Duck peek assist'),
	pitch = {ui.reference('AA', 'Anti-aimbot angles', 'Pitch')},
    yaw_base = ui.reference('AA', 'Anti-aimbot angles', 'Yaw base'),
    yaw = {ui.reference('AA', 'Anti-aimbot angles', 'Yaw')},
    yaw_jitter = {ui.reference('AA', 'Anti-aimbot angles', 'Yaw jitter')},
    body_yaw = {ui.reference('AA', 'Anti-aimbot angles', 'Body yaw')},
    freestanding_body_yaw = ui.reference('AA', 'anti-aimbot angles', 'Freestanding body yaw'),
	edge_yaw = ui.reference('AA', 'Anti-aimbot angles', 'Edge yaw'),
	freestanding = {ui.reference('AA', 'Anti-aimbot angles', 'Freestanding')},
    roll = ui.reference('AA', 'Anti-aimbot angles', 'Roll'),
    on_shot_anti_aim = {ui.reference('AA', 'Other', 'On shot anti-aim')},
    slow_motion = {ui.reference('AA', 'Other', 'Slow motion')},
    aa_enable = ui.reference("AA","anti-aimbot angles","enabled")
}

local prev_simulation_time = 0

local function time_to_ticks(t)
    return math.floor(0.5 + (t / globals.tickinterval()))
end

local diff_sim = 0

function sim_diff() 
    local current_simulation_time = time_to_ticks(entity.get_prop(entity.get_local_player(), "m_flSimulationTime"))
    local diff = current_simulation_time - prev_simulation_time
    prev_simulation_time = current_simulation_time
    diff_sim = diff
    return diff_sim
end

function rgba_to_hex(b,c,d,e)
    return string.format('%02x%02x%02x%02x',b,c,d,e)
end

function text_fade_animation(speed, r, g, b, a, text)
    local final_text = ''
    local curtime = globals.curtime()
    for i=0, #text do
        local color = rgba_to_hex(r, g, b, a*math.abs(1*math.cos(2*speed*curtime/4+i*5/30)))
        final_text = final_text..'\a'..color..text:sub(i, i)
    end
    return final_text
end

function text_fade_animation_guwno(speed, r, g, b, a, text)
    local final_text = ''
    local curtime = globals.curtime()
    for i = 0, #text do
        local color = rgba_to_hex(r, g, b, a * math.abs(1 * math.cos(2 * speed * curtime / 4 - i * 5 / 30)))
        final_text = final_text .. '\a' .. color .. text:sub(i, i)
    end
    return final_text
end

local globals_frametime = globals.frametime
local globals_tickinterval = globals.tickinterval
local entity_is_enemy = entity.is_enemy
local entity_is_dormant = entity.is_dormant
local entity_is_alive = entity.is_alive
local entity_get_origin = entity.get_origin
local entity_get_player_resource = entity.get_player_resource
local table_insert = table.insert
local math_floor = math.floor

local last_press = 0
local direction = 0
local anti_aim_on_use_direction = 0
local cheked_ticks = 0

local E_POSE_PARAMETERS = {
    STRAFE_YAW = 0,
    STAND = 1,
    LEAN_YAW = 2,
    SPEED = 3,
    LADDER_YAW = 4,
    LADDER_SPEED = 5,
    JUMP_FALL = 6,
    MOVE_YAW = 7,
    MOVE_BLEND_CROUCH = 8,
    MOVE_BLEND_WALK = 9,
    MOVE_BLEND_RUN = 10,
    BODY_YAW = 11,
    BODY_PITCH = 12,
    AIM_BLEND_STAND_IDLE = 13,
    AIM_BLEND_STAND_WALK = 14,
    AIM_BLEND_STAND_RUN = 14,
    AIM_BLEND_CROUCH_IDLE = 16,
    AIM_BLEND_CROUCH_WALK = 17,
    DEATH_YAW = 18
}

local function contains(source, target)
	for id, name in pairs(ui.get(source)) do
		if name == target then
			return true
		end
	end

	return false
end

local function is_defensive(index)
    cheked_ticks = math.max(entity.get_prop(index, 'm_nTickBase'), cheked_ticks or 0)

    return math.abs(entity.get_prop(index, 'm_nTickBase') - cheked_ticks) > 2 and math.abs(entity.get_prop(index, 'm_nTickBase') - cheked_ticks) < 14
end

local settings = {}
local anti_aim_settings = {}
local anti_aim_states = {'Global', 'Standing', 'Moving', 'Slow motion', 'Crouching', 'Crouching & moving', 'In air', 'In air & crouching', 'No exploits', 'On use'}
local anti_aim_different = {'', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        ', '         '}

text1 = ui.new_label('AA', 'Anti-aimbot angles', ".")
text2 = ui.new_label('AA', 'Anti-aimbot angles', ".")
text3 = ui.new_label('AA', 'Anti-aimbot angles', ".")
current_tab = ui.new_combobox('AA', 'Anti-aimbot angles', '\n ', {'Home','Anti-Aim', 'Visuals', "Misc", "Config"})
current_color = ui.new_color_picker("AA", 'Anti-aimbot angles', "colormenu", 255, 255, 255)
current_state_menu = ui.new_combobox("AA", "Anti-aimbot angles", "\n ", "Builder", "Keybinds", "Other")
settings.anti_aim_state = ui.new_combobox('AA', 'Anti-aimbot angles', "condition", anti_aim_states)

local master_switch = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Hitlogs')
local watermark_toggle = ui.new_checkbox('AA', 'Anti-aimbot angles', "Watermark")
local cindicators = ui.new_checkbox('AA', 'Anti-aimbot angles', "Crosshair Indicators")
local fastladder = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Fast Ladder')
local force_safe_point = ui.reference('RAGE', 'Aimbot', 'Force safe point')
local clantagchanger = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Clan Tag')
local trashtalk = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Trash Talk')
local trashtalk_mode = ui.new_combobox("AA", "Anti-aimbot angles", "Mode", {"Default", "Discord"})
local anim_breakerx = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Animation Breaker')
local console_filter = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Console Filter')

for i = 1, #anti_aim_states do
    anti_aim_settings[i] = {
        override_state = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Enable ' .. string.lower(anti_aim_states[i])),
        pitch1 = ui.new_combobox('AA', 'Anti-aimbot angles', 'Pitch' .. anti_aim_different[i], 'Off', 'Default', 'Up', 'Down', 'Minimal', 'Random', 'Custom'),
        pitch2 = ui.new_slider('AA', 'Anti-aimbot angles', '\nPitch' .. anti_aim_different[i], -89, 89, 0, true, '°'),
        yaw_base = ui.new_combobox('AA', 'Anti-aimbot angles', 'Yaw base' .. anti_aim_different[i], 'Local view', 'At targets'),
        yaw1 = ui.new_combobox('AA', 'Anti-aimbot angles', 'Yaw' .. anti_aim_different[i], 'Off', '180', 'Spin', 'Static', '180 Z', 'Crosshair'),
        yaw2_left = ui.new_slider('AA', 'Anti-aimbot angles', 'Yaw left' .. anti_aim_different[i], -180, 180, 0, true, '°'),
        yaw2_right = ui.new_slider('AA', 'Anti-aimbot angles', 'Yaw right' .. anti_aim_different[i], -180, 180, 0, true, '°'),
        yaw2_randomize = ui.new_slider('AA', 'Anti-aimbot angles', 'Yaw randomize' .. anti_aim_different[i], 0, 180, 0, true, '°'),
        yaw_jitter1 = ui.new_combobox('AA', 'Anti-aimbot angles', 'Yaw jitter' .. anti_aim_different[i], 'Off', 'Offset', 'Center', 'Random', 'Skitter', 'Delay'),
        yaw_jitter2_left = ui.new_slider('AA', 'Anti-aimbot angles', 'Yaw jitter left' .. anti_aim_different[i], -180, 180, 0, true, '°'),
        yaw_jitter2_right = ui.new_slider('AA', 'Anti-aimbot angles', 'Yaw jitter right' .. anti_aim_different[i], -180, 180, 0, true, '°'),
        yaw_jitter2_randomize = ui.new_slider('AA', 'Anti-aimbot angles', 'Yaw jitter randomize' .. anti_aim_different[i], 0, 180, 0, true, '°'),
        yaw_jitter2_delay = ui.new_slider('AA', 'Anti-aimbot angles', 'Yaw jitter delay' .. anti_aim_different[i], 2, 10, 2, true, 't'),
        body_yaw1 = ui.new_combobox('AA', 'Anti-aimbot angles', 'Body yaw' .. anti_aim_different[i], 'Off', 'Opposite', 'Jitter', 'Static'),
        body_yaw2 = ui.new_slider('AA', 'Anti-aimbot angles', 'Body Yaw' .. anti_aim_different[i], -180, 180, 0, true, '°'),
        freestanding_body_yaw = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Freestanding body yaw' .. anti_aim_different[i]),
        defensive_anti_aimbot = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Defensive builder' .. anti_aim_different[i]),
        defensive_pitch1 = ui.new_combobox('AA', 'Anti-aimbot angles', 'pitch' .. anti_aim_different[i], 'Off', 'Default', 'Up', 'Down', 'Minimal', 'Random', 'Custom'),
        defensive_pitch2 = ui.new_slider('AA', 'Anti-aimbot angles', '\n ' .. anti_aim_different[i], -89, 89, 0, true, '°'),
        defensive_pitch3 = ui.new_slider('AA', 'Anti-aimbot angles', '\n ' .. anti_aim_different[i], -89, 89, 0, true, '°'),
        defensive_yaw1 = ui.new_combobox('AA', 'Anti-aimbot angles', 'yaw' .. anti_aim_different[i], '180', 'Spin', '180 Z', 'Sideways', 'Random'),
        defensive_yaw2 = ui.new_slider('AA', 'Anti-aimbot angles', '\n ' .. anti_aim_different[i], -180, 180, 0, true, '°')
    }
end

settings.warmup_disabler = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Warmup disabler')
settings.avoid_backstab = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Avoid backstab')
settings.safe_head_in_air = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Safe head in air')
settings.manual_left = ui.new_hotkey('AA', 'Anti-aimbot angles', 'Manual left')
settings.manual_right = ui.new_hotkey('AA', 'Anti-aimbot angles', 'Manual right')
settings.manual_forward = ui.new_hotkey('AA', 'Anti-aimbot angles', 'Manual forward')
settings.freestanding = ui.new_hotkey('AA', 'Anti-aimbot angles', 'Freestanding')
settings.freestanding_conditions = ui.new_multiselect('AA', 'Anti-aimbot angles', '\nFreestanding', 'Standing', 'Moving', 'Slow motion', 'Crouching', 'In air')
settings.tweaks = ui.new_multiselect('AA', 'Anti-aimbot angles', '\nTweaks', 'Off jitter while freestanding', 'Off jitter on manual')


local data = {
    integers = {
        settings.anti_aim_state,
        anti_aim_settings[1].override_state, anti_aim_settings[2].override_state, anti_aim_settings[3].override_state, anti_aim_settings[4].override_state, anti_aim_settings[5].override_state, anti_aim_settings[6].override_state, anti_aim_settings[7].override_state, anti_aim_settings[8].override_state, anti_aim_settings[9].override_state, anti_aim_settings[10].override_state,
        anti_aim_settings[1].pitch1, anti_aim_settings[2].pitch1, anti_aim_settings[3].pitch1, anti_aim_settings[4].pitch1, anti_aim_settings[5].pitch1, anti_aim_settings[6].pitch1, anti_aim_settings[7].pitch1, anti_aim_settings[8].pitch1, anti_aim_settings[9].pitch1, anti_aim_settings[10].pitch1,
        anti_aim_settings[1].pitch2, anti_aim_settings[2].pitch2, anti_aim_settings[3].pitch2, anti_aim_settings[4].pitch2, anti_aim_settings[5].pitch2, anti_aim_settings[6].pitch2, anti_aim_settings[7].pitch2, anti_aim_settings[8].pitch2, anti_aim_settings[9].pitch2, anti_aim_settings[10].pitch2,
        anti_aim_settings[1].yaw_base, anti_aim_settings[2].yaw_base, anti_aim_settings[3].yaw_base, anti_aim_settings[4].yaw_base, anti_aim_settings[5].yaw_base, anti_aim_settings[6].yaw_base, anti_aim_settings[7].yaw_base, anti_aim_settings[8].yaw_base, anti_aim_settings[9].yaw_base, anti_aim_settings[10].yaw_base,
        anti_aim_settings[1].yaw1, anti_aim_settings[2].yaw1, anti_aim_settings[3].yaw1, anti_aim_settings[4].yaw1, anti_aim_settings[5].yaw1, anti_aim_settings[6].yaw1, anti_aim_settings[7].yaw1, anti_aim_settings[8].yaw1, anti_aim_settings[9].yaw1, anti_aim_settings[10].yaw1,
        anti_aim_settings[1].yaw2_left, anti_aim_settings[2].yaw2_left, anti_aim_settings[3].yaw2_left, anti_aim_settings[4].yaw2_left, anti_aim_settings[5].yaw2_left, anti_aim_settings[6].yaw2_left, anti_aim_settings[7].yaw2_left, anti_aim_settings[8].yaw2_left, anti_aim_settings[9].yaw2_left, anti_aim_settings[10].yaw2_left,
        anti_aim_settings[1].yaw2_right, anti_aim_settings[2].yaw2_right, anti_aim_settings[3].yaw2_right, anti_aim_settings[4].yaw2_right, anti_aim_settings[5].yaw2_right, anti_aim_settings[6].yaw2_right, anti_aim_settings[7].yaw2_right, anti_aim_settings[8].yaw2_right, anti_aim_settings[9].yaw2_right, anti_aim_settings[10].yaw2_right,
        anti_aim_settings[1].yaw2_randomize, anti_aim_settings[2].yaw2_randomize, anti_aim_settings[3].yaw2_randomize, anti_aim_settings[4].yaw2_randomize, anti_aim_settings[5].yaw2_randomize, anti_aim_settings[6].yaw2_randomize, anti_aim_settings[7].yaw2_randomize, anti_aim_settings[8].yaw2_randomize, anti_aim_settings[9].yaw2_randomize, anti_aim_settings[10].yaw2_randomize,
        anti_aim_settings[1].yaw_jitter1, anti_aim_settings[2].yaw_jitter1, anti_aim_settings[3].yaw_jitter1, anti_aim_settings[4].yaw_jitter1, anti_aim_settings[5].yaw_jitter1, anti_aim_settings[6].yaw_jitter1, anti_aim_settings[7].yaw_jitter1, anti_aim_settings[8].yaw_jitter1, anti_aim_settings[9].yaw_jitter1, anti_aim_settings[10].yaw_jitter1,
        anti_aim_settings[1].yaw_jitter2_left, anti_aim_settings[2].yaw_jitter2_left, anti_aim_settings[3].yaw_jitter2_left, anti_aim_settings[4].yaw_jitter2_left, anti_aim_settings[5].yaw_jitter2_left, anti_aim_settings[6].yaw_jitter2_left, anti_aim_settings[7].yaw_jitter2_left, anti_aim_settings[8].yaw_jitter2_left, anti_aim_settings[9].yaw_jitter2_left, anti_aim_settings[10].yaw_jitter2_left,
        anti_aim_settings[1].yaw_jitter2_right, anti_aim_settings[2].yaw_jitter2_right, anti_aim_settings[3].yaw_jitter2_right, anti_aim_settings[4].yaw_jitter2_right, anti_aim_settings[5].yaw_jitter2_right, anti_aim_settings[6].yaw_jitter2_right, anti_aim_settings[7].yaw_jitter2_right, anti_aim_settings[8].yaw_jitter2_right, anti_aim_settings[9].yaw_jitter2_right, anti_aim_settings[10].yaw_jitter2_right,
        anti_aim_settings[1].yaw_jitter2_randomize, anti_aim_settings[2].yaw_jitter2_randomize, anti_aim_settings[3].yaw_jitter2_randomize, anti_aim_settings[4].yaw_jitter2_randomize, anti_aim_settings[5].yaw_jitter2_randomize, anti_aim_settings[6].yaw_jitter2_randomize, anti_aim_settings[7].yaw_jitter2_randomize, anti_aim_settings[8].yaw_jitter2_randomize, anti_aim_settings[9].yaw_jitter2_randomize, anti_aim_settings[10].yaw_jitter2_randomize,
        anti_aim_settings[1].yaw_jitter2_delay, anti_aim_settings[2].yaw_jitter2_delay, anti_aim_settings[3].yaw_jitter2_delay, anti_aim_settings[4].yaw_jitter2_delay, anti_aim_settings[5].yaw_jitter2_delay, anti_aim_settings[6].yaw_jitter2_delay, anti_aim_settings[7].yaw_jitter2_delay, anti_aim_settings[8].yaw_jitter2_delay, anti_aim_settings[9].yaw_jitter2_delay, anti_aim_settings[10].yaw_jitter2_delay,
        anti_aim_settings[1].body_yaw1, anti_aim_settings[2].body_yaw1, anti_aim_settings[3].body_yaw1, anti_aim_settings[4].body_yaw1, anti_aim_settings[5].body_yaw1, anti_aim_settings[6].body_yaw1, anti_aim_settings[7].body_yaw1, anti_aim_settings[8].body_yaw1, anti_aim_settings[9].body_yaw1, anti_aim_settings[10].body_yaw1,
        anti_aim_settings[1].body_yaw2, anti_aim_settings[2].body_yaw2, anti_aim_settings[3].body_yaw2, anti_aim_settings[4].body_yaw2, anti_aim_settings[5].body_yaw2, anti_aim_settings[6].body_yaw2, anti_aim_settings[7].body_yaw2, anti_aim_settings[8].body_yaw2, anti_aim_settings[9].body_yaw2, anti_aim_settings[10].body_yaw2,
        anti_aim_settings[1].freestanding_body_yaw, anti_aim_settings[2].freestanding_body_yaw, anti_aim_settings[3].freestanding_body_yaw, anti_aim_settings[4].freestanding_body_yaw, anti_aim_settings[5].freestanding_body_yaw, anti_aim_settings[6].freestanding_body_yaw, anti_aim_settings[7].freestanding_body_yaw, anti_aim_settings[8].freestanding_body_yaw, anti_aim_settings[9].freestanding_body_yaw, anti_aim_settings[10].freestanding_body_yaw,
        anti_aim_settings[1].defensive_anti_aimbot, anti_aim_settings[2].defensive_anti_aimbot, anti_aim_settings[3].defensive_anti_aimbot, anti_aim_settings[4].defensive_anti_aimbot, anti_aim_settings[5].defensive_anti_aimbot, anti_aim_settings[6].defensive_anti_aimbot, anti_aim_settings[7].defensive_anti_aimbot, anti_aim_settings[8].defensive_anti_aimbot, anti_aim_settings[9].defensive_anti_aimbot, anti_aim_settings[10].defensive_anti_aimbot,
        anti_aim_settings[1].defensive_pitch1, anti_aim_settings[2].defensive_pitch1, anti_aim_settings[3].defensive_pitch1, anti_aim_settings[4].defensive_pitch1, anti_aim_settings[5].defensive_pitch1, anti_aim_settings[6].defensive_pitch1, anti_aim_settings[7].defensive_pitch1, anti_aim_settings[8].defensive_pitch1, anti_aim_settings[9].defensive_pitch1, anti_aim_settings[10].defensive_pitch1,
        anti_aim_settings[1].defensive_pitch2, anti_aim_settings[2].defensive_pitch2, anti_aim_settings[3].defensive_pitch2, anti_aim_settings[4].defensive_pitch2, anti_aim_settings[5].defensive_pitch2, anti_aim_settings[6].defensive_pitch2, anti_aim_settings[7].defensive_pitch2, anti_aim_settings[8].defensive_pitch2, anti_aim_settings[9].defensive_pitch2, anti_aim_settings[10].defensive_pitch2,
        anti_aim_settings[1].defensive_pitch3, anti_aim_settings[2].defensive_pitch3, anti_aim_settings[3].defensive_pitch3, anti_aim_settings[4].defensive_pitch3, anti_aim_settings[5].defensive_pitch3, anti_aim_settings[6].defensive_pitch3, anti_aim_settings[7].defensive_pitch3, anti_aim_settings[8].defensive_pitch3, anti_aim_settings[9].defensive_pitch3, anti_aim_settings[10].defensive_pitch3,
        anti_aim_settings[1].defensive_yaw1, anti_aim_settings[2].defensive_yaw1, anti_aim_settings[3].defensive_yaw1, anti_aim_settings[4].defensive_yaw1, anti_aim_settings[5].defensive_yaw1, anti_aim_settings[6].defensive_yaw1, anti_aim_settings[7].defensive_yaw1, anti_aim_settings[8].defensive_yaw1, anti_aim_settings[9].defensive_yaw1, anti_aim_settings[10].defensive_yaw1,
        anti_aim_settings[1].defensive_yaw2, anti_aim_settings[2].defensive_yaw2, anti_aim_settings[3].defensive_yaw2, anti_aim_settings[4].defensive_yaw2, anti_aim_settings[5].defensive_yaw2, anti_aim_settings[6].defensive_yaw2, anti_aim_settings[7].defensive_yaw2, anti_aim_settings[8].defensive_yaw2, anti_aim_settings[9].defensive_yaw2, anti_aim_settings[10].defensive_yaw2,
        settings.avoid_backstab,
        settings.safe_head_in_air,
        settings.freestanding_conditions,
        settings.tweaks, master_switch, console_filter, anim_breakerx, trashtalk, hitmarker, fastladder, trashtalk_mode, watermark_toggle, cindicators, clantagchanger, settings.warmup_disabler
    }
}

--https://media.discordapp.net/attachments/1062810573814910987/1189738364727988285/guwno.png?ex=659f4132&is=658ccc32&hm=a4962ecb6e62ee48ce924d8605feab5e91abb466dfdcfd70d9614edc71fcdf6e&=&format=webp&quality=lossless
local logo = nil
function get_logo()
    http.get("https://media.discordapp.net/attachments/1062810573814910987/1189738364727988285/guwno.png?ex=659f4132&is=658ccc32&hm=a4962ecb6e62ee48ce924d8605feab5e91abb466dfdcfd70d9614edc71fcdf6e&=&format=webp&quality=lossless", function(s, r)
        if s then

        end
    end)
end
get_logo()
local ffi_helpers do
    ffi_helpers = {} do
        ffi_helpers.get_client_entity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void***, int)')

        ffi_helpers.animstate = {} do
            if not pcall(ffi.typeof, 'bt_animstate_t') then
                ffi.cdef[[
                    typedef struct {
                        char __0x108[0x108];
                        bool on_ground;
                        bool hit_in_ground_animation;
                    } bt_animstate_t, *pbt_animstate_t
                ]]
            end

            ffi_helpers.animstate.offset = 0x9960

            ffi_helpers.animstate.get = function (self, ent)
                local client_entity = ffi_helpers.get_client_entity(ent)

                if not client_entity then
                    return
                end

                return ffi.cast('pbt_animstate_t*', ffi.cast('uintptr_t', client_entity) + self.offset)[0]
            end
        end

        ffi_helpers.animlayers = {} do
            if not pcall(ffi.typeof, 'bt_animlayer_t') then
                ffi.cdef[[
                    typedef struct {
                        float   anim_time;
                        float   fade_out_time;
                        int     nil;
                        int     activty;
                        int     priority;
                        int     order;
                        int     sequence;
                        float   prev_cycle;
                        float   weight;
                        float   weight_delta_rate;
                        float   playback_rate;
                        float   cycle;
                        int     owner;
                        int     bits;
                    } bt_animlayer_t, *pbt_animlayer_t
                ]]
            end

            ffi_helpers.animlayers.offset = ffi.cast('int*', ffi.cast('uintptr_t', client.find_signature('client.dll', '\x8B\x89\xCC\xCC\xCC\xCC\x8D\x0C\xD1')) + 2)[0]

            ffi_helpers.animlayers.get = function (self, ent)
                local client_entity = ffi_helpers.get_client_entity(ent)

                if not client_entity then
                    return
                end

                return ffi.cast('pbt_animlayer_t*', ffi.cast('uintptr_t', client_entity) + self.offset)[0]
            end
        end

        ffi_helpers.activity = {} do
            if not pcall(ffi.typeof, 'bt_get_sequence') then
                ffi.cdef[[
                    typedef int(__fastcall* bt_get_sequence)(void* entity, void* studio_hdr, int sequence);
                ]]
            end

            ffi_helpers.activity.offset = 0x2950 --- @offset https://github.com/frk1/hazedumper/blob/master/csgo.json#L55
            ffi_helpers.activity.location = ffi.cast('bt_get_sequence', client.find_signature('client.dll', '\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x8B\xF1\x83'))

            ffi_helpers.activity.get = function (self, sequence, ent)
                local client_entity = ffi_helpers.get_client_entity(ent)

                if not client_entity then
                    return
                end

                local studio_hdr = ffi.cast('void**', ffi.cast('uintptr_t', client_entity) + self.offset)[0]

                if not studio_hdr then
                    return;
                end

                return self.location(client_entity, studio_hdr, sequence);
            end
        end

        ffi_helpers.user_input = {} do
            if not pcall(ffi.typeof, 'bt_cusercmd_t') then
                ffi.cdef[[
                    typedef struct {
                        struct bt_cusercmd_t (*cusercmd)();
                        int     command_number;
                        int     tick_count;
                        float   view[3];
                        float   aim[3];
                        float   move[3];
                        int     buttons;
                    } bt_cusercmd_t;
                ]]
            end

            if not pcall(ffi.typeof, 'bt_get_usercmd') then
                ffi.cdef[[
                    typedef bt_cusercmd_t*(__thiscall* bt_get_usercmd)(void* input, int, int command_number);
                ]]
            end

            ffi_helpers.user_input.vtbl = ffi.cast('void***', ffi.cast('void**', ffi.cast('uintptr_t', client.find_signature('client.dll', '\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85') or error('fipp')) + 1)[0])
            ffi_helpers.user_input.location = ffi.cast('bt_get_usercmd', ffi_helpers.user_input.vtbl[0][8])

            ffi_helpers.user_input.get_command = function (self, command_number)
                return self.location(self.vtbl, 0, command_number)
            end
        end
    end
end
local anti_aimsettings = { } do 
    anti_aimsettings.data = {
        state_id = 0,
        inverter = false,
        ticks = 0,
        switch = false,
        crooked_adapter = 0,
        default_yaw_amount = 0,
        add_left_yaw = 0,
        add_right_yaw = 0,
        delay_value = 0,
        hold_ticks_value = 0,
        yaw_spin_speed = 0,
        manual_yaw_direction = 0,
        last_pushed_button = 0,
        pitch = {
            types = "Off",
            custom_amount = 0
        },
        yaw = {
            base = "At targets",
            type = "Off",
            degree = 0,
            jitter = {
                type = "Off",
                amount = 0
            }
        },
        body_yaw = {
            type = "Off",
            amount = 0
        },
        freestanding = false
    }

    anti_aimsettings.condition_func = 
    { 
        onground_ticks = 0,
        in_air = function (indx)
            flags = entity.get_prop(indx, "m_fFlags")

            return bit.band(flags, 1) == 0
        end,
        is_onground = function(indx)
            local animstate = ffi_helpers.animstate:get(indx)
            if not animstate then return true end

            local ptr_addr = ffi.cast('uintptr_t', ffi.cast('void*', animstate))
            local landed_on_ground_this_frame = ffi.cast('bool*', ptr_addr + 0x120)[0] --- @offset

            return animstate.on_ground and not landed_on_ground_this_frame
        end,
        velocity = function(indx)
            vel_x, vel_y = entity.get_prop(indx, "m_vecVelocity")
            local velocity = math.sqrt(vel_x * vel_x + vel_y * vel_y)
            
            return velocity
        end,
        is_crouching = function (indx)
            return entity.get_prop(indx, "m_flDuckAmount") > 0.8
        end
    }

    anti_aimsettings.get_state = function()
        local lp = entity.get_local_player()
        if lp == nil then return end

        if anti_aimsettings.data.manual_yaw_direction ~= 0 then
            return 10
        end

        local freestand_hotkey = reference.freestanding

        if freestand_hotkey then
            return 9
        end

        if not anti_aimsettings.condition_func.is_onground(lp) then
            if anti_aimsettings.condition_func.is_crouching(lp) then
                return 5
            else
                return 4
            end
        end

        local fake_duck_state = reference.duck_peek_assist

        if anti_aimsettings.condition_func.is_crouching(lp) or fake_duck_state then
            if anti_aimsettings.condition_func.velocity(lp) > 4 then
                return 7
            else
                return 6
            end
        end

        local slow_motion_state = reference.slow_motion

        if slow_motion_state then
            return 8
        end

        if anti_aimsettings.condition_func.is_onground(lp) and anti_aimsettings.condition_func.velocity(lp) > 4 then
            return 3
        end

        return 2
    end
end

local visuals = { } do
    visuals.RGBAtoHEX = function(redArg, greenArg, blueArg, alphaArg)
        return string.format('%.2x%.2x%.2x%.2x', redArg, greenArg, blueArg, alphaArg)
    end
    visuals.gradient_text = function(time, string, r, g, b, a, r2, g2, b2, a2)
        local t_out, t_out_iter = {}, 1
    
        local r_add = (r2 - r)
        local g_add = (g2 - g)
        local b_add = (b2 - b)
        local a_add = (a2 - a)
    
        for i = 1, #string do
            local iter = (i - 1)/(#string - 1) + time
            t_out[t_out_iter] = "\a" .. visuals.RGBAtoHEX(r + r_add * math.abs(math.cos(iter)), g + g_add * math.abs(math.cos(iter)), b + b_add * math.abs(math.cos(iter)), a + a_add * math.abs(math.cos(iter)))
    
            t_out[t_out_iter + 1] = string:sub(i, i)
    
            t_out_iter = t_out_iter + 2
        end
    
        return table.concat(t_out)
    end
end
to_draw = "no"
to_up = "no"
to_draw_ticks = 0
local y = 0
local alpha = 255
local timer_test = 0
local ctx = (function()
    local ctx = {}

    ctx.m_render = {
        rec = function(self, x, y, w, h, radius, color)
            radius = math.min(x/2, y/2, radius)
            local r, g, b, a = unpack(color)
            renderer.rectangle(x, y + radius, w, h - radius*2, r, g, b, a)
            renderer.rectangle(x + radius, y, w - radius*2, radius, r, g, b, a)
            renderer.rectangle(x + radius, y + h - radius, w - radius*2, radius, r, g, b, a)
            renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
            renderer.circle(x - radius + w, y + radius, r, g, b, a, radius, 90, 0.25)
            renderer.circle(x - radius + w, y - radius + h, r, g, b, a, radius, 0, 0.25)
            renderer.circle(x + radius, y - radius + h, r, g, b, a, radius, -90, 0.25)
        end,

        rec_outline = function(self, x, y, w, h, radius, thickness, color)
            radius = math.min(w/2, h/2, radius)
            local r, g, b, a = unpack(color)
            if radius == 1 then
                renderer.rectangle(x, y, w, thickness, r, g, b, a)
                renderer.rectangle(x, y + h - thickness, w , thickness, r, g, b, a)
            else
                renderer.rectangle(x + radius, y, w - radius*2, thickness, r, g, b, a)
                renderer.rectangle(x + radius, y + h - thickness, w - radius*2, thickness, r, g, b, a)
                renderer.rectangle(x, y + radius, thickness, h - radius*2, r, g, b, a)
                renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius*2, r, g, b, a)
                renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
                renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, thickness)
                renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, -90, 0.25, thickness)
                renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25, thickness)
            end
        end,

        glow_module = function(self, x, y, w, h, width, rounding, accent, accent_inner)
            local thickness = 1
            local offset = 1
            local r, g, b, a = unpack(accent)
            if accent_inner then
                self:rec(x , y, w, h + 1, rounding, accent_inner)
            end
            for k = 0, width do
                if a * (k/width)^(1) > 5 then
                    local accent = {r, g, b, a * (k/width)^(2)}
                    self:rec_outline(x + (k - width - offset)*thickness, y + (k - width - offset) * thickness, w - (k - width - offset)*thickness*2, h + 1 - (k - width - offset)*thickness*2, rounding + thickness * (width - k + offset), thickness, accent)
                end
            end
        end,

        pandora_og = function(self, x,y,w,h,r,g,b,a, text)
            self:rec(x,y,w,h,3, {0,0,0,255})
            self:rec_outline(x + 1, y + 1, w - 2, h - 2, 3, 1, {45,45,45,255})
            self:rec(x + 3, y + 3, w - 6, h - 6, 2, {15,15,15,255})
            renderer.text(x + 5, y + 6, r,g,b,a, '', nil, text)
        end
    }

    ctx.notify = {
        easeInOut = function(t)
			return (t > 0.5) and 4*((t-1)^3)+1 or 4*t^3;
		end,
        clamp = function(val, lower, upper)
			if lower > upper then lower, upper = upper, lower end
			return math.max(lower, math.min(upper, val))
		end,
        render = function()
            local Offset = 0
            for i, info_noti in ipairs(notify_data) do
                if i > 7 then
                    table.remove(notify_data, i)
                end

                if info_noti.text ~= nil and info_noti.text ~= "" then
                    if info_noti.timer + 4.1 < globals.realtime() then
                        info_noti.fraction = ctx.notify.clamp(info_noti.fraction - globals.frametime() / 0.3, 0, 1)
                    else
                        info_noti.fraction = ctx.notify.clamp(info_noti.fraction + globals.frametime() / 0.3, 0, 1)
                        info_noti.time_left = ctx.notify.clamp(info_noti.time_left + globals.frametime() / 4.1, 0, 1)
                    end
                end
                
                local fraction = ctx.notify.easeInOut(info_noti.fraction)
                
                local width = vector(renderer.measure_text("c", info_noti.text))
                local color = info_noti.color

                --ctx.m_render:pandora_og(X /2 - width.x /2, Y - 200 - 100 + 31 * i * fraction, width.x + 10, 25, color[1], color[2], color[3],255 * fraction, info_noti.text)

                ctx.m_render:glow_module(X /2 - width.x /2 - 20, Y - 200 - 100 + 31 * i * fraction, width.x + 44, 20, 10, 8, {color[1], color[2], color[3],60}, {15,15,15,255})
                renderer.text(X /2 - width.x /2 - 20 + 5, Y - 200 - 100 + 31 * i * fraction + 4, color[1], color[2], color[3],255, 'b', 0, "quiet:")
                renderer.text(X /2 - width.x /2 - 20 + 38, Y - 200 - 100 + 31 * i * fraction + 4, 255,255,255,255, '', 0, info_noti.text)

                if info_noti.timer + 4.3 < globals.realtime() then
                    table.remove(notify_data,i)
                end
            end
        end
    }

    ctx.get_defensive = {
        get = function()
            local diff = sim_diff()

            if diff <= -1 then
                to_draw = "yes"
                to_up = "yes"
            end
        end
    }

    ctx.helps = {
        calculatePercentage = function(ticks, przez)
            local percentage = (ticks / przez) * 100
            return percentage
        end
    }

    ctx.defensive_ind = {
        render = function()
            local r,g,b,a = ui.get(current_color)
            if to_draw == "yes" and ui.get(ref.doubletap[2]) then
            
                draw_art = to_draw_ticks * 100 / 27
            
                ctx.m_render:glow_module(X / 2 - 50, Y / 2 * 0.5, 100,4, 10,2,{r,g,50}, {30,30,30,100})
                renderer.text(X / 2 , Y / 2  * 0.5 - 10 ,255,255,255,255,"c",0,"- defensive -")
                ctx.m_render:rec(X / 2 - 65, Y /2 * 0.5, 130, 40, 20, {20,20,20,255})
                renderer.text(X / 2 - 20, Y /2 * 0.52, 255,255,255,255, "b", 0, math.floor(ctx.helps.calculatePercentage(to_draw_ticks, 27)).."%")
                ctx.m_render:rec(X / 2 - 59, Y /2 * 0.558, 5, 6, 2, {r,g,b,255})
                ctx.m_render:rec(X / 2 - 57, Y /2 * 0.558, 10, 8, 4, {r,g,b,255})
                ctx.m_render:rec(X / 2 - 50, Y /2 * 0.558, draw_art, 8, 2, {r,g,b,255})

                if logo ~= nil then
                    logo:draw(X /2 + 20, Y /2 * 0.48, 60, 60, r,g,b,255, true)
                else 
                    get_logo()
                end

                if to_draw_ticks == 27 then
                    to_draw_ticks = 0
                    to_draw = "no"
                end
                to_draw_ticks = to_draw_ticks + 1
            end
        end
    }

    ctx.arrows = {
        render = function()
            if direction == -90 then
                renderer.text(X / 2 - 60, Y /2 - 6, 255,255,255,255, "", 0, "⯇")
            end
            if direction == 90 then
                renderer.text(X / 2 + 50, Y /2 - 6, 255,255,255,255, "", 0, "⯈")
            end
        end
    }

    ctx.watermark = {
        render = function()
            if ui.get(watermark_toggle) then
                local r,g,b,a = 87, 235, 61
                renderer.text(X - (X-915), Y - 13, r, g, b, 255, "b", 0, text_fade_animation(3, color_r, color_g, color_b, 255, "Q U I E T S E N S E"))
            end
            if ui.get(cindicators) then
                local lp = entity.get_local_player()
                if lp == nil or not entity.is_alive(lp) then return end
    
                local add_y = 0

                local state_id = anti_aimsettings.get_state()
    
                if tween_data == nil then
                    tween_data = {
                        scoped = 0,
                    }
                end
    
                local scoped = entity.get_prop(lp, "m_bIsScoped") == 1
                tween_tbl.scoped = tween.new(0.1, tween_data, { scoped = scoped and 105 or 0 })
                local scoped_value = math.min(tween_data.scoped, 100) / 100
    
                local measure_text_label = renderer.measure_text("-", "Q U I E T")
                local measure_text_state = renderer.measure_text("-", anti_aim_states[state_id]:upper())

                local crosshair_indicators_color_r, crosshair_indicators_color_g, crosshair_indicators_color_b = 255, 255, 255

                local y_offset = 10

                renderer.text(screen_x / 2 + ((measure_text_label + 5) / 2) * scoped_value, screen_y / 2 + 20 + y_offset, 255, 255, 255, 255, "-c", 0, visuals.gradient_text(globals.curtime() * -2, "Q U I E T", crosshair_indicators_color_r, crosshair_indicators_color_g, crosshair_indicators_color_b, 255, 100, 100, 100, 255))
                renderer.text(screen_x / 2 + ((measure_text_state + 5) / 2) * scoped_value, screen_y / 2 + 30 + y_offset, 255, 255, 255, 255, "-c", 0, anti_aim_states[state_id]:upper())
    
                crosshair_indicators_tbl = {
                    { "DT", reference.double_tap },
                    { "OS-AA", not reference.double_tap and reference.on_shot_anti_aim },
                }
    
                for k, v in ipairs(crosshair_indicators_tbl) do
                    local alpha_key = "indicator_alpha_" .. k
                    if tween_data[alpha_key] == nil then
                        tween_data[alpha_key] = 0
                    end
            
                    local measure_text_binds = renderer.measure_text("-", v[1])
                    tween_tbl[alpha_key] = tween.new(0.2, tween_data, { [alpha_key] = v[2] and 255 or 0 })
                    local alpha = math.min(tween_data[alpha_key], 100) / 100
            
                    add_y = add_y + 10 * alpha
            
                    if alpha > 0.01 then
                        renderer.text(screen_x / 2 + ((measure_text_binds + 5) / 2) * scoped_value, screen_y / 2 + 30 + add_y + y_offset, 255, 255, 255, 255 * alpha, "-c", 0, v[1])
                    end
                end
            end
        end
    }

    ctx.helps = {
        lerp = function(a, b, t)
            return a + (b - a) * t
        end
    }


    ctx.loading_anim = {
        run = function()
            local sizing = ctx.helps.lerp(0.1, 0.9, math.sin(globals.realtime() * 2) * 0.5 + 0.5)
            local rotation = ctx.helps.lerp(0, 360, globals.realtime() % 1)
            y = ctx.helps.lerp(y, 20, globals.frametime() * 2)
            --alpha = ctx.helps.lerp(alpha, 0, globals.frametime() * 1)
            timer_test = timer_test + 2

            if timer_test > X - 200 then
                alpha = ctx.helps.lerp(alpha, 0, globals.frametime() * 2.7)
            end

            if timer_test > X then
                timer_test = X + 1
            end

            renderer.rectangle(0, 0, X, Y, 20, 20, 20, alpha)
            renderer.rectangle(0, 0, timer_test, 3, color_r, color_g, color_b, alpha)
            if logo ~= nil then
                logo:draw(X/2 - (y * 2) - 10, Y/2 - 180, 25 + (y * 4),25 + (y * 4), 255,255,255,alpha)
            else
                get_logo()
            end
            renderer.text(X/2, Y /2 - 30, 184, 184, 184, alpha, 'c+', 0, 'Welcome \a'..rgba_to_hex(color_r, color_g, color_b, alpha)..quiet.username)
            renderer.text(X/2, Y /2, 184, 184, 184, alpha, 'c+', 0, 'Build \a'..rgba_to_hex(color_r, color_g, color_b, alpha)..quiet.build)
            renderer.text(X/2, Y - y, 184, 184, 184, alpha, 'c', 0, 'quiet.lua')
        end
    }

    return ctx
end)()

client.set_event_callback('paint', function()
    ctx.watermark.render()
end)

client.set_event_callback('paint_ui', function()
end)

function new_notify(string, r, g, b, a)
    local notification = {
        text = string,
        timer = globals.realtime(),
        color = { r, g, b, a },
        alpha = 0,
        fraction = 0,
        time_left = 0
    }

    if #notify_data == 0 then
        notification.y = Y + 20
    else
        local lastNotification = notify_data[#notify_data]
        notification.y = lastNotification.y + 20 
    end

    table.insert(notify_data, notification)
end

local function import(text)
    local status, config =
        pcall(
        function()
            return json.parse(base64.decode(text))
        end
    )

    if not status or status == nil then
        client.color_log(255, 0, 0, "quiet ~\0")
	    client.color_log(200, 200, 200, " error while importing!")
        return
    end

    if config ~= nil then
        for k, v in pairs(config) do
            k = ({[1] = 'integers'})[k]  -- Убедитесь, что это правильно
    
            for k2, v2 in pairs(v) do
                if k == 'integers' then
                    local item = data[k][k2]  -- Получаем элемент из data
    
                    -- Проверяем, что item не nil
                    if item ~= nil then
                        -- Убедитесь, что v2 имеет правильный тип
                        if type(v2) == "number" or type(v2) == "boolean" or type(v2) == "string" then
                            ui.set(item, v2)  -- Устанавливаем значение
                        else
                            --print("Неправильный тип значения для ui.set:", v2)
                        end
                    else
                        --print("Элемент не найден в data:", k, k2)
                    end
                end
            end
        end
    end

    client.color_log(124, 252, 0, "quiet ~\0")
	client.color_log(200, 200, 200, " config successfully imported!")

end

client.set_event_callback('setup_command', function(cmd)
    local self = entity.get_local_player()

    if entity.get_player_weapon(self) == nil then return end

    local using = false
    local anti_aim_on_use = false

    local inverted = entity.get_prop(self, "m_flPoseParameter", 11) * 120 - 60

    local is_planting = entity.get_prop(self, 'm_bInBombZone') == 1 and entity.get_classname(entity.get_player_weapon(self)) == 'CC4' and entity.get_prop(self, 'm_iTeamNum') == 2
    local CPlantedC4 = entity.get_all('CPlantedC4')[1]

    local eye_x, eye_y, eye_z = client.eye_position()
	local pitch, yaw = client.camera_angles()

    local sin_pitch = math.sin(math.rad(pitch))
	local cos_pitch = math.cos(math.rad(pitch))

	local sin_yaw = math.sin(math.rad(yaw))
	local cos_yaw = math.cos(math.rad(yaw))

    local direction_vector = {cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch}

    local fraction, entity_index = client.trace_line(self, eye_x, eye_y, eye_z, eye_x + (direction_vector[1] * 8192), eye_y + (direction_vector[2] * 8192), eye_z + (direction_vector[3] * 8192))

    if CPlantedC4 ~= nil then
        dist_to_c4 = vector(entity.get_prop(self, 'm_vecOrigin')):dist(vector(entity.get_prop(CPlantedC4, 'm_vecOrigin')))

        if entity.get_prop(CPlantedC4, 'm_bBombDefused') == 1 then dist_to_c4 = 56 end

        is_defusing = dist_to_c4 < 56 and entity.get_prop(self, 'm_iTeamNum') == 3
    end

    if entity_index ~= -1 then
        if vector(entity.get_prop(self, 'm_vecOrigin')):dist(vector(entity.get_prop(entity_index, 'm_vecOrigin'))) < 146 then
            using = entity.get_classname(entity_index) ~= 'CWorld' and entity.get_classname(entity_index) ~= 'CFuncBrush' and entity.get_classname(entity_index) ~= 'CCSPlayer'
        end
    end

    if cmd.in_use == 1 and not using and not is_planting and not is_defusing and ui.get(anti_aim_settings[10].override_state) then cmd.buttons = bit.band(cmd.buttons, bit.bnot(bit.lshift(1, 5))); anti_aim_on_use = true; state_id = 10 else if (ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) == false and (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])) == false and ui.get(anti_aim_settings[9].override_state) then anti_aim_on_use = false; state_id = 9 else if (cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0) and entity.get_prop(self, 'm_flDuckAmount') > 0.8 and ui.get(anti_aim_settings[8].override_state) then anti_aim_on_use = false; state_id = 8 elseif (cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0) and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and ui.get(anti_aim_settings[7].override_state) then anti_aim_on_use = false; state_id = 7 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and (entity.get_prop(self, 'm_flDuckAmount') > 0.8 or ui.get(reference.duck_peek_assist)) and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and ui.get(anti_aim_settings[6].override_state) then anti_aim_on_use = false; state_id = 6 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and entity.get_prop(self, 'm_flDuckAmount') > 0.8 and vector(entity.get_prop(self, 'm_vecVelocity')):length() < 2 and ui.get(anti_aim_settings[5].override_state) then anti_aim_on_use = false; state_id = 5 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == true and ui.get(anti_aim_settings[4].override_state) then anti_aim_on_use = false; state_id = 4 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == false and ui.get(anti_aim_settings[3].override_state) then anti_aim_on_use = false; state_id = 3 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() < 2 and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and ui.get(anti_aim_settings[2].override_state) then anti_aim_on_use = false; state_id = 2 else anti_aim_on_use = false; state_id = 1 end end end
    if cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0 then freestanding_state_id = 5 elseif (entity.get_prop(self, 'm_flDuckAmount') > 0.8 or ui.get(reference.duck_peek_assist)) and bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 then freestanding_state_id = 4 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == true then freestanding_state_id = 3 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == false then freestanding_state_id = 2 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() < 2 then freestanding_state_id = 1 end

    ui.set(settings.manual_forward, 'On hotkey')
    ui.set(settings.manual_right, 'On hotkey')
    ui.set(settings.manual_left, 'On hotkey')

    cmd.force_defensive = ui.get(anti_aim_settings[state_id].defensive_anti_aimbot)

    ui.set(reference.pitch[1], ui.get(anti_aim_settings[state_id].pitch1))
    ui.set(reference.pitch[2], ui.get(anti_aim_settings[state_id].pitch2))
    ui.set(reference.yaw_base, (direction == 180 or direction == 90 or direction == -90) and anti_aim_on_use == false and 'Local view' or ui.get(anti_aim_settings[state_id].yaw_base))
    ui.set(reference.yaw[1], (direction == 180 or direction == 90 or direction == -90) and anti_aim_on_use == false and '180' or ui.get(anti_aim_settings[state_id].yaw1))

    if ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
        if inverted > 0 then
            if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_left) or -90
                last_press = globals.realtime()
            elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_left) or 90

                last_press = globals.realtime()
            elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw_jitter2_left) or 180

                last_press = globals.realtime()
            end
        else
            if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_right) or -90
                last_press = globals.realtime()
            elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_right) or 90
                last_press = globals.realtime()
            elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw_jitter2_right) or 180

                last_press = globals.realtime()
            end
        end
    else
        if inverted > 0 then
            if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw2_left) or -90

                last_press = globals.realtime()
            elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw2_left) or 90

                last_press = globals.realtime()
            elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw2_left) or 180

                last_press = globals.realtime()
            end
        else
            if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw2_right) or -90

                last_press = globals.realtime()
            elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw2_right) or 90

                last_press = globals.realtime()
            elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw2_right) or 180

                last_press = globals.realtime()
            end
        end
    end

    if ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
        if math.random(0, 1) ~= 0 then
            yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
            yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
        else
            yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
            yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
        end

        if inverted > 0 then
            if yaw_jitter2_left == 180 then yaw_jitter2_left = -180 elseif yaw_jitter2_left == 90 then yaw_jitter2_left = 89 elseif yaw_jitter2_left == -90 then yaw_jitter2_left = -89 end

            if not (direction == 180 or direction == 90 or direction == -90) then direction = yaw_jitter2_left end
        else
            if yaw_jitter2_right == 180 then yaw_jitter2_right = -180 elseif yaw_jitter2_right == 90 then yaw_jitter2_right = 89 elseif yaw_jitter2_right == -90 then yaw_jitter2_right = -89 end

            if not (direction == 180 or direction == 90 or direction == -90) then direction = yaw_jitter2_right end
        end
    else
        if inverted > 0 then
            if math.random(0, 1) ~= 0 then yaw2_left = ui.get(anti_aim_settings[state_id].yaw2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) else yaw2_left = ui.get(anti_aim_settings[state_id].yaw2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) end

            if yaw2_left == 180 then yaw2_left = -180 elseif yaw2_left == 90 then yaw2_left = 89 elseif yaw2_left == -90 then yaw2_left = -89 end

            if not (direction == 90 or direction == -90 or direction == 180) then direction = yaw2_left end
        else
            if math.random(0, 1) ~= 0 then yaw2_right = ui.get(anti_aim_settings[state_id].yaw2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) else yaw2_right = ui.get(anti_aim_settings[state_id].yaw2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) end

            if yaw2_right == 180 then yaw2_right = -180 elseif yaw2_right == 90 then yaw2_right = 89 elseif yaw2_right == -90 then yaw2_right = -89 end

            if not (direction == 90 or direction == -90 or direction == 180) then direction = yaw2_right end
        end
    end

    if anti_aim_on_use == true then
        if ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
            if inverted > 0 then
                if math.random(0, 1) ~= 0 then
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                else
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                end
            else
                if math.random(0, 1) ~= 0 then
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                else
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                end
            end
        else
            if inverted > 0 then
                if math.random(0, 1) ~= 0 then
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                else
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                end
            else
                if math.random(0, 1) ~= 0 then
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                else
                    anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                end
            end
        end
    end

    if direction > 180 or direction < -180 then direction = -180 end
    if anti_aim_on_use_direction > 180 or anti_aim_on_use_direction < -180 then anti_aim_on_use_direction = -180 end

    ui.set(reference.yaw[2], anti_aim_on_use == false and direction or anti_aim_on_use_direction)
    ui.set(reference.yaw_jitter[1], ((direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false or ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' or ui.get(anti_aim_settings[state_id].yaw1) == 'Off') and 'Off' or ui.get(anti_aim_settings[state_id].yaw_jitter1))

    if inverted > 0 then
        if math.random(0, 1) ~= 0 then yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) else yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) end

        if yaw_jitter2_left > 180 or yaw_jitter2_left < -180 then yaw_jitter2_left = -180 end

        ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and yaw_jitter2_left or 0)
    else
        if math.random(0, 1) ~= 0 then yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) else yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) end

        if yaw_jitter2_right > 180 or yaw_jitter2_right < -180 then yaw_jitter2_right = -180 end

        ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and yaw_jitter2_right or 0)
    end

    if ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
        if (ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) == true or (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])) == true then
            ui.set(reference.body_yaw[1], (direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false and 'Opposite' or 'Static')
        else
            ui.set(reference.body_yaw[1], (direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false and 'Opposite' or 'Jitter')
        end
    else
        ui.set(reference.body_yaw[1], (direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false and 'Opposite' or ui.get(anti_aim_settings[state_id].body_yaw1))
    end

    if cmd.command_number % ui.get(anti_aim_settings[state_id].yaw_jitter2_delay) + 1 > ui.get(anti_aim_settings[state_id].yaw_jitter2_delay) - 1 then
        delayed_jitter = not delayed_jitter
    end

    if ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
        if (ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) == true or (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])) == true then
            ui.set(reference.body_yaw[2], delayed_jitter and -90 or 90)
        else
            ui.set(reference.body_yaw[2], -40)
        end
    else
        ui.set(reference.body_yaw[2], ui.get(anti_aim_settings[state_id].body_yaw2))
    end

    ui.set(reference.freestanding_body_yaw, ui.get(anti_aim_settings[state_id].yaw1) ~= 'Off' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' and false or ui.get(anti_aim_settings[state_id].freestanding_body_yaw))

    --defensive_aa
    if ui.get(anti_aim_settings[state_id].defensive_anti_aimbot) and is_defensive_active and ((ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) or (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2]))) and not (direction == 180 or direction == 90 or direction == -90) then
        ui.set(reference.pitch[1], ui.get(anti_aim_settings[state_id].defensive_pitch1))

        if ui.get(anti_aim_settings[state_id].defensive_pitch1) == 'Random' then
            ui.set(reference.pitch[1], 'Custom')
            ui.set(reference.pitch[2], math.random(ui.get(anti_aim_settings[state_id].defensive_pitch2), ui.get(anti_aim_settings[state_id].defensive_pitch3)))
        else
            ui.set(reference.pitch[2], ui.get(anti_aim_settings[state_id].defensive_pitch2))
        end

        ui.set(reference.yaw_jitter[1], 'Off')
        ui.set(reference.body_yaw[1], 'Opposite')

        if ui.get(anti_aim_settings[state_id].defensive_yaw1) == '180' then
            ui.set(reference.yaw[1], '180')

            ui.set(reference.yaw[2], ui.get(anti_aim_settings[state_id].defensive_yaw2))
        elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == 'Spin' then
            ui.set(reference.yaw[1], 'Spin')

            ui.set(reference.yaw[2], ui.get(anti_aim_settings[state_id].defensive_yaw2))
        elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == '180 Z' then
            ui.set(reference.yaw[1], '180 Z')

            ui.set(reference.yaw[2], ui.get(anti_aim_settings[state_id].defensive_yaw2))
        elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == 'Sideways' then
            ui.set(reference.yaw[1], '180')

            if cmd.command_number % 4 >= 2 then
                ui.set(reference.yaw[2], math.random(85, 100))
            else
                ui.set(reference.yaw[2], math.random(-100, -85))
            end
        elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == 'Random' then
            ui.set(reference.yaw[1], '180')

            ui.set(reference.yaw[2], math.random(-180, 180))
        end
    end

    if ui.get(settings.safe_head_in_air) and (cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0) and entity.get_prop(self, 'm_flDuckAmount') > 0.8 and (entity.get_classname(entity.get_player_weapon(self)) == 'CKnife' or entity.get_classname(entity.get_player_weapon(self)) == 'CWeaponTaser') and anti_aim_on_use == false and not (direction == 180 or direction == 90 or direction == -90) then
        ui.set(reference.pitch[1], 'Down')
        ui.set(reference.yaw[1], '180')
        ui.set(reference.yaw[2], 0)
        ui.set(reference.yaw_jitter[1], 'Off')
        ui.set(reference.body_yaw[1], 'Off')
    end

    if ui.get(settings.freestanding) and ((contains(settings.freestanding_conditions, 'Standing') and freestanding_state_id == 1) or (contains(settings.freestanding_conditions, 'Moving') and freestanding_state_id == 2) or (contains(settings.freestanding_conditions, 'Slow motion') and freestanding_state_id == 3) or (contains(settings.freestanding_conditions, 'Crouching') and freestanding_state_id == 4) or (contains(settings.freestanding_conditions, 'In air') and freestanding_state_id == 5)) and anti_aim_on_use == false and not (direction == 180 or direction == 90 or direction == -90) then
        ui.set(reference.freestanding[1], true)
        ui.set(reference.freestanding[2], 'Always on')

        if contains(settings.tweaks, 'Off jitter while freestanding') then
            ui.set(reference.yaw[1], '180')
            ui.set(reference.yaw[2], 0)
            ui.set(reference.yaw_jitter[1], 'Off')
            ui.set(reference.body_yaw[1], 'Opposite')
            ui.set(reference.body_yaw[2], 0)
            ui.set(reference.freestanding_body_yaw, true)
        end
    else
        ui.set(reference.freestanding[1], false)
        ui.set(reference.freestanding[2], 'On hotkey')
    end

    if ui.get(settings.avoid_backstab) and anti_aim_on_use == false and not (direction == 180 or direction == 90 or direction == -90) then
        local players = entity.get_players(true)

        if players ~= nil then
            for i, enemy in pairs(players) do
                for h = 0, 18 do
                    local head_x, head_y, head_z = entity.hitbox_position(players[i], h)
                    local wx, wy = renderer.world_to_screen(head_x, head_y, head_z)
                    local fractions, entindex_hit = client.trace_line(self, eye_x, eye_y, eye_z, head_x, head_y, head_z)

                    if 250 >= vector(entity.get_prop(enemy, 'm_vecOrigin')):dist(vector(entity.get_prop(self, 'm_vecOrigin'))) and entity.is_alive(enemy) and entity.get_player_weapon(enemy) ~= nil and entity.get_classname(entity.get_player_weapon(enemy)) == 'CKnife' and (entindex_hit == players[i] or fractions == 1) and not entity.is_dormant(players[i]) then
                        ui.set(reference.yaw[1], '180')
                        ui.set(reference.yaw[2], -180)
                    end
                end
            end
        end
    end
end)

client.set_event_callback('paint_ui', function()
    if entity.get_local_player() == nil then cheked_ticks = 0 end

    if ui.is_menu_open() then
        ui.set_visible(reference.aa_enable, false)
        ui.set_visible(reference.pitch[1], false)
        ui.set_visible(reference.pitch[2], false)
        ui.set_visible(reference.yaw_base, false)
        ui.set_visible(reference.yaw[1], false)
        ui.set_visible(reference.yaw[2], false)
        ui.set_visible(reference.yaw_jitter[1], false)
        ui.set_visible(reference.yaw_jitter[2], false)
        ui.set_visible(reference.body_yaw[1], false)
        ui.set_visible(reference.body_yaw[2], false)
        ui.set_visible(reference.freestanding_body_yaw, false)
        ui.set_visible(reference.edge_yaw, false)
        ui.set_visible(reference.freestanding[1], false)
        ui.set_visible(reference.freestanding[2], false)
        ui.set_visible(reference.roll, false)
        ui.set_visible(current_state_menu, ui.get(current_tab) == "Anti-Aim")
        ui.set_visible(settings.anti_aim_state, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Builder")
        ui.set_visible(settings.avoid_backstab, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Other")
        ui.set_visible(settings.safe_head_in_air, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Other")
        ui.set_visible(settings.manual_forward, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Keybinds")
        ui.set_visible(settings.manual_right, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Keybinds")
        ui.set_visible(settings.manual_left, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Keybinds")
        ui.set_visible(settings.freestanding, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Keybinds")
        ui.set_visible(settings.warmup_disabler, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Other")
        ui.set_visible(settings.freestanding_conditions, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Keybinds")
        ui.set_visible(settings.tweaks, ui.get(current_tab) == 'Anti-Aim' and ui.get(current_state_menu) == "Keybinds")
        ui.set_visible(master_switch, ui.get(current_tab) == 'Visuals')
        ui.set_visible(console_filter, ui.get(current_tab) == 'Misc')
        ui.set_visible(anim_breakerx, ui.get(current_tab) == 'Misc')
        ui.set_visible(fastladder, ui.get(current_tab) == 'Misc')
        ui.set_visible(trashtalk, ui.get(current_tab) == 'Misc')
        ui.set_visible(trashtalk_mode, ui.get(current_tab) == 'Misc')
        ui.set_visible(clantagchanger, ui.get(current_tab) == 'Misc')
        ui.set_visible(watermark_toggle, ui.get(current_tab) == 'Visuals')
        ui.set_visible(cindicators, ui.get(current_tab) == 'Visuals')
        

        for i = 1, #anti_aim_states do
            ui.set_visible(anti_aim_settings[i].override_state, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(current_state_menu) == "Builder"); ui.set(anti_aim_settings[1].override_state, true); ui.set_visible(anti_aim_settings[1].override_state, false)
            ui.set_visible(anti_aim_settings[i].pitch1,ui.get(current_tab) == 'Anti-Aim' and  ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].pitch2, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].pitch1) == 'Custom' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw_base, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw1, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw2_left, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw2_right, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw2_randomize, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw_jitter1, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw_jitter2_left, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Off' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw_jitter2_right, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Off' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw_jitter2_randomize, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Off' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].yaw_jitter2_delay, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) == 'Delay' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].body_yaw1, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].body_yaw2, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and (ui.get(anti_aim_settings[i].body_yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].body_yaw1) ~= 'Opposite') and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].freestanding_body_yaw, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].body_yaw1) ~= 'Off' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay' and ui.get(current_state_menu) == "Builder")
            ui.set_visible(anti_aim_settings[i].defensive_anti_aimbot, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(current_state_menu) == "Builder"); ui.set_visible(anti_aim_settings[9].defensive_anti_aimbot, false)
            ui.set_visible(anti_aim_settings[i].defensive_pitch1, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].defensive_anti_aimbot) and ui.get(current_state_menu) == "Builder"); ui.set_visible(anti_aim_settings[9].defensive_pitch1, false)
            ui.set_visible(anti_aim_settings[i].defensive_pitch2, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].defensive_anti_aimbot) and (ui.get(anti_aim_settings[i].defensive_pitch1) == 'Random' or ui.get(anti_aim_settings[i].defensive_pitch1) == 'Custom') and ui.get(current_state_menu) == "Builder"); ui.set_visible(anti_aim_settings[9].defensive_pitch2, false)
            ui.set_visible(anti_aim_settings[i].defensive_pitch3, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].defensive_anti_aimbot) and ui.get(anti_aim_settings[i].defensive_pitch1) == 'Random' and ui.get(current_state_menu) == "Builder"); ui.set_visible(anti_aim_settings[9].defensive_pitch3, false)
            ui.set_visible(anti_aim_settings[i].defensive_yaw1, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].defensive_anti_aimbot) and ui.get(current_state_menu) == "Builder"); ui.set_visible(anti_aim_settings[9].defensive_yaw1, false)
            ui.set_visible(anti_aim_settings[i].defensive_yaw2, ui.get(current_tab) == 'Anti-Aim' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].defensive_anti_aimbot) and (ui.get(anti_aim_settings[i].defensive_yaw1) == '180' or ui.get(anti_aim_settings[i].defensive_yaw1) == 'Spin' or ui.get(anti_aim_settings[i].defensive_yaw1) == '180 Z') and ui.get(current_state_menu) == "Builder"); ui.set_visible(anti_aim_settings[9].defensive_yaw2, false)
        end
    end
end)

import_btn = ui.new_button("AA", "Anti-aimbot angles", "Import settings", function() import(clipboard.get()) end)
export_btn = ui.new_button("AA", "Anti-aimbot angles", "Export settings", function() 
    local code = {{}}

    for i, integers in pairs(data.integers) do
        table.insert(code[1], ui.get(integers))
    end

    clipboard.set(base64.encode(json.stringify(code)))
    client.color_log(124, 252, 0, "quiet ~\0")
	client.color_log(200, 200, 200, " config successfully exported!")
end)
default_btn = ui.new_button("AA", "Anti-aimbot angles", "Default Config", function() 
    import('W1siU2xvdyBtb3Rpb24iLHRydWUsdHJ1ZSx0cnVlLHRydWUsdHJ1ZSx0cnVlLHRydWUsdHJ1ZSx0cnVlLGZhbHNlLCJPZmYiLCJEb3duIiwiRG93biIsIkRvd24iLCJEb3duIiwiRG93biIsIkRvd24iLCJEb3duIiwiRG93biIsIk9mZiIsMCwwLDAsMCwwLDAsMCwwLDAsMCwiTG9jYWwgdmlldyIsIkxvY2FsIHZpZXciLCJBdCB0YXJnZXRzIiwiQXQgdGFyZ2V0cyIsIkF0IHRhcmdldHMiLCJBdCB0YXJnZXRzIiwiQXQgdGFyZ2V0cyIsIkF0IHRhcmdldHMiLCJBdCB0YXJnZXRzIiwiTG9jYWwgdmlldyIsIk9mZiIsIjE4MCIsIjE4MCIsIjE4MCIsIjE4MCIsIjE4MCIsIjE4MCIsIjE4MCIsIjE4MCIsIk9mZiIsMCwtMjYsMCwwLC0zNiwwLC0zOCwtMjgsMCwwLDAsMzAsMCwwLDI4LDAsNTAsNDIsMCwwLDAsMCwwLDAsMCwwLDAsMCwwLDAsIk9mZiIsIkRlbGF5IiwiRGVsYXkiLCJTa2l0dGVyIiwiRGVsYXkiLCJEZWxheSIsIkRlbGF5IiwiRGVsYXkiLCJEZWxheSIsIk9mZiIsMCwtMzMsLTMzLDMxLC01MiwtMzgsLTQyLC00MiwtMzIsMCwwLDQyLDQ0LC0yMiw0MiwzMiw1Niw1NCwzNiwwLDAsMCwwLDQ1LDAsMCwwLDAsMCwwLDIsNiw3LDIsNCw3LDcsNyw2LDIsIk9mZiIsIk9mZiIsIk9mZiIsIkppdHRlciIsIk9mZiIsIk9mZiIsIk9mZiIsIk9mZiIsIk9mZiIsIk9mZiIsMCwwLDAsMjcsMCwwLDAsMCwwLDAsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsZmFsc2UsdHJ1ZSxmYWxzZSxmYWxzZSx0cnVlLHRydWUsZmFsc2UsZmFsc2UsIk9mZiIsIkRvd24iLCJEb3duIiwiUmFuZG9tIiwiRG93biIsIkRvd24iLCJSYW5kb20iLCJSYW5kb20iLCJEb3duIiwiT2ZmIiwxLDAsMCwtNDIsLTg5LC04OSwtNDEsLTQxLDAsMCwxLDAsMCwtNDIsLTg5LC04OSwtNDEsLTIzLDAsMCwiMTgwIiwiU3BpbiIsIlNwaW4iLCJTaWRld2F5cyIsIlNwaW4iLCJTcGluIiwiU2lkZXdheXMiLCJTaWRld2F5cyIsIlNpZGV3YXlzIiwiMTgwIiwxLDAsMCwwLC04OSwtODksLTQxLC04OSwwLDAsdHJ1ZSx0cnVlLHt9LHt9LHRydWUsdHJ1ZSx0cnVlLHRydWUsdHJ1ZSx0cnVlLGZhbHNlLGZhbHNlXV0=')
end)

client.set_event_callback('paint_ui', function()
    if entity.get_local_player() == nil then cheked_ticks = 0 end

    ui.set_visible(export_btn, ui.get(current_tab) == 'Config')
    ui.set_visible(import_btn, ui.get(current_tab) == 'Config')
    ui.set_visible(default_btn, ui.get(current_tab) == 'Config')
end)

ui.set_callback(console_filter, function()
    cvar.con_filter_text:set_string("cool text")
    cvar.con_filter_enable:set_int(1)
end)

local clantag = {
    steam = steamworks.ISteamFriends,
    prev_ct = "",
    orig_ct = "",
    enb = false,
}

local function get_original_clantag()
    local clan_id = cvar.cl_clanid.get_int()
    if clan_id == 0 then return "\0" end

    local clan_count = clantag.steam.GetClanCount()
    for i = 0, clan_count do 
        local group_id = clantag.steam.GetClanByIndex(i)
        if group_id == clan_id then
            return clantag.steam.GetClanTag(group_id)
        end
    end
end

local clantag_anim = function(text, indices)

    time_to_ticks = function(t)
        return math.floor(0.5 + (t / globals.tickinterval()))
    end

    local text_anim = "               " .. text ..                       "" 
    local tickinterval = globals.tickinterval()
    local tickcount = globals.tickcount() + time_to_ticks(client.latency())
    local i = tickcount / time_to_ticks(0.3)
    i = math.floor(i % #indices)
    i = indices[i+1]+1
    return string.sub(text_anim, i, i+15)
end



local killsay_sentences = {
    "сын шлюхенции ты чет слабый для quiet",
    ".gg/xocu",
    "кебаб ебаный тычо падаеш",
    "quiet vs all",
    "1 бот ты чо не вывез quiet system aa",
    "я твою мать ебу, у меня твой язык",
    "и чо те мамаша после хуя бомж",
    "луасенс не бустит , квайт поможет сын шалавы",
    "и че  за хуйня? ебу тя клопяра",
    "przelecialem ciebezdomnego",
    "ты че мразота ? вздумал тягатся с квайт юзером?",
    "ну ты ваще хуевый бомж, иди коучнис ",
    "сегодня все апонент перефразируй самооправкацию с языка и накинь в зеркало хуем в рот",
    "зеркала разбиты все инцеалами твои временами хуем в рот провокацией мать убей что отцу соври вопросом бабке хуй в рот забей",
    "провокация господину отрицаением харкатель твой",
    "подожди какой хуй в жопе у тебя на лице твоём? утверди на пенисе жопой родной, чё маме?",
    "кто твоя мама кроме пидораски ебаной на лице твоём, чё отцу ?",
    "кто твоя мама жопой твоей ?",
    "так кто факал тебя пидора ебаного, че в зеркало ?",
    "че расстерялся перед моим хуем",
    "у меня твой язык кто ебал тя отрицание в дик",
    "у тя мама по падику с голой жопе бегает wtf",
    "11:11",
    "представь правдимую самопровокацию в ввиде языка твоего в жопу , все определения твои "
}
local killsay_ds_sentences = {
    "go cop quiet nn .gg/xocu",
    "best lua provider at .gg/xocu",
    ".gg/xocu owns all",
    "best lua -> .gg/xocu",
    "11:11",
    "the n1 gs lua -> .gg/xocu"
}

local deathsay_sentences = {
    "повезло  дебилу не более",
    "повезло тебе сын шлюхи",
    "ладно в этом раунде я умер но в следующем я отыграюсь...",
    "ладно чит сегодня на твоей стороне..."
}

local function on_player_death(event)
    local local_player = entity.get_local_player()
    local attacker = client.userid_to_entindex(event.attacker)
    local victim = client.userid_to_entindex(event.userid)

    if local_player == nil or attacker == nil or victim == nil then
        return
    end
   
    if ui.get(trashtalk) then
        if ui.get(trashtalk_mode) == "Default" then
            if attacker == local_player and victim ~= local_player then
                local killsay = "say " .. killsay_sentences[math.random(#killsay_sentences)]
                --client.log(killsay)
                client.exec(killsay)
            end
        else
            if attacker == local_player and victim ~= local_player then
                local killsay = "say " .. killsay_ds_sentences[math.random(#killsay_ds_sentences)]
                --client.log(killsay)
                client.exec(killsay)
            end
        end
    end

    if ui.get(trashtalk) then
        if victim == local_player then
            local deathsay = "say " .. deathsay_sentences[math.random(#deathsay_sentences)]
            client.log(deathsay)
            client.exec(deathsay)
        end
    end
end

client.set_event_callback("player_death", on_player_death)


local function clantag_set()
    local lua_name = "quietsense"
    if ui.get(clantagchanger) then
        if ui.get(ui.reference("Misc", "Miscellaneous", "Clan tag spammer")) then ui.set(ui.reference("Misc", "Miscellaneous", "Clan tag spammer"), false) end

		local clan_tag = clantag_anim(lua_name, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25})

        if entity.get_prop(entity.get_game_rules(), "m_gamePhase") == 5 then
            clan_tag = clantag_anim('quiet.lua ', {13})
            client.set_clan_tag(clan_tag)
        elseif entity.get_prop(entity.get_game_rules(), "m_timeUntilNextPhaseStarts") ~= 0 then
            clan_tag = clantag_anim('quiet.lua ', {13})
            client.set_clan_tag(clan_tag)
        elseif clan_tag ~= clantag.prev_ct  then
            client.set_clan_tag(clan_tag)
        end

        clantag.prev_ct = clan_tag
        clantag.enb = true
    elseif clantag.enb == true then
        client.set_clan_tag(get_original_clantag())
        clantag.enb = false
    end
end

clantag.paint = function()
    if entity.get_local_player() ~= nil then
        if globals.tickcount() % 2 == 0 then
            clantag_set()
        end
    end
end

clantag.run_command = function(e)
    if entity.get_local_player() ~= nil then 
        if e.chokedcommands == 0 then
            clantag_set()
        end
    end
end

clantag.player_connect_full = function(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then 
        clantag.orig_ct = get_original_clantag()
    end
end

clantag.shutdown = function()
    client.set_clan_tag(get_original_clantag())
end

client.set_event_callback("paint", clantag.paint)
client.set_event_callback("run_command", clantag.run_command)
client.set_event_callback("player_connect_full", clantag.player_connect_full)
client.set_event_callback("shutdown", clantag.shutdown)
--


--[[client.set_event_callback('console_input', function(text)
    if string.find(text, '//export') then
        local code = {{}}

        for i, integers in pairs(data.integers) do
            table.insert(code[1], ui.get(integers))
        end

        clipboard.set(base64.encode(json.stringify(code)))
    elseif string.find(text, '//import') then
        import(clipboard.get())
    elseif string.find(text, '//default') then
        http.get('https://pastebin.com/raw/xJy4ipac', function(success, response)
            if not success or response.status ~= 200 then return end

            import(response.body)
        end)
    end
end)]]

client.set_event_callback('net_update_end', function()
    if entity.get_local_player() ~= nil then
        is_defensive_active = is_defensive(entity.get_local_player())
    end
end)

--fastladder
client.set_event_callback('setup_command', function(cmd)
    if ui.get(fastladder) then
        local pitch, yaw = client.camera_angles()
        if entity.get_prop(entity.get_local_player(), "m_MoveType") == 9 then
            cmd.yaw = math.floor(cmd.yaw+0.5)
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
end)

--legbreaker
local ref = {
    leg_movement = ui.reference('AA', 'Other', 'Leg movement')
}

local ab = {}

ab.pre_render = function()
    if ui.get(anim_breakerx) then
                entity.set_prop(entity.get_local_player(), "m_flPoseParameter", math.random(0, 10)/10, 3)
                entity.set_prop(entity.get_local_player(), "m_flPoseParameter", math.random(0, 10)/10, 7)
                entity.set_prop(entity.get_local_player(), "m_flPoseParameter", math.random(0, 10)/10, 6)
            end
        end
        

ab.setup_command = function(e)
    if not ui.get(anim_breakerx) then return end

    local local_player = entity.get_local_player()
    if not entity.is_alive(local_player) then return end

    ui.set(ref.leg_movement, 'Always slide')
end

local ui_callback = function(c)
    local enabled, addr = ui.get(c), ''

    if not enabled then
        addr = 'un'
    end
    
    local _func = client[addr .. 'set_event_callback']

    _func('pre_render', ab.pre_render)
    _func('setup_command', ab.setup_command)
end

ui.set_callback(master_switch, ui_callback)
ui_callback(master_switch)

local is_on_ground = false

--- @region: process main work
--
client.set_event_callback("setup_command", function()
    if entity.get_local_player() == nil then return end

    gamerulesproxy = entity.get_all("CCSGameRulesProxy")[1]
    warmup = entity.get_prop(gamerulesproxy,"m_bWarmupPeriod")
    --print(warmup)
  
    if ui.get(settings.warmup_disabler) and warmup == 1 then
        ui.set(reference.body_yaw[1], 'Off')
        ui.set(reference.yaw[2], math.random(-180, 180))
        ui.set(reference.yaw_jitter[1], 'Random')
        ui.set(reference.pitch[1], 'Random')
    end
end)
--

client.set_event_callback("setup_command", function(cmd)
    is_on_ground = cmd.in_jump == 0

    if ui.get(anim_breakerx) then
        ui.set(ref.leg_movement, cmd.command_number % 3 == 0 and "Off" or "Always slide")
    end
    ctx.get_defensive.get()
end)

client.set_event_callback("pre_render", function()
    local self = entity.get_local_player()
    if not self or not entity.is_alive(self) then
        return
    end

    local self_index = c_entity.new(self)
    local self_anim_state = self_index:get_anim_state()

    if not self_anim_state then
        return
    end

    if ui.get(anim_breakerx) then
        entity.set_prop(self, "m_flPoseParameter", E_POSE_PARAMETERS.STAND, globals.tickcount() % 4 > 1 and 5 / 10 or 1)
    
        local self_anim_overlay = self_index:get_anim_overlay(12)
        if not self_anim_overlay then
            return
        end

        local x_velocity = entity.get_prop(self, "m_vecVelocity[0]")
        if math.abs(x_velocity) >= 3 then
            self_anim_overlay.weight = 100 / 100
        end
    end
end)

local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}
local weapon_to_verb = { knife = ' Knifed', hegrenade = ' Naded', inferno = ' Burned' }

client.set_event_callback('aim_hit', function(e)
	if not ui.get(master_switch) or e.id == nil then
		return
	end

	local group = hitgroup_names[e.hitgroup + 1] or "?"

	client.color_log(124, 252, 0, "quiet ~\0")
	client.color_log(200, 200, 200, " Hit\0")
	client.color_log(124, 252, 0, string.format(" %s\0", entity.get_player_name(e.target)))
	client.color_log(200, 200, 200, " in the\0")
	client.color_log(124, 252, 0, string.format(" %s\0", group))
	client.color_log(200, 200, 200, " for\0")
	client.color_log(124, 252, 0, string.format(" %s\0", e.damage))
	client.color_log(200, 200, 200, " damage\0")
	client.color_log(200, 200, 200, " (\0")
	client.color_log(124, 252, 0, string.format("%s\0", entity.get_prop(e.target, "m_iHealth")))
	client.color_log(200, 200, 200, " health remaining)")

    local r,g,b,a = ui.get(current_color)
    new_notify(string.format("\aFFFFFFFF Hit \a%s%s\aFFFFFFFF in the \a%s%s\aFFFFFFFF for \a%s%d\aFFFFFFFF damage (%d health remaining)", rgba_to_hex(r,g,b,255), entity.get_player_name(e.target), rgba_to_hex(r,g,b,255), group, rgba_to_hex(r,g,b,255), e.damage, entity.get_prop(e.target, "m_iHealth") ), r,g,b,255)
end)

client.set_event_callback("aim_miss", function(e)
	if not ui.get(master_switch) then
		return
	end

	local group = hitgroup_names[e.hitgroup + 1] or "?"

	client.color_log(255, 0, 0, "quiet ~\0")
	client.color_log(200, 200, 200, " Missed shot in\0")
	client.color_log(255, 0, 0, string.format(" %s\'s\0", entity.get_player_name(e.target)))
	client.color_log(255, 0, 0, string.format(" %s\0", group))
	client.color_log(200, 200, 200, " due to\0")
	client.color_log(255, 0, 0, string.format(" %s", e.reason))

    local r,g,b,a = ui.get(current_color)
    new_notify(string.format("\aFFFFFFFF Missed \a%s%s\aFFFFFFFF (\a%s%s\aFFFFFFFF) due to \a%s%s", rgba_to_hex(219, 99, 96,255), entity.get_player_name(e.target), rgba_to_hex(219, 99, 96,255), group, rgba_to_hex(219, 99, 96,255), e.reason), 219, 99, 96,255)
end)

client.set_event_callback('player_hurt', function(e)
	if not ui.get(master_switch) then
		return
	end
	
	local attacker_id = client.userid_to_entindex(e.attacker)

	if attacker_id == nil or attacker_id ~= entity.get_local_player() then
        return
    end

	if weapon_to_verb[e.weapon] ~= nil then
        local target_id = client.userid_to_entindex(e.userid)
		local target_name = entity.get_player_name(target_id)

		print(string.format("%s %s for %i damage (%i remaining)", weapon_to_verb[e.weapon], string.lower(target_name), e.dmg_health, e.health))
		client.color_log(124, 252, 0, "quiet ~\0")
		client.color_log(200, 200, 200, string.format(" %s\0", weapon_to_verb[e.weapon]))
		client.color_log(124, 252, 0, string.format(" %s\0", target_name))
		client.color_log(200, 200, 200, " for\0")
		client.color_log(124, 252, 0, string.format(" %s\0", e.dmg_health))
		client.color_log(200, 200, 200, " damage\0")
		client.color_log(200, 200, 200, " (\0")
		client.color_log(124, 252, 0, string.format("%s\0", e.health))
		client.color_log(200, 200, 200, " health remaining)")

        local r,g,b,a = ui.get(current_color)
        new_notify(weapon_to_verb[e.weapon].." \a"..rgba_to_hex(r,g,b,a)..target_name.."\aFFFFFFFF for".." \a"..rgba_to_hex(r,g,b,a)..e.dmg_health.."\aFFFFFFFF damage (".."\a"..rgba_to_hex(r,g,b,a)..e.health.."\aFFFFFFFF)", r,g,b,a)
	end
end)

client.set_event_callback('shutdown', function()
    ui.set_visible(reference.aa_enable, true)
    ui.set_visible(reference.pitch[1], true)
    ui.set_visible(reference.yaw_base, true)
    ui.set_visible(reference.yaw[1], true)
    ui.set_visible(reference.body_yaw[1], true)
    ui.set_visible(reference.edge_yaw, true)
    ui.set_visible(reference.freestanding[1], true)
    ui.set_visible(reference.freestanding[2], true)
    ui.set_visible(reference.roll, true)

    ui.set(reference.pitch[1], 'Off')
    ui.set(reference.pitch[2], 0)
    ui.set(reference.yaw_base, 'Local view')
    ui.set(reference.yaw[1], 'Off')
    ui.set(reference.yaw[2], 0)
    ui.set(reference.yaw_jitter[1], 'Off')
    ui.set(reference.yaw_jitter[2], 0)
    ui.set(reference.body_yaw[1], 'Off')
    ui.set(reference.body_yaw[2], 0)
    ui.set(reference.freestanding_body_yaw, false)
    ui.set(reference.edge_yaw, false)
    ui.set(reference.freestanding[1], false)
    ui.set(reference.freestanding[2], 'On hotkey')
end)

local IsNewClientAvailable = panorama.loadstring([[
	var oldClientStatus = NewsAPI.IsNewClientAvailable;

	return {
		disable: function(){
			NewsAPI.IsNewClientAvailable = function(){ return false };
		},
		restore: function(){
            NewsAPI.IsNewClientAvailable = oldClientStatus;
		}
	}
]])()

IsNewClientAvailable.disable()

client.set_event_callback("shutdown", function()
	IsNewClientAvailable.restore()
end)

client.set_event_callback("paint_ui", function()
    local r,g,b,a = ui.get(current_color)

    color_r = r
    color_g = g
    color_b = b
    color_a = a


    ui.set(text1, text_fade_animation(3, r,g,b,a, "Quiet Systems"))
    ui.set(text2, text_fade_animation(3, r,g,b,a, "Welcome back - "..string.lower(quiet.username)))
    ui.set(text3, text_fade_animation(3, r,g,b,a, "Lua Build - "..string.lower(quiet.build)))

    ctx.notify.render()
end)

client.set_event_callback("paint", function()
    --ctx.defensive_ind.render()
    ctx.arrows.render()
end)

-- local defensive1 = ui.new_checkbox('AA', 'Anti-aimbot angles', 'Force Defensive')
-- client.set_event_callback("setup_command", function(cmd)
-- if ui.get(defensive1) then
--   cmd.force_defensive = true
--   end
-- end)
