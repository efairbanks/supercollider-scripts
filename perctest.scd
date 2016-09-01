(
{
var out, env, freq;
  freq=500;
  env=EnvGen.ar(Env([0,1,0],[0.1,20]),doneAction:2);
  env=env**3;
  out=Ringz.ar(BPF.ar(PinkNoise.ar(),18000*(1-env)+30,0.5), Array.series(20,4,1)*(freq/2)+{exprand(freq/15, freq/25)}.dup(20), 30/Array.series(30,1,1))*(1/Array.series(30,8,1));
  out=out/100;
  out=out*env;
  out!2;
}.play;
)