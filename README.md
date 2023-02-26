# loqic
Logic based data query library for FunL.

**loqic** provides library for matching given **query** against given **facts**.
It's meant to be used for programs written in [FunL programming language](https://github.com/anssihalmeaho/funl).

Model is based on Logic Programming model in [Structure and Interpretation of Computer Programs](https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html) -book (SICP).

This model can be useful when there's need to define relations between items and having different kind of queries applied to those relations.
It enables declarative way to express relations and queries.

In **FunL** this library works on purely functional basis so there's no side-effects possible there.

## Facts
Fact is data which is representing some knowledge.
Fact can be also thought as defining some relation between several data items.

Technically facts is list of facts, one fact is also list which contains values.

## Queries
Queries can be either **simple queries** or **compound queries**.
Simple query is used for matching facts based on values and variables.

Simple query is list which can contain:

* values
* variables (like '?x')

Variables are represented as strings which start with '?'.

**Note.** values must be comparable in FunL.

Compound queries are combining other queries (simple or compound).
There are following compound queries:

Query name | Meaning
---------- | -------
'and' | is satisfied if all given sub-queries are satisifed
'or' | is satisfied if at least one of given sub-queries is satisfied
'not' | is satisfied if given sub-query is not satisfied
'funl' | applying FunL operators for given arguments

Format of 'and' query:

```
list('and' <sub-query-1> <sub-query-2> ...)
```

Format of 'or' query:

```
list('or' <sub-query-1> <sub-query-2> ...)
```

Format of 'not' query:

```
list('not' <sub-query>)
```

Special compound query is **'funl'** -query.
It works so that 2nd item in list is FunL-operator which is to be applied.
All rest of items in list (from 3rd one) are given as arguments to operator-call.
Arguments for operator call can be:

* values
* variables

Operator call result is assumed to be **bool**.
If result is **true** then query is satisifed, if **false** then it's not satisfied.

Format of 'funl' query:

```
list('funl' <operator-name:string> <value/variable> <value/variable> ...)
```

## API
There's one function (**match**) in loqic which is provided for matching given query
for given facts.
First argument is query (list) and second argumenst is list of facts.
Return value is list of maps where each map contains variable bindings by which
query was satisfied.

Format:

```
call(loqic.match <query> <facts>) -> list of binding-maps
```

Return value is list of all bindings (_maps_) which satisfy query.
Binding map contains variable names (_strings_) as keys and related values
are values to which those variables are bound.

## Example
Link to [Example code](https://github.com/anssihalmeaho/loqic/blob/main/examples/comics.fnl).

Run example by giving related query as argument (query1 - query7):

```
funla -args="'query1'" examples/comics.fnl
```

Example (_comics.fnl_) has following superhero comics related facts:

```
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
```

**query1:** Find all members of X-Men who are not male

```
list('and'
    list('belongs' '?name' 'X-Men')
    list('not' list('male' '?name'))
)
```

```
map('name' : 'Storm')
map('name' : 'Phoenix')
```

**query2:** Find all female superheroes who belong to either X-Men or Avengers

```
list('and'
    list('or'
        list('belongs' '?name' 'X-Men')
        list('belongs' '?name' 'Avengers')
    )
    list('female' '?name')
)
```

```
map('name' : 'Storm')
map('name' : 'Phoenix')
map('name' : 'Wasp')

```

**query3:** Find all female superheroes who do not belong to either X-Men or Avengers

```
list('and'
    list('female' '?name')
    list('not' list('belongs' '?name' 'X-Men'))
    list('not' list('belongs' '?name' 'Avengers'))
)
```

```
map('name' : 'She-Hulk')
map('name' : 'Wonder Woman')
```

**query4:** Find all superheroes (male or female) who do not belong to either X-Men or Avengers

```
list('and'
    list('or'
        list('male' '?name')
        list('female' '?name')
    )
    list('not' list('belongs' '?name' 'X-Men'))
    list('not' list('belongs' '?name' 'Avengers'))
)
```

```
map('name' : 'SpiderMan')
map('name' : 'Superman')
map('name' : 'Batman')
map('name' : 'She-Hulk')
map('name' : 'Wonder Woman')
```


**query5:** Find the group to which Thor belongs to

```
list('belongs' 'Thor' '?group')
```

```
map('group' : 'Avengers')
```

**query6:** Find all heroes who belong to some group so that given group belongs to titles published by Marvel.
And from those results choose the one in which group is X-Men.

```
list('and'
    list('belongs' '?name' '?group')
    list('publisher' 'Marvel' '?titles')
    list('funl' 'in' '?titles' '?group')
    list('funl' 'eq' '?group' 'X-Men')
)
```

```
map('group' : 'X-Men', 'titles' : list('X-Men', 'Avengers', 'SpiderMan'), 'name' : 'Wolverine')
map('group' : 'X-Men', 'titles' : list('X-Men', 'Avengers', 'SpiderMan'), 'name' : 'Storm')
map('group' : 'X-Men', 'titles' : list('X-Men', 'Avengers', 'SpiderMan'), 'name' : 'Cyclops')
map('group' : 'X-Men', 'titles' : list('X-Men', 'Avengers', 'SpiderMan'), 'name' : 'Phoenix')
```

**query7:** Find heroes (male or female) whose titles publisher is DC Comics

```
list('and'
    list('or'
        list('male' '?name')
        list('female' '?name')
    )
    list('publisher' 'DC Comics' '?titles')
    list('funl' 'in' '?titles' '?name')
)
```

```
map('name' : 'Superman', 'titles' : list('Superman', 'Batman', 'Wonder Woman'))
map('name' : 'Batman', 'titles' : list('Superman', 'Batman', 'Wonder Woman'))
map('name' : 'Wonder Woman', 'titles' : list('Superman', 'Batman', 'Wonder Woman'))
```


## Limitations
As stated in SICP also, this query logic contains some possible confusions if
it's thought to be same as classical deductive logic.

For example, 'not' -query in beginning of compound 'and' -query can give
empty results (related to so-called closed world assumption).
So 'not' -queries are better to be placed in the end of compound queries.

## Future development issues
There following future development possibilities:

* Adding concept of **rules**
* Supporting anonymous variables (just '?')
* Dot ('.') notation for skipping multiple items in matching (simple query)
* Representing results so that variables would be replaced by bindings in query
* REPL for giving queries and facts
