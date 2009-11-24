SuperStrict


Import scheutz.assimp
Import sidesign.minib3d

Import "fileenumerator.bmx"
Import "fitanimmesh.bmx"


Local width:Int=640,height:Int=480,depth:Int=16,mode:Int=0

AppTitle = "Show all assimp samples"

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

'skipExt.addlast("hmp")
skipExt.addlast("xml")
'skipExt.addlast("nff")
skipExt.addlast("ac")
'enumFiles(filelist,"../assimp/test/models/stl",skipExt)
'e'numFiles(filelist,"../assimp/test/models/obj",skipExt)
enumFiles(filelist,"../assimp/test/models",skipExt)
'enumFiles(filelist,"../assimp/test/models/dxf",skipExt)
'enumFiles(filelist,"C:\data\My Dropbox",skipExt)
'enumFiles(filelist,"../assimp/test/models",skipExt)
'enumFiles(filelist,"./",skipExt)




Local filearray:Object[] = filelist.toarray()
Local fileNUmber:Int = 0

If filearray.length = 0 Then
	Notify "No files to show, please choose a different directory"
	End
EndIf

Local sp:tentity = CreateSphere()


ScaleEntity sp, 24,24,24
EntityAlpha sp, 0.3

Local mesh:tMesh = CreateCube()

PointEntity cam,mesh

' slideshow
Local go:Int =1
Local lastslideTime:Int = MilliSecs()
Local slideDuration:Int = 1000
Local slideshow:Int = True



Local currentFile:String

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


			mesh = aiLoadMiniB3D(String filearray[fileNUmber])
			
			
			If mesh
			'	EntityPickMode mesh,2
			'	fitAnimmesh mesh,-100,-100,-100,200,200,200,True	
			EndIf
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
	
	
 
	RenderWorld
	Text 0,0,fileNUmber + "/" + filearray.length + " " + StripDir(currentFile)

	Flip
	


Wend
End


Function aiLoadMiniB3D:tMesh(filename:String)

	Local scene:aiScene = New aiScene

	aiSetImportPropertyInteger(AI_CONFIG_PP_SBP_REMOVE, aiPrimitiveType_LINE | aiPrimitiveType_POINT )

	Local flags:Int
	
'	aiProcess_SplitLargeMeshes | ..
'	aiProcess_ValidateDataStructure | ..
'	aiProcess_ImproveCacheLocality | ..
'	aiProcess_RemoveRedundantMaterials | ..	
'	aiProcess_JoinIdenticalVertices | ..	
'	aiProcess_ConvertToLeftHanded | ..
'	aiProcess_ConvertToLeftHanded | ..	
		
	flags:Int = ..
	aiProcess_CalcTangentSpace | ..
	aiProcess_Triangulate | ..
	aiProcess_GenNormals | ..
	aiProcess_SortByPType | ..
	aiProcess_FindDegenerates | ..
	aiProcess_FindInvalidData | ..
	aiProcess_GenUVCoords | ..
	aiProcess_TransformUVCoords | ..
	aiProcess_PreTransformVertices
		


	If scene.ImportFile(filename, flags)


	
	'--- Make brushes ---------------------------------------------------------
	Local brushes:tBrush[scene.NumMaterials]
	
	Local i:Int
	
	For Local mat:aimaterial = EachIn scene.Materials
	
'Rem
'Rem
		DebugLog " "
		DebugLog " -     --------   Material Name " + mat.GetMaterialName()
		DebugLog " -     --------   mat.IsTwoSided() " + mat.IsTwoSided()
		DebugLog " -     --------   mat.GetShininess() " + mat.GetShininess()
		DebugLog " -     --------   mat.GetAlpha() " + mat.GetAlpha()
'E'ndRem	
	
	
		Local names:String[] = mat.GetPropertyNames()
	
		For Local s:String = EachIn names
			DebugLog "Property: *" + s + "*"
			
			'DebugLog "matbase " + mat.GetFloatValue(s)
			
			Select s
				Case AI_MATKEY_TEXTURE_BASE
					DebugLog "matbase " +  mat.GetMaterialString(s)
			End Select
			
		Next
