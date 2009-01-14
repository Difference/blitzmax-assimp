SuperStrict

Rem
bbdoc: assimp
about: The Open Asset Import Library
End Rem

Module scheutz.assimp

ModuleInfo "Version: 0.10"
ModuleInfo "Author: Copyright (c) 2006-2008, ASSIMP Development Team"
ModuleInfo "License: BSD License"

ModuleInfo "CC_OPTS:-fexceptions"


Import "common.bmx"
Import brl.math




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


Type aiMatrix4x4
	Field a1:Float , a2:Float , a3:Float , a4:Float
	Field b1:Float , b2:Float , b3:Float , b4:Float
	Field c1:Float , c2:Float , c3:Float , c4:Float
	Field d1:Float , d2:Float , d3:Float , d4:Float
	
	Field heading:Float
	Field attitude:Float
	Field bank:Float


	Field Tx:Float
	Field Ty:Float
	Field Tz:Float
	
	Field Sx:Float
	Field Sy:Float
	Field Sz:Float
		
	Field Rx:Float
	Field Ry:Float
	Field Rz:Float





	

	Function Create:aiMatrix4x4(p:Float Ptr)
	
		Local m:aiMatrix4x4 = New aiMatrix4x4
		
		
		DebugLog "MAtrix"
		
		For Local i:Int =  0 To 15
			DebugLog i + " " + p[i]
		Next
		
		
		
		m.a1 = p[0]
		m.a2 = p[1]
		m.a3 = p[2]
		m.a4 = p[3]
		
		m.b1 = p[4]
		m.b2 = p[5]
		m.b3 = p[6]
		m.b4 = p[7]

		m.c1 = p[8]
		m.c2 = p[9]
		m.c3 = p[10]
		m.c4 = p[11]

		m.d1 = p[12]
		m.d2 = p[13]
		m.d3 = p[14]
		m.d4 = p[15]	
		
		
		m.Decompose()
		
		Return m									
	
	End Function




	Method multiply(m:aiMatrix4x4)	
		
		Local p:Float[16]
		
		p[0]  = m.a1 * a1 + m.b1 * a2 + m.c1 * a3 + m.d1 * a4
		p[1]  = m.a2 * a1 + m.b2 * a2 + m.c2 * a3 + m.d2 * a4
		p[2]  = m.a3 * a1 + m.b3 * a2 + m.c3 * a3 + m.d3 * a4
		p[3]  = m.a4 * a1 + m.b4 * a2 + m.c4 * a3 + m.d4 * a4
		p[4]  = m.a1 * b1 + m.b1 * b2 + m.c1 * b3 + m.d1 * b4
		p[5]  = m.a2 * b1 + m.b2 * b2 + m.c2 * b3 + m.d2 * b4
		p[6]  = m.a3 * b1 + m.b3 * b2 + m.c3 * b3 + m.d3 * b4
		p[7]  = m.a4 * b1 + m.b4 * b2 + m.c4 * b3 + m.d4 * b4
		p[8]  = m.a1 * c1 + m.b1 * c2 + m.c1 * c3 + m.d1 * c4
		p[9]  = m.a2 * c1 + m.b2 * c2 + m.c2 * c3 + m.d2 * c4
		p[10] = m.a3 * c1 + m.b3 * c2 + m.c3 * c3 + m.d3 * c4
		p[11] = m.a4 * c1 + m.b4 * c2 + m.c4 * c3 + m.d4 * c4
		p[12] = m.a1 * d1 + m.b1 * d2 + m.c1 * d3 + m.d1 * d4
		p[13] = m.a2 * d1 + m.b2 * d2 + m.c2 * d3 + m.d2 * d4
		p[14] = m.a3 * d1 + m.b3 * d2 + m.c3 * d3 + m.d3 * d4
		p[15] = m.a4 * d1 + m.b4 * d2 + m.c4 * d3 + m.d4 * d4
		
		m.a1 = p[0]
		m.a2 = p[1]
		m.a3 = p[2]
		m.a4 = p[3]
		
		m.b1 = p[4]
		m.b2 = p[5]
		m.b3 = p[6]
		m.b4 = p[7]

		m.c1 = p[8]
		m.c2 = p[9]
		m.c3 = p[10]
		m.c4 = p[11]

		m.d1 = p[12]
		m.d2 = p[13]
		m.d3 = p[14]
		m.d4 = p[15]			
		
		
		Decompose()
		
	End Method
	
	
	Method Decompose()
	
	
	' All of these are pretty mush shots in the dark it seems.
	' Somebody will have to help out.
	
	
