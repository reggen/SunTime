#TEMPLATE(Suntime,'RADFusion Suntime Template. Version 1.0 May 30, 2012'),FAMILY('ABC')
#! Copyright 2012 by RADFusion International, LLC. 
#!
#! ABC compliant wrapper for SunClass class 
#!
#EXTENSION(SuntimeABC,'RFI Global Suntime Class'),APPLICATION
#DECLARE(%SuntimeVersion)
#BOXED('Default prompts'),AT(0,0),WHERE(%False),HIDE
  #INSERT (%OOPHiddenPrompts(ABC))
#ENDBOXED
#!-------------------------------------------------------------------------
#!region Prepare structure
#PREPARE                                                                        #!Set class name in case developers never edits the name
  #SET(%SunVersion,'1.0.0')                                                 #!Current version update for existing installs
  #CALL(%ReadABCFiles(ABC))                                                     #!Read ABC class headers if needed
  #CALL(%SetClassDefaults(ABC),'ST','ST','SunClass')                            #!Set local name from libsrc class name
#ENDPREPARE                                                                     #! end #PREPARE 
#!end region
#!-------------------------------------------------------------------------
#ATSTART                                                                        #!Execute this code before #EXTENSION template generates its code
  #CALL(%ReadABCFiles(ABC))                                                     #!Read ABC class headers if needed
  #CALL(%SetClassDefaults(ABC),'ST','ST','SunClass')                            #!Set local name from libsrc class name
  #DECLARE(%SunInstance)
  #SET(%SunInstance,%ThisObjectName)
#ENDAT                                                                          #! end #ATSTART
#!-------------------------------------------------------------------------
#AT(%BeforeGenerateApplication)                                                 #!For exporting the class
  #CALL(%AddCategory(ABC),'SUN')                                           #!The parameter in the !ABCIncludeFile comment in the INC file
  #CALL(%SetCategoryLocation(ABC),'SUN','SUN')                        #!Used for DLLMode_ and LinkMode_ pragmas (see defines tab in project editor)
#ENDAT                                                                          #! end #AT(%BeforeGenerateApplication)
#!-------------------------------------------------------------------------
#INSERT(%RADFusionLogo)
#PROMPT('Suntime Version',@S10),%SunVersion,DEFAULT(%SunVersion),PROP(PROP:READONLY,1),PROP(PROP:FontColor,000FFFFH),PROP(PROP:Color,0FF0000H) #!Display only
#BUTTON('Global Suntime &Instance'),PROP(PROP:FontColor,7B0012H),PROP(PROP:FontStyle,400),AT(,,90,20)                                   #!Global object dialog
  #INSERT(%RADFusionLogo)
  #BUTTON('&Sun Class'),AT(4,,186,20),PROP(PROP:FontColor,0C79A3H),PROP(PROP:FontStyle,400) #!Display a button
    #WITH(%ClassItem,'ST')                                                      #!Show the global instance name
      #INSERT(%GlobalClassPrompts(ABC))                                         #!Add the class prompt dialog.
    #ENDWITH                                                                    #! end #WITH(%ClassItem,'ST')
  #ENDBUTTON                                                                    #! end #BUTTON('&Sun Class')
#ENDBUTTON                                                                         #! end #TAB('Local &Objects')
#!-------------------------------------------------------------------------
#BUTTON('Sun&time Base Class'),PROP(PROP:FontColor,7B0012H),PROP(PROP:FontStyle,400),AT(,,,20)                                           #!Global class dialog
  #INSERT(%RADFusionLogo)
  #PROMPT('&Default class:',FROM(%pClassName)),%ClassName,DEFAULT('SunClass'),REQ
  #DISPLAY()
  #BOXED(' Usage '),PROP(PROP:Bevel,-1)
    #DISPLAY('If you have another class you wish to use instead, select it from the list or use the default shown.'),AT(,,175,16),PROP(PROP:FontColor,0C79A3H)
  #ENDBOXED
#ENDBUTTON                                                                         #! end #TAB('C&lasses')
#!-------------------------------------------------------------------------
#AT(%GatherObjects)                                                             #!Ensure objects are known and loaded in memory
  #CALL(%ReadABCFiles(ABC))                                                     #!Read ABC class headers if needed
  #CALL(%AddObjectList(ABC),'ST')                                               #!Add the template object to object list 
  #ADD(%ObjectList,%ThisObjectName)                                             #!Add the object to the list of all objects
  #SET(%ObjectListType,'SunClass')                                              #!Set the base class name
#ENDAT                                                                          #! end #AT(%GatherObjects)
#!-------------------------------------------------------------------------
#AT(%GlobalDataClasses)                                                        #!At global class embed point
  #CALL(%SetClassItem(ABC), 'ST')                                               #!Set the current instance
  #INSERT(%GenerateClass(ABC), 'ST','Global instance and definition'),NOINDENT  #!and generate class instance into column 1, but preserve indent of template code
#ENDAT                                                                          #! end #AT(%GloballDataClasses)
#!-------------------------------------------------------------------------
#AT(%DebugerMethodCodeSection),PRIORITY(5000),DESCRIPTION('Parent Call'),WHERE(%ParentCallValid())  #!Add parent call embed point
  #CALL(%GenerateParentCall(ABC))                                               #!Generate the parent call
