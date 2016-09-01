s.boot;

(
b = Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav");
e={|t_trig=1,pitch=1,grainSize=0.01,tempo=0.0001,buffer=0,phase=0,pos=0|
  GrainBuf.ar(1,LFSaw.ar(2/grainSize),grainSize,buffer,pitch,Phasor.ar(t_trig,tempo,0,1,pos))!2;
}.play;
e.set(\buffer,b);
OSCdef.new(\wiiaxis,{|msg|
  e.set(\pitch,msg[1]*2);
  e.set(\grainSize,msg[3]/30);
  e.set(\tempo,msg[2]/50000);
},'/test');
~angle=0;
OSCdef.new(\wiianalog,{|msg|
  var x=msg[1]*2-1;
  var y=msg[2]*2-1;
  var angle=((Complex(x,y).phase+pi)/(pi*2));
  var mag=Complex(x,y).magnitude;
  if(mag>0.5,{
    e.set(\pos,angle);
  });
},'/analog');
OSCdef.new(\abutton,{|msg|
  if(msg[1]>0,{e.set(\t_trig,1);});
},'/a');
)
Complex(1,100).angle/(2*pi);
(
x={|freq=440,phaseAmount=1,phaseFreq=1000,reverbAmount=0|
  var out=0;
  freq=Lag.kr(freq);
  phaseAmount=Lag.kr(phaseAmount);
  phaseFreq=Lag.kr(phaseFreq);
  reverbAmount=Lag.kr(reverbAmount);
  out=SinOsc.ar(freq,SinOsc.ar([phaseFreq,phaseFreq*7],0,phaseAmount));
  out=out+FreeVerb.ar(out*reverbAmount,1,0.95,0.3);
  out!2;
}.play;
OSCdef.new(\wiiaxis,{|msg|
  x.set(\freq,20+(msg[1]**2*100));
  x.set(\phaseAmount,msg[3]*200);
  x.set(\phaseFreq,20+(msg[2]**2*1000));
  x.set(\reverbAmount,msg[4]**1.5);
},'/test');
)