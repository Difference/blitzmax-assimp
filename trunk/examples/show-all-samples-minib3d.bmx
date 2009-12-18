SuperStrict

Import "fileenumerator.bmx"
'Import "minib3dsf/minib3d.bmx"
Import "assimpminib3d.bmx"


Local width:Int=640,height:Int=480,depth:Int=16,mode:Int=0

AppTitle = "Show all assimp samples"

' Set up camera and lights
Graphics3D width,height ,depth,mode

Local cam:TCamera=CreateCamera()
PositionEntity cam,0,150,-145

CameraClsColor cam,200,200,255
CameraRange cam,0.1,1000

Local light:TLight=CreateLight()
RotateEntity light,45,0,0


' get some files to show
Local filelist:TList  = New TList
Local skipExt:TList = New TList

skipExt.addlast("xml") ' assimp crash?
skipExt.addlast("ac") ' assimp crash?
skipExt.addlast("irrmesh") ' minib3d parallels crash
skipExt.addlast("md2") ' minib3d parallels crash
skipExt.addlast("mdl") '<- J.I joe crashes assimp
skipExt.addlast("nff") '<- dodecahedron.nff crashes assimp

enumFiles(filelist,"../assimp/test/models",skipExt)

Local filearray:Object[] = filelist.toarray()
Local fileNUmber:Int = 0

If filearray.length = 0 Then
	Notify "No files to show, please choose a different directory"
	End
EndIf

Local currentFile:String

Local mesh:tMesh = CreateCube()

PointEntity cam,mesh

' slideshow
Local go:Int =1
Local lastslideTime:Int = MilliSecs()
Local slideDuration:Int = 1000
Local slideshow:Int = True


While Not KeyDown(KEY_ESCAPE)		


	If slideshow
		If MilliSecs() > lastslideTime + slideDuration
			go  =1
		EndIf
	EndIf	



	If KeyHit(KEY_SPACE) Or go = 1 Then
		go = 0
		If fileNUmber > filearray.length -1
			fileNUmber = 0
		EndIf

		DebugLog String filearray[fileNUmber]

		If aiIsExtensionSupported(String filearray[fileNUmber])

			currentFile = String filearray[fileNUmber]
			If mesh Then FreeEntity mesh
			' the assimp loader
			mesh = AssimpLoadMesh(String filearray[fileNUmber])
			
		EndIf

			lastslideTime = MilliSecs()


		fileNUmber:+1

	EndIf
	
	If mesh 
		TurnEntity mesh,0,1,0
	EndIf
	

	' control camera
	MoveEntity cam,KeyDown(KEY_D)-KeyDown(KEY_A),0,KeyDown(KEY_W)-KeyDown(KEY_S)
	TurnEntity cam,KeyDown(KEY_DOWN)-KeyDown(KEY_UP),KeyDown(KEY_LEFT)-KeyDown(KEY_RIGHT),0
	'DebugStop
	RenderWorld
	Text 0,0,fileNUmber + "/" + filearray.length + " " + StripDir(currentFile)

	Flip
	


Wend
End



