s.boot;
(
x.free;
x={
  var out, freq, env;
  freq = 440;
  freq = (((Pulse.ar(freq*2)*100).atan)+1/2+1)*freq;
  out = RLPF.ar(Pulse.ar(freq),freq*8,0.1);
  out = out * 0.1;
  out = out!2;
  out;
}.play;
)
(
x.free;
x={
  var out, freq, env, lpfenv;
  freq = 55;
  lpfenv = EnvGen.ar(Env([0,1,0],[0,0.1]), doneAction:2, curve:\cubed);
  env = EnvGen.ar(Env([0,1,1,0],[0.005,0.1-0.01,0.005]));
  out = Pulse.ar(freq,0.3)+Pulse.ar(freq+1.234,0.5);
  //out = out * env;
  out = (out*10).atan;
  out = RLPF.ar(out,lpfenv*16000+30,0.05);
  out = (out*10).atan;
  out = out * 0.05;
  out!2;
}.play;
)
(
x.free;
x={
  var out, freq;
  freq = 400;
  out = 0;
  ((20000/freq)-1).asInteger.do({|inc|
    inc=inc+1;
    out = out + (Pulse.ar(freq*inc,0.5+SinOsc.ar(0.01.rand+1,0,0.4))*LPF.ar(Dust.ar(50+50.rand),50+50.rand)/inc);
  });
  out=out*EnvGen.ar(Env([0,1,-10.dbamp],[0.005,0.1]))*40;
  out!2;
}.play;
)
(
x.free;
x={
  var out, freq, env;
  env=EnvGen.ar(Env([0,1,0.1],[0.001,0.2]));
  freq=200*1;
  out=SinOsc.ar(freq+SinOsc.ar([freq,freq*7],0,freq*8*env));
  out=out*((-20).dbamp);
  out!2;
}.play;
)
(
x.free;
x={|out, freq=40, env, feedback|
  feedback=LocalIn.ar(2);
  freq = freq+(feedback/2);
  out = Pulse.ar(freq,0.5+(feedback/100))+feedback;//+Saw.ar(freq);
  LocalOut.ar(DelayN.ar(out*0.9,1,1/freq));
  out=out*0.1;
  out!2;
}.play;
t.stop;
t=TempoClock(120/30).sched(0,{
  var freq;
  if(e==nil,{e=();});
  if(e.beat==nil,{e.beat=0;});
  freq = (Scale.minor.performDegreeToKey([7,3,6,4])+23).midicps.wrapAt(e.beat);
  x.set(\freq,freq);
  Synth(\leads,[\freq,freq]);
  e.beat=e.beat+1;
  8;});
)
(
x.free;
x={
  var out, freq, env, feedback;
  feedback=LocalIn.ar(2);
  env=EnvGen.ar(Env([0,1,0.1],[0.001,0.2]));
  freq=MouseX.kr()*20;
  out=SinOsc.ar(freq+SinOsc.ar([freq,freq*7],feedback[0],freq*8*env+(feedback[0]*200)));
  out=out*((-20).dbamp);
  //out=[out,out]+DelayN.ar(feedback,1,1/(freq));
  out=[out,out]+DelayC.ar(feedback[0],1,1/(freq));
  LocalOut.ar(out/2.01);
  out=out*((-40).dbamp);
  out;
}.play;
)
(
x.free;
x={
  var out, freq, env, feedback;
  feedback=LocalIn.ar(2);
  env=EnvGen.ar(Env([0,1,0.1],[0.001,0.2]));
  freq=MouseX.kr()*300+10+SinOsc.ar(0.1,0,1);
  out=Mix.ar(Saw.ar([freq,freq*1.0123456,freq*0.98765,freq*3]+(feedback[0]*freq)))/4;
  out=out*((-20).dbamp);
  out=[out,out]+DelayC.ar(feedback,1,1/freq/1.01);
  LocalOut.ar(out*MouseY.kr(0.05,0.99));
  out;
}.play;
)
(
b=0;
t=TempoClock(120/30).schedAbs(0,{
  3.do({|inc|
    var frequency=(Scale.minor.performDegreeToKey(inc*2+[0,4,1,5].reverse.wrapAt((b/8).asInteger))).midicps;
    while({frequency<150},{frequency=frequency*2;});
    x={
      var out, freq, env;
      env=EnvGen.ar(Env([0,1*MouseX.kr(),0.1*MouseX.kr(),0],[0.001,1*MouseY.kr(),4]),doneAction:2);
      freq=frequency;
      out=SinOsc.ar(freq+SinOsc.ar([freq,freq*6],0,freq*12*env));
      out=out*((-20).dbamp)*env;
      out!2;
    }.play;
  });
  b=b+1;
  1;
});
)