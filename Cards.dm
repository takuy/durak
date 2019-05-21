
var
	Deck/Deck = new
	Game/Game = new


Cards
	parent_type = /obj
	icon = 'Deck.dmi'
	layer = 100
	mouse_over_pointer = MOUSE_HAND_POINTER

	var
		val = ""
		suit
		beat = 0

	New(locz, is)
		..()
		icon_state = is
		if(is=="Talon")
			tag = is
			name = tag
			return
		Deck.talon += src
		name = names()
		src.mouse_drag_pointer = src
		tag = name

	Click(nloc, con, params)
		params = params2list(params)
		if(name == "Talon")
			if(params["alt"])
				usr << system(kText.list2text(Deck.talon,", "))
			if(params["right"])
				usr << system("There are [Deck.talon.len] cards left in the deck. The trump is <b>[Deck.trump]</b>.")
			return

	MouseDrop(ovr_obj, src_loc)
		if(name == "Talon")
			return
		if(usr in players)
			if(!(src in Game.table) && !src.beat && src!=ovr_obj &&!(ovr_obj in usr.hand))
				if(Game.attacker == usr)
					if(istype(ovr_obj,/table) && (src in usr.client.screen))
						Attack(ovr_obj)
				else if(Game.defender == usr)
					if(istype(ovr_obj, /Cards))
						Defend(ovr_obj)
					else if(istype(ovr_obj,/table) && Game.passing)
						Defend(ovr_obj,1)
				else if((Game.table.len) && (Game.defender.hand.len>1) && istype(ovr_obj,/table))
					Match(ovr_obj)
			if(usr.hand.len==0)
				world << system("<b>[usr]</b> is the winner of this match.")
				world << system("You may continue playing, or the host may reboot.")
				players -= usr

	proc
		Attack(ovr_obj)
			Game.defender = players.Find(usr)==players.len? players[1] : players[players.Find(usr)+1]
			world << system("[usr] plays their attack; <b>[src]</b>; to [Game.defender].")
			Game.defender.client.screen += Cant
			Game.attacker = null
			usr.hand -= src
			onTable(ovr_obj)
			for(var/mob/x in players)
				x.client.screen += Done

		Defend(ovr_obj,pass)
			var/Cards/att = ovr_obj
			if(!pass)
				if(att.beat)
					return
				if((att.suit == src.suit&&(order.Find(att.val) < order.Find(src.val)))||\
				((src.suit==Deck.trump.suit&&att.suit!=Deck.trump.suit)) ||\
				(att.suit==Deck.trump.suit&&src.suit==Deck.trump.suit)&&(order.Find(att.val) <= order.Find(src.val)))
					world << system("[usr] beats <b>[att]</b> with <b>[src]</b>.")
					src.beat = 1
					att.beat = 1
					usr.hand -= src
					onTable(att,1)
			else
				Pass(ovr_obj)

		Pass(ovr_obj)
			var/compare = 0
			for(var/Cards/x in Game.table)
				if(x.val == src.val)
					compare = 1
					break
			if(compare)
				Game.defender.client.screen -= Cant
				Game.defender = players.Find(usr) == players.len? players[1] : players[players.Find(usr)+1]
				Game.defender.client.screen += Cant
				world << system("[usr] has passed the attack, by matching the value; <b>[src]</b>, to the person to the left; [Game.defender]. The attack is pushed onto them.")
				if(src.suit == Deck.trump.suit && Game.passing == 2)
					world << system("Because 'Flashing' is on, [usr] passed it without placing the card on the table, because it is of the trump.suit.")
				onTable(ovr_obj)

		Match(ovr_obj)
			var/k = kText.list2text(Game.table)
			if(findtextEx(k,src.val))
				onTable(ovr_obj)
				usr.hand -= src
				world << system("[usr] matches a card on the table; <b>[src]</b>. [Game.defender] must beat it.")
		names()
			switch(copytext(icon_state,1,2))
				if("D") suit = "Diamonds"
				if("H") suit = "Hearts"
				if("S") suit = "Spades"
				if("C") suit = "Clubs"
			switch(copytext(icon_state,3))
				if("1") val = "Ace"
				if("2") val = "Two"
				if("3") val = "Three"
				if("4") val = "Four"
				if("5") val = "Five"
				if("6") val = "Six"
				if("7") val = "Seven"
				if("8") val = "Eight"
				if("9") val = "Nine"
				if("10") val = "Ten"
				if("11") val = "Jack"
				if("12") val = "Queen"
				if("13") val = "King"
			return "[val] of [suit]"
		Reset()
			loc = null
			beat = 0
			icon = initial(icon)
			pixel_y = 0
			pixel_x = 0

		onTable(atom/t,b)
			Game.table += src
			usr.client.screen -= src
			if(b)
				src.icon = turn(icon,90)
				src.pixel_y -= 16
				src.layer = t.layer+1
			src.Move(isturf(t)? t : t.loc)

		Place(mob/x,first,ohan)
			if(first)
				missile(/Cards, Deck.deck, x)
			//	world << system("[src] is first"
			else if(src==ohan)
			//	world << system("[src] is in ohand"
			else if(src!=ohan)
				missile(/Cards, ((src in Game.table)? src : Deck.deck), x)
			//	world << system("[src] not ohan, [(src in Game.table)? src : Deck.deck]"
			if(x.client)
				var/m = ((-round(-(x.hand.Find(src)/9)))-1)*9
				screen_loc = "[(4+x.hand.Find(src)-(m))],[(m/9)+1]:-48" //
				layer = initial(layer) - (m / 9)
				x.client.screen += src