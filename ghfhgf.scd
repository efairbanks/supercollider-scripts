
(

SynthDef(	\cymb,
				{
					
					|freq=440|
					
					var env = EnvGen.ar(Env([0,1,0],[0.025,0.001]));
			
					var noise = BPF.ar(WhiteNoise.ar(),8000*(1-env)+1000,1);
					
					var reson = Ringz.ar(env**10*noise,[777,1111,3333,4567,9876],0.1);
					
					var output = DetectSilence.ar(reson,doneAction:2);
					
					Out.ar(0,reson);
					
				}).store();
	
)

(

~derp = 1/(2**(4.rand));

t=TempoClock(140/60).schedAbs(	0,
									{
										
										|beat|
									
										if(	beat%1==0,
												{~derp=1/(2**(4.rand));},
												{});
									
										Synth(\cymb);
									
										~derp;
										
									});

 )