SuperStrict

' Include this file to use use assimp to load meshes in minib3d
Import scheutz.assimp
Import "minib3d-sf/minib3d.bmx"



'Function AssimpLoadAnimMesh:TMesh(file$,parent:TEntity=Null)
'	' no animation support yet
'	Return TMesh.LoadAnimMesh(file$,parent)
'End Function


Function AssImpLoadMesh:tMesh(filename:String,parent:TEntity=Null)

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
	aiProcess_SplitLargeMeshes | ..
	aiProcess_CalcTangentSpace | ..
	aiProcess_Triangulate | ..
	aiProcess_GenNormals | ..
	aiProcess_SortByPType | ..
	aiProcess_FindDegenerates | ..
	aiProcess_FindInvalidData | ..
	aiProcess_GenUVCoords | ..
	aiProcess_TransformUVCoords | ..
	aiProcess_FlipUVs | ..
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
		
		
		
		Scene.ReleaseImport()
		
		Return mesh	

	Else
		DebugLog "nothing imported"
	EndIf



End Function
