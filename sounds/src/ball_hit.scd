(
// Startup procedures
// Evaluate this block or nothing else will work
s.boot;
)

(
// This is the sound
SynthDef.new(\ballhit, {
    arg freq=440, atk=0.1, sus=0, rel=1, amp=0.5, cutoff_freq=1760;
    var sig, env;

    // Create the initial signal
    // A simple saw wave who's frequency is modified by an exponential line
    // Going up by a minor third
    sig = Saw.ar(XLine.ar(
        freq, 
        freq * 6 / 5,
        atk + sus + rel
    ));


    // Create an envelope to have nice sounding
    // beginnings and ends to the note
    // *atk is how long it takes the sound to start
    // *sus is how long it persists at full volume
    // *rel is how long it takes the sound to die away
    // doneAction: 2 indicates that the synth object should
    //    be cleaned up after it finishes playing
    env = EnvGen.ar(
        Env(
            [0, 1, 0.8, 0],
            [atk, sus, rel]
        ), 
        doneAction: 2
    );

    sig = LPF.ar(sig, cutoff_freq, 2);
    
    // Add the envelop to the signal
    sig = sig * env;
    
    // Adjust the output volume by the amp
    sig = sig * amp;

    // Send the signal to the standard output bus
    Out.ar(0, sig);


}).add;
)

(
// Try out the sound
x = Synth(
    \ballhit,
    [
        \freq, 80,
        \amp,  0.44,
        \atk, 0.03,
        \rel, 0.4,
    ]
);
)

(
s.recSampleFormat = "int24";
s.recHeaderFormat = "wav";

Routine ({

    // Start recording
    s.record("./ball_hit.wav");

    wait(0.02);
    x = Synth(
        \ballhit,
        [
            \freq, 80,
            \amp,  0.44,
            \atk, 0.03,
            \rel, 0.4,
        ]
    );

    wait(0.5);
    s.stopRecording;

}).play;

)

