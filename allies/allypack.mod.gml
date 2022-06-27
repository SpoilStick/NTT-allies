#macro current_frame_active (current_frame < floor(current_frame) + current_time_scale)

#define init
global.drawer = noone;

global.sprAllyTurretSpwn = sprite_add("Sprites/sprAllyTurretDead.png", 10, 12, 12);
global.sprAllyTurretIdle = sprite_add("Sprites/sprAllyTurretIdle.png", 16, 12, 12);
global.sprAllyTurretHurt = sprite_add("Sprites/sprAllyTurretHurt.png", 3, 12, 12);
global.sprAllyTurretDead = sprite_add("Sprites/sprAllyTurretDead.png", 6, 12, 12);
global.sprAllyTurretFire = sprite_add("Sprites/sprAllyTurretFire.png", 3, 12, 12);

global.sprAllyVan			= sprite_add("Sprites/sprAllyVan.png",			18,	38.5,	19.5)
global.sprAllyVanSiren		= sprite_add("Sprites/sprAllyVanSiren.png",		3,	38.5,	23.5)
global.sprAllyVanOutline	= sprite_add("Sprites/sprAllyVanOutline.png",	18,	38.5,	19.5)
global.sprAllyVanStop		= sprite_add("Sprites/sprAllyVanStop.png",		18,	38.5,	19.5)

#define step
if(!instance_exists(global.drawer)
&& instance_exists(Ally))
{
	global.drawer = instance_create(0, 0, CustomObject);
	with(global.drawer)
	{
		script_bind_draw(draw_guns, Ally.depth);
	}
}

with instances_matching(Ally, "name", "Captain Ally") {
	wep = 121
}

with(AllyBullet)
{
	//if("creator" not in self)
	creator = instance_nearest(xstart, ystart, Ally);
	if(instance_exists(creator)
	&& creator.my_health > 0)
	{
		gunally = 1;
		with(creator)
		{
			var _o = other;
			var _fire = player_fire_ext(_o.direction, wep, x+lengthdir_x(12, _o.direction), y+lengthdir_y(12, _o.direction), team, id);
			wepangle = _fire.wepangle;
			alarm1 = _fire.reload;
		}
	}
	instance_destroy();
}

#define AllyPortal_create(_x, _y, _van)
    return mod_script_call("mod", "popo", "AllyPortal_create", _x, _y, _van);

#define popo
    return {
         /// Popo ///
		"RadExplosion"	: { van : 0, lvl : 5 },
        "AmmoChest"		: { van : 0, lvl : 10 },
        "WeaponChest"	: { van : 0, lvl : 20 },
        "CaptainAlly"	: { van : 0, lvl : 25 },

         /// Vans ///
        "AllyVan"		: { van : 1, lvl :  1},
        "AmmoDrop"      : { van : 1, lvl :  5 }
    }

#define AmmoChest_spawn
sound_play(sndChest);
instance_create(x, y, AmmoChest);
repeat(7)
with instance_create(x, y, Smoke) {
	direction = random(360)
	speed = (1.7 + random(7)) / 7;
}

#define CaptainAlly_spawn
    with instance_create(x, y, Ally) {
		image_blend = c_yellow
		name = "Captain Ally"
		maxhealth *= 2
		my_health *= 2
		gunally = 1;
		wepangle = choose(140,-140);
	}
    repeat(5) with(instance_create(x, y, PortalL)){
        motion_add(random(360), 2);
        depth = 0;
    }

#define RadExplosion_spawn
     // Explosion:
	with instance_create(x, y, PlasmaImpact) {
		team = 2;
	}

	repeat(1)
	for (var i = random(3); i < 720+1; i += random(3)) {
		with instance_create(x, y, HorrorBullet) {
			team = 2;
			motion_add(i, 0.25 + random(10));
			image_angle = direction
		}
	}

     // Pickups:
    pickup_drop(33, 0);

#define RadTurret_spawn
obj_create(x, y, "AllyTurret");

#define WeaponChest_spawn
sound_play(sndChest);
instance_create(x, y, AmmoChest);
repeat(7)
with instance_create(x, y, Smoke) {
	direction = random(360)
	speed = (1.7 + random(7)) / 7;
}

#define AmmoDrop_spawn
sound_play(sndChest);
sound_play_pitch(sndSnowBotThrow, 1.2);
instance_create(x, y, VenuzAmmoSpawn);

