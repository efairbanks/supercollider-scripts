
(

~melseq = [0,3,4,2,-1,1,2,4];

~ticks = 32;

~interp = {

	|from, to, depth, chaos|
	
	var n = from.size;
	
	from = from.add(to);
	
	n.do({
	
		|i|
		
		var randval, mean, order;
		
		randval = rrand(from[i],from[i+1]);
		
		mean = (from[i]+from[i+1])/2;
		
		order = 1-chaos;
		
		from = from.add((randval*chaos)+(mean*order));
		
	});
	
	from.removeAt(n);
	
	from = from.perfectShuffle;
	
	from = from.round(1);
	
	if(depth==0,{
		
		from;
		
	},{
		
		thisFunction.(from, to, depth-1, chaos);
		
	});
	
}

)

(

~qqq = ~interp.([0,4,2,5,0,5,1,-1],0,3,6/7);

~qqq = ~qqq ++ (~interp.([0,4,2,5,0,5,1,-1],0,3,2/7)+7);

~qqq = (~qqq.perfectShuffle()).clump(2);

Pbind(	\degree, Pseq(~qqq, 2),
			\dur, 0.1,
			\amp, Prand([Pseq([1,0,1,0,1,1])], inf),
			\scale, Scale.minor).play;

)

((~interp.([0,4,2,5,0,5,1,-1],0,3,6/7) ++ ~interp.([0,4,2,5,0,5,1,-1],0,3,6/7))*[1,0,0,1,0,0,1,0]).plot;

rrand(3,5)

[3].flat

10.do({|i| i;});

/*

[from]

[from, r1]

[[from, r1-1], [r1, r1-2]]

[[[from, r1-1-1],[r1-1, r1-1-2]],[[],[]]]


generate buddy for 0

generate buddy for 0 and n/2

generate buddy for 0 and 


*/
