/datum/map_template/shelter
	var/shelter_id
	var/description
	var/blacklisted_turfs
	var/whitelisted_turfs
	var/banned_areas
	var/banned_objects

/datum/map_template/shelter/New()
	. = ..()
	blacklisted_turfs = typecacheof(list(/turf/unsimulated, /turf/simulated/floor))
	banned_areas = typecacheof(/area/shuttle)
	banned_objects = list()

/datum/map_template/shelter/proc/check_deploy(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		var/area/A = get_area(T)
		if(is_type_in_typecache(A, banned_areas))
			return SHELTER_DEPLOY_BAD_AREA

		var/banned = is_type_in_typecache(T, blacklisted_turfs)
		var/permitted = !whitelisted_turfs || is_type_in_typecache(T, whitelisted_turfs)
		if(banned && !permitted)
			return SHELTER_DEPLOY_BAD_TURFS

		for(var/obj/O in T)
			if((O.density && O.anchored && !istype(O, /obj/structure/flora)) || is_type_in_typecache(O, banned_objects))
				return SHELTER_DEPLOY_ANCHORED_OBJECTS
	return SHELTER_DEPLOY_ALLOWED

/datum/map_template/shelter/proc/add_roof(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		if(isopenturf(T))
			T.ChangeTurf(/turf/simulated/shuttle/floor/voidcraft)

/datum/map_template/shelter/proc/annihilate_plants(turf/deploy_location)
	var/deleted_atoms = 0
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		for(var/obj/structure/flora/AM in T)
			++deleted_atoms
			qdel(AM)
	admin_notice("<span class='danger'>Annihilated [deleted_atoms] plants.</span>", R_DEBUG)

/datum/map_template/shelter/proc/update_lighting(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		T.lighting_build_overlay()

/datum/map_template/shelter/alpha
	name = "Shelter Alpha"
	shelter_id = "shelter_alpha"
	description = "A cosy self-contained pressurized shelter, with \
		built-in navigation, entertainment, medical facilities and a \
		sleeping area! Order now, and we'll throw in a TINY FAN, \
		absolutely free!"
	mappath = "_maps/templates/shelters/shelter_1.dmm"

/datum/map_template/shelter/beta
	name = "Shelter Beta"
	shelter_id = "shelter_beta"
	description = "An extremely luxurious shelter, containing all \
		the amenities of home, including carpeted floors, hot and cold \
		running water, a gourmet three course meal, cooking facilities, \
		and a deluxe companion to keep you from getting lonely during \
		an ash storm."
	mappath = "_maps/templates/shelters/shelter_2.dmm"

/datum/map_template/shelter/gamma
	name = "Shelter Gamma"
	shelter_id = "shelter_gamma"
	description = "A luxury elite bar which holds an entire bar \
		along with two vending machines, tables, and a restroom that \
		also has a sink. This isn't a survival capsule and so you can \
		expect that this won't save you if you're bleeding out to \
		death."
	mappath = "_maps/templates/shelters/shelter_3.dmm"

/datum/map_template/shelter/delta
	name = "Shelter Delta"
	shelter_id = "shelter_delta"
	description = "A small firebase that contains equipment and supplies \
		for roughly a squad of military troops. Large quantities of \
		supplies allow it to hold out for an extended period of time\
		and a built in medical facility allows field treatment to be \
		possible."
	mappath = "_maps/templates/shelters/shelter_4.dmm"

/datum/map_template/shelter/phi
	name = "Shelter Phi"
	shelter_id = "shelter_phi"
	description = "An heavily modified variant of the luxury shelter, \
		this particular model has extra food, drinks, and other supplies. \
		Originally designed for use by colonists on worlds with little to \
		to no contact, the expense of these shelters have prevented them \
		from seeing common use."
	mappath = "_maps/templates/shelters/shelter_a.dmm"
