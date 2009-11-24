SuperStrict


Import scheutz.assimp
Import sidesign.minib3d
Import "fitanimmesh.bmx"
Import "fileenumerator.bmx"

Local width:Int=640,height:Int=480,depth:Int=16,mode:Int=0


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
skipExt.addlast("nff")
'enumFiles(filelist,"../assimp/test/models/obj",skipExt)
'enumFiles(filelist,"../assimp/test/models/smd",skipExt)
'enumFiles(filelist,"C:\data\My Dropbox",skipExt)
enumFiles(filelist,"../assimp/test/models",skipExt)
'enumFiles(filelist,"./",skipExt)

Local path$'=RequestDir("Select a Folder",CurrentDir())


If FileType(path$) = 2

	enumFiles(filelist,path,skipExt)

EndIf


Local filearray:Object[] = filelist.toarray()
Local fileNUmber:Int = 0

If filearray.length = 0 Then
	Notify "No files to show, please choose a different directory"
	End
EndIf


Local sp:tentity = CreateSphere()
'EntityAlpha sp, 0.4

'ScaleEntity sp, 24,24,24


Local mainEnt:tentity = CreateCube()

PointEntity cam,mainEnt

' used by fps code
Local old_ms:Int=MilliSecs()
Local renders:Int
Local fps:Int


'Notify "here"

Local go:Int =1
Local lastslideTime:Int = MilliSecs()
Local slideDuration:Int = 2000
Local slideshow:Int '= True

Local currentModel:String  ="Press space to load the next model"

Function FlipRot(e:tEntity,axis:Int)
	If e = Null Then Return 
	Local cc:Int=CountChildren(e)

	If cc
		For Local c:Int =1 To cc
			FlipRot(GetChild(e,c),axis)
		Next	
	EndIf



	Local rotX:Float = EntityPitch(e)
	Local rotY:Float = EntityYaw(e)
	Local rotZ:Float = EntityRoll(e)
	
	Select axis	
	
		Case 1
			rotX = -rotX
		Case 2
			rotY = -rotY		
		Case 3
			rotZ = -rotZ
	End Select

	
	
	

	RotateEntity e,rotX,rotY,rotZ



End Function



While Not KeyDown(KEY_ESCAPE)		
 

	If slideshow
		If MilliSecs() > lastslideTime + slideDuration
			go  =True
		EndIf
	EndIf	

	If KeyHit(KEY_X)
		FlipRot mainEnt , 1
	EndIf

	If KeyHit(KEY_Y)
		FlipRot mainEnt , 2
	EndIf

	If KeyHit(KEY_Z)
		FlipRot mainEnt , 3
	EndIf


	If KeyHit(KEY_U)
		UpdateEntityNormals mainEnt
	EndIf
	
	If KeyHit(KEY_F)
		FlipEntity mainEnt
	EndIf	


	If KeyHit(KEY_9)
		ScaleEntity  mainEnt , -1,-1,-1
	EndIf




	If KeyHit(KEY_SPACE) Or go = 1 Then
		go = 0
		If fileNUmber > filearray.length -1
			fileNUmber = 0
		EndIf

		DebugLog String filearray[fileNUmber]

		If aiIsExtensionSupported(String filearray[fileNUmber])

			currentModel = String filearray[fileNUmber]

			If mainEnt Then FreeEntity mainEnt


			mainEnt = aiLoadMiniB3D(String filearray[fileNUmber])
			
		EndIf

			lastslideTime = MilliSecs()


		fileNUmber:+1

	EndIf
	
	If mainEnt
		TurnEntity mainEnt,0,1,0
	EndIf
	

	' control camera
	MoveEntity cam,KeyDown(KEY_D)-KeyDown(KEY_A),0,KeyDown(KEY_W)-KeyDown(KEY_S)
	TurnEntity cam,KeyDown(KEY_DOWN)-KeyDown(KEY_UP),KeyDown(KEY_LEFT)-KeyDown(KEY_RIGHT),0
	
	
	RenderWorld
	
	Text 0,0,fileNUmber + "/" + filearray.length + " " + StripDir( currentModel )

	Flip
	


Wend
End


Function aiLoadMiniB3D:tEntity(filename:String)

	Local scene:aiScene = New aiScene

	aiSetImportPropertyInteger(AI_CONFIG_PP_SBP_REMOVE, aiPrimitiveType_LINE | aiPrimitiveType_POINT )


'		
	
	Local flags:Int
