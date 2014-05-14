(

SynthDef(\dubstepBassI,{

	|freq=440, bus=0|

	var modulators, carrier, env, out, harmonic1, harmonic2, modulationAmount, modulationLFO1, modulationLFO2, sub, fx;

	env = EnvGen.ar(Env([1,0,1],[0.01,0.1]), doneAction:2);

	harmonic1 = 7;

	harmonic2 = 17;

	modulationAmount = 1000;

	modulationLFO1 = (SinOsc.ar(freq*4)+1)/2;

	modulationLFO2 = (SinOsc.ar(freq*2)+1)/4+0.25;

	modulators = SinOsc.ar(freq)+SinOsc.ar(freq*harmonic1)+SinOsc.ar(freq*harmonic2);

	carrier = SinOsc.ar(freq+(modulators*(modulationAmount*modulationLFO1*modulationLFO2)))/4;

	carrier = HPF.ar(carrier, 165);

	fx = LPF.ar(HPF.ar(Latch.ar(carrier,Saw.ar(freq*2)),1400),10000)/2;

	sub = SinOsc.ar([freq/16,freq/8,freq/4,freq/2,freq,freq*2,freq*4,freq*8])/2;

	sub = HPF.ar(sub, 55);

	sub = LPF.ar(sub, 110);

	out = (carrier+sub+fx)/8;

	Out.ar(bus,out!2);

}).store;

SynthDef(\delayFX,{

	|inBus=0, outBus=0|

	var in, feedIn, out, delay1, delay2, delay3;

	in = In.ar(inBus, 2);

	feedIn = In.ar(inBus, 2) + LocalIn.ar(2);

	delay1 = DelayL.ar(feedIn, 1, 0.22);
	delay2 = DelayL.ar(feedIn, 1, 0.08);
	delay3 = DelayL.ar(feedIn, 1, 00.03);

	LocalOut.ar((delay1+delay2+delay3)/3*0.7);

	Out.ar(outBus,in+(feedIn*((-10).dbamp)));

}).store;

)