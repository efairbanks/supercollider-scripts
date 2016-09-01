

(

{
	
	var nse = (Resonz.ar(WhiteNoise.ar(),[111,264,486,853,1236,3622,6421]*0.9,SinOsc.ar(0.2,0,0.03,0.04))/5);
	
	(nse * Pulse.ar(10,SinOsc.ar(5,0,0.6,0.7)))!2;
	
}.play;

)

SynthDef(\derp,{

	|a=#[200,433,822,1611]|
	
	Out.ar(0,SinOsc.ar(a,0,0.1)!2);
	
}).store;

(

f = {
	
		|ratio = 2, elements = 10|
	
		var x = [2];
		
		elements.do({x = x ++ (x[x.size-1]*2)});
	
		};
		
f.value(1.33,10);

//Synth(\derp,[\a,[300,500,700,1300,2000]]);

)


