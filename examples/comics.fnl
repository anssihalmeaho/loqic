
ns main

import stdfu
import loqic

# run this by giving query as argument:
#   funla -args="'query6'" comics.fnl
main = proc(query-name)
	facts = list(
		list('belongs' 'Wolverine' 'X-Men')
		list('belongs' 'Storm' 'X-Men')
		list('belongs' 'Cyclops' 'X-Men')
		list('belongs' 'Phoenix' 'X-Men')

		list('belongs' 'Thor' 'Avengers')
		list('belongs' 'Iron Man' 'Avengers')
		list('belongs' 'Wasp' 'Avengers')

		list('male' 'Wolverine')
		list('male' 'Cyclops')
		list('male' 'Thor')
		list('male' 'Iron Man')
		list('male' 'SpiderMan')
		list('male' 'Superman')
		list('male' 'Batman')

		list('female' 'Phoenix')
		list('female' 'Storm')
		list('female' 'Wasp')
		list('female' 'She-Hulk')
		list('female' 'Wonder Woman')

		list('publisher' 'Marvel' list('X-Men' 'Avengers' 'SpiderMan'))
		list('publisher' 'DC Comics' list('Superman' 'Batman' 'Wonder Woman'))
	)

	# Find all members of X-Men who are not male
	query1 = list('and'
		list('belongs' '?name' 'X-Men')
		list('not' list('male' '?name'))
	)

	# find all female superheroes who belong to either X-Men or Avengers
	query2 = list('and'
		list('or'
			list('belongs' '?name' 'X-Men')
			list('belongs' '?name' 'Avengers')
		)
		list('female' '?name')
	)

	# find all female superheroes who do not belong to either X-Men or Avengers
	query3 = list('and'
		list('female' '?name')
		list('not' list('belongs' '?name' 'X-Men'))
		list('not' list('belongs' '?name' 'Avengers'))
	)

	# find all superheroes (male or female) who do not belong to either X-Men or Avengers
	query4 = list('and'
		list('or'
			list('male' '?name')
			list('female' '?name')
		)
		list('not' list('belongs' '?name' 'X-Men'))
		list('not' list('belongs' '?name' 'Avengers'))
	)

	# find the group to which Thor belongs to
	query5 = list('belongs' 'Thor' '?group')

	# find all heroes who belong to some group so that
	# given group belongs to titles published by Marvel.
	# And from those results choose the one in which group is X-Men.
	query6 = list('and'
		list('belongs' '?name' '?group')
		list('publisher' 'Marvel' '?titles')
		list('funl' 'in' '?titles' '?group')
		list('funl' 'eq' '?group' 'X-Men')
	)

	# find heroes (male or female) whose titles publisher is DC Comics
	query7 = list('and'
		list('or'
			list('male' '?name')
			list('female' '?name')
		)
		list('publisher' 'DC Comics' '?titles')
		list('funl' 'in' '?titles' '?name')
	)

	query = symval(query-name)
	results = call(loqic.match query facts)
	call(stdfu.loop func(item output) plus(output sprintf('%v\n' item)) end results '\n')
end

endns
