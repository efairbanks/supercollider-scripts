(

{
	
	var out = 0;
	
	var tone = SinOsc.ar(300*EnvGen.ar(Env([1,0.01].reverse,[0.2]))+SinOsc.ar(880,0,400))*EnvGen.ar(Env([1,0],[1]))*0.2;
	
	var noise = PinkNoise.ar()*EnvGen.ar(Env([1,0.5,0],[0.2,1]))*0.7;
	
	noise = IFFT(PV_BinShift(FFT(LocalBuf(4096),noise),0.5));
	
	noise = 0;
	
	out = DelayL.ar(LocalIn.ar(1),1,0.001) + tone + noise;
	
	out = IFFT(PV_BinShift(FFT(LocalBuf(4096),out),3));
	
	out = LPF.ar(out,16000);
	
	LocalOut.ar(out*0.75);
	
	Limiter.ar(out,0.5,0.1);
	
}.play;

)