'End Rem	
	
	
		Local DiffuseColors:Float[] = mat.GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)	
		
		brushes[i] = CreateBrush(mat.GetDiffuseRed()*255,mat.GetDiffuseGreen()*255,mat.GetDiffuseBlue()*255)
	
		' seems alpha comes in different places denpending om model format.
		' seems wavefront obj alpha doen't load
	'	BrushAlpha brushes[i],mat.GetAlpha()' * mat.GetDiffuseAlpha() (might be 0 so not good)
		
		BrushShininess brushes[i],mat.GetShininess()
		
		
		
		If mat.IsTwoSided()
	'		BrushFX brushes[i] ,16
		EndIf

		Local texFilename:String = mat.GetMaterialTexture()
	
	
		DebugLog "TEXTURE filename: " + texFilename
	
		If Len(texFilename)
		
			' remove currentdir prefix, but leave relative subfolder path intact
			If  texFilename[..2] = ".\" Or texFilename[..2] = "./"
				texFilename = texFilename [2..]
			EndIf
			
			'assume the texture names are stored relative to the file
			texFilename  = ExtractDir(filename) + "/" + texFilename


			If Not FileType(texFilename  )
				texFilename   = ExtractDir(filename) + "/" + StripDir(texFilename)
			EndIf

			DebugLog texFilename
			
			
			If FileType(texFilename  )
				'DebugStop
				Local tex:TTexture=LoadTexture(texFilename)	
				If tex
					BrushTexture brushes[i],tex	
				EndIf	
				
			EndIf
			
		EndIf

		i:+1
	Next
	
	
	
	'--- Make mesh ---------------------------------------------------------	
	
	Local mesh:tMesh = CreateMesh()
	
	
		DebugLog "scene.numMeshes:  "  + scene.numMeshes
	
	
	For Local m:aimesh = EachIn scene.meshes

		Local surf:tSurface = CreateSurface(mesh,brushes[m.MaterialIndex])
		
		' vertices, normals and texturecoords
		For Local i:Int = 0 To m.NumVertices - 1
		
		
			'DebugLog  m.VertexX(i) + " , "  + m.VertexY(i) + " , "  + m.VertexZ(i)

			Local index:Int


			index = AddVertex(surf,m.VertexX(i) ,m.VertexY(i),m.VertexZ(i))			
			

			If m.HasNormals()
				VertexNormal(surf,index,m.VertexNX(i) ,m.VertexNY(i),m.VertexNZ(i))
			EndIf
			
			If m.HasTextureCoords(0)
				VertexTexCoords(surf,index,m.VertexU(i) ,m.VertexV(i),m.VertexW(i))
			EndIf

			If m.HasTextureCoords(1)
				VertexTexCoords(surf,index,m.VertexU(i,1) ,m.VertexV(i,1),m.VertexW(i,1))
			EndIf

		Next
	

		For Local i:Int = 0 To m.NumFaces - 1
		
		
			'DebugLog  m.TriangleVertex(i,0) + " , "  + m.TriangleVertex(i,1) + " , "  + m.TriangleVertex(i,2)
		
		
			' this check is only in because assimp seems to be returning out of range indexes on rare occtions
			' with aiProcess_PreTransformVertices on.
			Local validIndex:Int = True
		
			If m.TriangleVertex(i,0) >=m.NumVertices Then validIndex = False
			If m.TriangleVertex(i,1) >=m.NumVertices Then validIndex = False
			If m.TriangleVertex(i,2) >=m.NumVertices Then validIndex = False				
		
			If validIndex
				AddTriangle(surf, m.TriangleVertex(i,0) ,  m.TriangleVertex(i,1) , m.TriangleVertex(i,2))
			Else
				DebugLog "TriangleVertex index was out of range for triangle nr. : " + i
				DebugLog "indexes: " + m.TriangleVertex(i,0) + " , "  + m.TriangleVertex(i,1) + " , "  + m.TriangleVertex(i,2)
			
			EndIf
		Next

	Next
	
	
	

	
		Return mesh	

	Else
		DebugLog "nothing imported"
	EndIf

	Scene.ReleaseImport()

End Function

