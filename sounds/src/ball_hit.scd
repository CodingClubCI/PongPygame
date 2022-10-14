// The language here is called sclang and is part of a sound synthesis 
// ecosystem known as Supercollider. Sclang is an interpreted language 
// in which each line (or groups of lines within parentheses) can be run
// individually to send to the server which is called scsynth. 
// People do lots of cool things with Supercollider and similar languages
// such as live coding entire tracks of music. 
//
// If you want to learn more about Supercollider, you should check out 
// Eli Fieldsteel's tutorials beginning here: 
// https://www.youtube.com/watch?v=yRzsOOiJ_p4&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC
//
// You can download the Supercollider system from here:
// https://supercollider.github.io/downloads

// You always have to boot the local sound server before you can do most of 
// the cool stuff with Supercollider
(
// Startup procedures
// Evaluate this block or nothing else will work
s.boot;
)

(
// This is the sound
// A SynthDef is a way to create a synthesizer and save it for use later
// notice the `.new` at the beginning and the `.add` at the end
// first argument:
//     the name of the synth, notice the syntax
// second argument:
//     a function (notice the curly braces) which creates a sound
SynthDef.new(\ballhit, {
    // freq: the initial pitch of the sound in Hz
    // atk: how long it takes for the sound to reach full volume
    // sus: how long the sound sustains
    // rel: how long it takes the sound to decay
    // amp: percentage multiplier for the volume of the sound
    // cutoff_freq: where to begin dampening the high end of the sound in Hz
    arg freq=440, atk=0.1, sus=0, rel=1, amp=0.5, cutoff_freq=1760;
    var sig, env;

    // Create the initial signal
    // A simple saw wave who's frequency is modified by an exponential line
    // Going up by a minor third
    // Saw.ar is fed a single argument for its pitch in Hz
    // XLine.ar generates an exponential curve
    //     first argument: starting pitch in Hz
    //     second argument: ending pitch in Hz
    //     third argument: how long it takes to move between those pitches
    sig = Saw.ar(XLine.ar(
        freq, 
        freq * 6 / 5,
        atk + sus + rel
    ));


    // Create an envelope to have nice sounding
    // beginnings and ends to the note
    // EnvGen.ar is given two arguments
    //     first argument: and envelope object detailing the shape
    //         to use in the EnvGen signal
    //     doneAction: 2 indicates that the synth object should
    //         be cleaned up after it finishes playing
    //     
    // Env is given two arguments
    //     first argument: an array of numbers which indicate the 
    //         multipliers applied to the signal at each portion of
    //         envelope
    //      second argument: an array which indicates how long it takes
    //         to move between the different stages of the envelope

    env = EnvGen.ar(
        Env(
            [0, 1, 0.8, 0],
            [atk, sus, rel]
        ), 
        doneAction: 2
    );

    // LPF.ar modifies the signal with a Lowpass filter
    // Lowpass filters attenuates high portions of the sound,
    // allowing low portions of the sound to "pass" through
    // the pitch in Hz at which this attenuation starts is
    // the cutoff frequency
    sig = LPF.ar(sig, cutoff_freq, 2);
    
    // Add the envelop to the signal
    sig = sig * env;
    
    // Adjust the output volume by the amp
    sig = sig * amp;

    // Send the signal to the standard output bus
    // 0 indicates that the sound will be played to 
    // the first (and default) playback device
    // the second argument is the signal we've been creating
    Out.ar(0, sig);


}).add;
)

(
// Try out the sound
// This is how we create an instance of the synth which we
// defined earlier in the SynthDef
// notice the strange format in which the arguments are passed in
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
// These two lines of code ensure that python can read the sound file
// We produce
s.recSampleFormat = "int24";
s.recHeaderFormat = "wav";

// A routine is a sequence of code to be executed sequentially
// ususally you would do this to schedule events to happen one after another
// In this case, we use it to control exporting our audio
Routine ({

    // Start recording
    // first argument:
    //     the path to the audio file output
    s.record("./ball_hit.wav");

    // It takes a moment for supercollider to begin recording
    // So this line ensures that we hear the entire sound
    wait(0.02);
    
    // Create the synth from before
    x = Synth(
        \ballhit,
        [
            \freq, 80,
            \amp,  0.44,
            \atk, 0.03,
            \rel, 0.4,
        ]
    );
    
    // Wait for the sound to finish before stopping the recording
    wait(0.5);
    s.stopRecording;

}).play;

)

