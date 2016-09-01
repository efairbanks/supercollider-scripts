
(

{
	
	var output;
	
	output = Pulse.ar(20,SinOsc.ar(0.1,0,1.0),1.0);
	
	output = LPF.ar(output, SinOsc.ar(1.05,0,400,400));
	
	output = output * 0.5 * SinOsc.ar(120,0,0.5);

	output = FreeVerb.ar(output, 0.4, 0.9, 0.2);

	Out.ar(0, output ! 2);
	
}.play;
	
)