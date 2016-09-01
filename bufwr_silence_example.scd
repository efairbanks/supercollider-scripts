(
~test={
  // ring buf duration is 5 seconds, but the duration doesn't seem
  // to change whether or not the screeching happens, just how quickly
  // it starts
  var ringBuf = LocalBuf.new(SampleRate.ir()*5, 1);
  var master = 0;
  var phasor = 0;

  // generate test signal
  master=SinOsc.ar(1000+SinOsc.ar(0.4,0,300));

  // create normal phasor to step through ring buffer cyclically
  phasor = Phasor.ar(0, BufRateScale.kr(ringBuf),0,BufFrames.kr(ringBuf));

  // zero out ring buffer halfway away from the read/write head
  BufWr.ar(DC.ar(0), ringBuf, phasor + (BufFrames.kr(ringBuf)/2));

  // Read from the ring buffer
  master = BufRd.ar(1, ringBuf, phasor)*(-500.dbamp);

  // output
  Out.ar(0,master!2);
}.play;
)