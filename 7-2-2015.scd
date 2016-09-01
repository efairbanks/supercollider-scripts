ServerOptions.outDevices;
Server.default.options.outDevice_("Soundflower (64ch)");
s.boot;
e.metro.tempo=135/15;
(
e=nil;
if(e==nil,{
  e=();
  e.beat=0;
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/its_a_new_day.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/new_orleans.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/funky_drummer.wav");
  e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/fools_gold.wav");
  e.breakLookup=(0:[9,8,5],1:[2,5,9,8,11],2:[8,5,3],3:[10,6],4:[0]);
  e.levelBeats=();
  e.maxLevel=4;
  e.metro=TempoClock(180/15).sched(0,{e.run.();e.beat=e.beat+1;1;});
});
~level2beats={|level|
  2**level;
};
~getLevel={|index, maxLevel|
  while({(maxLevel>0).and((index%~level2beats.(maxLevel))!=0)},{
    maxLevel=maxLevel-1;
  });
  maxLevel;
};
e.run={
  var level=~getLevel.(e.beat%~level2beats.(e.maxLevel),e.maxLevel);
  if(e.levelBeats[level]==nil,{e.levelBeats[level]=0;});
  e.levelBeats[level]=e.levelBeats[level]+1;
  if(e.breakLookup[level].size>0,{
    Synth(\break,[
      \bufnum,e.break.bufnum,
      \offset,e.breakLookup[level].wrapAt(e.levelBeats[level])/~level2beats.(e.maxLevel),
      \dur,(0.1/(1.65**e.maxLevel))*(2**level),
      \amp,(0.5/(1.35**e.maxLevel))*(1.4**level)]);
  });
};
)
(
SynthDef(\break,{|offset=0.5,bufnum,dur=0.075,amp=0.5|
  var phasor, out, env, rate;
  rate = 1;
  env=EnvGen.ar(Env([0,1,0],[0.001,dur]),doneAction:2);
	phasor = Phasor.ar(1, BufRateScale.kr(bufnum)*rate,0,BufFrames.kr(bufnum))+(offset*BufFrames.kr(bufnum));
	out = BufRd.ar(1, bufnum, phasor)*env*amp;
  Out.ar(0,out!2);
}).store;
)