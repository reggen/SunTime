!ABCIncludeFile(SUN)

!<HELP>
!<CLASS>SunClass</CLASS>
!<Parent>None</PARENT>
!<COMPOSITION</COMPOSITION>
!<TYPE>FORM</TYPE>
!<STATUS></STATUS>
!<DEMO></DEMO>
!<DLL></DLL>
!<HEADER>SunTime.INC</HEADER>
!<CODE>SunTime.CLW</CODE>
!<TLB></TLB>
!<TEMPLATE>SunTime.TPL</TEMPLATE>
!<EXAMPLE></EXAMPLE>
!<REVISED>Oct 27, 2014</REVISED>
!<DOC>This class computes the sun rise and sunset time for a given location expressed 
!as a latitude and longitude with any offset (like daylight savings) based on a passed 
!in date.
!
!Once the class is instnatiated, you must call the Init method as follows:
!
!InstanceName.Init(Latitude, Longitude, OffSet, <Date>)  See the method docs for details.
!
!After this, all you need to compute the sunrise and/or sunset is call these methods:
!
!SunRiseTime = InstanceName.SunRise()
!SunSetTime = InstanceName.SunSet()
!</DOC>
!/HELP>

Official            EQUATE(90833)
Civil               EQUATE(96000)
Nautical            EQUATE(102000)
Astro               EQUATE(108000)
Zenith              EQUATE(Official)
Pi                  EQUATE(3.1415926535898)
HiTime              EQUATE(8640000)   !11:59:59 PM  Hundreths of seconds since midnight
Midnight            EQUATE(1)         !12:00:00 AM  Zero is "no time" 
TZIDUnknown         EQUATE(0)         !Daylight saving time not used because no transition dates or auto adjustment is disabled
TZIDStandard        EQUATE(1)         !System is operating in the range covered by TimeZoneInfo.StandardDate 
TZIDDaylight        EQUATE(2)         !System is operating in the range covered by TimeZoneInfo.DaylightDate 

SunClass            CLASS,TYPE,MODULE('SunTime.clw'),LINK('SunTime.clw',_SunLinkMode_),DLL(_SunDLLMode_)
Latitude              DECIMAL(10,5)                                         !Latitude
Longitude             DECIMAL(10,5)                                         !Longitude (west values are negative)
InDate                LONG                                                  !Input date, defaults to TODAY()
N                     LONG                                                  !Day of the year
LongHr                DECIMAL(10,5)                                         !Longitude hour
T                     DECIMAL(10,5)                                         !Longitudinal time
RiseOrSet             LONG                                                  !True if rising time desired
M                     DECIMAL(10,5)                                         !Sun's mean anomaly
L                     DECIMAL(10,5)                                         !Sun's true longitude
RA                    DECIMAL(10,5)                                         !Sun's right ascension
LQuadrant             DECIMAL(10,5)
RAQuadrant            DECIMAL(10,5)
sinDec                DECIMAL(10,5)                                         !Sun's declination sine
cosDec                DECIMAL(10,5)                                         !Sun's declination cosine
cosH                  DECIMAL(10,5)                                         !Sun's local hour angle
H                     DECIMAL(10,5)                                         !Hours
Ti                    DECIMAL(10,5)                                         !Local mean time of rising or setting
UT                    DECIMAL(10,5)                                         !UTC
LocalOffset           LONG                                                  !local time offset
LocalT                DECIMAL(10,5)                                         !Local time 

Init                  PROCEDURE(*DECIMAL xLat,*DECIMAL xLon,LONG xOffSet,<LONG xDate>),VIRTUAL     !Call with location, offset and optional date (default to today)
Deg2Rad               PROCEDURE(*DECIMAL xAngle),REAL,PROC,PRIVATE
Rad2Deg               PROCEDURE(*DECIMAL xAngle),REAL,PROC,PRIVATE 
FixValue              PROCEDURE(*DECIMAL xValue,LONG xMin,LONG xMax),REAL,PROC,PRIVATE
Floor                 PROCEDURE(SREAL xVal),LONG,PROC,PRIVATE
CalcTime              PROCEDURE(),LONG,PROC,VIRTUAL                         !Calculates sunrise or sunset and returns Clarion standard time
Sunrise               PROCEDURE(),LONG,PROC,VIRTUAL                         !Calculate sunrise time and returns Clarion standard time
Sunset                PROCEDURE(),LONG,PROC,VIRTUAL                         !Calculate sunset time and returns Clarion standard time
                    END
