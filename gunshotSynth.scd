(
{
  var out = 0;
  // --- //
  var lowMidFreq = 800;
  var midHighFreq = 4000;
  var duration = 0.02;
  // --- //
  var highEnv = EnvGen.ar(Env([1,0],[duration]));
  var midEnv = EnvGen.ar(Env([1,0],[duration*1.5]));
  var lowEnv = EnvGen.ar(Env([1,0],[duration*2]));
  // --- //
  var high = HPF.ar(WhiteNoise.ar(),midHighFreq) * highEnv;
  var mid = LPF.ar(HPF.ar(PinkNoise.ar(),lowMidFreq),midHighFreq) * midEnv;
  var low = LPF.ar(PinkNoise.ar(),lowMidFreq) * lowEnv;
  out = LPF.ar(high + mid + low, 7000);
  out!2;
}.play;
)