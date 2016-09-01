(
{
var out, env;
  env=EnvGen.ar(Env([0,1,0],[0.005,0.15]),doneAction:2);
  env=env**3;
  out=Ringz.ar(BPF.ar(PinkNoise.ar(0.1),7000*env+30,0.2), {exprand(300, 20000)}.dup(200)).mean;
  out=out*env;
  out!2;
}.play;
)