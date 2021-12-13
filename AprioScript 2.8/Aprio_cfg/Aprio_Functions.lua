local pedLocals = player.get_player_ped(player.player_id())
local req, opt, popt, Paths, data, kick_param, kick_param_data = {}, {}, {}, {}, {}, {}, {}
Paths.Root = utils.get_appdata_path("PopstarDevs", "2Take1Menu")

--\\Splitting strings because lua makes this a pita
function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
--split_string = Split("Hello World!", " ")

local keks_custom_modder_flags = 
	{
		["Has-Suspicious-Stats"] = 0,
		["Blacklist"] = 0,
		["Modded-Name"] = 0,
		["Godmode"] = 0,
		["0-Health-GodMode"] = 0
	}

--\\Checking for 0 health godmode/OTR
function pedHealthCheck()
	for i = 0, 31 do 
		if player.is_player_valid(i) then
			if ped.get_ped_max_health(i) == 0.0 then
				player.set_player_as_modder(i, keks_custom_modder_flags["0-Health-GodMode"])
			else
				system.wait(10)
			end
		else
			system.wait(10)
		end
	end
end

--\\Easy OTR
function easyOTR(context)
    if context.feat.on then
		ped.set_ped_max_health(pedLocals,  0)
	else
		ped.set_ped_max_health(pedLocals, 328)
		ped.set_ped_health(pedLocals, 328)
	end
end
	
--\\Easy godmode
function easyGM(context)
    if context.feat.on then
        ped.set_ped_max_health(pedLocals, 1000000)
		ped.set_ped_health(pedLocals,  1000000)
	else
		ped.set_ped_max_health(pedLocals, 328)
		ped.set_ped_health(pedLocals, 328)
	end
end

--\\Fire sniper for whiny kids
function fireSniper(context)
	if context.feat.on then
		weapon.give_weapon_component_to_ped(pedLocals, 0xA914799, 0xEC0F617)
    else
		weapon.give_weapon_component_to_ped(pedLocals, 0xA914799, 0x89EBDAA7)
	end
end

--\\Osiris scripts fixed safespace
function safeSpace(context)
	while context.feat.on do
    location = player.get_player_coords(player.player_id()) --save location
    menu.notify("Here is safe space!", "", 1, 190)
    entity.set_entity_coords_no_offset(pedLocals, v3(-75, -818, 326)) --mazebank
    system.yield(10)
	
    while context.feat.on do
      entity.set_entity_coords_no_offset(pedLocals, v3(-8292.664, -4596.8257, 14358.0))--safe space
      system.yield(1000)
    end
	
    if feat.on == false then
      menu.notify("Wait a sec", "", 2, 190)
    end
	
    system.yield(10)
	entity.set_entity_coords_no_offset(pedLocals, location)
	end
end

--\\Osiris scripts explosive quickswap updated
function quickSwap(context)
	if context.feat.on then
		if player.get_player_vehicle(pedLocals) == 143113 then
			system.wait(10)
		else
			if ped.is_ped_shooting(pedLocals) then
				if ped.get_current_ped_weapon(pedLocals) == 2726580491 then
					weapon.remove_weapon_from_ped(pedLocals, 2726580491)
					weapon.give_delayed_weapon_to_ped(pedLocals, 2726580491, 0, 1)
				end
				system.wait(1)
				if ped.get_current_ped_weapon(pedLocals) == 1672152130 then
					weapon.remove_weapon_from_ped(pedLocals, 1672152130)
					weapon.give_delayed_weapon_to_ped(pedLocals, 1672152130, 0, 1)
				end
			end
		end
	end
end

