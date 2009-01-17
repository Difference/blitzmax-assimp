SuperStrict


Import scheutz.assimp
Import sidesign.minib3d
Import "fitanimmesh.bmx"

Local width:Int=640,height:Int=480,depth:Int=16,mode:Int=0


Graphics3D width,height ,depth,mode

Local cam:TCamera=CreateCamera()
PositionEntity cam,0,150,-245

CameraClsColor cam,200,200,255
CameraRange cam,0.1,2000

Local light:TLight=CreateLight()
RotateEntity light,45,0,0


' get some files to show
Local filelist:TList  = New TList
'enumFiles(filelist,"../assimp/test/models/md2")
'enumFiles(filelist,"../assimp/test/models/collada")
enumFiles(filelist,"../assimp/test/models")
'enumFiles(filelist,"../troublemodels")

Local filearray:Object[] = filelist.toarray()
Local fileNUmber:Int = 0

If filearray.length = 0 Then
	Notify "No files to show, please choose a different directory"
	End
EndIf


'Local sp:tentity = CreateSphere()
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
	
	Text 0,0,fileNUmber + "/" + filearray.length + " " + currentModel 

	Flip
	


Wend
End


Function aiLoadMiniB3D:tEntity(filename:String)

	Local scene:aiScene = New aiScene

	aiSetImportPropertyInteger(AI_CONFIG_PP_SBP_REMOVE, aiPrimitiveType_LINE | aiPrimitiveType_POINT )

	
	Local flags:Int
	
		
'	aiProcess_SplitLargeMeshes | ..
'	aiProcess_ValidateDataStructure | ..
'	aiProcess_ImproveCacheLocality | ..
'	aiProcess_RemoveRedundantMaterials | ..	
'	aiProcess_JoinIdenticalVertices | ..	
'	aiProcess_PreTransformVertices
'	
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
	aiProcess_TransformUVCoords





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

		
			Local DiffuseColors:Float[] = mat.GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)	
			
			brushes[i] = CreateBrush(mat.GetDiffuseRed()*255,mat.GetDiffuseGreen()*255,mat.GetDiffuseBlue()*255)
		
			BrushShininess brushes[i],mat.GetShininess()		
			
			If mat.IsTwoSided() 'Or 2=2
				BrushFX brushes[i] ,16
			EndIf
	
			Local texFilename:String = mat.GetMaterialTexture()
		
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
			
			
				DebugLog "Texture: " + texFilename   
			
				
				If FileType(texFilename  )
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
					
		Local ent:tEntity = ProccesIaNodeAndChildren(scene,brushes,scene.RootNode)
		
		' make y up
		TurnEntity ent , 90,0,0	
		
		'fitAnimmesh ent,-100,-100,-100,200,200,200,True
	
		Return ent	

	Else
		DebugLog "nothing imported"
	EndIf

	Scene.ReleaseImport()

End Function

Function ProccesIaNodeAndChildren:tEntity(scene:aiScene,brushes:tBrush[],n:aiNode,parent:tEntity=Null)


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
	ScaleEntity e ,    n.transformation.Sz , n.transformation.Sx , n.transformation.Sy,False


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

		Local vertexOffset:Int = CountVertices(surf)

		
		' vertices, normals and texturecoords
		For Local i:Int = 0 To m.NumVertices - 1
		
		
			'DebugLog  m.VertexX(i) + " , "  + m.VertexY(i) + " , "  + m.VertexZ(i)

			Local vid:Int = AddVertex(surf,m.VertexX(i) ,m.VertexY(i),-m.VertexZ(i))			
			

			If m.HasNormals()
				VertexNormal(surf,vid,m.VertexNX(i) ,m.VertexNY(i),-m.VertexNZ(i))
			EndIf
			
			If m.HasTextureCoords(0)
				VertexTexCoords(surf,vid,m.VertexU(i) ,-m.VertexV(i),m.VertexW(i))
			EndIf

			If m.HasTextureCoords(1)
				VertexTexCoords(surf,vid,m.VertexU(i,1) ,-m.VertexV(i,1),m.VertexW(i,1))
			EndIf

		Next
	

		For Local i:Int = 0 To m.NumFaces - 1	
			AddTriangle(surf, m.TriangleVertex(i,2) + vertexOffset ,  m.TriangleVertex(i,1) + vertexOffset , m.TriangleVertex(i,0)+ vertexOffset)
		Next



End Function



Function enumFiles(list:TList,dir:String)
	
	Local folder:Int=ReadDir(dir)
	Local file:String

	Repeat
		
		file=NextFile(folder)
	
		If (file <> ".") And (file <> "..") And (file)
			Local fullPath:String=RealPath(dir+"/"+file)
		
			If FileType(fullPath)=FILETYPE_DIR
				enumFiles(list,fullPath)
			Else
				'DebugLog ExtractExt(fullPath)
				If aiIsExtensionSupported(fullPath)
				
					If Lower(ExtractExt(fullPath))<> "nff"	' Filter out nff for now
													' assimp author is looking into a fix
						list.AddLast(fullPath)
					EndIf
				
				EndIf
			End If	
		End If
		
	Until (file=Null)
	
	CloseDir folder
	'FlushMem
	
End Function

