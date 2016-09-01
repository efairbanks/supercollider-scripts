
(

~chord = {
	
	|degree, lbound, ubound, numnotes, complexity|
	
	var degrees = [];
	
	var chord = [];
	
	if(complexity>7,{complexity=7});
	
	if(lbound>ubound,{var temp = lbound;lbound = ubound;ubound = temp;});
	
	complexity.do({
		
		|inc|
		
		var mul = 2;
		
		if(complexity==2,{mul = 4;});
		
		degrees = degrees ++ (inc*mul%7);
		
		});
		
	(ubound-lbound).do({
		
		|inc|
		
		var note = lbound + inc;
		
		if(degrees.includes(note%7),{chord = chord ++ note});
		
		});
		
	while({chord.size>numnotes},{chord.removeAt(chord.size.rand)});
	
	chord+degree;
	
	};

)

(

SynthDef(\leads,

	{
		
		|freq=440,dur=0.1,amp=0.05|
		
		freq = freq * 2;
		
		Out.ar(0,SinOsc.ar(freq+SinOsc.ar(Rand(3,10),0,freq/60),0,amp)*EnvGen.ar(Env([1,0.25,0],[dur,1]),doneAction:2)!2);
		
		}).store;

)

(

d = [1,4,5,4,3,5,2,9];

i = 0;
	
t = TempoClock(0.5).sched(0,{

	var chord = ~chord.value(d[i]-1+7%14-7,-3,20,15.rand+4,4.rand+2);
	
	var backupchord = ~chord.value(d[i]-1%7-7,-15,5,1.rand+3,3.rand+2);
	
	var time = rrand(0.85,1.0);
	
	d = d ++ chord;
	
	if(rrand(0,1)>0.7,{chord = chord.reverse;});
	
	if(rrand(0,1)>0.3,{chord = chord.perfectShuffle;});
	
	if(rrand(0,1)>0.8,{chord = chord.reverse;});
	
	if(rrand(0,1)>0.6,{chord = chord.perfectShuffle;});
	
	chord.size.do({
		
		|inc|
		
		t.sched(time*inc/chord.size,{(degree: chord[inc],instrument:\leads,amp:0.02).play;});
		
	});
	
	backupchord.size.do({
		
		|inc|
		
		t.sched(0,{(degree: backupchord[inc],instrument:\leads,dur:1).play;});
		
		});
	
	backupchord.postln;
	
	i = (i + 1)%d.size;
	
	1;
	
});

)

