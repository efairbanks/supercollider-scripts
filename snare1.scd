
(

SynthDef( \snare, {
	
	|amp=0.1,out=0,vel=0.5,mute=1|
	
	var env, envstick, envbody, envsnare, output, stick, body, snare;
	
	env = EnvGen.ar(Env.new([0,1,1,0],[0,mute,0]), doneAction:2);
	
	
	envsnare = EnvGen.ar(Env.new([0,1,0],[1/1000,(150*rrand(0.75,1.25)*mute)/1000]));
	
	snare = GrayNoise.ar();
	
	snare = BPF.ar(snare, 1000, 1 ) + BPF.ar(snare, 5000, 1.25 );
	
	snare = snare * envsnare * 0.4;
	
	
	envbody = EnvGen.ar(Env.new([0,1,0],[1/1000,(125*rrand(0.75,1.25)*mute)/1000]));
	
	body = SinOsc.ar([133*rrand(0.95,1.05),200*rrand(0.975,1.025)],[0.25,0.5]);
	
	body = body * envbody * 0.25;
	
	
	envstick = EnvGen.ar(Env.new([0,1,0],[1/1000,(40*rrand(0.20,1.25)*mute)/1000]));
	
	stick = WhiteNoise.ar();
	
	stick = BPF.ar( stick, 1000, 0.2 ) + BPF.ar( stick, 2000, 0.1 ) + BPF.ar( stick, 4000, 0.1 );
	
	stick = stick * envstick;
	
	
	output = stick + snare + body;
	
	Out.ar(out,output*env*amp);
	
}).add;
	
(instrument:'snare',dur:0.3).play;

)

Pbind(	'instrument', 'snare',
		'dur', 0.1,
		'mute', Prand([1,0.9,0.8,0.7],inf),
		'amp', Prand([1,0.75,0.6,0.5],inf)
		
).play;
