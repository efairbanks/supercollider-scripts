

(

Synth(\kick);

Synth(\hats);

Synth(\snaredrum);

Synth(\snare);

Synth(\bass);

Synth(\pluck);

)

(

w = Window.new("Derp", Rect(100,100,640,480), border:true);

w.front;

w.view.background_(Color.black);
        
w.drawFunc = {

	var beat, beat1, beat2, beat4, beat8, beat16, beat32, width, height;

	width = w.bounds.width;
	height = w.bounds.height;
	
	beat = ~globalBeat;
	
	Pen.fillColor = Color.green;
	
	beat1 = beat.wrap(0, 1);
	
	Pen.fillRect(Rect(0,125,width*beat1/1,25));
	
	beat2 = beat.wrap(0, 2);
	
	Pen.fillRect(Rect(0,100,width*beat2/2,25));
	
	beat4 = beat.wrap(0, 4);
	
	Pen.fillRect(Rect(0,75,width*beat4/4,25));
	
	beat8 = beat.wrap(0, 8);
	
	Pen.fillRect(Rect(0,50,width*beat8/8,25));
	
	beat16 = beat.wrap(0, 16);
	
	Pen.fillRect(Rect(0,25,width*beat16/16,25));
	
	beat32 = beat.wrap(0, 32);
	
	Pen.fillRect(Rect(0,0,width*beat32/32,25));
	
};

AppClock.sched(0.0,{w.refresh;1/30;});

w.view.keyDownAction = {
		
	|v,c,m,u,k|
	
	~curDegree = c.switch(
	
		$z, -8,
		$x, -7,
		$c, -6,
		$v, -5,
		$a, -4,
		$s, -3,
		$d, -2,
		$f, -1,
		$q, 0,
		$w, 1,
		$e, 2,
		$r, 3,
		$1, 4,
		$2, 5,
		$3, 6,
		$4, 7,
		0
	
	);
	
	//~curDegree.postln;
	
};

)

(

~curScale = Scale.minor;

~curDegree = 0;

~players = [];

~players = ~players.add({

	|beat|
	
	
	
});

~playFunc = {

	|beat|
	
	var intbeat;
	
	~globalBeat = beat;
	
	intbeat = (beat*6).asInteger;
	
	//intbeat.postln;
	
	if(intbeat%6==0,{
	
		Synth(\kick);
		
		if(~bass!=nil&&intbeat%(4*6)==0,{
		
			~bass.set(\freq, ~curScale.degreeToFreq(~curDegree, 880, 0));
			
		},{
		
			~bass.set(\freq, ~curScale.degreeToFreq(~curDegree, 440, 0));
			
		});
		
	});
	
	if(intbeat%12==6,{
	
		Synth(\snaredrum, [\amp, -3.dbamp]);
		
		Synth(\snare, [\amp, -3.dbamp]);
		
	});
	
	if(intbeat%6==3,{
	
		Synth(\hats);
		
	});
	
	if(intbeat%3==0,{
	
		Synth(\pluck, [\freq, ~curScale.degreeToFreq(~curDegree, 440, 0)]);
		
	});
	
	if(intbeat%3==2,{
	
		Synth(\pluck, [\freq, ~curScale.degreeToFreq(~curDegree, 440, 0)]);
		
	});
	
	if(intbeat%(32*6)==0,{
		
		Synth(\noisesweep, [\dur, t.beatDur*32]);
		
		//"sdaf".postln;
		
	});
	
	1/6;
	
}

)

(

t = TempoClock(130/60).sched(0,{

	|beat|
	
	~playFunc.(beat);
	
});

)

(

t.stop;

)

