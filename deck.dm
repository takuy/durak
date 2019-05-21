Deck
	var
		list/talon = new
		Cards
			trump
			deck
		setting = 36

	proc
		Create()
			world << system("<b>Initializing deck...</b>")
			talon = new
			for(var/x in icon_states('Deck.dmi'))
				if(x)
					var/value = text2num(copytext(x,3))
					if(setting==36)
						if((value>=2)&&(value<=5))
							continue
					new /Cards(talon,x)
			var/Cards/D = new (locate(1,1,1),"Talon")
			deck = D

		Reset()
			for(var/mob/x in players)
				x.hand = new
				x.client.screen += Join
				x.client.screen += Start
			talon = new
			Start()

		Shuffle()
			world << system("<b>Shuffling cards...</b>")
			for(var/i=1 to talon.len)
				talon.Swap(i, rand(1,talon.len))

		Deal()
			world << system("<b>Dealing hands, 6 cards to [players.len] people...</b>")
			for(var/i=1 to 6)
				for(var/mob/x in players)
					x.client.screen -= Join
					x.client.screen -= Start
					var/Cards/card = talon[talon.len]
					x.hand += card
					talon -= card
					card.Place(x,first=1)
					sleep(2)
			trump = talon[talon.len]
			talon -= trump
			talon.Insert(1,trump)
			world << system("<b>[trump]</b> has been flipped after dealing all the cards. <b>[trump.suit]</b> is the trump suit!")
			deck.overlays += image( turn(Deck.trump.icon,90), icon_state=trump.icon_state, layer=OBJ_LAYER-1, pixel_x = 8, pixel_y = -16)
Game
	var
		mob/attacker
		mob/defender
		list/table = new
		passing = 0

	proc
		New_round(k)
			var
				list/defohand = new
			if(k)
				defohand = defender.hand.Copy()
				attacker = players.Find(defender)==players.len? players[1] : players[players.Find(defender)+1]
				defender.hand = defender.hand+Game.table
			else
				world << system("[defender] has beaten everything on the table.")
				attacker = players[players.Find(defender)]
			world << system("The new attacker is <b>[attacker]</b>.")
			for(var/mob/x in players)
				var/list/ohand = new
				ohand = (x == defender&&k) ? defohand : x.hand.Copy()
				x.done = 0
				if(Deck.talon.len && (x in players))
					while((x.hand.len<6) && Deck.talon.len)
						if(Deck.talon.len)
							var/Cards/draw = Deck.talon[Deck.talon.len]
							Deck.talon -= draw
							x.hand += draw
				x.Redraw_Hand(ohand)
			for(var/Cards/x in Game.table)
				x.Reset()
				Game.table -= x
			defender = null

proc
	Find_lowest()
		var
			Cards/lowest
			holder
		for(var/mob/x in players)
			for(var/Cards/y in x.hand)
				if(y.suit == Deck.trump.suit)
					lowest = lowest? lowest : y
					holder =  holder? holder : x
					if(order.Find(y.val)<order.Find(lowest.val))
						lowest = y
						holder = x
		if(!lowest)
			world << system("No trumps were dealt this round.")
			Deck.Reset()
			return
		return list(lowest,holder)
	Start()
		GameOn = 1
		Deck.Create() //Create the deck
		sleep(5)
		Deck.Shuffle() //shuffle
		sleep(5)
		Deck.Deal() //deal
		var/list/k = Find_lowest()
		if(k[2])
			Game.attacker = k[2]
			world << system("[Game.attacker] has the lowest dealt trump card; <b>[k[1]]</b>. They are the first attacker.")
