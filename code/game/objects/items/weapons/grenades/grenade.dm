/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = ITEMSIZE_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 4
	throw_range = 20
	slot_flags = SLOT_MASK|SLOT_BELT

	var/active = 0
	var/det_time = 50
	var/loadable = TRUE
	var/arm_sound = 'sound/weapons/armbomb.ogg'

/obj/item/grenade/proc/clown_check(var/mob/living/user)
	if((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")

		activate(user)
		add_fingerprint(user)
		spawn(5)
			detonate()
		return 0
	return 1


/*/obj/item/grenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (istype(target, /obj/item/storage)) return ..() // Trying to put it in a full container
	if (istype(target, /obj/item/gun/grenadelauncher)) return ..()
	if((user.get_active_held_item() == src) && (!active) && (clown_check(user)) && target.loc != src.loc)
		to_chat(user, "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>")
		active = 1
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		spawn(det_time)
			detonate()
			return
		user.setDir(get_dir(user, target))
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
	return*/


/obj/item/grenade/examine(mob/user)
	. = ..()
	if(det_time > 1)
		. += "<span class = 'notice'>The timer is set to [det_time/10] seconds.</span>"
		return
	if(det_time == null)
		. += "<span class = 'danger'>The [src] is set for instant detonation.</span>"


/obj/item/grenade/attack_self(mob/user as mob)
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You prime \the [name]! [det_time/10] seconds!</span>")

			activate(user)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
	return


/obj/item/grenade/proc/activate(mob/user as mob)
	if(active)
		return

	if(user)
		msg_admin_attack("[key_name_admin(user)] primed \a [src.name]")

	icon_state = initial(icon_state) + "_active"
	active = 1
	playsound(loc, arm_sound, 75, 1, -3)

	spawn(det_time)
		detonate()
		return


/obj/item/grenade/proc/detonate()
//	playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)


/obj/item/grenade/attackby(obj/item/W as obj, mob/user as mob)
	if(W.is_screwdriver())
		switch(det_time)
			if (1)
				det_time = 10
				to_chat(user, "<span class='notice'>You set the [name] for 1 second detonation time.</span>")
			if (10)
				det_time = 30
				to_chat(user, "<span class='notice'>You set the [name] for 3 second detonation time.</span>")
			if (30)
				det_time = 50
				to_chat(user, "<span class='notice'>You set the [name] for 5 second detonation time.</span>")
			if (50)
				det_time = 1
				to_chat(user, "<span class='notice'>You set the [name] for instant detonation.</span>")
		add_fingerprint(user)
	..()
	return

/obj/item/grenade/attack_hand()
	walk(src, null, null)
	..()
	return
