

SynthDef(	\rbank,
			{
			
			|dur=1|
			
			var freqs = NamedControl.kr(\freqs,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
			
			var amps = NamedControl.kr(\amps,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
			
			var phases = NamedControl.kr(\phases,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
			
			var modfreqs = freqs * EnvGen.ar(Env([1,0],[dur]));
			
			var tone = SinOsc.ar(modfreqs,phases,amps)*EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
			
			tone = tone + LPF.ar((PinkNoise.ar()*EnvGen.ar(Env([1,0],[0.004])))*0.02,2250);
			
			Out.ar(0,tone!2);
				
			}).store;


			TempoClock(70/60).sched(
						
						0,
						{
							x = Synth(\rbank,[\freqs,f.value(1.1,20)*120,\amps,f.value(0.225+rand(0,0.7),20),\dur,0.18]);
							
							1
							
						});

f = {
	
		|ratio = 2, elements = 10|
	
		var x = [1];
		
		elements.do({x = x ++ (x[x.size-1]*ratio)});
		
		x;
	
		};