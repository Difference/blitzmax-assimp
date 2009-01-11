SuperStrict

Import "source.bmx"



Extern 

	Function aiIsExtensionSupported:Int(pFile$z)

	Function aiImportFile:Int    Ptr( pFile$z,pFlags:Int)
	Function aiReleaseImport(pScene:Byte Ptr)
	
	
	
	
	Function aiGetMaterialColor:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Byte Ptr) 
	Function aiGetMaterialString:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Byte Ptr) 	
	Function aiGetMaterialIntegerArray:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Int Ptr,pMax:Int Ptr)
	Function aiGetMaterialFloatArray:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Float Ptr,pMax:Int Ptr)

	Function aiGetMaterialTexture:Int(..
			pMat:Byte Ptr,..
			T_ype:Int,..
			index:Int,..
			path:Byte Ptr,..
			mapping:Byte Ptr = Null,..
			uvindex:Byte Ptr = Null,..
			blend:Float Ptr = Null,..
			op:Byte Ptr = Null,..
			mapmode:Byte Ptr = Null)
	
End Extern

	Const AI_SUCCESS:Int  = $0

'	//! Indicates that a Function failed
	Const AI_FAILURE:Int  = -$1

'	//! Indicates that a file was invalid
	Const AI_INVALIDFILE:Int  = -$2

'	//! Indicates that Not enough memory was available
'	//! To perform the requested operation
	Const AI_OUTOFMEMORY:Int  = -$3

'	//! Indicates that an illegal argument has been
'	//! passed To a Function. This is rarely used,
'	//! most functions Assert in this Case.
	Const AI_INVALIDARG:Int = -$4



	Const aiProcess_CalcTangentSpace:Int = 1
	Const aiProcess_JoinIdenticalVertices:Int = 2
	Const aiProcess_ConvertToLeftHanded:Int = 4
	Const aiProcess_Triangulate:Int = 8
	Const aiProcess_RemoveComponent:Int = $10
	Const aiProcess_GenNormals:Int = $20
	Const aiProcess_GenSmoothNormals:Int = $40
	Const aiProcess_SplitLargeMeshes:Int = $80
	Const aiProcess_PreTransformVertices:Int = $100
	Const aiProcess_LimitBoneWeights:Int = $200
	Const aiProcess_ValidateDataStructure:Int = $400
	Const aiProcess_ImproveCacheLocality:Int = $800
	Const aiProcess_RemoveRedundantMaterials:Int = $1000
	Const aiProcess_FixInfacingNormals:Int = $2000
	Const aiProcess_OptimizeGraph:Int = $4000
	Const aiProcess_SortByPType:Int = $8000
	Const aiProcess_FindDegenerates:Int = $10000
	Const aiProcess_FindInvalidData:Int = $20000
	Const aiProcess_GenUVCoords:Int = $40000
	Const aiProcess_TransformUVCoords:Int = $80000


	Const MAXLEN:Int = 1024

	Const AI_MAX_NUMBER_OF_COLOR_SETS:Int = 4
	Const AI_MAX_NUMBER_OF_TEXTURECOORDS:Int = 4

'	Const aiPrimitiveType_POINT:Int       = $1
'	Const aiPrimitiveType_LINE:Int        = $2
'	Const aiPrimitiveType_TRIANGLE:Int    = $4
'	Const aiPrimitiveType_POLYGON:Int     = $8


	' material property buffer content type
	Const aiPTI_Float:Int = $1
	Const aiPTI_String:Int = $3
	Const aiPTI_Integer:Int = $4
	Const aiPTI_Buffer:Int = $5

	' a few of the many matkey constants
	Const AI_MATKEY_NAME:String = "$mat.name"
	Const AI_MATKEY_COLOR_DIFFUSE:String ="$clr.diffuse" 
	Const AI_MATKEY_TWOSIDED:String = "$mat.twosided"
	Const AI_MATKEY_OPACITY:String = "$mat.opacity"
	Const AI_MATKEY_SHININESS:String = "$mat.shininess"