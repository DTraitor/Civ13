/obj/structure/loom
	name = "loom"
	desc = "A loom, used to transform cotton into cloth."
	icon = 'icons/obj/structures.dmi'
	icon_state = "loom"
	flammable = TRUE
	not_movable = FALSE
	not_disassemblable = TRUE
/obj/structure/loom/attackby(var/obj/item/stack/W as obj, var/mob/living/carbon/human/H as mob)
	if (istype(W, /obj/item/stack/material/cotton))
		H.visible_message("You start to produce the cloth.")
		icon_state = "loom1"
		if (do_after(H, min(W.amount*20, 200), H.loc))
			H.visible_message("You finish producing the cloth.")
			icon_state = "loom"
			var/obj/item/stack/material/cloth/clothes = new/obj/item/stack/material/cloth(H.loc)
			clothes.amount = W.amount
			qdel(W)
		else
			icon_state = "loom"
/obj/structure/mill
	name = "mill"
	desc = "A small mill, used to grind cereals into flour."
	icon = 'icons/obj/structures.dmi'
	icon_state = "flour_mill"
	flammable = TRUE
	not_movable = FALSE
	not_disassemblable = FALSE
/obj/structure/mill/attackby(var/obj/item/stack/W as obj, var/mob/living/carbon/human/H as mob)
	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat))
		H.visible_message("You start to mill the [W.name].")
		icon_state = "flour_mill1"
		if (do_after(H, 20, H.loc))
			H.visible_message("You finish milling the [W.name].")
			var/obj/item/weapon/reagent_containers/food/condiment/flour/flour = new/obj/item/weapon/reagent_containers/food/condiment/flour(H.loc)
			flour.reagents.remove_reagent("flour", 20)
			icon_state = "flour_mill"
			qdel(W)
		else
			icon_state = "flour_mill"

/obj/structure/dehydrator
	name = "dehydrator"
	desc = "A wood structure used to dry meat, fish, tobacco, and so on."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "wood_drier0"
	var/filled = 0
	var/stage = 0
	var/obj_type = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	flammable = TRUE
	not_movable = FALSE
	not_disassemblable = FALSE

/obj/structure/dehydrator/attackby(var/obj/item/stack/W as obj, var/mob/living/carbon/human/H as mob)
	if (filled >= 4)
		H << "<span class='notice'>\The [src] is full!</span>"
		return
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/rawcutlet) && filled < 4)
		var/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/RC = W
		if (RC.rotten == TRUE)
			H << "This is rotten."
			return
		else
			H << "You hang the [W.name] to dry."
			filled += 1
			obj_type = W.type
			icon_state = "wood_drier[filled]"
			qdel(W)
			obj_type = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet
			dry_obj(obj_type)
			return
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/fishfillet) && filled < 4)
		var/obj/item/weapon/reagent_containers/food/snacks/fishfillet/FF = W
		if (FF.rotten == TRUE)
			H << "This is rotten."
			return
		else
			H << "You hang the [W.name] to dry."
			filled += 1
			obj_type = W.type
			icon_state = "wood_drier[filled]"
			qdel(W)
			obj_type = /obj/item/weapon/reagent_containers/food/snacks/fishfillet
			dry_obj(obj_type)
			return
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/salmonfillet) && filled < 4)
		var/obj/item/weapon/reagent_containers/food/snacks/salmonfillet/SF = W
		if (SF.rotten == TRUE)
			H << "This is rotten."
			return
		else
			H << "You hang the [W.name] to dry."
			filled += 1
			obj_type = W.type
			icon_state = "wood_drier[filled]"
			qdel(W)
			obj_type = /obj/item/weapon/reagent_containers/food/snacks/driedsalmon
			dry_obj(obj_type)
			return
