/obj/item/spacecash
	name = "0 Thaler"
	desc = "It's worth 0 Thalers."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "spacecash1"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = ITEMSIZE_SMALL
	var/access = list()
	access = access_crate_cash
	var/worth = 0
	drop_sound = 'sound/items/drop/paper.ogg'
	pickup_sound = 'sound/items/pickup/paper.ogg'

/obj/item/spacecash/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/spacecash))
		if(istype(W, /obj/item/spacecash/ewallet)) return 0

		var/obj/item/spacecash/SC = W

		SC.adjust_worth(src.worth)
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/h_user = user

			h_user.temporarily_remove_from_inventory(src, INV_OP_FORCE | INV_OP_SHOULD_NOT_INTERCEPT | INV_OP_SILENT)
			h_user.temporarily_remove_from_inventory(SC, INV_OP_FORCE | INV_OP_SHOULD_NOT_INTERCEPT | INV_OP_SILENT)
			h_user.put_in_hands(SC)
		to_chat(user, "<span class='notice'>You combine the Thalers to a bundle of [SC.worth] Thalers.</span>")
		qdel(src)

/obj/item/spacecash/update_icon()
	overlays.Cut()
	name = "[worth] Thaler\s"
	if(worth in list(1000,500,200,100,50,20,10,1))
		icon_state = "spacecash[worth]"
		desc = "It's worth [worth] Thalers."
		return
	var/sum = src.worth
	var/num = 0
	for(var/i in list(1000,500,200,100,50,20,10,1))
		while(sum >= i && num < 50)
			sum -= i
			num++
			var/image/banknote = image('icons/obj/items.dmi', "spacecash[i]")
			var/matrix/M = matrix()
			M.Translate(rand(-6, 6), rand(-4, 8))
			M.Turn(pick(-45, -27.5, 0, 0, 0, 0, 0, 0, 0, 27.5, 45))
			banknote.transform = M
			src.overlays += banknote
	if(num == 0) // Less than one thaler, let's just make it look like 1 for ease
		var/image/banknote = image('icons/obj/items.dmi', "spacecash1")
		var/matrix/M = matrix()
		M.Translate(rand(-6, 6), rand(-4, 8))
		M.Turn(pick(-45, -27.5, 0, 0, 0, 0, 0, 0, 0, 27.5, 45))
		banknote.transform = M
		src.overlays += banknote
	src.desc = "They are worth [worth] Thalers."

/obj/item/spacecash/proc/adjust_worth(var/adjust_worth = 0, var/update = 1)
	worth += adjust_worth
	if(worth > 0)
		if(update)
			update_icon()
		return worth
	else
		qdel(src)
		return 0

/obj/item/spacecash/proc/set_worth(var/new_worth = 0, var/update = 1)
	worth = max(0, new_worth)
	if(update)
		update_icon()
	return worth

/obj/item/spacecash/attack_self()
	var/amount = input(usr, "How many Thalers do you want to take? (0 to [src.worth])", "Take Money", 20) as num
	if(!src || QDELETED(src))
		return
	amount = round(clamp(amount, 0, src.worth))

	if(!amount)
		return

	adjust_worth(-amount)
	var/obj/item/spacecash/SC = new (usr.loc)
	SC.set_worth(amount)
	usr.put_in_hands(SC)

/obj/item/spacecash/is_static_currency(prevent_types)
	return (prevent_types & PAYMENT_TYPE_CASH)? NOT_STATIC_CURRENCY : PLURAL_STATIC_CURRENCY

/obj/item/spacecash/do_static_currency_feedback(amount, mob/user, atom/target, range)
	user.visible_message(SPAN_NOTICE("[user] inserts some cash into [target]."), SPAN_NOTICE("You insert [amount] [CURRENCY_NAME_PLURAL_PROPERR] into [target]."), SPAN_NOTICE("You hear some papers shuffling."), range)

/obj/item/spacecash/consume_static_currency(amount, force, mob/user, atom/target, range)
	if(force)
		amount = min(amount, worth)
	if(amount > worth)
		return PAYMENT_INSUFFICIENT
	worth -= amount
	do_static_currency_feedback(amount, user, target, range)
	. = amount
	if(!worth)
		qdel(src)

/obj/item/spacecash/amount_static_currency()
	return worth

/obj/item/spacecash/c1
	name = "1 Thaler"
	icon_state = "spacecash1"
	desc = "It's worth 1 credit."
	worth = 1

/obj/item/spacecash/c10
	name = "10 Thaler"
	icon_state = "spacecash10"
	desc = "It's worth 10 Thalers."
	worth = 10

/obj/item/spacecash/c20
	name = "20 Thaler"
	icon_state = "spacecash20"
	desc = "It's worth 20 Thalers."
	worth = 20

/obj/item/spacecash/c50
	name = "50 Thaler"
	icon_state = "spacecash50"
	desc = "It's worth 50 Thalers."
	worth = 50

/obj/item/spacecash/c100
	name = "100 Thaler"
	icon_state = "spacecash100"
	desc = "It's worth 100 Thalers."
	worth = 100

/obj/item/spacecash/c200
	name = "200 Thaler"
	icon_state = "spacecash200"
	desc = "It's worth 200 Thalers."
	worth = 200

/obj/item/spacecash/c500
	name = "500 Thaler"
	icon_state = "spacecash500"
	desc = "It's worth 500 Thalers."
	worth = 500

/obj/item/spacecash/c1000
	name = "1000 Thaler"
	icon_state = "spacecash1000"
	desc = "It's worth 1000 Thalers."
	worth = 1000

/proc/spawn_money(sum, spawnloc, mob/living/carbon/human/human_user)
	var/obj/item/spacecash/SC = new (spawnloc)

	SC.set_worth(sum)
	if (ishuman(human_user) && !human_user.get_active_held_item())
		human_user.put_in_hands(SC)

/obj/item/spacecash/ewallet
	name = "charge card"
	icon_state = "efundcard"
	desc = "A card that holds an amount of money."
	drop_sound = 'sound/items/drop/card.ogg'
	pickup_sound = 'sound/items/pickup/card.ogg'
	var/owner_name = "" //So the ATM can set it so the EFTPOS can put a valid name on transactions.
	attack_self() return  //Don't act
	attackby()    return  //like actual
	update_icon() return  //space cash

/obj/item/spacecash/ewallet/examine(mob/user)
	. = ..()
	if (!(user in view(2)) && user!=src.loc)
		return
	. += "<font color=#4F49AF>Charge card's owner: [src.owner_name]. Thalers remaining: [src.worth].</font>"

/obj/item/spacecash/ewallet/is_static_currency(prevent_types)
	return (prevent_types & PAYMENT_TYPE_CHARGE_CARD)? NOT_STATIC_CURRENCY : DISCRETE_STATIC_CURRENCY

/obj/item/spacecash/ewallet/do_static_currency_feedback(amount, mob/user, atom/target, range)
	visible_message(SPAN_NOTICE("[user] swipes [src] through [target]."), SPAN_NOTICE("You swipe [src] through [target]."), SPAN_NOTICE("You hear a card swipe."), range)

/obj/item/spacecash/ewallet/amount_static_currency()
	return worth

/obj/item/spacecash/ewallet/consume_static_currency(amount, force, mob/user, atom/target, range)
	if(force)
		amount = min(amount, worth)
	if(amount > worth)
		return PAYMENT_INSUFFICIENT
	worth -= amount
	do_static_currency_feedback(amount, user, target, range)
	return amount
