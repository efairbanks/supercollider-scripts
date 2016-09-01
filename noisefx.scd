(
{
  var outl=0, outr=0;
  400.do({outl=outl+SinOsc.ar(ExpRand(2000.0,2500.0),2.0.rand,2).tanh;});
  400.do({outr=outr+SinOsc.ar(ExpRand(2000.0,2500.0),2.0.rand,2).tanh;});
  outl=HPF.ar(outl,20);
  outr=HPF.ar(outr,20);
  -50.dbamp*[outl,outr];
}.play;
)
(
{
  var outl=0, outr=0;
  200.do({outl=outl+SinOsc.ar(ExpRand(100.0,1500.0)+SinOsc.ar(3.0.rand,0,1000.0.rand),2.0.rand,25).tanh;});
  200.do({outr=outr+SinOsc.ar(ExpRand(100.0,1500.0)+SinOsc.ar(3.0.rand,0,1000.0.rand),2.0.rand,25).tanh;});
  outl=HPF.ar(outl,20);
  outr=HPF.ar(outr,20);
  -50.dbamp*[outl,outr];
}.play;
)
(
{
  var outl=0, outr=0;
  200.do({outl=outl+SinOsc.ar(ExpRand(430.0,450.0)+SinOsc.ar(3.0.rand,2.0.rand,40.0.rand),2.0.rand,25).tanh;});
  200.do({outr=outr+SinOsc.ar(ExpRand(430.0,450.0)+SinOsc.ar(3.0.rand,2.0.rand,40.0.rand),2.0.rand,25).tanh;});
  outl=HPF.ar(outl,20);
  outr=HPF.ar(outr,20);
  -50.dbamp*[outl,outr];
}.play;
)