--\\Good old zero2menu fps crash protex
function fpsCrashCheck()
	while true do
		local limit = 10  
		for i in ipairs(vehicle.get_all_vehicles()) do    
			local veh = vehicle.get_all_vehicles()[i]
			if vehicleNearByStorage[entity.get_entity_model_hash(veh)] ~= nil then
				vehicleNearByStorage[entity.get_entity_model_hash(veh)] = vehicleNearByStorage[entity.get_entity_model_hash(veh)]+1
			else
      --hinzufügen mit 1
			vehicleNearByStorage[entity.get_entity_model_hash(veh)] = 1
			end    
    --check limits
			if (vehicleNearByStorage[entity.get_entity_model_hash(veh)] > limit) and ped.get_vehicle_ped_is_using(pedLocals) ~= veh then
				local pos = entity.get_entity_coords(veh)
				pos.y = 20000
				network.request_control_of_entity(veh)
				entity.set_entity_coords_no_offset(veh,pos)
				entity.freeze_entity(veh,true)      
				entity.set_entity_as_no_longer_needed(veh)
			end
		end
  
		for i in ipairs(vehicle.get_all_vehicles())do
			local veh = vehicle.get_all_vehicles()[i]
			if entity.is_entity_dead(veh) then
				local pos = entity.get_entity_coords(veh)
				pos.y = 20000
				network.request_control_of_entity(veh)
				entity.set_entity_coords_no_offset(veh,pos)
				entity.freeze_entity(veh,true)  
				entity.set_entity_as_no_longer_needed(veh)
			end    
		end  
		vehicleNearByStorage = {}
		if true then    
			return HANDLER_CONTINUE
		else
			return HANDLER_POP
		end
	end
end


--\\Spawns peds and vehicles for rc trolls and puts ped in vehicle and send to chase
function seater(count, id, hashs)
	for u=1, count do
		local pos = player.get_player_coords(id)
		local hash = gameplay.get_hash_key(hashs)
		streaming.request_model(hash)
		cars[u] = vehicle.create_vehicle(hash, v3(pos.x + math.random(0, 15), pos.y + math.random(0, 15), pos.z), pos.z, true, false)
		streaming.request_model(0x92991B72)
		drivers[u] = ped.create_ped(26, 0x92991B72, v3(pos.x + 7, pos.y, pos.z), pos.z, true, false)
		ped.set_ped_into_vehicle(drivers[u], cars[u], -1)
		menu.notify("RC Toy Spawned", "Stand", 5, 2)
		ai.task_vehicle_chase(drivers[u], player.get_player_ped(id))
		ai.task_vehicle_follow(drivers[u], cars[u], player.get_player_ped(id), 50.0, 0, 1)
		menu.notify("RC Toy Chasing", "Stand", 5, 2)
		system.wait(500)
	end
	return cars, drivers
end

--\\Auto req control from keks
function req.ctrl(e, t)
    if entity.is_an_entity(e) then
		if not network.has_control_of_entity(e) then
			network.request_control_of_entity(e)
			t = t or 75
			local time = utils.time_ms() + t
			while entity.is_an_entity(e) and not network.has_control_of_entity(e) do
				system.wait(0)
				network.request_control_of_entity(e)
				if time < utils.time_ms() then
					return false
				end
			end
		end
	return network.has_control_of_entity(e)
    end
    return false
end

function s_coords(i, p)
    req.ctrl(i)
    entity.set_entity_velocity(i, v3())
    entity.set_entity_coords_no_offset(i, p)
end

--\\Cleanup func for single entities 
function clean(X)
	req.ctrl(X, 350)
	entity.set_entity_velocity(X, v3())
	s_coords(X, v3(8000, 8000, -1000))
	entity.delete_entity(X)
	system.wait(1)
	menu.notify("Cleanup has completed", "", 10, 2)
	return
end

--\\Cleanup func for peds
function cleanPeds()
    local remove = ped.get_all_peds()
    for i = 1, #remove do
        local Y = remove[i]
        if not ped.is_ped_a_player(Y) then
            req.ctrl(Y, 250)
            entity.set_entity_velocity(Y, v3())
            s_coords(Y, v3(8000, 8000, -1000))
            entity.delete_entity(Y)
        end
    end
end

--\\Function to request control of entities for a time
function request_model(h, t)
	if not h then 
		return 
	end
	if not streaming.has_model_loaded(h) then
   		streaming.request_model(h)
    	local time = utils.time_ms() + t
    	while not streaming.has_model_loaded(h) and time > utils.time_ms() do
       		system.wait(5)
   		end
	end
	return streaming.has_model_loaded(h)
