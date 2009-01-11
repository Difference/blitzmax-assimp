SuperStrict

Rem
bbdoc: assimp
about: The Open Asset Import Library
End Rem

Module scheutz.assimp

ModuleInfo "Version: 0.07"
ModuleInfo "Author: Copyright (c) 2006-2008, ASSIMP Development Team"
ModuleInfo "License: BSD License"

ModuleInfo "CC_OPTS:-fexceptions"


Import "common.bmx"

'Import brl.retro



Type aiMaterialProperty

	Field mKey:String
	Field Semantic:Int
	Field Index:Int
	Field DataLength:Int
	Field mType:Int				
	Field mData:Byte Ptr		
	
	
	Function Create:aiMaterialProperty(pProps:Byte Ptr)
	
		Local mp:aiMaterialProperty = New aiMaterialProperty
				
		mp.mKey =  String.fromcstring(pProps +  4)
		
		Local pVars:Int Ptr =  Int Ptr(pProps + MAXLEN  + 4 )
		
		mp.Semantic:Int = pVars[0]
		mp.Index  =  pVars[1]
		mp.DataLength=  pVars[2]
		mp.mType =  pVars[3]
		mp.mData =  Byte Ptr pVars[4]

		Return mp
	
	End Function


	Method GetFloatValue:Float(index:Int)
		Return Float Ptr (mData)[index]
	End Method
	
	
	Method GetStringProperty:String()
		Return String.fromcstring(mData + 4 )
	End Method

	Method GetIntegerValue:Int (index:Int)
		Return Int Ptr (mData)[index]
	End Method

	Method GetByteValue:Byte(index:Int)
		Return mData[index]
	End Method

 	
	
End Type

Type aiMaterial

	Field pMaterial:Int Ptr
	Field Properties:aiMaterialProperty[]
	Field NumProperties:Int
	Field NumAllocated:Int
	
	

	' ---- helper functions based on Assimp api ----------------------------
	
	Method GetMaterialName:String()
		Return GetMaterialString(AI_MATKEY_NAME)
	End Method	


	Method IsTwoSided:Int()
		Local values:Int[] = GetMaterialIntegerArray(AI_MATKEY_TWOSIDED)
		If values.length Then Return values[0]
	End Method
	
	Method GetAlpha:Float()
		Local values:Float[] = GetMaterialFloatArray(AI_MATKEY_OPACITY)
		If values.length Then
			Return values[0]	
		Else		
			Return 1.0
		EndIf
	End Method

	Method GetShininess:Float()
		Local values:Float[] = GetMaterialFloatArray(AI_MATKEY_SHININESS)
		If values.length Then
			Return values[0]	
		Else		
			Return 1.0
		EndIf
	End Method


	

	' diffuse
	Method GetDiffuseRed:Float()
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[0]
	End Method

	Method GetDiffuseGreen:Float()
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[1]
	End Method
	
	Method GetDiffuseBlue:Float()
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[2]
	End Method
	
	Method GetDiffuseAlpha:Float()
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[3]
	End Method		

	
	
	
	' ---- helper functions assumes material properties loaded with scene ----------------------------
	
	Method GetPropertyNames:String[]()
		Local names:String[NumProperties]	
		For Local i:Int = 0 To NumProperties - 1
			names[i] = Properties[i].mKey
		Next
		Return names
	End Method	
	
	
	' ---- native ai functions -----------------------------------------------------------------
	Method GetMaterialString:String(Key:String)
		Local s:Byte[4+MAXLEN]
		
		If aiGetMaterialString(pMaterial,Key,0,0,Varptr s[0]) = AI_SUCCESS
			
			Return String.fromcstring(Varptr s[4])
			
		EndIf	
	End Method
	
	
	Method GetMaterialColor:Float[](Key:String)	
		Local colors:Float[4]
		If aiGetMaterialColor(pMaterial,Key,0,0,colors)	= AI_SUCCESS
			Return colors
		EndIf
	End Method
	
	
	Method GetMaterialIntegerArray:Int[](Key:String)
		
		Local size:Int = 1024
		Local values:Int[size]
		
		If aiGetMaterialIntegerArray(pMaterial,Key,0,0,values,Varptr size)	= AI_SUCCESS
			values = values[..size]
			Return values
		EndIf
		
	End Method	
	

	Method GetMaterialFloatArray:Float[](Key:String)
		Local size:Int = 1024
		Local values:Float[size]
		
		If aiGetMaterialFloatArray(pMaterial,Key,0,0,values,Varptr size)	= AI_SUCCESS
			values = values[..size]
			Return values
		EndIf
	End Method	

	
	
	Method GetMaterialTexture:String(index:Int=0)
	
		Local s:Byte[4+MAXLEN]
		
		If aiGetMaterialTexture(pMaterial,0,index,Varptr s[0]) = AI_SUCCESS
			Return String.fromcstring(Varptr s[4])
		EndIf			
	
	End Method
	