#ENDAT                                                                          #! end #AT(%DebugerClassMethodCodeSection,%ApplicationTemplateInstance)
#!-------------------------------------------------------------------------
#IF(%BaseClassToUse())                                                          #!If there is a base class
  #CALL(%FixClassName(ABC),%BaseClassToUse())                                   #!Assign the base class, cleaning up any errors
  #FOR(%pClassMethod)                                                           #!For every method in this class
    #FOR(%pClassMethodPrototype),WHERE(%MethodEmbedPointValid())                #!and the prototype is not private  
      #CALL(%SetupMethodCheck(ABC))                                             #!ensure the proper instance, any overrides, etc are generated
      #EMBED(%SunClassMethodDataSection,'Sun Class Method Data Section'),%pClassMethod,%pClassMethodPrototype,LABEL,DATA,PREPARE(,%FixClassName(%FixBaseClassToUse('SunClass'))),TREE(%GetEmbedTreeDesc('SUN','DATA'))
      #?CODE                                                                    #<!Add CODE statement for method
      #EMBED(%SunClassMethodCodeSection,'SunClass Method Code Section'),%pClassMethod,%pClassMethodPrototype,PREPARE(,%FixClassName(%FixBaseClassToUse('SunClass'))),TREE(%GetEmbedTreeDesc('SUN','CODE'))
      #CALL(%CheckAddMethodPrototype(ABC),%ClassLines)                          #!Generate the prototype and structure for each method
    #ENDFOR                                                                     #! end #FOR(%pClassMethodPrototype),WHERE(%MethodEmbedPointValid())
  #ENDFOR                                                                       #! end #FOR(%pClassMethod)
  #CALL(%GenerateNewLocalMethods(ABC),'SUN',%True)                              #!Generate any new methods code from class dialog, if present
#ENDIF                                                                          #! end #IF(%BaseClassToUse())
#!-------------------------------------------------------------------------
#AT(%GlobalData)
  #INSERT(%GenerateClass(ABC),'ST'),NOINDENT
#ENDAT 
#!-------------------------------------------------------------------------
#AT(%ProgramProcedures), WHERE(%ProgramExtension<>'DLL' OR ~%GlobalExternal)
  #CALL(%GenerateVirtuals(ABC), 'ST', 'Global Objects|SunClass Template', '%GlobalEmbedVirtuals(Suntime)', %TRUE)
#ENDAT
#!-------------------------------------------------------------------------
#EXTENSION(SunTimeProcedure,'RFI Local Suntime extension'),PROCEDURE,REQ(SuntimeABC),PRIMARY('Latitude and Longitude file',OPTKEY),DESCRIPTION('File with location data for sunrise and sunset calculations:' & %SunTable)
#INSERT(%RADFusionLogo)
#PROMPT('Table containing location:',FILE),%SunTable,REQ
#ENABLE(%SunTable)
  #BOXED(' Suntime Setup '),PROP(PROP:Bevel,1)
    #PROMPT('Start Date:',EXPR),%SunDate,DEFAULT('TODAY()')
    #PROMPT('Latitude:',FIELD(%SunTable)),%SunLat,REQ
    #PROMPT('Longitude:',FIELD(%SunTable)),%SunLon,REQ
    #PROMPT('Offset:',FIELD(%SunTable)),%SunOffset,DEFAULT('0')
  #ENDBOXED
#ENDENABLE
#!-------------------------------------------------------------------------
#AT (%WindowManagerMethodCodeSection,'Init','(),BYTE'),PRIORITY(7500)
Access:%SunTable.Next()                                                   #<!Assumes a one record file
  #IF (%SunDate<>'TODAY()')
%SunInstance.Init(%SunLat,%SunLon,%SunOffset,%SunDate)                    #<!Intialize the Sun class with passed start date
  #ELSE
%SunInstance.Init(%SunLat,%SunLon,%SunOffset)                             #<!Intialize the Sun class with omitted start date, which means TODAY()
  #ENDIF
#ENDAT  
#!-------------------------------------------------------------------------
#!-Group code here---------------------------------------------------------
#!-------------------------------------------------------------------------
#GROUP(%GlobalEmbedVirtuals, %TreeText, %DataText, %CodeText)
#EMBED(%SunClassDataSection,'SunClass Method Data Section'), %ApplicationTemplateInstance,%pClassMethod,%pClassMethodPrototype,TREE(%TreeText & %DataText)
  #?CODE
  #EMBED(%SunClassCodeSection,'SunClass Method Code Section'), %ApplicationTemplateInstance,%pClassMethod,%pClassMethodPrototype,TREE(%TreeText & %CodeText)
#!-------------------------------------------------------------------------
#GROUP(%ParentCallValid),AUTO
#DECLARE(%RVal)
#CALL(%ParentCallValid(ABC)),%RVal
#RETURN(%RVal)
#!-------------------------------------------------------------------------
#!#GROUP(%ODS,*%SymbolToPass)                                                      #!Example debug group, salt to taste
#!#RUNDLL('ODS.DLL','ODS','Debugview message: ' & %SymbolToPass),WIN32,RELEASE     #!ODS.DLL should be in bin - not shipped, search Clarion Mag for template debugger
#!-------------------------------------------------------------------------
#GROUP(%RADFusionLogo)
  #BOXED   (''),AT(5,0,184,93),PROP(PROP:Bevel,-1)
    #IMAGE('RADFusionLight800.jpg'), AT(5, 1, 183, 92)
  #ENDBOXED
#!-------------------------------------------------------------------------