#define AllyVan_spawn
obj_create(x, y, "AllyVan");
depth = -1;

#define obj_create(_x, _y, _obj)
switch(_obj){
	case "AllyVan":
	with instance_create(x,y,CustomObject){
		name = "AllyVan"
		team = 2;
		
		image_alpha = 0;
		if instance_exists(enemy)
		target = instance_nearest(x,y,enemy)
		else target = instance_nearest(x,y,Floor)
		if(target.x > x)
			right = 1
		else 
			right = -1
		direction = 90 - (90 * right)
		image_angle = direction
		drivespeed = 15
		depth = other.depth
		start = 20
		zscale = 1
		land = 10
		sprite_index = global.sprAllyVan
		maxspeed = 6
		maxhealth = 250
		my_health = 250
		meleedamage = 320
		on_draw = script_ref_create(vandraw)
		on_step = script_ref_create(vanguide)
		on_destroy = script_ref_create(vanexplo)
		
		baby = 0
		image_speed = 0.4
		with instance_create(x,y,CustomHitme){
			mama = other
			other.baby = id
			team = 2
			maxhealth = 250
			my_health = 250
			image_alpha = 0;
			friction = 10
			canfly = 1
			sprite_index = global.sprAllyVan
			image_speed = 0
			on_hurt = script_ref_create(AllyVan_hurt)
			}
		//alarm0 += choose(0,1,1) //round(1.5 * alarm0)
		spr_shadow = mskNone

		return id;
	}
	case "AllyTurret":
	sound_play_pitch(sndTurretSpawn, 0.6);
	with(instance_create(_x, _y, CustomEnemy)){
		name = _obj;

		 // Visual:
		spr_spwn = global.sprAllyTurretSpwn;
		spr_idle = global.sprAllyTurretIdle;
		spr_walk = spr_idle;
		spr_hurt = global.sprAllyTurretHurt;
		spr_dead = global.sprAllyTurretDead;
		spr_fire = global.sprAllyTurretFire;
		spr_shadow = shd24;
		spr_shadow_y = -1;
		sprite_index = spr_spwn;
		hitid = [spr_idle, "Ally Turret"];
		depth = -2;

		 // Sound:
		snd_hurt = sndTurretHurt;
		snd_dead = sndTurretDead;

		 // Vars:
		mask_index = mskScorpion;
		maxhealth = 50;
		gunangle = random(360);
		team = 2;
		size = 3;
		target = noone;

		alarm1 = ceil((image_number + sprite_get_number(spr_idle)) / image_speed) + 1;

		on_step     = AllyTurret_step;
		on_draw     = AllyTurret_draw;
		on_hurt     = AllyTurret_hurt;
		on_death    = AllyTurret_death;
		on_end_step = AllyTurret_end_step;

		return id;
	}
}

