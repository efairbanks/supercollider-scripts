(
40.do({|inc|
  {
    var decreasingEnv = EnvGen.ar(Env([1,0.25,0],[0.6,1.3]),doneAction:2)**3;
    var freq = ExpRand(12000.rand+200,12000.rand+200);
    var out = BPF.ar(WhiteNoise.ar(),freq,0.1*decreasingEnv+0.05)*(decreasingEnv/(freq/200));
    out!2;
  }.play;
});
)


Server.default.makeGui;