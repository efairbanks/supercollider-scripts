(
{
  var env = EnvGen.ar(Env([0,1,0],[0.04,1]),doneAction:2);
  var freq=26; var noise=600*env; var freqCoef=11; var modCoef=3*env; var out;
  out = SinOsc.ar([freq,freq*3],SinOsc.ar(WhiteNoise.ar()*noise+(freq*freqCoef))*modCoef,[1,1/2]);
  out = FreeVerb.ar(out);
  out = -20.dbamp*out*env;
  out!2;
}.play;
)
