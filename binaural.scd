
(

{

	var lc, rc, harmonics, beatfreq, amplitudes, rootfreq, pulse;
	
	pulse = LPF.ar(Pulse.ar(0.3,0.5),2);
	
	rootfreq = MouseY.kr(2,16);
	
	rootfreq = rootfreq*rootfreq;
	
	harmonics = [1,2,3,4];
	
	amplitudes = 1/harmonics;
	
	beatfreq = MouseX.kr(0,20);
	
	lc = SinOsc.ar((rootfreq*harmonics)+(beatfreq/2),0,amplitudes);
	
	rc = SinOsc.ar((rootfreq*harmonics)-(beatfreq/2),0,amplitudes);
	
	lc = lc * pulse;
	
	rc = rc * pulse;
	
	Out.ar(0, [Mix.new(lc), Mix.new(rc)]);
	
}.scope;

)