/obj/structure/dehydrator/proc/dry_obj(var/obj_type = null)
	spawn(1200) //2 minutes
		if (obj_type == /obj/item/weapon/reagent_containers/food/snacks/rawcutlet)
			new/obj/item/weapon/reagent_containers/food/snacks/driedmeat(src.loc)
			visible_message("The meat finishes drying.")
			filled -= 1
			icon_state = "wood_drier[filled]"
			return
		else if (obj_type == /obj/item/weapon/reagent_containers/food/snacks/fishfillet)
			new/obj/item/weapon/reagent_containers/food/snacks/driedfish(src.loc)
			visible_message("The fish finishes drying.")
			filled -= 1
			icon_state = "wood_drier[filled]"
			return

/obj/item/weapon/starterjar
	name = "fermentation starter jar"
	icon = 'icons/obj/drinks.dmi'
	desc = "A glass jar, used to multiply yeast."
	icon_state = "jar0"
	item_state = "beaker"
	var/fermenting = 0
	var/fermenting_timer = 0
	var/fermenting_contents = 0
/obj/item/weapon/starterjar/New()
	..()

/obj/item/weapon/starterjar/attackby(obj/O as obj, mob/living/carbon/human/user as mob)
	if (fermenting != 0)
		user << "This jar already has a starter culture inside!"
		return
	if (istype(O, /obj/item/weapon/reagent_containers/food/condiment/flour))
		user << "You add flour to the jar."
		fermenting = 1
		icon_state = "jar1"
		fermenting_timer = world.time + 1800
		qdel(O)
		fermenting_process()
		return

	if (istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat))
		user << "You add wheat to the jar."
		fermenting = 1
		icon_state = "jar1"
		fermenting_timer = world.time + 2400
		qdel(O)
		fermenting_process()
		return

	else if (istype(O, /obj/item/weapon/reagent_containers/food/condiment/enzyme))
		user << "You add some yeast to the jar."
		fermenting = 2
		fermenting_contents++
		icon_state = "jar2"
		qdel(O)
		yeast_growth()
		return
	else
		..()

/obj/item/weapon/starterjar/proc/fermenting_process()
	if (world.time >= fermenting_timer)
		visible_message("The flour in the jar ferments.")
		fermenting = 2
		fermenting_contents = 1
		icon_state = "jar2"
		yeast_growth()
	else
		spawn(100)
			fermenting_process()

/obj/item/weapon/starterjar/proc/yeast_growth()
	if (fermenting_contents > 0)
		spawn(1800)
			if (fermenting_contents > 0 && fermenting_contents < 5)
				fermenting_contents++
			yeast_growth()

/obj/item/weapon/starterjar/attack_self(var/mob/living/carbon/human/user as mob)
	if (fermenting == 2 && fermenting_contents > 0)
		user << "You take some yeast out of the jar."
		new/obj/item/weapon/reagent_containers/food/condiment/enzyme(user.loc)
		fermenting_contents--
		if (fermenting_contents == 0)
			fermenting = 0
			icon_state = "jar0"
	else
		..()


////////////////////////SEED/COLLECTOR/////////////////////////////////////
/obj/item/weapon/storage/seed_collector
	name = "seed collector"
	icon = 'icons/obj/storage.dmi'
	desc = "To store your seeds."
	icon_state = "seed_collector"
	item_state = "backpack"
	var/active = FALSE
	w_class = 4
	slot_flags = SLOT_BACK
	max_w_class = 2
	max_storage_space = 45 // can hold 2 w_class 4 items. 28 let it hold 3
	can_hold = list(
		/obj/item/stack/farming/seeds,
		)
	flammable = TRUE

/obj/item/weapon/storage/seed_collector/attack_self(var/mob/living/carbon/human/user as mob)
	active = TRUE
	var/total_storage_space = 0
	for (var/obj/item/I in contents)
		total_storage_space += I.get_storage_cost() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if (total_storage_space+1 > max_storage_space)
		user << "<span class='notice'>[src] is too full, make some space.</span>"
		active = FALSE
		return
	if (!(src.loc == user))
		active = FALSE
		return
	else
		for (var/obj/item/stack/farming/seeds/SD in user.loc)
			var/doneexisting = FALSE
			for (var/obj/item/stack/farming/seeds/SDC in contents)
				if (SDC.type == SD.type)
					SDC.amount += SD.amount
					qdel(SD)
					doneexisting = TRUE
					user << "You collect the seeds."
					return
			if (!doneexisting)
				SD.forceMove(src)
				user << "You collect the seeds."
				return

