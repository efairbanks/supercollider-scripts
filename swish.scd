(
{
var out, env;
  env=EnvGen.ar(Env([0,1,0],[0.005,0.5]),doneAction:2);
  env=env**3;
  out=Ringz.ar(BPF.ar(PinkNoise.ar(0.1),5000+SinOsc.ar(20,3.14,5000*env)+30,0.01), {exprand(300, 20000)}.dup(1000)).mean;
  out=out*env;
  out!2;
}.play;
)