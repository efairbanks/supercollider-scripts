
(

~eugen = {
	
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
		
	a.addAll(b).flat;
	
};

~eucvt = {

	|array|

	var return;
	
	array.size.do({
		
		|inc|
		
		if(	(array[inc] == 0).and(return.size>0),
			{return[return.size-1] = return[return.size-1] + 1;},
			{return = return ++ [0];}
		);
				
	});
	
	[0] ++ (return+1);
	
};

~euexp = {
	
	|lengths|

	var a = Array.new();
	
	lengths.size.do({
		
		|inc|
	
		a = a ++ (0!lengths[inc]);
		
		if(	inc<(lengths.size-1),
			{a = a ++ [1];},
			{});
		
	});

	a;

};

)

(

~seq = [];

4.do({
	
	|inc|
	
	~seq = ~seq ++ ~eugen.value(3.rand+1,4);
	
});

~seq = ~eucvt.value(~seq);

~inc = 0;

~beats = 0;

t = TempoClock(140/(60)*4).schedAbs(0,{
	
	var return;
	
	while({~seq[~inc]==0;},{~inc=(~inc+1)%~seq.size;});
	
	return = ~seq[~inc];
	
	Synth(\pop, [\freq,5000,\len,(return**2)*40,\amp,(10-return)/80,\out,0]);
	Synth(\pop, [\freq,6000,\len,(return**2)*40,\amp,(10-return)/80,\out,1]);
	
	~inc = ~inc+1;
	
	if(	~inc<~seq.size,
		{},
		{~inc=0;});
		
	(return).postln;
		
	return;
	
});

TempoClock(140/(60)).schedAbs(	0,
									{
									
										Synth(\kick);
										
										1
										
									});
									
TempoClock(140/(60)).schedAbs(	1,
									{
									
										Synth(\snare);
										
										2
										
									});

)