////////////////////////ORE/COLLECTOR//////////////////////////////////////

/obj/item/weapon/storage/ore_collector
	name = "ore collector"
	icon = 'icons/obj/storage.dmi'
	desc = "A leather bag, used to collect ores."
	icon_state = "ore_collector"
	item_state = "backpack"
	var/active = FALSE
	w_class = 4
	slot_flags = SLOT_BACK
	max_w_class = 3
	max_storage_space = 28 // can hold 2 w_class 4 items. 28 let it hold 3
	can_hold = list(
		/obj/item/stack/ore,
		/obj/item/stack/material/stone,
		)
	flammable = TRUE

/obj/item/weapon/storage/ore_collector/attack_self(var/mob/living/carbon/human/user as mob)
	active = TRUE
	var/total_storage_space = 0
	for (var/obj/item/I in contents)
		total_storage_space += I.get_storage_cost() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if (total_storage_space+3 > max_storage_space)
		user << "<span class='notice'>[src] is too full, make some space.</span>"
		active = FALSE
		return
	if (!(src.loc == user))
		active = FALSE
		return
	else
		for (var/obj/item/stack/ore/OR in user.loc)
			var/doneexisting = FALSE
			for (var/obj/item/stack/ore/ORC in contents)
				if (ORC.type == OR.type)
					ORC.amount += OR.amount
					qdel(OR)
					doneexisting = TRUE
					user << "You collect the ore."
			if (!doneexisting)
				OR.forceMove(src)
				user << "You collect the ore."

		for (var/obj/item/stack/material/stone/SR in user.loc)
			var/doneexisting = FALSE
			for (var/obj/item/stack/material/stone/SRC in contents)
				if (SRC.type == SR.type)
					SRC.amount += SR.amount
					qdel(SR)
					doneexisting = TRUE
					user << "You collect the stone."
			if (!doneexisting)
				SR.forceMove(src)
				user << "You collect the stone."



////////////////////OIL/WELL///////////////////////////
/obj/structure/oilwell
	name = "wooden oil well"
	desc = "An oil well, extracting petroleum to a barrel."
	icon = 'icons/obj/obj32x64.dmi'
	icon_state = "oilwell"
	flammable = TRUE
	anchored = TRUE
	var/obj/structure/oil_spring/base = null
	var/list/barrel = list()
	not_movable = TRUE
	not_disassemblable = TRUE

/obj/structure/oilwell/New()
	..()
	for (var/obj/structure/oil_spring/OS in src.loc)
		base = OS
	if (base != null)
		start_extraction()
		return
	else
		return

/obj/structure/oilwell/proc/start_extraction()
	if (base)
		if (barrel)
			spawn(1200)
				extract()
				return
		else
			return

	else
		return

/obj/structure/oilwell/proc/extract()
	if (!isemptylist(barrel))
		if (barrel[1].reagents.total_volume < barrel[1].reagents.maximum_volume)
			barrel[1].reagents.add_reagent("petroleum", min(barrel[1].reagents.maximum_volume - barrel[1].reagents.total_volume, 10))
			base.counter = 0
			spawn(1200)
				extract()
			return
		else
			return
	else
		return

/obj/structure/oilwell/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers/glass/barrel))
		if (isemptylist(barrel))
			barrel += W
			user.drop_from_inventory(W)
			W.forceMove(locate(0,0,0))
			visible_message("[user] puts \the [W] in \the [src].","You put \the [W] in \the [src].")
			start_extraction()
			return
	else
		..()

/obj/structure/oilwell/attack_hand(var/mob/living/carbon/human/H)
	if (!isemptylist(barrel))
		H << "You start taking \the [barrel[1]] from \the [src]..."
		if (do_after(H,35,src))
			visible_message("You remove \the [barrel[1]].","[H] removes \the [barrel[1]] from \the [src].")
		for(var/obj/item/weapon/reagent_containers/glass/barrel/B in barrel)
			B.loc = get_turf(src)
			barrel -= B
			return
	else
		H << "There is no container to remove from \the [src]."
		return


