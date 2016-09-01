
/*

Supercollider recvs on port 57120

*/

(

~deviceaddr = "10.0.2.32";

~devicerecvport = 9000;

~adrs = NetAddr(~deviceaddr, ~devicerecvport);

~adrs.sendMsg("/1/fader2", 0.5);

~responder = OSCresponderNode(nil, "/1/fader2", {
	
	|t, r, msg|
	
	("/1/fader2: " + t).postln; msg[1].postln;
	
}).add;
	

)
