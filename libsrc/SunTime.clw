  MEMBER

WORD                    EQUATE(USHORT)
DWORD                   EQUATE(LONG)
TIME_ZONE_ID_UNKNOWN    EQUATE(0)
TIME_ZONE_ID_STANDARD   EQUATE(1)
TIME_ZONE_ID_DAYLIGHT   EQUATE(2)

SYSTEMTIME          GROUP,TYPE
wYear                 WORD
wMonth                WORD
wDayOfWeek            WORD
wDay                  WORD
wHour                 WORD
wMinute               WORD
wSecond               WORD
wMilliSecond          WORD
                    END

TimeZoneInfo        GROUP,TYPE
Bias                  LONG
StandardName          USHORT,DIM(32)
StandardDate          LIKE(SYSTEMTIME)
StandardBias          LONG
DayLightName          USHORT,DIM(32)
DayLightDate          LIKE(SYSTEMTIME)
DayLightBias          LONG
                    END

  MAP
    MODULE('kernel32')
      GetTimeZoneInformation(*TimeZoneInfo),LONG,PROC,RAW,PASCAL,NAME('GetTimeZoneInformation')
    END
  END 

  INCLUDE('SunTime.inc'),ONCE
  
!!!<summary>This method is required and must be the first method called.  All parameters are required except the start date.
!!!If no start date provided, the method assumes today.</summary>
!!!<param name="*DECIMAL xLat"></param>
!!!<param name="*DECIMAL xLon"></param>
!!!<param name="*DECIMAL xOffset"></param>
!!!<param name="*DECIMAL xDate"></param>
!!!<returns></returns>
SunClass.Init        PROCEDURE(*DECIMAL xLat,*DECIMAL xLon,LONG xOffSet,<LONG xDate>)     !Call with Sunrise or Sunset desired and location
  CODE
  SELF.Latitude = xLat                                                        !Set the current latitdue value
  SELF.Longitude = xLon                                                       !Set the current longitude value
  SELF.LocalOffset = xOffSet                                                  !Set the GMT offset, if any
  IF OMITTED(xDate)
    SELF.N = TODAY() - DATE(1,1,YEAR(TODAY())) + 1                            !Calculate the day of the year from today
  ELSE
    SELF.N = xDate - DATE(1,1,YEAR(xDate)) + 1                                !Calculate the day of the year from input
  END
  
  
!!!<summary>This is a private method that converts degrees to radians</summary>
!!!<param name="(*DECIMAL xAngle)"></param>
!!!<returns>REAL</returns>
SunClass.Deg2Rad     PROCEDURE(*DECIMAL xAngle)!,REAL,PROC,PRIVATE            !Convert degrees to radians
RetVal                REAL

  CODE
  RetVal = Pi * xAngle / 180
  RETURN RetVal
  
!!!<summary>This is a private method that converts radians to degrees</summary>
!!!<param name="(*DECIMAL xAngle)"></param>
!!!<returns>REAL</returns>
SunClass.Rad2Deg     PROCEDURE(*DECIMAL xAngle)!,REAL,PROC,PRIVATE            !Convert radians to degrees
RetVal                REAL

  CODE
  RetVal = 180 * xAngle / Pi
  RETURN RetVal
  
!!!<summary>This is a private method that fixes the value based on min and max values.</summary>
!!!<param name="(*DECIMAL xValue)"></param>
!!!<param name="(*DECIMAL xMin)"></param>
!!!<param name="(*DECIMAL xMax)"></param>
!!!<returns>REAL</returns>
SunClass.FixValue    PROCEDURE(*DECIMAL xValue,LONG xMin,LONG xMax)!,REAL,PROC,PRIVATE 
RetVal                REAL

  CODE
  RetVal = xValue                                                             !Assign return value
  LOOP WHILE RetVal < xMin                                                    !Loop until return value is not less than passed minimum
    RetVal += xMax - xMin                                                     !Increment while loop is true
  END
  LOOP WHILE RetVal >= xMax                                                   !loop until return value is not greater than passed maximum
    RetVal -= xMax - xMin                                                     !Decrement while loop is true
  END
  RETURN RetVal                                                               !Return the unchanged or changed value, depending
  
!!!<summary>Since Clarion has no Floor() function, this method provides one.</summary>
!!!<param name="(SREAL x)"></param>
!!!<returns>LONG</returns>
SunClass.Floor       PROCEDURE(SREAL xVal)!,LONG                              !Our own Floor() function since Clarion does not have one.
RetVal                LONG

  CODE
  RetVal = xVal                                                               !Assignment strips out the decimal portion during data conversion
  IF xVal < 0 AND xVal <> RetVal                                              !If passed value less than zero and its not equal to assignment 
    RetVal -= 1                                                               !Decrement whole number
  END 
  RETURN RetVal                                                               !Return the new value
  