#define vanguide
//trace(my_health)
	
	if instance_number(enemy)==array_length_1d(instances_matching(CustomObject,"sprite_index",global.sprAllyVan))
	and instance_exists(enemy) and instance_exists(Corpse) and !instance_exists(Spiral){
		if fork(){
			var nc_ = instance_nearest(mouse_x,mouse_y,Corpse)
			wait 30
			if !instance_exists(Portal) and instance_exists(self)
			instance_create(nc_.x,nc_.y,Portal)
			
			exit;
			}
		}
	
	if start>0 start -= 1
	//image_angle = direction
	if start < 10 and drivespeed > 0
		drivespeed -= 0.3
	if drivespeed > 0{
		motion_add(direction, drivespeed)
		instance_create(x+lengthdir_x(30,image_angle+180+30),y+lengthdir_y(30,image_angle+180+30),CaveSparkle)
		instance_create(x+lengthdir_x(30,image_angle+180-30),y+lengthdir_y(30,image_angle+180-30),CaveSparkle)
		instance_create(x+lengthdir_x(30,image_angle+30),y+lengthdir_y(30,image_angle+30),CaveSparkle)
		instance_create(x+lengthdir_x(30,image_angle-30),y+lengthdir_y(30,image_angle-30),CaveSparkle)
		if start < 4{
		if random(4)<1 instance_create(x+lengthdir_x(30,image_angle+180+30),y+lengthdir_y(30,image_angle+180+30),GroundFlame) 
		if random(4)<1 instance_create(x+lengthdir_x(30,image_angle+180-30),y+lengthdir_y(30,image_angle+180-30),GroundFlame) 
		if random(4)<1 instance_create(x+lengthdir_x(30,image_angle+30),y+lengthdir_y(30,image_angle+30),GroundFlame)
		if random(4)<1 instance_create(x+lengthdir_x(30,image_angle-30),y+lengthdir_y(30,image_angle-30),GroundFlame) 
		}
		}
	else friction = 1
	if speed > maxspeed 
			speed = maxspeed
	while place_meeting(x,y,Wall){
		with instance_nearest(x+hspeed,y+vspeed,Wall){
			instance_create(x,y,FloorExplo);
			instance_destroy()
			}
		}
	
	if speed == 0 and  land > 0
		land -= 1
	if land = 1{
		var ix = x+lengthdir_x(36,image_angle+180);
		var iy = y+lengthdir_y(36,image_angle+180);
		repeat(5 + 5 * GameCont.loops){
			var copper = Ally;
			with instance_create(ix + random(24) - 12,iy + random(24) - 12,copper)
				motion_add(point_direction(other.x,other.y,x,y),8)
			instance_create(ix,iy,PortalClear)
			}
		
			repeat 10
			scrPickups(90)

			repeat(2 + irandom(1))
				instance_create(x+random_range(-30,30),y+random_range(-30,30), HealthChest)
			
		repeat(30)
			with instance_create(x,y,Dust){
				motion_add(random(360),random(6))
				depth = other.depth + .1
				}
		}
	if instance_exists(target)
			var ang = point_direction(x,y,target.x,target.y);
		else 
			var ang = image_angle;
	if start > 5
		image_angle = image_angle+(angle_difference(ang,image_angle)/8)
	if start < 5 and drivespeed > 0 and !place_meeting(x,y,target) and distance_to_object(target)<(game_width/2){
		image_angle = ang
		//image_angle = angle_difference(ang,direction)
		motion_add(direction+(angle_difference(ang,direction)/4), drivespeed/(5+start))
		drivespeed -= 0.3
		
		}
if instance_exists(baby){
		with baby{
			with instance_nearest(x,y,hitme) if distance_to_object(other)<32
				motion_add(point_direction(other.x,other.y,x,y),0.5)
			x=other.x+other.hspeed
			y=other.y+other.vspeed
			if other.speed > 1
			canmelee = 1
			else
			canmelee = 0
			image_angle = other.image_angle
			}
		}
	else instance_destroy()

#define vandraw
if instance_exists(baby){
	var creator = baby
	var i;
	var j = 0;
	draw_sprite_ext(global.sprAllyVanOutline, 0 , x, y ,image_xscale, image_yscale, image_angle, c_white, 0.5);
	if creator.nexthurt > current_frame 
		d3d_set_fog(1, c_white, 0, 1)
	for (i = 0; i <= 20; i++){
		repeat(zscale){
			draw_sprite_ext(global.sprAllyVanOutline, clamp(i,0,17) , x, y-land - .5 *(i + j) ,image_xscale, image_yscale, image_angle, c_white, 1);
			j += 1;
			}
		}
	d3d_set_fog(0, 0, 0, 0)
	j = 0
	if speed == 0
		var sprite = global.sprAllyVanStop;
	else
		var sprite = global.sprAllyVan;
	if creator.nexthurt > current_frame 
		d3d_set_fog(1, c_white, 0, 1)
	for (i = 0; i <= 20; i++){
		repeat(zscale){
			draw_sprite_ext(sprite, clamp(i,0,17) , x, y-land - .5 *(i + j) ,image_xscale, image_yscale, image_angle, c_white, 1);
			j += 1;
			}
		}
	d3d_set_fog(0, 0, 0, 0)
	if speed > 1{
		draw_sprite_ext(global.sprAllyVanSiren, image_index , x, y-land - .5 *(i + j),image_xscale, image_yscale, image_angle, image_blend, 1);
			}
	}
#define vanexplo
	
repeat(10)
instance_create(x+random_range(-30,30),x+random_range(-30,30),BlueFlame)

#define AllyVan_hurt(_hitdmg, _hitvel, _hitdir)
if(!instance_is(other, Corpse) && !instance_is(other, Debris)){
	my_health -= _hitdmg;			// Damage
	motion_add(_hitdir, _hitvel/2);	// Knockback
}