end

--\\Creates peds with parameters
function Cped(type, hash, coords, dir)
	request_model(hash, 300)
	local ped = ped.create_ped(type, hash, coords, dir, true, false)
	streaming.request_model(hash)
	return ped
end

--\\Custome SE kick/crash sender
function customSES(context)
	local count = 0
	while context.val.on do
		for i = 1, 13 do
			par1 = math.random(-1000, 99999999)
			par2 = math.random(-99999999999999, -9)
			par3 = math.random(46190868, 999999999)
			par4 = math.random(-1, 9)
			par5 = math.random(-99999999999999, -46190868)
			par6 = math.random(9999999999, 9999999899990868)
				system.yield(50)
			script.trigger_script_event(seKicks[math.random(1, #seKicks)], context.id, {par3, par5, par2, par3, par2, par1, par3, par1})
				system.yield(50)
		end
		count = count + 1
		menu.notify("Event set sent: ".. count, "Custom Script Event Sender", 4, 6)
		system.wait(12000)
	end
end

--\\Rains and attaches/detaches a set of objs and veh
function crazyRain(context)
    while context.feat.on do
		local pid = context.pid
		local id = entity.get_entity_bone_index_by_name(player.get_player_ped(context.pid), "IK Head")
        local pos_start = v3()
        pos_start = player.get_player_coords(context.pid)
        pos_start.z = pos_start.z + 30.0
        local pos_end = player.get_player_coords(context.pid)
        local offset = v3()
        offset.x = math.random(-5,5)
        offset.y = math.random(-5,5)
		
        local ob = object.create_object(gameplay.get_hash_key("prop_elecbox_11"), pos_end + offset, true, true)
		local ob1 = object.create_object(gameplay.get_hash_key("prop_ld_int_safe_01"), pos_end + offset, true, true)
		local ob2 = object.create_object(gameplay.get_hash_key("prop_devin_box_dummy_01"), pos_end + offset, true, true)
		local ob3 = object.create_object(gameplay.get_hash_key("ch_prop_ch_diamond_xmastree"), pos_end + offset, true, true)
		local ob4 = object.create_object(gameplay.get_hash_key("bkr_prop_clubhouse_jukebox_01a"), pos_end + offset, true, true)
		local ob5 = object.create_object(gameplay.get_hash_key("prop_elecbox_11"), pos_end + offset, true, true)
		local ob6 = object.create_object(gameplay.get_hash_key("prop_devin_box_dummy_01"), pos_end + offset, true, true)
		local ob7 = object.create_object(gameplay.get_hash_key("prop_elecbox_11"), pos_end + offset, true, true)
		local veh_spawn = vehicle.create_vehicle(0x15F27762, pos_end + offset, pos_start.z, true, false)
		local veh_spawn1 = vehicle.create_vehicle(0x4FAF0D70, pos_end + offset, pos_start.z, true, false)
		local veh_spawn2 = vehicle.create_vehicle(0x810369E2, pos_end + offset, pos_start.z, true, false)
		entity.set_entity_god_mode(ob, true)
		entity.set_entity_god_mode(ob1, true)
		entity.set_entity_god_mode(ob2, true)
		entity.set_entity_god_mode(ob3, true)
		entity.set_entity_god_mode(ob4, true)
		entity.set_entity_god_mode(ob5, true)
		entity.set_entity_god_mode(ob6, true)
		entity.set_entity_god_mode(ob7, true)
		entity.set_entity_god_mode(veh_spawn, true)
		entity.set_entity_god_mode(veh_spawn1, true)
		entity.set_entity_god_mode(veh_spawn2, true)
			system.wait(5000)
		entity.attach_entity_to_entity(ob, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(ob1, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(ob2, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(ob3, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(ob4, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(ob5, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(ob6, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(ob7, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(veh_spawn, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(veh_spawn1, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		entity.attach_entity_to_entity(veh_spawn2, player.get_player_ped(pid), id, pos_start, pos_end, true, true, true, 1, true)
		
			system.wait(10000)
		clean(ob)
		clean(ob1)
		clean(ob2)
		clean(ob3)
		clean(ob4)
		clean(ob5)
		clean(ob6)
		clean(ob7)
		clean(veh_spawn)
		clean(veh_spawn1)
		clean(veh_spawn2)
    end
end

--\\Railgun kill loop func
function rgun(context)
	while context.feat.on do
		system.wait(0)
		local pos = v3()
		pos = player.get_player_coords(context.pid)
		pos.z = pos.z + 65.0
		gameplay.shoot_single_bullet_between_coords(pos, player.get_player_coords(context.pid) + v3(0, 0, 1), 10000.00, 0x6D544C99, 0, true, false, 10000.0)
	end
end


--\\Ped pool fill crash func
function pedFill(context)
	for i = 1, 5 do 
		for i = 0 , 30 do 
			local pos = player.get_player_coords(context.pid)
			local npc = Cped(26, 0x92991B72,pos, 0)
			system.wait(0)
		end
	end
		 
	system.wait(15000)
	cleanPeds()
end

--\\Invis vehicle lag func
function invis(context)

	local pos = player.get_player_coords(context.pid)
	local hashes = {
	0x810369E2,
	0x6827CF72,
	0x4FAF0D70,
	0xD039510B,
	0x9B16A3B4,
	0xC3FBA120,
	0x1A7FCEFA,
	0xCEEA3F4B,
	0x2592B5CF,
	0x81BD2ED0,
	0x18606535,
	0xF7004C86,
	0x3D6AAA9B,
	0xDB6B4924,
	0xEDA4ED97,
	0xFE0A508C,
	0x15F27762,
	0x3F119114,
	0x250B0C5E,
	0xB79F589E,
	0x9D80F93,
	0xB2CF7250,
	0xB79C1BF5,
	0x761E2AD3,
	0x3E2E4F8A,
	0x1AAD0DED,
	0xEA313705,
	0xE6E967F8,
	0x4C80EB0E,
	0xEDC6F847,
	0xD577C962,
	0x84718D34,
	0x149BD32A,
	0xB8081009,
	0xA7FF33F5,
	0x9E6B14D6,
	0x6A59902D
	}

	for i = 1, #hashes do
		streaming.request_model(hashes[i])
	end
	
	system.wait(10000)
	
	local veh_spawn, veh_spawn1, veh_spawn2 = {}, {}, {}
	while context.feat.on do
		local count = 1
		while count <= #hashes do 
			veh_spawn[#veh_spawn+1] = vehicle.create_vehicle(hashes[count], pos, pos.z, true, false)
			entity.set_entity_god_mode(veh_spawn[#veh_spawn], true)
			entity.set_entity_visible(veh_spawn[#veh_spawn], false)
			
			veh_spawn1[#veh_spawn1+1] = vehicle.create_vehicle(hashes[count], pos, pos.z, true, false)
			entity.set_entity_god_mode(veh_spawn1[#veh_spawn1], true)
			entity.set_entity_visible(veh_spawn1[#veh_spawn1], false)
			
			veh_spawn2[#veh_spawn2+1] = vehicle.create_vehicle(hashes[count], pos, pos.z, true, false)
			entity.set_entity_god_mode(veh_spawn2[#veh_spawn2], true)
			entity.set_entity_visible(veh_spawn2[#veh_spawn2], false)
			count = count+1
		end
		
		system.wait(1000)

		for u = 1, #hashes do
			entity.delete_entity(veh_spawn[u])
			entity.delete_entity(veh_spawn1[u])
			entity.delete_entity(veh_spawn2[u])
		end
	end

	for g = 1, #hashes do
		streaming.set_model_as_no_longer_needed(hashes[g])
	end
end

--\\Sub lag func
function subs(context)
    if context.feat.on then 
        local pos = player.get_player_coords(context.pid)
        local veh_hash = 0x4FAF0D70

		streaming.request_model(veh_hash)
			system.wait(1000)
		while (not streaming.has_model_loaded(veh_hash)) do
			system.wait(10)
		end
		
		local tableOfVehicles = {}
		for i = 1, 75 do
			tableOfVehicles[#tableOfVehicles + 1] = vehicle.create_vehicle(veh_hash, pos, pos.z, true, false)
		end
			system.wait(1000)
		for i = 1, #tableOfVehicles do
			entity.delete_entity(tableOfVehicles[i])
		end
		tableOfVehicles = {}

		streaming.set_model_as_no_longer_needed(veh_hash)
	end
end

--\\Cargo lag func
function cargos(context)
    if context.feat.on then
        local pos = player.get_player_coords(context.pid)
        local veh_hash = 0x15F27762

		streaming.request_model(veh_hash)
			system.wait(1000)
		while (not streaming.has_model_loaded(veh_hash)) do
			system.wait(10)
		end
		
		local tableOfVehicles = {}
		for i = 1, 75 do
			tableOfVehicles[#tableOfVehicles + 1] = vehicle.create_vehicle(veh_hash, pos, pos.z, true, false)
		end
			system.wait(1000)
		for i = 1, #tableOfVehicles do
			entity.delete_entity(tableOfVehicles[i])
		end
		tableOfVehicles = {}

		streaming.set_model_as_no_longer_needed(veh_hash)
	end
end

--\\Opressors/home rocket veh troll?
function cartroll(context)
	while context.feat.on do
		local pped = player.get_player_ped(context.pid)
		if player.get_player_vehicle(pped) == 2069146067 or 1336872304  or 2594093022 or 1565978651 or 4252008158 or 2908775872 or 3656405053 or 3319621991 or 3052358707 or 4212341271 or 1229411063 or 1593933419 or 3568198617 or 1181327175 or 1692272545 or 1036591958 or 295054921 or 1489874736 or 886810209 or 884483972 or 1455990255 or 3013282534 or 1483171323 or 970385471 or 3602674979 or 2306538597 or 562680400 or 2413121211 then
			if ped.is_ped_shooting(pped) then
				local tom  = player.get_player_vehicle(pped)
				network.request_control_of_entity(tom)
				--entity.set_entity_coords_no_offset(tom, v3(0,0,100000000))
				if ped.get_current_ped_weapon(pped) == 1672152130 then
					weapon.remove_weapon_from_ped(pped, 1672152130)
					weapon.give_delayed_weapon_to_ped(pped, 1672152130, 0, 1)
				end
				system.wait(1)
			end
		end
	end
end

--\\Netbail kick 
function netbail(pid)
	local par = script.get_global_i(1630816 + (1 + (pid * 597) + 508))
		system.yield(150)
	script.trigger_script_event(2092565704, pid, {pid, par})
		system.yield(150)
	script.trigger_script_event(2092565704, pid, {pid, par})
		system.yield(150)
	script.trigger_script_event(2092565704, pid, {pid, par})
		system.yield(150)
end

--\\Auto host grabber
function autoHost(context)
	while context.feat.on do
		local host = player.get_host()
		if blamed == host then
			system.wait(1000)
		else
			netbail(host)
		end
	end
end

------------------------------

function OffsetCoords(pos, heading, distance)
    heading = math.rad((heading - 180) * -1)
    return v3(pos.x + (math.sin(heading) * -distance), pos.y + (math.cos(heading) * -distance), pos.z)
end

function get_offset(pid, dist)
    local pos = player.get_player_coords(pid)
    offsetPos = OffsetCoords(pos, player.get_player_heading(pid), dist)
    return offsetPos
end

function SCID(pid)
    
    return player.get_player_scid(pid)
end

function PlyPed(pid)
    local PlayerPed = player.get_player_ped(pid)
    return PlayerPed
end

function modeluwu()
    streaming.request_model(uwu)
     while(not streaming.has_model_loaded(uwu))
     do
     system.wait(10)
       end
      player.set_player_model(uwu)
         streaming.set_model_as_no_longer_needed(uwu)
end

--block orbital doorway with wall

local OrbitalBlocks = {}
local pos, telpos, rot, mypos = v3(), v3(), v3(), v3()
mypos = player.get_player_coords(player.player_id())
local mycurhead = player.get_player_heading(player.player_id())

--TODO: Function Data & Entity Arrays

AttachedCunt={}AttachedCunt2={}
escort, escortveh, spawned_cunts, groupIDs, allpeds, allveh, allobj, allpickups, alkonost, kosatka, scids, spawned_cunt1, spawned_cunt2, spawned_cunt3, spawned_cunt, BlipIDs, EntityHash, EntityHash2, Thread2Id, Thread1Id, Esp_pid, markID, boobs, boobveh = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
lesveh, lester, groupIDs, lester_group = {}, {}, {}, {}

scidN = 0
local size_marker, marker_type, offsetz_marker = 1.0, 0, 1.5

--TODO: Recoverie

function Get_Last_MP(stat)
    local text = stat
    local hash = gameplay.get_hash_key("MPPLY_LAST_MP_CHAR")
    local MP = stats.stat_get_int(hash, 1)
    return (string.format("MP" ..MP .."_" ..text))
    end

--TODO: Features veh check    

    function veh_check(pid)
        pped = player.get_player_ped(pid)
        if player.is_player_in_any_vehicle(pid) or ped.is_ped_in_any_vehicle(pped) then
            local plyveh, pedveh = player.is_player_in_any_vehicle(pid),  ped.is_ped_in_any_vehicle(pped)
            menu.notify("Player in Veh Check: " .. tostring(plyveh) .."\nPlayer Ped in Veh Check: " ..  tostring(pedveh), "Player Vehicle Check")
            local vehchk1 = ped.get_vehicle_ped_is_using(pped)
            local vehchk2 = player.get_player_vehicle(pid)
        
            menu.notify("Player Vehicle ID: " .. vehchk2 .."\nPlayers Ped Vehicle ID: " .. vehchk1, "Player Vehicle Check")
        end
        end

--TODO: Features veh speed

function playervehspd(pid, speed)
    local plyveh = player.get_player_vehicle(pid)
    entity.set_entity_max_speed(plyveh, speed)
    network.request_control_of_entity(plyveh)
    vehicle.modify_vehicle_top_speed(plyveh, speed)
    entity.set_entity_max_speed(plyveh, speed)
end

--TODO: Spawn attach

function spawn_attach(hash, bone, pos, rot, col, pid)
	streaming.request_model(hash)
	while (not streaming.has_model_loaded(hash)) do
		system.wait(10)
	end
	local i = #spawned_cunts + 1
	spawned_cunts[i] = object.create_object(hash, pos, true, false)
	pped = player.get_player_ped(pid)
	entity.attach_entity_to_entity(spawned_cunts[i], pped, bone, pos, rot, true, col, false, 0, true)
end

-- Player Ped ID / Entity ID (attach build)

function spawn_object_onp(hash, pid)
    local pos, rot, rot2 = v3(), v3(180.00,0.0,0.0), v3(180.00,0.0,90.00)
    local offset, arot = v3(0.0,0.0,1.0), v3(180.0,0.0,90.00)
    pos = player.get_player_coords(pid)
    pos.z = pos.z + 7.0
    local Spawn, Spawn2
    Spawn = object.create_object(hash, pos, true, true)
    Spawn2 = object.create_object(hash, pos, true, true)
    entity.set_entity_as_mission_entity(Spawn2, true, false)
    entity.set_entity_collision(Spawn2, false, false, false)
    entity.set_entity_as_mission_entity(Spawn, true, false)
    entity.set_entity_collision(Spawn, false, false, false)
    entity.set_entity_rotation(Spawn, rot)
    --entity.set_entity_rotation(Spawn2, rot2)
    entity.attach_entity_to_entity(Spawn2, Spawn, 0, offset,  arot, true, false, false, 0, true)
    return Spawn, Spawn2
    end

--Get Offset to self POS
local SelfoffsetPos, offsetPos = v3(), v3()

function Self_offsetPos(pos, heading, distance)
heading = math.rad((heading - 180) * -1)
return v3(pos.x + (math.sin(heading) * -distance), pos.y + (math.cos(heading) * -distance), pos.z)
end
function get_offset2me(dist)
local pos = player.get_player_coords(player.player_id())
SelfoffsetPos = Self_offsetPos(pos, player.get_player_heading(player.player_id()), dist)
return SelfoffsetPos
end

-- Get player ip

function GetIP(pid)
    ip = player.get_player_ip(pid)
    return ip
    end

function dec2ip(decip)
    local div, quote, ip;
    for i = 3, 0, -1 do
        div = 2 ^ (i * 8)
        quote, decip = math.floor(decip / div), math.fmod(decip, div)
        if nil == ip then
            ip = quote
            else ip = ip .. "." .. quote
        end
    end
    return ip
    end

-- send slasher halloween

function HitSquad(pid)
        local hash = gameplay.get_hash_key("G_M_M_Slasher_01")
       
       streaming.request_model(hash)
       while (not streaming.has_model_loaded(hash)) do
          system.wait(0)
       end
       
       for i = 1, 10 do
          local pos = entity.get_entity_coords(player.get_player_ped(pid))
          pos.x = pos.x + math.random(-20, 20 + i)
          pos.y = pos.y + math.random(-20, 20)
         
          local Peds = ped.create_ped(4, hash, pos, 1.0, true, false)
          weapon.give_delayed_weapon_to_ped(Peds, 0x476BF155, 0, true)
          ped.set_ped_health(Peds, 410)
          ped.set_ped_combat_ability(Peds, 2)
          ped.set_ped_combat_attributes(Peds, 5, true)
          ai.task_combat_ped(Peds, player.get_player_ped(pid), 1, 16)
          ped.set_ped_relationship_group_hash(Peds, 0x84DCFAAD)
          gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(Peds), entity.get_entity_coords(Peds) + v3(0, 0.0, 0.1), 0, 453432689, player.get_player_ped(pid), false, true, 100)
          streaming.set_model_as_no_longer_needed(hash)   
       end
    end

-- Grapple Gun 

function GrappleGun()
    local boolrtn, impact = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()), v3())
    local loc = player.get_player_coords(player.player_id())
    impact.x = impact.x - loc.x
    impact.y = impact.y - loc.y
    impact.z = impact.z - loc.z + 4
    
    if boolrtn then
        rope.rope_load_textures()
        rope.add_rope(impact, v3(0,0,0), 10.2, 2, 10.0, 1.0, 1, false, false, false, 0, true)
        local obj = object.create_object(gameplay.get_hash_key("prop_devin_box_dummy_01"), impact, true, false)
        local pos = entity.get_entity_coords(obj)
      
        rope.attach_rope_to_entity(2, obj, v3(pos.x, pos.y, pos.z), true)
        system.wait(500)
        entity.set_entity_velocity(player.get_player_ped(player.player_id()), impact)
        rope.rope_load_textures()
        ai.task_sky_dive(player.get_player_ped(player.player_id()), true)
    end
end

-- Spawn manager  

function SpawnPed(val)
        local hash = gameplay.get_hash_key(pedList[val.value+1])
    
        streaming.request_model(hash)
        while(not streaming.has_model_loaded(hash)) do
           system.wait(0)
        end
        if(streaming.is_model_valid(hash)) then
           ped.create_ped(26, hash, player.get_player_coords(player.player_id()), 0, true, false)
        end
        streaming.set_model_as_no_longer_needed(hash) 
    end

function SpawnFlippedMap()
        local pos = player.get_player_coords(player.player_id())
        pos.x = pos.x 
        pos.y = pos.y
        pos.z = pos.z + 500
    
        local e = object.create_world_object(gameplay.get_hash_key("ch2_lod3_slod3"), pos, true, false)
        local roat = v3()
        roat.x = 0
        roat.y = -200
        roat.z = 5
    
        entity.set_entity_rotation(e, roat)
    
    end
