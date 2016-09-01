

(

t.clear;

~baseRhythm = ED.create(5,13);

// --- //

~beatCursor = 0;

t = TempoClock(120/30).sched(0,{
	
	|beat|
	
	if(~beatCursor==0,{
		
		~kickRhythm = ED.expand(ED.convert(ED.extrapolate(ED.convert(~baseRhythm)*2,Array.rand(4,3,9),16))*8);

		~snareRhythm = ED.extrapolate(ED.convert(ED.expand(ED.convert(~baseRhythm.rotate((~baseRhythm.size/2).asInteger))*16)),Array.rand(2,0,1)++[1],128);

		~hatsRhythm = ED.expand(ED.convert(ED.extrapolate(ED.convert(~baseRhythm)*4,2**Array.rand(10,0,3),16))*4);
		
		"New Measure".postln;
		
		});
	
	if(~kickRhythm[~beatCursor]==1,{Synth(\kick)});
	
	if(~snareRhythm[~beatCursor]==1,{Synth(\snare)});
		
	if(~hatsRhythm[~beatCursor]==1,{Synth(\hats,[\len,sin(~beatCursor*16*pi/(~baseRhythm.size*16))+2/16,\amp,cos(~beatCursor*32*pi/(~baseRhythm.size*16))+2/32])});
	
	~beatCursor = (~beatCursor + 1)%(~baseRhythm.size*16);
	
	1/16;
	
	});
	
)