#define AllyTurret_step
     // Hurt:
    if(current_frame_active){
        if(random(maxhealth) > my_health){
            instance_create(x + 6 - random(12), y + 6 - random(12), SmokeOLD);
            sound_play_pitchvol(sndLightningHit, 0.6 + random(0.2), 0.5);
        }
    }

	hyper = 1 - my_health/maxhealth;

	 // Target:
	if(!instance_exists(target) || collision_line(x, y, target.x, target.y, Wall, 0, 0)){
		target = instance_nearest(x, y, enemy);
	}
	
	gunangle = point_direction(x, y, target.x, target.y)
    var _targetVisible = (instance_exists(target) && !collision_line(x, y, target.x, target.y, Wall, 0, 0));

     // Alarm1 : General
    if alarm1 < 0 {
		trace(distance_to_object(target))
        alarm1 = ceil(sprite_get_number(spr_idle) / image_speed) + 2 - 8 * hyper;
		
		if (_targetVisible) {
			repeat(1+hyper*2+random(2*hyper))
			with instance_create(x + 4 - random(8), y + 4 - random(8), Flame) {
				image_blend = c_lime
				motion_add(other.gunangle + 8 + 8 * other.hyper - random(16 + 16 * other.hyper), 4 + other.hyper * 2 + random(2 + other.hyper * 2));
				image_angle = direction;
				team = other.team;
				creator = other;
				hitid = other.hitid;
			}
		}
    }
	else {
		alarm1 -= 1
	}

     // Animate:
    if(sprite_index == spr_idle || (sprite_index != spr_idle && image_index + image_speed > image_number - 1)){
        sprite_index = spr_idle;
        image_index = image_number - (alarm1 * image_speed);
    }

#define AllyTurret_draw
    var h = (nexthurt > current_frame + 3 && sprite_index != spr_hurt);
    if(h) d3d_set_fog(1, c_white, 0, 0);
    draw_self_enemy();
    if(h) d3d_set_fog(0, 0, 0, 0);

#define AllyTurret_hurt(_hitdmg, _hitvel, _hitdir)
    my_health -= _hitdmg;		    // Damage
    motion_add(_hitdir, _hitvel);   // Knockback
    nexthurt = current_frame + 6;   // I-Frames
    sound_play_hit(snd_hurt, 0.3);  // Sound

     // Hurt Sprite:
    if(sprite_index != spr_spwn && sprite_index != spr_fire){
        sprite_index = spr_hurt;
        image_index = 0;
    }

#define AllyTurret_end_step
    x = xprevious;
    y = yprevious;
    speed = 0;

#define AllyTurret_death
     // Explosion:
	with instance_create(x, y, PlasmaImpact) {
		team = 2;
	}

	for (var i = random(9); i < 360+9; i += random(9)) {
		with instance_create(x, y, HorrorBullet) {
			team = 2;
			motion_add(i, 1 + random(6));
			image_angle = direction
		}
	}

     // Pickups:
    pickup_drop(33, 0);
	
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
	
#define draw_self_enemy()
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * right, image_yscale, image_angle, image_blend, image_alpha);
	
#define scrPickups(_dropchance)
with(instance_nearest(x,y,Player)){
	var _need = 0;
	var w = wep;
	repeat(2){
		if(w = bwep && bwep = 0) _need += 0.5;
		else{
			if(ammo[weapon_get_type(w)] < typ_amax[weapon_get_type(w)] * 0.2) _need += 0.75;
			else{
				if(ammo[weapon_get_type(w)] > typ_amax[weapon_get_type(w)] * 0.6) _need += 0.1;
				else _need += 0.5;
			}
		}
		w = bwep;
	}

	if(random(100) < _dropchance * (_need + (skill_get(4) * 0.6))){
		if(random(maxhealth) > my_health && random(3) < 2 && GameCont.crown != 2) instance_create(other.x + random_range(-2, 2), other.y + random_range(-2, 2), HPPickup);
		else if(GameCont.crown != 5) instance_create(other.x + random_range(-2, 2), other.y + random_range(-2, 2), AmmoPickup);
	}
}

#define draw_guns
with(Ally)
{
	if("gunally" in self)
	{
		draw_sprite_ext(weapon_get_sprite(wep), 0, x, y, 1, right, gunangle+wepangle, c_white, 1);
	}
}
