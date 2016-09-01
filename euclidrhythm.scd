
(

~euclidianrhythm = {
	
	|pulses, steps|
	
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
		
		/*
		a.postln;
		b.postln;
		b.size.postln;
		"---".postln;
		*/
		
		b.size.do({
		
			|inc|
			
			tempa = Array.new(steps).addAll(a);
			
			a[inc%a.size] = tempa[inc%a.size].add(b[inc]);
			
			split = (split+1)%a.size;
			
		});
		
		b = a.copyRange(split,a.size-1);
		
		tempa = a.copyRange(0,split-1);
		
		a = Array.new(steps).addAll(tempa);
		/*
		split.postln;
		"---".postln;
		a.postln;
		b.postln;
		b.size.postln;
		"--------".postln;
		"".postln;
		"---".postln;
		*/			
	});
		
	a.addAll(b).flat;	
};

~euclidianrhythm.value(5,13);

)