~lex = {
	
	|string|

	var getType = {

		|element|
		
		var type = \symbol;
		
		var haschars = "[a-zA-Z]+".matchRegexp(element++" ");
			
		var hasdigits = "[0-9]+".matchRegexp(element++" ");
		
		var isfloat = "[\.]+".matchRegexp(element++" ");
		
		if( hasdigits && isfloat.not, {type = \integer;});
		
		if( hasdigits && isfloat, {type = \float;});
		
		if( element == "\(", {type = \leftparen;});
		
		if( element == "\)", {type = \rightparen;});
		
		type;
	
	};

	var tokens = [];

	string.replace("\("," \( ").replace("\)"," \) ").split($ ).do({
	
		|element, index|
		
		if( (element != "") && (element != " ") && (element != nil) && (element != []), {
		
			tokens = tokens.add(element);
			
		});
		
	});

	tokens.collect({
	
		|element|
		
		var return = nil;
				
		getType.(element).switch(
		
			\leftparen,	{"\("},
			\rightparen,	{"\)"},
			\symbol,		{element.asSymbol},
			\integer,		{element.asInteger},
			\float,		{element.asFloat}
					
		);
		
	});

};

~parse = {
	
	|symbols|
	
	var processingexpression = false;
	
	var symboltree = [];
	
	var expression = [];
	
	var pcount = 0;
	
	symbols.do({
	
		|element, index|
		
		if( (element == "\(") && (processingexpression == false), {processingexpression = true; expression = [];});
		
		if( element == "\(", {pcount = pcount + 1;});
		
		if( element == "\)", {pcount = pcount - 1;});
		
		if(	processingexpression == true,
			{
				
				expression = expression.add(element);
				
				if( (element == "\)") && (pcount == 0),{
				
					processingexpression = false;
					
					symboltree = symboltree.add(~parse.(expression.copyRange(1,expression.size-2)));
					
				});
				
			},
			{
			
				symboltree = symboltree.add(element);
				
			});
		
	});
	
	symboltree;
	
};

~parse.(~lex.("test 1 2"));
