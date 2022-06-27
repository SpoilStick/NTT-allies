#macro current_frame_active (current_frame < floor(current_frame) + current_time_scale)

#define init
    global.newLevel = instance_exists(GenCont);

	global.sprAllyPortal 			= sprite_add("Sprites/sprAllyPortal.png", 			5,	16,	16);
	global.sprAllyPortalCharge 		= sprite_add("Sprites/sprAllyPortalCharge.png", 	4,	4,	4);
	global.sprAllyPortalClose		= sprite_add("Sprites/sprAllyPortalClose.png", 		14,	16,	16);
	global.sprAllyPortalDisappear	= sprite_add("Sprites/sprAllyPortalDisappear.png", 	6,	16,	16);
	global.sprAllyPortalStart		= sprite_add("Sprites/sprAllyPortalStart.png", 		2,	16,	16);
	
	global.sprAllyVanPortal				= sprite_add("Sprites/sprAllyVanPortal.png",			5,	40,	40);
	global.sprAllyVanPortalCharge		= sprite_add("Sprites/sprAllyVanPortalCharge.png",		2,	40,	40);
	global.sprAllyVanPortalClose		= sprite_add("Sprites/sprAllyVanPortalClose.png",		14,	40,	40);
	global.sprAllyVanPortalDisappear	= sprite_add("Sprites/sprAllyVanPortalDisappear.png",	5,	40,	40);
	global.sprAllyVanPortalStart		= sprite_add("Sprites/sprAllyVanPortalStart.png",		2,	40,	40);

#define popo_type(_modType, _modName, _typName)
    return {
        typ_name  : _typName,
        mod_type  : _modType,
        mod_name  : _modName,
        on_create : script_ref_create_ext(_modType, _modName, _typName + "_create"),
        on_spawn  : script_ref_create_ext(_modType, _modName, _typName + "_spawn"),
        on_step   : script_ref_create_ext(_modType, _modName, _typName + "_step")
    };

#define step
    if("vanlevel" not in GameCont) GameCont.vanlevel = 0;

     // Replace IDPD Spawns:
    with(IDPDSpawn) if(instance_is(self, IDPDSpawn)) && "ally" not in self {
		if random(6) < 1 {
			GameCont.popolevel--;
			repeat(random(2 + random(GameCont.loops)))
			AllyPortal_create(x + random_range(-32, 32), y + random_range(-32, 32), 0);
		}
		ally = 1;
    }
    with(VanSpawn) && "ally" not in self{
		if random(6) < 1 {
			AllyPortal_create(x + random_range(-32, 32), y + random_range(-32, 32), 1);
		}
		ally = 1;
    }
	

with(Player){
    if "lasthealth" not in self{
        lasthealth = lsthealth;
    }
    if (lasthealth > my_health){
		repeat(random(1 + GameCont.loops)) {
			if random(20 - 5 * skill_get(5)) < 1 {
				AllyPortal_create(x + random_range(-32, 32), y + random_range(-32, 32), 0);
			}
		}
		
		repeat(random(2 + GameCont.loops)) {
			if random(200 - 50 * skill_get(5)) < 1 {
				AllyPortal_create(x + random_range(-32, 32), y + random_range(-32, 32), 1);
			}
		}
		
        lasthealth = my_health;
    }
    if lasthealth < my_health lasthealth = my_health;
}
	
	

#define draw_dark
    with(instances_named(CustomObject, "IDPDPortal")){
        var r = (van ? 120 : 60);
        draw_circle(x, y, r + random(6), 0);
    }

#define draw_dark_end
    with(instances_named(CustomObject, "IDPDPortal")){
        var r = (van ? 40 : 20);
        draw_circle(x, y, r + random(6), 0);
    }

#define instances_named(_inst, _name)
    return instances_matching(_inst, "name", _name);

#define scrAlarm(_alarm)
    var a = alarm_get(_alarm);
    if(a > 0){
        a -= max(1, current_time_scale);
        alarm_set(_alarm, a);
        if(a <= 0){
            alarm_set(_alarm, -1);
            return true;
        }
    }
    return false;