Rem	
	flags:Int = ..	
		aiProcess_CalcTangentSpace | ..
		aiProcess_JoinIdenticalVertices | ..
		aiProcess_Triangulate | ..
		aiProcess_GenNormals | ..
		aiProcess_SplitLargeMeshes | ..
		aiProcess_ValidateDataStructure | ..
		aiProcess_ImproveCacheLocality | ..
		aiProcess_RemoveRedundantMaterials | ..
		aiProcess_SortByPType | ..
		aiProcess_FindDegenerates | ..
		aiProcess_FindInvalidData | ..
		aiProcess_GenUVCoords | ..
		aiProcess_ConvertToLeftHanded | ..	
		aiProcess_PreTransformVertices | ..	
		aiProcess_TransformUVCoords
EndRem

	flags:Int = ..	
		aiProcess_Triangulate | ..
		aiProcess_GenNormals | ..
		aiProcess_ConvertToLeftHanded | ..	
		aiProcess_PreTransformVertices


	flags:Int = ..
	aiProcess_CalcTangentSpace | ..
	aiProcess_Triangulate | ..
	aiProcess_GenNormals | ..
	aiProcess_SortByPType | ..
	aiProcess_FindDegenerates | ..
	aiProcess_FindInvalidData | ..
	aiProcess_GenUVCoords | ..
	aiProcess_TransformUVCoords | ..
	aiProcess_ConvertToLeftHanded

'	aiProcess_PreTransformVertices



	Rem
		
	flags:Int = ..
	aiProcess_CalcTangentSpace | ..
	aiProcess_Triangulate | ..
	aiProcess_GenNormals | ..
	aiProcess_SortByPType | ..
	aiProcess_FindDegenerates | ..
	aiProcess_FindInvalidData | ..
	aiProcess_GenUVCoords | ..		
	aiProcess_ConvertToLeftHanded | ..	
	aiProcess_TransformUVCoords
EndRem

'If Lower(ExtractExt(filename)) = "x" Then flags = flags ~ aiProcess_ConvertToLeftHanded




	If scene.ImportFile(filename, flags)


	
		'--- Make brushes ---------------------------------------------------------
		Local brushes:tBrush[scene.NumMaterials]
		
		Local i:Int
		
		For Local mat:aimaterial = EachIn scene.Materials
		
'Rem
		DebugLog " "
		DebugLog " -     --------   Material Name " + mat.GetMaterialName()
		DebugLog " -     --------   mat.IsTwoSided() " + mat.IsTwoSided()
		DebugLog " -     --------   mat.GetShininess() " + mat.GetShininess()
		DebugLog " -     --------   mat.GetAlpha() " + mat.GetAlpha()
	
	
	
		Local names:String[] = mat.GetPropertyNames()
	
		For Local s:String = EachIn names
			DebugLog s
		Next
'End Rem	

		
		Local fx :Int 
		
		
			Local DiffuseColors:Float[] = mat.GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)	
			
			brushes[i] = CreateBrush(mat.GetDiffuseRed()*255,mat.GetDiffuseGreen()*255,mat.GetDiffuseBlue()*255)
		
			BrushShininess brushes[i],mat.GetShininess()		
			
			
			'fx = 2
			
			If mat.IsTwoSided() 'Or 2=2
				fx:+ 16 
			EndIf
	
			BrushFX brushes[i] ,fx
	
				Local texFilename:String = mat.GetMaterialTexture()
			
			
				DebugLog "VIRGIN texFilename : " + texFilename
			
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
		
		
		
		DebugLog "scene.numMeshes:  "  + scene.numMeshes
					

		

		'If Lower(ExtractExt(filename)) = "md2" Then reverceFaces = True		
					
					
		Local ent:tEntity = ProccesIaNodeAndChildren(scene,brushes,scene.RootNode,Null)
	
		fitAnimmesh ent,-100,-100,-100,200,200,200,True		
'		fitAnimmesh ent,-100,-100,-100,200,200,200,True	
		' make y up
		'TurnEntity ent , -90,0,0	
		
	'	Local scaleFlipNeeded :Int
	'	If Lower(ExtractExt(filename)) = "x" Then scaleFlipNeeded = True

		'If scaleFlipNeeded Then ScaleFlipEntity(ent)
	
		Return ent	

	Else
		DebugLog "nothing imported"
	EndIf

	Scene.ReleaseImport()

End Function


Function FlipEntity(e:tEntity)
	If e = Null Then Return
	Local childcount:Int=CountChildren(e)
	
	If childcount
		For Local c:Int=1 To childcount
			FlipEntity GetChild(e,c)
		Next
	EndIf

	If e.class = "Mesh" 
'		ScaleMesh tMesh(e),-1,1,-1
		FlipMesh tMesh(e)
'		ScaleMesh tMesh(e),-1,1,1
		'FlipMesh tMesh(e)
		
	EndIf

End Function



' dirty x model fixer
Function ScaleFlipEntity(e:tEntity)

	Local childcount:Int=CountChildren(e)
	
	If childcount
		For Local c:Int=1 To childcount
			ScaleFlipEntity GetChild(e,c)
		Next
	EndIf

	If e.class = "Mesh" 
