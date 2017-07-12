purescript-polyphonic-soundfonts
================================

This is a PureScript wrapper for danigb's soundfont project: [soundfont-player](https://github.com/danigb/soundfont-player). It differs from [purescript-soundfonts](https://github.com/newlandsvalley/purescript-soundfonts) in that it allows soundfonts for multiple instruments to reside in memory at the same time - i.e. it allows for polyphonic music. It also uses the latest version of danigb's soundfont-player. Eventually purescript-soundfonts will be deprecated in favour of this library.  


It again loads soundfonts taken from Benjamin Gleitzman's package of [pre-rendered sound fonts](https://github.com/gleitz/midi-js-soundfonts). You may either load a single piano soundfont from a local server or else a set of soundfonts from Benjamin Gleitzman's github server. It then provides functions which allow you to play either an individual note or a sequence of notes.

The description of a MidiNote now contains an indication of the channel  (i.e. the polyphonic voice) :

     type MidiNote =
       { channel :: Int           -- the MIDI channel
       . id  :: Int               -- the MIDI pitch number
       , timeOffset :: Number     -- the time delay in seconds before the note is played
       , duration :: Number       -- the duration of the note
       , gain :: Number           -- the volume (between 0 and 1)
       }

We specify a duration for the note which will allow you to play staccato sequences. however, each note 'rings' for 10% more than its alloted time which allows the option of a legato feel whilst still letting each note to be started accurately at tempo.  Purescript-aff now incorporates a [delay](https://github.com/slamdata/purescript-aff/blob/master/src/Control/Monad/Aff.purs) function and this can be used to pace the notes correctly.

## Build

     npm install -g pulp purescript
     bower install
     pulp build

## Example

To build an example that runs in the browser:

     ./buildExample.sh

and then navigate to /example/dist/index.html