#define AllyPortal_create(_x, _y, _van)
     // Increment IDPD Level:
    var _IDPDLevel = 0;
    if(_van){
        _IDPDLevel = ++GameCont.vanlevel;
    }
    else if(!instance_exists(LilHunter) || GameCont.loops > 0){
        _IDPDLevel = ++GameCont.popolevel;
    }

     // Compile Popo List:
    var _list = [popo_type("mod", mod_current, (_van ? "Van" : "Popo"))],
        _modType = ["mod", "weapon", "race", "skill", "crown", "area", "skin"],
        _scrt = "popo";

    for(var i = 0; i < array_length(_modType); i++){
        var t = _modType[i],
            _modName = mod_get_names(t);

        for(var j = 0; j < array_length(_modName); j++){
            var n = _modName[j];
            if(n != mod_current && mod_script_exists(t, n, _scrt)){
                _popo = mod_script_call(t, n, _scrt);
                for(var l = 0; l < lq_size(_popo); l++){
                    var _popoName = lq_get_key(_popo, l),
                        _popoType = lq_get(_popo, _popoName),
                        _popoLvl = lq_defget(_popoType, "lvl", 0),
                        _popoVan = lq_defget(_popoType, "van", 0);
    
                    if(_popoLvl <= _IDPDLevel && !(_popoVan ^^ _van)){
                        _list[array_length(_list)] = popo_type(t, n, _popoName);
                    }
                }
            }
        }
    }

     // Portal:
    with(instance_create(_x, _y, CustomObject)){
        name = "AllyPortal";

         // Vars:
        van = !!_van;
        clear = true; // Clear walls
        level = _IDPDLevel;
        friction = 0.1;

         // Visual:		
	    spr_strt = (van ? global.sprAllyVanPortalStart		: global.sprAllyPortalStart);
        spr_chrg = (van ? global.sprAllyVanPortalCharge		: global.sprAllyPortalCharge);
        spr_open = (van ? global.sprAllyVanPortalClose		: global.sprAllyPortalClose);
        spr_loop = (van ? global.sprAllyVanPortal			: global.sprAllyPortal);
        spr_clos = (van ? global.sprAllyVanPortalDisappear	: global.sprAllyPortalDisappear);
        spr_effx = global.sprAllyPortalCharge;
		
        image_speed = 0.4;
        depth = (!van ? -1 : -3);

         // Sound:
        snd_warn = (van ? sndVanWarning : sndEliteIDPDPortalSpawn);
        snd_spwn = (van ? sndVanPortal  : -1);
        if(GameCont.area == 101) snd_warn = sndOasisPopo;

         // Spawn Delay:
        var _portalNum = array_length(instances_matching(instances_named(object_index, name), "van", van));
        alarm0 = 40 + ((van ? 10 : 3) * _portalNum);

         // Type:
        var t = 0;
        if((!instance_exists(LilHunter) || GameCont.loops > 0) && random(3) < 2){
            t = irandom(array_length(_list) - 1);
            with(WantVan) canspawn = 1; // No more softlock
        }
        type = _list[t];
        can_step = mod_script_exists(type.on_step[0], type.on_step[1], type.on_step[2]);

         // Type's Create Event:
        var e = type.on_create;
        if(mod_script_exists(e[0], e[1], e[2])){
            mod_script_call(e[0], e[1], e[2]);
        }

         // Do Things:
        sound_play(snd_warn);
        sprite_index = spr_strt;
        if(van && clear) instance_create(x, y, PortalClear);

        on_step = IDPDPortal_step;

        return id;
    }

#define IDPDPortal_step
     // Type's Step:
    if(can_step){
        var e = type.on_step;
        mod_script_call(e[0], e[1], e[2]);
    }

     // Particles:
    if(sprite_index == spr_chrg && sprite_exists(spr_effx) && current_frame_active){
        with(instance_create(x + random_range(-48, 48), y + random_range(-48, 48), IDPDPortalCharge)){
            motion_add(point_direction(x, y, other.x, other.y), 2 + random(1));
            alarm0 = (point_distance(x, y, other.x, other.y) / speed) + 1;
            sprite_index = other.spr_effx;
        }
    }

     // Spawning:
    if(scrAlarm(0)){
         // Open:
        if(sprite_index == spr_chrg){
            alarm0 = 12;
            image_index = 0;
            sprite_index = spr_open;
        }

         // Spawn In:
        else{
             // Call Spawn Event:
            var e = type.on_spawn;
            if(mod_script_exists(e[0], e[1], e[2])){
                mod_script_call(e[0], e[1], e[2]);
            }

             // Clear Walls:    
            if(clear){
                clear = 0;
                if(van){
                    var o = 32;
                    for(var a = 0; a < 360; a += 90){
                        instance_create(x + lengthdir_x(o, a), y + lengthdir_y(o, a), PortalClear);
                    }
                }
                else instance_create(x, y, PortalClear);
                view_shake_at(x, y, 8);
                sound_play(snd_spwn);
            }
        }
    }

     // On Animating:
    if(sprite_index != spr_loop){
        if(image_index + image_speed > image_number - 1){
            if(sprite_index == spr_clos || sprite_index == spr_open){
                instance_destroy(); // Close
            }
            else sprite_index = spr_chrg; // Charging
        }
    }

#define Popo_create
     // Find what to spawn:
    spawn_idpd = Ally;
    spawn_num = 1;

    if(spawn_idpd == Ally) spawn_num = 1 + GameCont.loops;

#define Popo_spawn
global.a = random(360 / spawn_num)
for (var i = 0; i < 360; i += 360 / spawn_num) {
	with(instance_create(x + random_range(-4, 4), y + random_range(-4, 4), spawn_idpd)){
		speed = 6;
		direction = global.a + i;
	}
}

#define Van_spawn
    instance_create(x, y, Van);