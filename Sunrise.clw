  PROGRAM

  MAP
  END

  INCLUDE('SunTime.inc'),ONCE
  INCLUDE('RADDebuger.inc'),ONCE

ST                  SunClass 
DB                  DebugerClass
LOC:Latitude        DECIMAL(10,5)
LOC:Longitude       DECIMAL(10,5)
LOC:OffSet          LONG
LOC:Sunrise         LONG
LOC:SunSet          LONG
LOC:ClarionStand    LONG
LOC:TimeEntry       LONG

Window    WINDOW('Sunrise and Sunset'),AT(,,174,144),GRAY,FONT('Segoe UI Semibold', |
              10,,FONT:bold)
            PROMPT('Latitude:'),AT(17,22,,11),USE(?LatPrompt)
            ENTRY(@N-10.5),AT(72,23,,10),USE(LOC:Latitude)
            PROMPT('Longitude:'),AT(17,36,,11),USE(?LongPrompt)
            ENTRY(@N-10.5),AT(72,36,,10),USE(LOC:Longitude)
            PROMPT('GMT Offset:'),AT(17,49,,11),USE(?GMTOffSetPROMPT)
            ENTRY(@n-2),AT(72,50,16,10),USE(LOC:OffSet),TIP('Daylight time is computed, ' & |
                'use the standard offset always.')
            PROMPT('Time:'),AT(17,65),USE(?PROMPT1)
            SPIN(@T3),AT(72,65,56,10),USE(LOC:TimeEntry),HSCROLL,STEP(6001)
            STRING(@N15),AT(74,80),USE(LOC:ClarionStand),FONT(,,COLOR:Blue)
            STRING('Sunrise'),AT(72,90),USE(?STRING1)
            STRING('Sunset'),AT(114,90),USE(?STRING2)
            BUTTON('Compute'),AT(17,99),USE(?ComputeButton)
            STRING(@t3),AT(72,103,34),USE(LOC:Sunrise),FONT(,,COLOR:Blue)
            STRING(@t3),AT(114,103,34),USE(LOC:Sunset),FONT(,,COLOR:Blue)
            BUTTON('&OK'),AT(72,125,41,14),USE(?OkButton),STD(STD:Close),DEFAULT
          END

  CODE
  LOC:Latitude = 28.0366             !Set default value
  LOC:Longitude = -82.7659           !Longitude default
  LOC:Offset = -5                    !Offset from GMT default
  OPEN(Window)
  ACCEPT
    CASE ACCEPTED()
    OF ?ComputeButton
      ST.Init(LOC:Latitude,LOC:Longitude,LOC:OffSet)   !Default to today's date when leaving off last parameter
      LOC:Sunrise = ST.Sunrise() 
      LOC:SunSet  = ST.Sunset()
      DISPLAY()
    OF ?LOC:TimeEntry
      LOC:ClarionStand = LOC:TimeEntry
      DISPLAY()
    OF ?OkButton
      POST(EVENT:CloseWindow)
    END
    CASE EVENT()
    OF EVENT:NewSelection
      LOC:ClarionStand = LOC:TimeEntry
      DISPLAY()
    OF EVENT:Accepted
    END
  END

