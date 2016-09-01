
(

~binrhythm = {

	|pattern, probabilities|

	var newpattern;
	
	probabilities.do({
	
		|item|
		
		newpattern = pattern;
		
		pattern.size.do({
		
			newpattern = newpattern.add(if(1.0.rand<item, 1, 0));
			
		});
		
		pattern = newpattern;
				
		pattern = pattern.perfectShuffle;
		
	});
	
	pattern;
	
};

~seq = [[0,2,4],[-1,2,4],[-1,1,4],[-1,1,3],[-1,2,4],[-2,0,2],[-2,1,3],[-1,1,3]];

~monoseq = [0,2,3,4,0,2,3,4,-1,2,3,4,5,4,2,1];

~monoseq = (~monoseq.differentiate).integrate.clump(5).scramble.flat;

//Pbind(\degree, Pseq(~seq, 1)).play;

//~binrhythm.([1],[1,0.8,0.95,0.125]).plot;

Pbind(\degree, Pseq((~monoseq.differentiate).integrate.clump(5).scramble.flat, 16), \dur, 1/8, \amp, Pseq(~binrhythm.([1],[1,0.3,0.95,0.125]))).play;

Pbind(\degree, Pseq(~monoseq-7, 16), \dur, 1/8, \amp, Pseq(~binrhythm.([1],[1,1/3,0,0]))).play;

)
