"use strict";

var sf = function() {

  var context = null;

  var instruments = [];

  return {
      /* can the browser play ogg format? */
      canPlayOgg : function () {
         var audioTester = document.createElement("audio");
         if (audioTester.canPlayType('audio/ogg')) {
           return true;
         }
         else {
           return false;
         }
      },
      /* Get the audio context */
      establishAudioContext : function() {
        if (sf.context === null || sf.context === undefined) {
          sf.context = new (window.AudioContext || window.webkitAudioContext)();
        }
      },
      /* is web audio enabled ? */
      isWebAudioEnabled : function() {
        sf.establishAudioContext();
        if (sf.context) {
          return true;
        }
        else {
          return false;
        }
      },
      /* Get the current time from the audio context */
      getCurrentTime : function() {
         sf.establishAudioContext();
         if (sf.context) {
           return sf.context.currentTime;
         }
         else {
           return 0;
         }
      },
    _loadSoundFonts : function (names, callback) {
        // console.log ("load instruments: " + names);
        var vca = sf.context.createGain();
        vca.gain.value = 1;
        vca.connect(sf.context.destination);

        names.forEach(function (name, index) {
          console.log ("instrument index: " + index + " name: " + name);
          /* var instruments = []; */
          Soundfont.instrument (sf.context, name, { destination: vca }).then (function (instrument) {
            console.log('Loaded from: ', instrument.url)
            instruments[index] = instrument;
            // callback(true)();
            callback ({ instrument : name, channel : index }) ();
          });
          sf.instruments = instruments;
        });
      },
      loadPianoSoundFontImpl : function(dirname) {
        return function (callback) {
          return function() {
            sf.establishAudioContext();
            if (sf.context) {
                 var name = 'acoustic_grand_piano';
                 var dir = dirname + '/';
                 var extension = null;
                 if (sf.canPlayOgg()) {
                   extension = '-ogg.js';
                 }
                 else {
                   extension = '-mp3.js';
                 }
                 Soundfont.nameToUrl = function (name) { return dir + name + extension }
                 sf._loadSoundFonts ( [name], callback);
             }
           }
        }
      },
      /* load and decode the soundfont from the reomte server */
      loadRemoteSoundFontsImpl : function(instruments) {
        return function (callback) {
          return function() {
            sf.establishAudioContext();
            Soundfont.nameToUrl = null;
            if (sf.context) {
              sf._loadSoundFonts ( instruments, callback);
            }
          }
        }
       },
      // play a midi note
      playNote :  function (midiNote) {
          return function() {
            return sf._playNote(midiNote);
          }
      },
      _playNote : function (midiNote) {
        if (sf.instruments) {
          var inst = instruments[midiNote.channel];
          // console.log ("instrument:" + inst + " for channel " + midiNote.channel + " note: " + midiNote.id);
          if (inst) {
            var buffer = inst.buffers[midiNote.id];
            var source = sf.context.createBufferSource();
            var gainNode = sf.context.createGain();
            var timeOn = sf.context.currentTime + midiNote.timeOffset;
            // let the note ring for 10% more than it's alloted time to give a more legato feel
            var timeOff = sf.context.currentTime + midiNote.timeOffset + (midiNote.duration * 1.1);
            gainNode.gain.value = midiNote.gain;
            source.buffer = buffer;
            source.connect(gainNode);
            gainNode.connect(sf.context.destination);
            source.start(timeOn);
            source.stop(timeOff);
            return midiNote.timeOffset + midiNote.duration;
          }
          else {
            console.log("no instrument for channel " + midinote.channel );
            return 0.0;
          }
        }
        else {
          console.log("no instruments loaded");
          return 0.0;
        }
      }
    };
}();

exports.isWebAudioEnabled = sf.isWebAudioEnabled;
exports.canPlayOgg = sf.canPlayOgg;
exports.getCurrentTime = sf.getCurrentTime;
exports.loadPianoSoundFontImpl = sf.loadPianoSoundFontImpl;
exports.loadRemoteSoundFontsImpl = sf.loadRemoteSoundFontsImpl;
exports.playNote = sf.playNote;