(

{

var perc, melody;

perc = 16;
melody = 17;

~perc = 16;
~melody = 17;

SynthDef(\mixer,{

	var out, drums, leads, leadsSideChainMod;
	
	drums = In.ar(perc, 1);
	
	leads = In.ar(melody, 1);
	
	leadsSideChainMod = LPF.ar(HPF.ar(drums, 40), 200);
	
	leads = FreeVerb.ar(leads);
	
	leads = Compander.ar(leads, leadsSideChainMod, -30.dbamp, 1, 1/16, 5/1000, 40/1000);
	
	out = drums+leads;
	
	out = Limiter.ar(out, 1, 5/1000);
	
	Out.ar(0, out!2);
	
}).store;

if(~mixer!=nil, {~mixer.free; ~mixer = nil;});

~mixer = Synth(\mixer);

SynthDef(\snare, {
	
	|amp = 1, dur = 0.1|
	
	var env, noise, output;
	
	noise = Dust2.ar(4000);
	
	env = Line.ar(1.0, 0, 0.15, doneAction:2);
	
	output = LPF.ar(RHPF.ar( noise * env, 1000, 0.4), 9000)*amp;
	
	output = output*(-12.dbamp);
	
	Out.ar(perc, output);
	
}).store;

SynthDef(\hats, {

	|amp=1,out=0,dur=0.1|
	
	var env1, output;
	
	env1 = EnvGen.ar( Env.new([0,1,0],[0.0005,dur]), doneAction:2 );
	
	output = WhiteNoise.ar()*env1*env1*env1*env1*amp;
	
	output = FreeVerb.ar( output, 1/3, 0.8, 0.05 );
	
	output = HPF.ar( output, 5000 );
	
	output = output*(-24.dbamp);
	
	Out.ar(perc, output);
	
}).store;

f = {
	
	|ratio = 2, elements = 10|

	var x = [1];
	
	elements.do({x = x ++ (x[x.size-1]*ratio)});
	
	x;
	
};

SynthDef(\kick, {
			
	|dur=0.25,amp=1,basefreq=120|
	
	var output;
	
	var freqs = f.value(1.1,20)*basefreq;
	
	var amps = f.value(0.225,20)*0.5;
		
	var phases = NamedControl.kr(\phases,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
	
	var modfreqs = freqs * EnvGen.ar(Env([1,0],[dur]));
	
	var tone = SinOsc.ar(modfreqs,phases,amps)*EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
	
	tone = tone + LPF.ar((PinkNoise.ar()*EnvGen.ar(Env([1,0],[0.01])))*0.02,2250);
	
	tone = HPF.ar(tone,40)*amp;
	
	output = tone*(-6.dbamp);
	
	Out.ar(perc, output);
				
}).store;

SynthDef(\snaredrum,{

	|amp = 1|

	var noise = WhiteNoise.ar()*EnvGen.ar(Env([0,20,5,2,2/3,0]/40,[5,30,70,30,100]/1000),doneAction:2);
	
	var output = BPF.ar(noise, [200,1000,2000,5000], 0.5, [10,20,15,5]/7)*amp;

	output = output*(0.dbamp);

	Out.ar(perc,output);
	
}).store;

SynthDef(\highhat,{
	
	|amp = 1|

	var noise = WhiteNoise.ar()*EnvGen.ar(Env([0,20,5,2]/40,[5,40,70]/1000),doneAction:2);
	
	var output = BPF.ar(noise, [1000,2000,5000,7000,11000], 0.4, [3,5,15,10,15]/60)*amp;

	output = output*(-12.dbamp);

	Out.ar(perc,output);
	
}).store;

SynthDef(\bass,{

	|freq=440|
	
	var tone, out;
	
	tone = SinOsc.ar(freq/8) + SinOsc.ar(freq/16) + SinOsc.ar(freq/4) + SinOsc.ar(freq/2) + SinOsc.ar(freq) + SinOsc.ar(freq*2);
	
	tone = LPF.ar(tone, 110);
	
	tone = HPF.ar(tone, 55);
	
	tone = tone + LPF.ar(HPF.ar(Saw.ar(freq/8+SinOsc.ar(10,0,freq/500)), freq), freq*4);
	
	out = tone;
	
	out = out*(-23.dbamp);
	
	Out.ar(melody, out);
	
}).store;

SynthDef(\pluck,{

	|freq=440|
	
	var tone, env, out, pulsemod;
	
	pulsemod = SinOsc.ar(10,0,0.5) + 0.5;
	
	tone = HPF.ar(Saw.ar(freq*2,0.5),freq*4) + Pulse.ar(freq,pulsemod) + SinOsc.ar(freq*6,0,-10.dbamp);
	
	env = EnvGen.ar(Env([0,1,0],[5/1000,50/1000]), doneAction: 2);
	
	out = tone*env;
	
	out = RLPF.ar(out, env*freq*8+(freq*2), 0.2);
	
	out = out*(-26.dbamp);
	
	Out.ar(~melody, out);
	
}).store;

SynthDef(\noisesweep,{
	
	|dur|
	
	var noise, env, out;
	
	env = SinOsc.ar(1/dur,pi/2,0.4)+0.6;
	
	env = env*env;
	
	noise = WhiteNoise.ar()*env*EnvGen.ar(Env([(0.dbamp),(-20.dbamp)],[dur]),doneAction:2);
	
	noise = Latch.ar(noise, Pulse.ar(18000*env));
	
	noise = LPF.ar(noise, 17000*env);
	
	noise = noise*(-30.dbamp);
	
	out = HPF.ar(noise, 1000);
	
	Out.ar(~melody, out);

}).store;
/*
SynthDef(\morphlead,{

	|freq=440, dur=1|
	
	var tone, env, out;
	
	Out.ar(~melody, out);
	
}).store;*/

if(~bass!=nil, {~bass.free; ~bass = nil;});

~bass = Synth(\bass);

}.()

)