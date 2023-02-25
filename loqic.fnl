
ns loqic

match = func(query_ facts_)
	gen-matcher = func(binds query facts)
		case(head(query)
			'and'  call(and-matcher binds query facts)
			'or'   call(or-matcher binds query facts)
			'not'  call(not-matcher binds query facts)
			'funl' call(funl-matcher binds query facts)

			# by default its simple query
			call(simple-matcher binds query facts)
		)
	end

	funl-matcher = func(binds query facts)
		import stdstr

		query2 = rest(query)

		# assumed to return bool value
		do-funl = func(lst)
			eval(
				sprintf(
					'%s( rest(argslist()): )'
					head(argslist())
				)
			)
		end

		get-values = func(bind args)
			loopy = func(argumentlist result)
				if(empty(argumentlist)
					result
					call(func()
						nextarg = head(argumentlist)
						val = if(and(
							eq(type(nextarg) 'string')
							call(stdstr.startswith nextarg '?')
							)
							# its variable, get value from bind map
							get(bind slice(nextarg 1))

							# else, assuming value
							nextarg
						)
						call(loopy rest(argumentlist) append(result val))
					end)
				)
			end

			call(loopy args list())
		end

		loop-binds = func(bindlist result)
			if(empty(bindlist)
				result
				call(func()
					next-bind = head(bindlist)
					valuelist = call(get-values next-bind rest(query2))
					is-match = call(do-funl head(query2) valuelist:)
					next-result = if(is-match
						append(result next-bind)
						result
					)
					call(loop-binds rest(bindlist) next-result)
				end)
			)
		end

		call(loop-binds binds list())
	end

	not-matcher = func(binds query facts)
		invert-binds = func(nbinds)
			loopy = func(bindmaps result)
				if(empty(bindmaps)
					result
					call(func()
						nextbind = head(bindmaps)
						next-result = if(in(nbinds nextbind)
							result
							append(result nextbind)
						)
						call(loopy rest(bindmaps) next-result)
					end)
				)
			end

			call(loopy binds list())
		end

		next-binds = call(gen-matcher binds head(rest(query)) facts)
		call(invert-binds next-binds)
	end

	remove-duplicates = func(sourcelist)
		loopy = func(slist result)
			if(empty(slist)
				result
				call(func()
					next-item = head(slist)
					next-result = if(in(result next-item)
						result
						append(result next-item)
					)
					call(loopy rest(slist) next-result)
				end)
			)
		end

		call(loopy sourcelist list())
	end

	or-matcher = func(binds query facts)
		loop-queries = func(subqueries result-binds)
			if(empty(subqueries)
				result-binds
				call(func()
					sub-query = head(subqueries)
					_ = if(eq(type(sub-query) 'list') 'ok' error('query not a list'))
					next-binds = call(gen-matcher binds sub-query facts)
					next-result = extend(result-binds next-binds)
					call(loop-queries rest(subqueries) next-result)
				end)
			)
		end

		call(loop-queries rest(query) list())
	end

	and-matcher = func(binds query facts)
		loop-queries = func(bind-maps subqueries)
			if(empty(subqueries)
				bind-maps
				call(func()
					sub-query = head(subqueries)
					_ = if(eq(type(sub-query) 'list') 'ok' error('query not a list'))
					next-binds = call(gen-matcher bind-maps sub-query facts)
					call(loop-queries next-binds rest(subqueries))
				end)
			)
		end

		call(loop-queries binds rest(query))
	end

	simple-matcher = func(binds query facts)
		loop-facts = func(bind factlist result)
			if(empty(factlist)
				result
				call(func()
					next-result = call(compare query bind head(factlist) result)
					call(loop-facts bind rest(factlist) next-result)
				end)
			)
		end

		loop-binds = func(bindlist result)
			if(empty(bindlist)
				result
				call(func()
					next-result = call(loop-facts head(bindlist) facts result)
					call(loop-binds rest(bindlist) next-result)
				end)
			)
		end

		out-binds = call(loop-binds binds list())
		out-binds
	end

	compare = func(query bind fact result)
		import stdstr

		# result pair = list(is-match new-bind-map)
		loop-fact = func(fact-items query-items bind-map)
			if(empty(fact-items)
				list(true bind-map)

				call(func()
					fact-item = head(fact-items)
					query-item = head(query-items)

					is-matching next-bind = cond(
						# handle variable
						call(stdstr.startswith query-item '?')
						call(func()
							varname = slice(query-item 1)
							found value = getl(bind-map varname):
							if(found
								if(eq(fact-item value)
									list(true bind-map) # 1) ok, name already in map
									list(false bind-map) # 2) not ok, conflict
								)
								list(true put(bind-map varname fact-item)) # 3) ok, add name to map
							)
						end)

						# handle value (default)
						list(eq(query-item fact-item) bind-map)
					):
					if(is-matching
						call(loop-fact rest(fact-items) rest(query-items) next-bind)
						list(false next-bind)
					)
				end)
			)
		end

		if(eq(len(fact) len(query))
			call(func()
				is-match next-bind = call(loop-fact fact query bind):
				if(is-match append(result next-bind) result)
			end)

			result
		)
	end

	bind-maps = call(gen-matcher list(map()) query_ facts_)
	call(remove-duplicates bind-maps)
end

endns

