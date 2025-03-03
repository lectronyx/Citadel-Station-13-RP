/turf
	/// multiz behavior flags
	var/z_flags = Z_AIR_UP | Z_OPEN_UP

/turf/proc/CanZPass(atom/A, direction)
	if(z == A.z)	// Moving FROM this turf
		return direction == UP	//Can't go below
	else
		if(direction == UP)	// On a turf below, trying to enter
			return 0
		if(direction == DOWN)	// On a turf above, trying to enter
			return !density && isopenturf(GetAbove(src))

/turf/simulated/open/CanZPass(atom, direction)
	return 1

/turf/space/CanZPass(atom, direction)
	return 1

/turf/proc/multiz_turf_del(turf/T, dir)
	SEND_SIGNAL(src, COMSIG_TURF_MULTIZ_DEL, T, dir)

/turf/proc/multiz_turf_new(turf/T, dir)
	SEND_SIGNAL(src, COMSIG_TURF_MULTIZ_NEW, T, dir)

/**
 * called during AfterChange() to request the turfs above and below us update their graphics.
 */
/turf/proc/update_vertical_turf_graphics()
	var/turf/simulated/open/above = GetAbove(src)
	if(istype(above))
		above.update_icon()

	var/turf/simulated/below = GetBelow(src)
	if(istype(below))
		below.update_icon() // To add or remove the 'ceiling-less' overlay.


//
// Open Space - "empty" turf that lets stuff fall thru it to the layer below
//

/turf/simulated/open
	name = "open space"
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	desc = "\..."
	density = 0
	plane = OPENSPACE_PLANE_START
	pathweight = 100000		// Seriously, don't try and path over this one numbnuts
	can_build_into_floor = TRUE
	allow_gas_overlays = FALSE
	z_flags = Z_AIR_UP | Z_AIR_DOWN | Z_OPEN_UP | Z_OPEN_DOWN | Z_CONSIDERED_OPEN

	var/turf/below

/turf/simulated/open/Initialize(mapload)
	. = ..()
	ASSERT(HasBelow(z))
	update()

/turf/simulated/open/Entered(var/atom/movable/mover)
	..()
	if(mover.movement_type & GROUND)
		mover.fall()

// Called when thrown object lands on this turf.
/turf/simulated/open/hitby(var/atom/movable/AM, var/speed)
	. = ..()
	if(AM.movement_type & GROUND)
		AM.fall()

/turf/simulated/open/proc/update()
	plane = OPENSPACE_PLANE + src.z
	below = GetBelow(src)
	below.update_icon()	// So the 'ceiling-less' overlay gets added.
	for(var/atom/movable/A in src)
		if(A.movement_type & GROUND)
			A.fall()
	SSopenspace.add_turf(src, 1)

// Override to make sure nothing is hidden
/turf/simulated/open/levelupdate()
	for(var/obj/O in src)
		O.hide(0)

/turf/simulated/open/examine(mob/user)
	. = ..()
	var/depth = 1
	for(var/T = GetBelow(src); isopenturf(T); T = GetBelow(T))
		depth += 1
	. += "It is about [depth] levels deep."

/**
* Update icon and overlays of open space to be that of the turf below, plus any visible objects on that turf.
*/
/turf/simulated/open/update_icon()
	cut_overlays() // Edit - Overlays are being crashy when modified.
	var/turf/below = GetBelow(src)
	if(below)
		var/below_is_open = isopenturf(below)

		if(below_is_open)
			underlays = below.underlays
		else
			var/image/bottom_turf = image(icon = below.icon, icon_state = below.icon_state, dir=below.dir, layer=below.layer)
			bottom_turf.plane = src.plane
			bottom_turf.color = below.color
			underlays = list(bottom_turf)
		copy_overlays(below)

		// Get objects (not mobs, they are handled by /obj/zshadow)
		var/list/o_img = list()
		for(var/obj/O in below)
			if(O.invisibility) continue	// Ignore objects that have any form of invisibility
			if(O.loc != below) continue	// Ignore multi-turf objects not directly below
			var/image/temp2 = image(O, dir = O.dir, layer = O.layer)
			temp2.plane = src.plane
			temp2.color = O.color
			temp2.overlays += O.overlays
			// TODO Is pixelx/y needed?
			o_img += temp2
		add_overlay(o_img)

		if(!below_is_open)
			add_overlay(/obj/effect/abstract/over_openspace_darkness)

		return 0
	return PROCESS_KILL

/obj/effect/abstract/over_openspace_darkness
	icon = 'icons/turf/open_space.dmi'
	icon_state = "black_open"
	plane = OVER_OPENSPACE_PLANE
	layer = MOB_LAYER

// Straight copy from space.
/turf/simulated/open/attackby(obj/item/C as obj, mob/user as mob)
	if (istype(C, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return
		var/obj/item/stack/rods/R = C
		if (R.use(1))
			to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			new /obj/structure/lattice(src)
		return

	if (istype(C, /obj/item/stack/tile/floor))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/floor/S = C
			if (S.get_amount() < 1)
				return
			qdel(L)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			S.use(1)
			ChangeTurf(/turf/simulated/floor, flags = CHANGETURF_INHERIT_AIR)
			return
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")

	// To lay cable.
	if(istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		coil.turf_place(src, user)

// Most things use is_plating to test if there is a cover tile on top (like regular floors)
/turf/simulated/open/is_plating()
	return TRUE

/turf/simulated/open/is_space()
	var/turf/below = GetBelow(src)
	return !below || below.is_space()

/turf/simulated/open/is_solid_structure()
	return locate(/obj/structure/lattice, src)	// Counts as solid structure if it has a lattice (same as space)

/turf/simulated/open/is_safe_to_enter(mob/living/L)
	if(L.can_fall())
		if(!locate(/obj/structure/stairs) in GetBelow(src))
			return FALSE
	return ..()