!!!<summary>This method is called by other methods and is not required to be called directly</summary>
!!!<param name="()"></param>
!!!<returns>Clarion Standard Time</returns>
SunClass.CalcTime    PROCEDURE()                                              !Method does the actual calculation and returns Clarion standard time
RetVal                  LONG 
X                       DECIMAL(10,5)
Days                    STRING('SunMonTueWedThuFriSat'),STATIC
Mons                    STRING('JanFebMarAprMayJunJulAugSepOctNovDec'),STATIC
DSub                    UNSIGNED,AUTO
MSub                    UNSIGNED,AUTO
TZ                      LIKE(TimeZoneInfo),AUTO 
Bias                    LONG,AUTO
BiasSign                BYTE,AUTO
Now                     LONG,AUTO

  CODE
  SELF.LongHr = SELF.Longitude / 15.0                                         !convert the longitude to hour value and calculate an approximate time
  IF SELF.RiseOrSet = 1                                                       !Sunrise time desired
    SELF.T = SELF.N + ((6 - SELF.LongHr) / 24)                                !
  ELSE                                                                        !Sunset time desired
    SELF.T = SELF.N + ((18 - SELF.LongHr) / 24)                               !
  END
  SELF.M = (0.9856 * SELF.T) - 3.289                                          !calculate the Sun's mean anomaly
  X = 2 * SELF.M
  SELF.L = SELF.M + (1.916 * SIN(SELF.Deg2Rad(SELF.M))) + (0.020 * SIN(SELF.Deg2Rad(X))) + 282.634   !calculate the Sun's true longitude
  SELF.L = SELF.FixValue(SELF.L, 0, 360)                                      !L potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
  X = ATAN(0.91764 * TAN(SELF.Deg2Rad(SELF.L)))                               !calculate the Sun's right ascension
  SELF.RA = SELF.Rad2Deg(X)                                                   !
  SELF.RA = SELF.FixValue(SELF.RA, 0, 360)                                    !RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
  SELF.Lquadrant  = SELF.Floor(SELF.L / 90) * 90                              !right ascension value needs to be in the same quadrant as L
  SELF.RAquadrant = SELF.Floor(SELF.RA / 90) * 90                             !
  SELF.RA = SELF.RA + (SELF.Lquadrant - SELF.RAquadrant)                      !
  SELF.RA = SELF.RA / 15                                                      !right ascension value needs to be converted into hours
  SELF.sinDec = 0.39782 * SIN(SELF.Deg2Rad(SELF.L))                           !calculate the Sun's declination
  SELF.cosDec = COS(ASIN(SELF.sinDec))                                        !
  X = Zenith / 1000                                                           !
  SELF.cosH = (COS(SELF.Deg2Rad(X)) - (SELF.sinDec * SIN(SELF.Deg2Rad(SELF.Latitude)))) / (SELF.cosDec * COS(SELF.Deg2Rad(SELF.Latitude)))  !calculate the Sun's local hour angle
  X = ACOS(SELF.cosH)                                                         !finish calculating H and convert into hours
  IF SELF.RiseOrSet = 1
    SELF.H = 360 - SELF.Rad2Deg(X)
  ELSE
    SELF.H = SELF.Rad2Deg(X)                                                  !
  END
  SELF.H = SELF.H / 15                                                        !finish calculating H and convert into hours
  SELF.Ti = SELF.H + SELF.RA - (0.06571 * SELF.T) - 6.622                     !calculate local mean time of rising/setting
  SELF.UT = SELF.Ti - SELF.LongHr                                             !adjust back to UTC
  SELF.UT = SELF.UT + SELF.localOffset                                        !convert UT value to local time zone of latitude/longitude
  CASE GetTimeZoneInformation (TZ)
  OF TIME_ZONE_ID_UNKNOWN
    Bias = 0
  OF TIME_ZONE_ID_STANDARD
    Bias = TZ.StandardBias
  OF TIME_ZONE_ID_DAYLIGHT
    Bias = CHOOSE (TZ.DayLightDate.wMonth <> 0, TZ.DayLightBias, 0)
  END
  Bias += TZ.Bias
  SELF.UT = SELF.FixValue(SELF.UT, 0, 24)                                     !UT potentially needs to be adjusted into the range [0,24) by adding/subtracting 24
  RetVal = INT(ROUND(SELF.UT * 3600,1))                                       !
  RetVal *= 100                                                               !Convert to standard Clarion time
  RetVal += (Bias * 100)
  RETURN RetVal

!!!<summary>This method computes the sunrise.</summary>
!!!<param name="()"></param>
!!!<returns>Clarion Standard Time</returns>
SunClass.Sunrise    PROCEDURE()!,LONG,PROC,VIRTUAL
RetVal                LONG

  CODE
  SELF.RiseOrSet = True
  RetVal = SELF.CalcTime()
  RETURN RetVal
  
!!!<summary>This method computes the sunset.</summary>
!!!<param name="()"></param>
!!!<returns>Clarion Standard Time</returns>
SunClass.Sunset     PROCEDURE()!,LONG,PROC,VIRTUAL
RetVal                LONG

  CODE
  SELF.RiseOrSet = False
  RetVal = SELF.CalcTime()
  RETURN RetVal
 
