SuperStrict


Import scheutz.assimp
Import sidesign.minib3d

Local width:Int=1024,height:Int=768,depth:Int=16,mode:Int=0

Graphics3D width,height ,depth,mode

Local cam:TCamera=CreateCamera()
PositionEntity cam,0,15,-45

CameraClsColor cam,200,200,255
CameraRange cam,0.1,100

Local light:TLight=CreateLight()
RotateEntity light,45,0,0

Local marker:TMesh=CreateSphere()
ScaleEntity marker,0.2,0.2,0.2
EntityColor marker,255,0,0


' get some files to show
Local filelist:TList  = New TList
enumFiles(filelist,"../assimp/test/models")
Local filearray:Object[] = filelist.toarray()
Local fileNUmber:Int = 0


Local mesh:tMesh = CreateCube()

PointEntity cam,mesh

' used by fps code
Local old_ms:Int=MilliSecs()
Local renders:Int
Local fps:Int


'Notify "here"

Local currentModel:String  ="Press space to load the nex model"


While Not KeyDown(KEY_ESCAPE)		

	If KeyHit(KEY_SPACE) Then
	
		If fileNUmber > filearray.length -1
			fileNUmber = 0
		EndIf

		DebugLog String filearray[fileNUmber]

		If aiIsExtensionSupported(String filearray[fileNUmber])

			currentModel = String filearray[fileNUmber]

			If mesh Then FreeEntity mesh

			mesh = aiLoadMiniB3D(String filearray[fileNUmber])
			
			If mesh
				EntityPickMode mesh,2
				FitMesh mesh,-10,-10,-10,20,20,20,True
			EndIf
		EndIf


		fileNUmber:+1

	EndIf
	
	If mesh 
		TurnEntity mesh,0,1,0
	EndIf
	

	' control camera
	MoveEntity cam,KeyDown(KEY_D)-KeyDown(KEY_A),0,KeyDown(KEY_W)-KeyDown(KEY_S)
	TurnEntity cam,KeyDown(KEY_DOWN)-KeyDown(KEY_UP),KeyDown(KEY_LEFT)-KeyDown(KEY_RIGHT),0
	
	

	RenderWorld

	
	Text 0,0,fileNUmber + "/" + filearray.length + " " + currentModel 

	Flip

Wend
End


Function aiLoadMiniB3D:tMesh(filename:String)

	Local scene:aiScene = New aiScene

	If scene.ImportFile(filename, aiProcess_Triangulate | aiProcess_ValidateDataStructure | aiProcess_GenNormals | aiProcess_PreTransformVertices)


	
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
		
		brushes[i] = CreateBrush(mat.GetDiffuseRed()*255,mat.GetDiffuseGreen()*255,mat.GetDiffuseBlue())
	
		' seems alpha comes in different places denpending om model format.
		' seems wavefront obj alpha doen't load
	'	BrushAlpha brushes[i],mat.GetAlpha()' * mat.GetDiffuseAlpha() (might be 0 so not good)
		
		BrushShininess brushes[i],mat.GetShininess()
		
		
		
		If mat.IsTwoSided()
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
	
	Local mesh:tMesh = CreateMesh()
	
	For Local m:aimesh = EachIn scene.meshes

		Local surf:tSurface = CreateSurface(mesh,brushes[m.MaterialIndex])
		
		' vertices, normals and texturecoords
		For Local i:Int = 0 To m.NumVertices - 1
		
		
			'DebugLog m.VertexX(i) + " , "  + m.VertexY(i) + " , "  + m.VertexZ(i)

		
			Local index:Int = AddVertex(surf,m.VertexX(i) ,m.VertexY(i),m.VertexZ(i))

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
			AddTriangle(surf, m.TriangleVertex(i,0) ,  m.TriangleVertex(i,1) , m.TriangleVertex(i,2))
		Next

	Next
	
	
	
	
	
		Return mesh	

	Else
		DebugLog "nothing imported"
	EndIf

	Scene.ReleaseImport()

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
				
					If Lower(ExtractExt(fullPath))<> "nff"
						list.AddLast(fullPath)
					EndIf
				
				EndIf
			End If	
		End If
		
	Until (file=Null)
	
	CloseDir folder
	'FlushMem
	
End Function