'method 1	
	
		Tx = a4
		Ty = b4 
		Tz = c4
	
	
		Sx = Sqr( a1*a1 + a2*a2 + a3*a3 )
		Sy = Sqr( b1*b1 + b2*b2 + b3*b3 ) 
		Sz = Sqr( c1*c1 + c2*c2 + c3*c3 )
		
		Local D:Float = a1 * (b2 * c3 - c2 * b3) - b1 * (a2 * c3 - c2 * a3) + c1 * (a2 * b3 - b2 * a3);
	
	
		Sx:* Sgn( D )
		Sy:* Sgn( D )
		Sz:* Sgn( D )
	
		Rx = ATan2( b3 / Sy, c3 / Sx ) 
		Ry = ASin( -a3 / Sx )
		Rz = ATan2( a2 / Sx, a1 / Sx )
		
		If( Cos(Ry) < 0.0001 ) 'To allow For precision/rounding errors 
			Rx = 0
			Rz = ATan2( -b1 / Sy, b2 / Sy )
		EndIf


' method 2 for rotation

Rem
		Local ang:Float=ATan2( b3,Sqr( a3*a3+c3*c3 ) )
		If ang <= 0.0001 And ang >=-0.0001 Then ang = 0.0
		Rx = ang


		Local a:Float= a3
		Local b:Float= c3
		If a<=0.0001 And a>=-0.0001 Then a =0.0
		If b<=0.0001 And b>=-0.0001 Then b =0.0
		Ry = ATan2(a3 ,c3 )


		a:Float=b1
		b:Float=b2
		If a <=0.0001 And a>=-0.0001 Then a=0.0
		If b <=0.0001 And b>=-0.0001 Then b=0.0
		Rz = ATan2(b1,b2)
EndRem
Rem

'method 3  for rotation

		Local heading:Float
		Local bank :Float
		Local attitude :Float		


		If (b1 > 0.998) ' singularity at north pole
			heading = ATan2(a3,c3)
			attitude = 90 'Pi/2
			bank = 0
			Return
		EndIf
		
		If (b1 < -0.998)' singularity at south pole
			heading = ATan2(a3,c3)
			attitude = - 90 '-Pi/2
			bank = 0
			Return
		EndIf
	
		heading = ATan2(-c1,a1)
		bank = ATan2(-b3,b2)
		attitude = ASin(b1)


		rx = heading
		ry = attitude
		rz = bank

EndRem
Rem

' method 4


		rx = -ATan2( c2,Sqr( c1*c1+c3*c3 ) ) 
		ry = -ATan2( c1,c3 )
		rz = ATan2( a2,b2 )
End Rem


	End Method 
	
		
		
'	Field a1:Float , a2:Float , a3:Float , a4:Float
'	Field b1:Float , b2:Float , b3:Float , b4:Float
'	Field c1:Float , c2:Float , c3:Float , c4:Float
'	Field d1:Float , d2:Float , d3:Float , d4:Float		
		
		
		

		

	Method GetScaleX:Float()
		Return Sqr(a1*a1 + a2*a2 + a3*a3);
	End Method

	Method GetScaleY:Float()
		Return Sqr(b1*b1 + b2*b2 + b3*b3);

	End Method

	Method GetScaleZ:Float()
		Return Sqr(c1*c1 + c2*c2 + c3*c3);	
	End Method



		
		
End Type

Type aiNode
	Field pointer:Byte  Ptr

	Field name:String
	Field transformation:aiMatrix4x4
	Field NumChildren:Int
	Field Children:aiNode[]
	Field NumMeshes:Int
	Field MeshIndexes:Int[]
	Field Parent:aiNode
	
	
		Function Create:aiNode(pointer:Byte Ptr,parent:aiNode = Null)
	
		Local n:aiNode = New aiNode
		
		n.Parent = parent
		
		n.pointer = pointer
		
		n.name = String.fromcstring(pointer + 4)


'		DebugLog "Nodename " + n.name

		n.transformation = aiMatrix4x4.Create(Float Ptr (Byte Ptr pointer + MAXLEN + 4))



		Local pBase:Int Ptr = Int Ptr(Byte Ptr pointer + MAXLEN + 4 + 16*4)

	
'Rem
		n.NumMeshes = pBase[3]
		
'		DebugLog "----------------------------Mesh count for this node: "  + n.NumMeshes
		

		Local pMeshIndexArray:Int Ptr = Int Ptr pBase[4]

		n.MeshIndexes = n.MeshIndexes[..n.NumMeshes ]

		For Local i:Int = 0 To n.NumMeshes - 1
			n.MeshIndexes[i] = pMeshIndexArray[i]
			
'			DebugLog "Mesh index : " + n.MeshIndexes[i]
		Next
'E'nd Rem


		' get child nodes
		n.NumChildren = pBase[1]

		If n.NumChildren
		
'			DebugLog "n.NumChildren "  + n.NumChildren
		
			Local pChildArray:Int Ptr = Int Ptr pBase[2]
		
			n.Children = n.Children[..n.NumChildren]
			
			For Local i:Int = 0 To n.NumChildren - 1
			
			
			
'				DebugLog "child pointer point " + pChildArray[i]
			
'				DebugLog " -- ---  Adding child"

				n.Children[i] = aiNode.Create(Byte Ptr pChildArray[i],n)
			
'				DebugLog " -- ---  Child added"
			Next
		Else
'			DebugLog "No children! "	
		
		EndIf


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
 		
			rootNode = aiNode.Create(Byte Ptr pointer[1])
			
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




