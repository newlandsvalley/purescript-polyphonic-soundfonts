module Main where

import Prelude
import Audio.SoundFont (AUDIO, LoadResult, MidiNote,
                   canPlayOgg, isWebAudioEnabled,
                   loadPianoSoundFont, loadRemoteSoundFonts, playNote, playNotes)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION, Error)
import Data.Time.Duration (Milliseconds(..))
import Data.Either (Either)
import Control.Monad.Aff (Aff, launchAff, liftEff', runAff, delay)

note :: Int -> Int -> Number -> Number -> Number -> MidiNote
note channel id timeOffset duration gain =
  { channel : channel, id : id, timeOffset : timeOffset, duration : duration, gain : gain }

noteSample1 :: MidiNote
noteSample1 = note 0 60 0.0 0.3 1.0

noteSample2 :: MidiNote
noteSample2 = note 0 62 0.4 0.3 1.0

noteSample3 :: MidiNote
noteSample3 = note 0 64 0.8 0.2 1.0

notesSample :: Array MidiNote
notesSample =
 [ note 0 60 1.0 0.5 1.0
 , note 0 62 1.5 0.5 1.0
 , note 0 64 2.0 0.5 1.0
 , note 0 65 2.5 0.5 1.0
 , note 0 67 3.0 1.5 1.0
 , note 0 71 3.0 1.5 1.0
 ]

voice2sample1 :: MidiNote
voice2sample1 =
  note 1 48 0.0 1.0 1.0

voice2sample2 :: MidiNote
voice2sample2 =
  note 1 47 1.0 1.0 1.0

voice2sample3 :: MidiNote
voice2sample3 =
    note 1 45 2.0 1.0 1.0

voice2sample4 :: MidiNote
voice2sample4 =
    note 1 43 3.0 1.5 1.0


{- -}
main :: forall e.
        Eff
          ( au :: AUDIO
          , console :: CONSOLE
          , exception :: EXCEPTION
          | e
          )
          Unit
main = do
    playsOgg <- canPlayOgg
    log ("can I play OGG: " <> show playsOgg)
    audioEnabled <- isWebAudioEnabled
    log ("can I play web-audio: " <> show audioEnabled)
    -- testMonophony
    testPolyphony

testPolyphony ::
   forall e.
        Eff
          ( exception :: EXCEPTION
          , au :: AUDIO
          , console :: CONSOLE
          | e
          )
          Unit
testPolyphony =
  do
    _ <- runAff logError logFontLoad (loadRemoteSoundFonts ["violin", "viola"])
    _ <- launchAff polyphony
    log "polyphony setup finished"

testMonophony ::
   forall e.
        Eff
          ( exception :: EXCEPTION
          , au :: AUDIO
          , console :: CONSOLE
          | e
          )
          Unit
testMonophony =
  do
    _ <- runAff logError logFontLoad (loadPianoSoundFont "soundfonts")
    _ <- launchAff monophony
    log "monophony setup finished"

monophony :: forall e.
        Aff
          (  au :: AUDIO
          , console :: CONSOLE
          | e
          )
          (Either Error Unit)
monophony =
  do
    _ <- delay (Milliseconds 3000.0)
    liftEff' do
      played1 <- playNote noteSample1
      log ("note duration: " <> show played1)
      played2 <- playNote noteSample2
      log ("note duration: " <> show played2)
      played3 <- playNote noteSample3
      log ("notes duration: " <> show played3)
      played4 <- playNotes notesSample
      log ("notes duration: " <> show played4)

polyphony :: forall e.
        Aff
          (  au :: AUDIO
          , console :: CONSOLE
          | e
          )
          (Either Error Unit)
polyphony =
  do
    _ <- delay (Milliseconds 6000.0)
    liftEff' do
      played1 <- playNote noteSample1
      log ("note duration: " <> show played1)
      played2 <- playNote noteSample2
      log ("note duration: " <> show played2)
      played3 <- playNote noteSample3
      log ("notes duration: " <> show played3)
      played4 <- playNotes notesSample
      log ("notes duration: " <> show played4)
      _ <- playNote voice2sample1
      _ <- playNote voice2sample2
      _ <- playNote voice2sample3
      _ <- playNote voice2sample4
      log "finished"

logError :: ∀ e. Error -> Eff (console :: CONSOLE | e)  Unit
logError = logShow

logFontLoad  :: ∀ e. LoadResult -> Eff (console :: CONSOLE | e)  Unit
logFontLoad lr =
  log $ lr.instrument <> " soundfont loaded to channel " <> (show lr.channel)