////////////////////PRINTING/PRESS///////////////////////////
/obj/structure/printingpress
	name = "printing press"
	desc = "Used to copy books and papers."
	icon = 'icons/obj/structures.dmi'
	icon_state = "printingpress0"
	flammable = TRUE
	var/list/base = list()
	var/list/copy = list()
	var/copying = FALSE
	not_movable = FALSE
	not_disassemblable = TRUE

/obj/structure/printingpress/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/book) || istype(W, /obj/item/weapon/paper))
		var/tolist = list("Cancel")
		if (isemptylist(copy) && isemptylist(base))
			tolist = list("Original","Copy","Cancel")
		else if (isemptylist(copy) && !isemptylist(base))
			tolist = list("Copy","Cancel")
		else if (!isemptylist(copy) && isemptylist(base))
			tolist = list("Original","Cancel")
		else
			tolist = list("Cancel")
		var/input = WWinput(user, "Add to original or copy?", "Printing Press", "Cancel", tolist)
		if (input == "Cancel")
			return
		else if (input == "Original")
			base += W
			user.drop_from_inventory(W)
			W.forceMove(locate(0,0,0))
			return

		else if (input == "Copy")
			copy += W
			user.drop_from_inventory(W)
			W.forceMove(locate(0,0,0))
			return
	else
		..()
/obj/structure/printingpress/attack_hand(var/mob/living/carbon/human/H)
	if (copying)
		return

	if (isemptylist(base) && isemptylist(copy))
		H << "There is nothing inside the press."
		return

	if (isemptylist(copy))
		for(var/obj/item/weapon/B in base)
			H << "You remove \the [B]."
			B.loc = get_turf(src)
			base -= B
		return

	if (isemptylist(base))
		for(var/obj/item/weapon/C in copy)
			H << "You remove \the [C]."
			C.loc = get_turf(src)
			copy -= C
		return
	if (!isemptylist(base) && !isemptylist(copy))
		if (base[1].type != copy[1].type)
			H << "Both documents must be of the same type."
			for(var/obj/item/weapon/C in copy)
				C.loc = get_turf(src)
				copy -= C
			for(var/obj/item/weapon/B in base)
				B.loc = get_turf(src)
				base -= B
			return
		else
			var/spawntimer = 90
			if (istype(base[1], /obj/item/weapon/book))
				spawntimer = 250
			else if (istype(base[1], /obj/item/weapon/paper))
				spawntimer = 90
			copying = TRUE
			visible_message("Copying \the [base[1]]...")
			icon_state = "printingpress1"
			if (do_after(H, spawntimer, src))
				if (!isemptylist(base) && !isemptylist(copy))
					visible_message("The printing press finishes copying.")
					icon_state = "printingpress0"
					for(var/obj/item/weapon/B in base)
						B.loc = get_turf(src)
						base -= B
						if (istype(B, /obj/item/weapon/book))
							var/obj/item/weapon/book/NC = B
							var/obj/item/weapon/book/NB = new/obj/item/weapon/book(src.loc)
							NB.dat = NC.dat
							NB.due_date = NC.due_date
							NB.author = NC.author
							NB.unique = NC.unique
							NB.title = NC.title

						else if (istype(B, /obj/item/weapon/paper))
							var/obj/item/weapon/paper/NC = B
							var/obj/item/weapon/paper/NP = new/obj/item/weapon/paper(src.loc)
							NP.info = NC.info
							NP.info_links = NC.info_links
							NP.fields = NC.fields
							NP.free_space = NC.free_space
							NP.rigged = NC.rigged
							NP.spam_flag = NC.spam_flag
					for(var/obj/item/weapon/C in copy)
						copy -= C
						qdel(C)
					copying = FALSE
					return
			else
				copying = FALSE
				icon_state = "printingpress0"
				return
	return
