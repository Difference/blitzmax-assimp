SuperStrict
Import "allfilesenumerator.bmx"

Const FIXESREMARK:String = "smallfix"

Local filelist:TList  = New TList
Local skipExt:TList = New TList

skipExt.addlast("exe") 

skipExt.addlast("svn-base")
skipExt.addlast("i")
skipExt.addlast("o")
skipExt.addlast("s")
skipExt.addlast("")
skipExt.addlast("bak")


enumFiles(filelist,AppDir,skipExt)

Local filearray:Object[] = filelist.toarray()

Local fixesList:TList = New TList


For Local filename:String = EachIn filearray

	FindFixes(filename,fixesList)

Next

For Local fi:tFixinfo = EachIn fixesList
	
	fi.List()

Next




Function FindFixes(filename:String,fixlist:TList)


	Local f:TStream = OpenFile(filename)
	
	If Not f RuntimeError "Can't open: " + filename
	
	Local linenr:Int 
	While Not Eof(f)
		Local l:String = ReadLine(f)
		
		If Instr(Lower(l),FIXESREMARK)
		
			fixlist.addlast( New tFixInfo.Create(filename,linenr,l))
		
			'DebugLog filename + " " + l
		
		EndIf
		linenr:+1
	Wend


End Function


Type tFixInfo
	Field filename:String
	Field linenumber:Int
	Field fixtext:String
	
	Method list()
	
		Local inf:String
		
		inf:+ filename + ": ~n" 
		inf:+ "Line: " + linenumber + "~n"
		inf:+ fixtext + "~n"
		
		Print inf
	
	End Method
	
	
	Method Create:tFixInfo(filename:String,linenumber:Int,fixtext:String)
	
		Self.filename = StripDir(filename)
		Self.linenumber = linenumber
		Self.fixtext = Trim(fixtext)
	
		Return Self
	End Method 
	
End Type

