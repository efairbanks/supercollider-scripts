
ED {
	
	*create { // create a euclidian distribution
	
		arg pulses, steps;
		
		var a = Array.new(steps);
		
		var b = Array.new(steps);
		
		var tempa = Array.new(steps);
		
		var tempb = Array.new(steps);
		
		var split;
		
		steps.do({
			
			|inc|
			
			if(	inc<pulses,
				{a = tempa.add(Array.new(steps).add(1));},
				{b = tempb.add(Array.new(steps).add(0));});
				
		});
		
		// --- //
		
		while(	{(b.size>1).and(a.size>0)},{
				
			split = 0;
			
			b.size.do({
			
				|inc|
				
				tempa = Array.new(steps).addAll(a);
				
				a[inc%a.size] = tempa[inc%a.size].add(b[inc]);
				
				split = (split+1)%a.size;
				
			});
			
			b = a.copyRange(split,a.size-1);
			
			tempa = a.copyRange(0,split-1);
			
			a = Array.new(steps).addAll(tempa);
	
		});
			
		^(a.addAll(b).flat);
	
	}
	
	*convert { // convert distribution to offset+pulse-interval notation

		arg array;
	
		var return, leadingzeroes;
		
		leadingzeroes = 0;
		
		while({array[0]==0},{array = array.copyRange(1,array.size-1);leadingzeroes=leadingzeroes+1});
		
		array.size.do({
			
			|inc|
			
			if(	(array[inc] == 0).and(return.size>0),
				{return[return.size-1] = return[return.size-1] + 1;},
				{return = return ++ [0];}
			);
					
		});
		
		^([leadingzeroes] ++ (return+1));
	
	}
	
	*expand { // convert distribution in offset+pulse-interval notation back to normal pulse notation
	
		arg lengths;
	
		var a = Array.new();
		
		if(lengths[0]>0,{a = a++0;});
		
		lengths.size.do({
			
			|inc|
		
			a = a ++ (0!(lengths[inc]-1));
			
			if(	inc<(lengths.size-1),
				{a = a ++ [1];},
				{});
			
		});
	
		^a;

	}
	
	*extrapolate { // convert distribution in offset+pulse-interval notation back to normal pulse notation but with parameterized modifications
		
		// two arrays followed by an int
		
		arg lengths, pulses, slots;
	
		var a = Array.new();
		
		(lengths.size-1).do({
			
			|inc|
			
			a = a ++ ED.create( pulses.wrapAt(inc+1), slots ).copyRange(0,lengths.wrapAt(inc+1)-1);
			
		});
	
		^((0!lengths[0])++a);

	}
	
}