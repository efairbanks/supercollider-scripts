(
t=TempoClock(110/30).sched(0,{
  b=if(b==nil,{0},{b})+1;
  x.free;
  x={
    var freq, out;
    freq=(12+(((b/4).floor*5)%12)).midicps*(1!7++[2,4,3].wrapAt(b/3)).wrapAt(b);
    out=(SinOsc.ar(freq+((SinOsc.ar([freq*2+SinOsc.ar(0.2),freq*4+SinOsc.ar(0.3),freq*6+SinOsc.ar(0.5)])*3).tanh*150))*1000).tanh!2;
    out=LPF.ar(out,50+SinOsc.ar([4,2,1,2].wrapAt(b),3.14/2,1000,1000));
    out*0.1;
  }.play;
  2});
)