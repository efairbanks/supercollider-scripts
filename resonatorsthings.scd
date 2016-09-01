

(

{
	
	var nse = (Resonz.ar(WhiteNoise.ar(),[111,264,486,853,1236,3622,6421]*0.9,SinOsc.ar(0.2,0,0.03,0.04))/5);
	
	(nse * Pulse.ar(10,SinOsc.ar(5,0,0.6,0.7)))!2;
	
}.play;

)

SynthDef(\derp,{

	|freqs=#[440,880,333,444,555,777,333,555]|
	
	var tone = SinOsc.ar(freqs,0,0.1);
	
	tone = LPF.ar(tone, 20000);
	
	Out.ar(0,tone!2);
	
}).store;

(

f = {
	
		|ratio = 2, elements = 10|
	
		var x = [1];
		
		elements.do({x = x ++ (x[x.size-1]*ratio)});
		
		x;
	
		};

{SinOsc.ar(f.value(0.9,20)*10000,f.value(3.73,20),f.value(0.35,20))!2}.play;

Synth(\derp,[\freqs,f.value(1.95,10)*220]);

)