End Type




Type aiNode
	Field pointer:Byte  Ptr
	
	Field name:String
	

	Function Create:aiNode(pointer:Byte  Ptr)
	
		Local n:aiNode = New aiNode
		
		n.pointer = pointer
		
		n.name = String.fromcstring(pointer + 4)

		Return n

	End Function
	
End Type


Type aiMesh
	Field PrimitiveTypes:Int
	Field NumVertices:Int
	Field NumFaces:Int
	Field pVertices:Float Ptr
	Field pNormals:Float Ptr
	Field pTangents:Byte Ptr
	Field pBitangents:Byte Ptr
	Field pColors:Byte Ptr[AI_MAX_NUMBER_OF_COLOR_SETS]
	Field pTextureCoords:Byte Ptr[AI_MAX_NUMBER_OF_TEXTURECOORDS]
	Field NumUVComponents:Int[AI_MAX_NUMBER_OF_TEXTURECOORDS]
	Field pFaces:Int Ptr
	Field NumBones:Int
	Field pBones:Byte Ptr
	Field MaterialIndex:Int
	
	
	Method HasTextureCoords:Int(coord_set:Int)
		If pTextureCoords[coord_set] <> Null Then Return True
	End Method


	'vertices
	Method VertexX:Float(index:Int)
		Return pVertices[index*3]
	End Method

	Method VertexY:Float(index:Int)
		Return pVertices[index*3+1]
	End Method

	Method VertexZ:Float(index:Int)
		Return pVertices[index*3+2]
	End Method
	
	'normals
	Method VertexNX:Float(index:Int)
		Return pNormals[index*3]
	End Method

	Method VertexNY:Float(index:Int)
		Return pNormals[index*3+1]
	End Method

	Method VertexNZ:Float(index:Int)
		Return pNormals[index*3+2]
	End Method
	
	' texcords - funky :-)
	Method VertexU:Float(index:Int,coord_set:Int=0)
		Return Float Ptr(pTextureCoords[coord_set])[index*3]
	End Method

	Method VertexV:Float(index:Int,coord_set:Int=0)
		Return Float Ptr(pTextureCoords[coord_set])[index*3 + 1]
	End Method

	Method VertexW:Float(index:Int,coord_set:Int=0)
		Return Float Ptr(pTextureCoords[coord_set])[index*3 + 2 ]
	End Method
	

	Method HasNormals:Int()
		If pNormals = Null Then
			Return False
		Else
			Return True
		EndIf
	End Method


	Method TriangleVertex:Int(index:Int,corner:Int)
		Local faceIndexes:Int Ptr = Int Ptr pFaces[index*2+1]
		Return faceIndexes[corner]
	End Method




	Method GetTriangularFaces:Int[,]()
	
		Local faces:Int[NumFaces,3]
		Local index:Int
		
		For Local count:Int = 0 To NumFaces  - 1
		
			Local faceCount:Int = pFaces[index]
			Local faceIndexes:Int Ptr = Int Ptr pFaces[index+1]
	
			' TODO for nontriangular faces: faceCount could be other than 3
			For Local n:Int = 0 To 2
				faces[count , n] = faceIndexes[n]
			Next
			
			index:+2
		Next

		Return faces

	End Method
	
