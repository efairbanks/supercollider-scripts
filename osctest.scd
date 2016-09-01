
(

var deviceaddr = "10.0.2.11";

var devicerecvport = 8080;

var adrs = NetAddr(deviceaddr, devicerecvport);

adrs.sendMsg("/vol1", 0.5);

//a.sendMsg("/control/createBlankInterface", "testing", "portrait");
//a.sendMsg("/control/pushDestination", "127.0.0.1:57120");

/*

NetAddr.langPort

o = OSCresponderNode(nil, "/vol1", {
	
	|t, r, msg|
	
	("vol1:" + t).postln; msg[1].postln;
	
}).add;

q = OSCresponderNode(nil, "/pan1", {
	
	|t, r, msg|
	
	("/pan1:" + t).postln; msg[1].postln;
	
}).add;

*/

)

(

~deviceaddr = "10.0.2.2";

~devicerecvport = 57120;

a = NetAddr(~deviceaddr, ~devicerecvport);

p = OSCresponderNode(nil, "/BassI/Timbre", {
	
	|t, r, msg|
	
	~timbre = msg[1];
		
}).add;

o = OSCresponderNode(nil, "/BassI/Degree", {
	
	|t, r, msg|
	
	Synth(\BassI,[\freq,Scale.minor.degreeToFreq(msg[1],55,0),\timbre,~timbre]);
	
}).add;

Synth(\BassI);

(

SynthDef(\BassI,{

	|freq=440,timbre=10|

	var tone, env, out;
	
	tone = Pulse.ar(freq/2,0.4)+Pulse.ar(freq*3/4,0.05)+SinOsc.ar(freq);
	
	env = EnvGen.ar(Env([0,1,0],[0.01,0.2]), doneAction:2);
	
	tone = RLPF.ar(tone, env*12000*timbre/10,0.2);
	
	tone = HPF.ar(tone, 30);
	
	out = tone*env;
	
	Out.ar(0, out!2);
	
}).store;

)