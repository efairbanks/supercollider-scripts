(
~test={|t_retrig=0,retrigmix=0,retrigspeed=1,retrigdur=1|
  var ringBuf = LocalBuf.new(SampleRate.ir()*5, 2);
  var retrigMixerLatch = 0;
  var bufFramesLatch = 0;
  var master = 0;
  var phasor = 0;
  var out = 0;

  // generate test signal
  master=SinOsc.ar(1000+SinOsc.ar(0.4,0,300))!2;

  // create normal phasor to step through ring buffer cyclically
  phasor = Phasor.ar(0, BufRateScale.kr(ringBuf),0,BufFrames.kr(ringBuf));

  // record the phasor position when t_retrig is triggered
  bufFramesLatch = Latch.ar(phasor,t_retrig);

  // zero out ring buffer halfway away from the read/write head
  BufWr.ar(0,ringBuf, phasor + (BufFrames.kr(ringBuf)/2));

  // write signal to ring buffer
  BufWr.ar(master, ringBuf, phasor);

  // if stutter effect is disabled, mix all the way to the normal
  // phasor and just spit out what's just been written to it, otherwise
  // mix all the way to the stutter phasor and use that as input to
  // the BufRd Ugen
  phasor = phasor * (1-retrigmix);
  phasor = phasor + ((Phasor.ar(t_retrig, BufRateScale.kr(ringBuf)*retrigspeed,0,SampleRate.ir()*(retrigdur*retrigspeed)) + bufFramesLatch) * retrigmix);

  // Read from the ring buffer
  master = BufRd.ar(1, ringBuf, phasor,interpolation:3);

  // output
  Out.ar(0,master);
}.play;

// keep track of beat for parameter sequencing
~beat=0;
t=TempoClock(120/15).sched(0,{
  var effectActive = 1;

  // retriggger effect is on for 32 beats and then off for 32 beats
  if(~beat%64>32,{effectActive=0;});

  // mess with retrigger effect, turning it off and on randomly
  ~test.set(\t_retrig,1*effectActive,\retrigmix,2.rand*effectActive,\retrigspeed,[-2,2,0.5,1].wrapAt(~beat),\retrigdur,1);

  // increment beat
  ~beat = ~beat + 1;
  1;
});
)