End Type

Type aiScene

	Field pointer:Int Ptr
	
	Field flags:Int
	Field rootNode:aiNode	
	
	Field numMeshes:Int
	
	Field meshes:aiMesh[]
	
	Field NumMaterials:Int
	Field Materials:aiMaterial[]
	
	
	Method ImportFile:Int Ptr( filename :String,readflags:Int)

	
		?WIN32	
		' TODO this is a fix for wavefront mtl not being found
		' does this mess up UNC paths or something else?
		filename.Replace("/","\")
		?
		
		
		pointer = aiImportFile(filename ,readflags)
	
					
		
		If pointer <> Null
		
			flags = pointer[0]
 		
			rootNode = aiNode.Create(Byte  Ptr pointer[1])
			
			numMeshes = pointer[2]
			
			Local pMeshArray:Int Ptr = Int Ptr pointer[3]
			
			
			meshes = meshes[..numMeshes]
			
			
			For Local i:Int = 0 To numMeshes - 1 
			
			
				Local pMesh:Int Ptr = Int Ptr pMeshArray[i]
			
			
				meshes[i] = New aimesh 
			
				meshes[i].PrimitiveTypes = pMesh[0]
				meshes[i].NumVertices = pMesh[1]
				meshes[i].NumFaces  = pMesh[2]

			
				meshes[i].pVertices  = Float Ptr pMesh[3]
				meshes[i].pNormals  = Float Ptr pMesh[4]
				meshes[i].pTangents  = Byte Ptr pMesh[5]
				meshes[i].pBitangents  = Byte Ptr pMesh[6]
				
				For Local n:Int = 0 To AI_MAX_NUMBER_OF_COLOR_SETS - 1
					meshes[i].pColors[n]  = Byte Ptr pMesh[7 + n]
				Next
				
				For Local n:Int = 0 To AI_MAX_NUMBER_OF_TEXTURECOORDS - 1
					meshes[i].pTextureCoords[n]  = Byte Ptr pMesh[11 + n]
				Next 
				
				For Local n:Int = 0 To AI_MAX_NUMBER_OF_TEXTURECOORDS - 1
					meshes[i].NumUVComponents[n]  = pMesh[15 + n]
				Next
				
				meshes[i].pFaces  = Int Ptr pMesh[19]
				meshes[i].NumBones  = pMesh[20]
				meshes[i].pBones  = Byte Ptr pMesh[21]
				meshes[i].MaterialIndex  = pMesh[22]
			

			Next
			
			
			NumMaterials = pointer[4]
			
			Local pMaterialArray:Int Ptr = Int Ptr pointer[5]			
			
			
			
			materials = materials[..NumMaterials]
			
		
			For Local i:Int = 0 To NumMaterials - 1 
				
				
	
				materials [i] = New aiMaterial 
				
				materials [i].pMaterial  = Int Ptr pMaterialArray[i]
				materials [i].NumProperties = materials [i].pMaterial[1]
				materials [i].NumAllocated = materials [i].pMaterial[2]				
	
	
'Rem ' loading properties is not needed, but I do it for now for a propertylist
				' redim
				materials [i].Properties = materials [i].Properties[..materials [i].pMaterial[1]]
				
				Local pMaterialPropertyArray:Int Ptr = Int  Ptr materials [i].pMaterial[0]	
				
				
				For Local p:Int = 0 To materials [i].NumProperties - 1
						materials [i].Properties[p] = aiMaterialProperty.Create(Byte Ptr pMaterialPropertyArray[p])
				Next
						
'EndRem
			Next
		
		EndIf
		
		
		Return pointer
		
	End Method
	
	
	Method ReleaseImport()

	
		If pointer <> Null
			aiReleaseImport(pointer)
		EndIf
		
		pointer = Null
		rootNode = Null
		meshes = Null
		numMeshes = 0
		flags = 0

	End Method
			
End Type