'		ScaleMesh tMesh(e),-1,1,-1
'		FlipMesh tMesh(e)
		ScaleMesh tMesh(e),-1,1,1
		'FlipMesh tMesh(e)
		
	EndIf

End Function


' dirty x model fixer
Function UpdateEntityNormals(e:tEntity)
	If e = Null Then Return
	Local childcount:Int=CountChildren(e)
	
	If childcount
		For Local c:Int=1 To childcount
			UpdateEntityNormals GetChild(e,c)
		Next
	EndIf

	If e.class = "Mesh" 
		UpdateNormals tMesh(e)		
	EndIf

End Function



Function ProccesIaNodeAndChildren:tEntity(scene:aiScene,brushes:tBrush[],n:aiNode,parent:tEntity=Null)


	'parent = null

	DebugLog "NODENAME: " + n.name

	Local e:tentity

	If n.NumMeshes = 0 Then
		e = CreatePivot(parent)
		
	Else
		e = CreateMesh(parent)
		
		
		' add this nodes Meshes
		For Local i:Int = 0 To n.NumMeshes - 1
		
		
			Local aim:aimesh = scene.meshes[n.MeshIndexes[i]]
		
			Local surf:tSurface = CreateSurface(tMesh(e),brushes[aim.MaterialIndex])
		
		
			MakeAiMesh scene.meshes[n.MeshIndexes[i]],surf
			
			
			
		
		Next
	EndIf


	' call this before reading the values, may go away in the future
	n.transformation.Decompose()

	PositionEntity e , n.transformation.Tx , n.transformation.Ty , -n.transformation.Tz,False
	RotateEntity e ,   -n.transformation.Rz, n.transformation.Rx , n.transformation.Ry,False
	ScaleEntity e ,    n.transformation.Sx , n.transformation.Sy , n.transformation.Sz,False


'	Local thisSign:Int = Sgn(n.transformation.Sx)
	
'		parentSign = parentSign * thisSign



'	PositionEntity e , n.transformation.Tx , n.transformation.Ty , n.transformation.Tz,False
'	RotateEntity e ,   -n.transformation.Rx, n.transformation.Ry , -n.transformation.Rz,False
'	ScaleEntity e ,    n.transformation.Sx , n.transformation.Sy , n.transformation.Sz,False








	DebugLog "x y z: " + n.transformation.Tx  + " , " + n.transformation.Ty + " , " + n.transformation.Tz
	DebugLog "rotate : " + n.transformation.Rx  + " , " + n.transformation.Ry + " , " + n.transformation.Rz
	DebugLog "Scale : " + n.transformation.Sx  + " , " + n.transformation.Sy  + " , " + n.transformation.Sz

	
	For Local i:Int = 0 To n.NumChildren - 1
		DebugLog "adding Child node..." 
		ProccesIaNodeAndChildren(scene,brushes,n.Children[i],e)
	Next

	Return e

End Function

Function MakeAiMesh(m:aimesh , surf:tSurface)


		
		If m.HasVertexColors(0)
			Local b:tBrush = GetSurfaceBrush(surf)	' makes a copy of the brush
			b.fx = b.fx | 2 | 32
			PaintSurface surf,b
		EndIf


		Local vertexOffset:Int = CountVertices(surf)
		
		
		' vertices, normals and texturecoords
		For Local i:Int = 0 To m.NumVertices - 1
		
		
			'DebugLog  m.VertexX(i) + " , "  + m.VertexY(i) + " , "  + m.VertexZ(i)

			Local vid:Int = AddVertex(surf, m.VertexX(i) , m.VertexY(i),-m.VertexZ(i))			
			

			If m.HasNormals()
				VertexNormal(surf,vid, m.VertexNX(i) , m.VertexNY(i),-m.VertexNZ(i))
			EndIf
			
			If m.HasTextureCoords(0)
				VertexTexCoords(surf,vid,m.VertexU(i) ,m.VertexV(i),m.VertexW(i))
			EndIf

			If m.HasTextureCoords(1)
				VertexTexCoords(surf,vid,m.VertexU(i,1) ,m.VertexV(i,1),m.VertexW(i,1))
			EndIf

			If m.HasVertexColors(0)
				VertexColor(surf,vid,m.VertexRed(i,0)*255 ,m.VertexGreen(i,0)*255,m.VertexBlue(i,0)*255,m.VertexAlpha(i,0))
			EndIf


		Next
	

		For Local i:Int = 0 To m.NumFaces - 1	
			AddTriangle(surf, m.TriangleVertex(i,0) + vertexOffset ,  m.TriangleVertex(i,1) + vertexOffset , m.TriangleVertex(i,2)+ vertexOffset)
		Next


End Function




