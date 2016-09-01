

(

t.clear;

// --- //

~beatCursor = 0;

ED.convert(ED.create(3,8));

t = TempoClock(96/30).sched(0,{
	
	|beat|
	
	if(~beatCursor==0,{
		
		~baseRhythm = ED.create(rrand(2,5),13);
		
		~kickRhythm = ED.expand(ED.convert(ED.extrapolate(ED.convert(~baseRhythm)*2,Array.rand(4,2,9),16))*8);

		~snareRhythm = ED.extrapolate(ED.convert(ED.expand(ED.convert(~baseRhythm.rotate((~baseRhythm.size/2).asInteger))*16)),Array.rand(5,0,1),128);

		~hatsRhythm = ED.expand(ED.convert(ED.extrapolate(ED.convert(~baseRhythm)*4,2**Array.rand(10,2,4),16))*4);
		
		"New Measure".postln;
		
		(	instrument: \leads,
			degree: ([[0,2,-3],[4,-1,1],[5,0,2],[-1,1,3]]-10).choose,
			amp: 0.03,
			dur:6
		).play;
		
		});
	
	if(~kickRhythm[~beatCursor]==1,{Synth(\kick)});
	
	if(~snareRhythm[~beatCursor]==1,{Synth(\snare)});
		
	if(~hatsRhythm[~beatCursor]==1,{Synth(\hats,[\len,sin(~beatCursor*16*pi/(~baseRhythm.size*16))+2/16,\amp,cos(~beatCursor*32*pi/(~baseRhythm.size*16))+2/32])});
	
	~beatCursor = (~beatCursor + 1)%(~baseRhythm.size*16);
	
	1/16;
	
	});
	
)