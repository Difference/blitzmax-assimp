SuperStrict

Import "source.bmx"



Extern 

	Function aiIsExtensionSupported:Int(pFile$z)

	Function aiImportFile:Int Ptr(pFile$z,pFlags:Int)
	Function aiReleaseImport(pScene:Byte Ptr)
	
	
	Function aiSetImportPropertyInteger(szName$z,value:Int)

	
	Function aiGetMaterialColor:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Byte Ptr) 
	Function aiGetMaterialString:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Byte Ptr) 	
	Function aiGetMaterialIntegerArray:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Int Ptr,pMax:Int Ptr)
	Function aiGetMaterialFloatArray:Int(pMat:Byte Ptr,pKey$z,T_ype:Int,index:Int,pOut:Float Ptr,pMax:Int Ptr)

	Function aiGetMaterialTexture:Int(..
			pMat:Int Ptr,..
			aiTextureType:Int,.. 
			index:Int,..
			path:Byte Ptr,..
			mapping:Byte Ptr = Null,..
			uvindex:Int Ptr = Null,..
			blend:Float Ptr = Null,..
			op:Byte Ptr = Null,..
			mapmode:Byte Ptr = Null,..
			flags:Int Ptr = Null)
	
End Extern


	Const AI_CONFIG_PP_SBP_REMOVE	:String = "pp.sbp.remove"


	Const AI_SUCCESS:Int  = $0
	Const AI_FAILURE:Int  = -$1
	Const AI_INVALIDFILE:Int  = -$2
	Const AI_OUTOFMEMORY:Int  = -$3
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

	Const aiPrimitiveType_POINT:Int       = $1
	Const aiPrimitiveType_LINE:Int        = $2
	Const aiPrimitiveType_TRIANGLE:Int    = $4
	Const aiPrimitiveType_POLYGON:Int     = $8


	' material property buffer content type
	Const aiPTI_Float:Int = $1
	Const aiPTI_String:Int = $3
	Const aiPTI_Integer:Int = $4
	Const aiPTI_Buffer:Int = $5

	' a few of the many matkey constants
	Const AI_MATKEY_NAME:String = "?mat.name"
	Const AI_MATKEY_COLOR_DIFFUSE:String ="$clr.diffuse" 
	Const AI_MATKEY_TWOSIDED:String = "$mat.twosided"
	Const AI_MATKEY_OPACITY:String = "$mat.opacity"
	Const AI_MATKEY_SHININESS:String = "$mat.shininess"



	Const AI_MATKEY_TEXTURE_BASE:String		=	"$tex.file"

	Const AI_MATKEY_UVWSRC_BASE:String			=	"$tex.uvwsrc"

	Const AI_MATKEY_TEXOP_BASE:String			=	"$tex.op"

	Const AI_MATKEY_MAPPING_BASE:String		=	"$tex.mapping"

	Const AI_MATKEY_TEXBLEND_BASE:String		=	"$tex.blend"

	Const AI_MATKEY_MAPPINGMODE_U_BASE:String	=	"$tex.mapmodeu"

	Const AI_MATKEY_MAPPINGMODE_V_BASE:String	=	"$tex.mapmodev"

	Const AI_MATKEY_TEXMAP_AXIS_BASE:String	=	"$tex.mapaxis"

	Const AI_MATKEY_UVTRANSFORM_BASE:String	=	"$tex.uvtrafo"

	Const AI_MATKEY_TEXFLAGS_BASE:String		=	"$tex.flags"

	Const aiTextureType_NONE:Int = $0







'    /** The texture is combined with the result of the diffuse

'	 *  lighting equation.

 '    */

    Const aiTextureType_DIFFUSE:Int = $1



'	/** The texture is combined with the result of the specular

'	 *  lighting equation.

'     */

    Const aiTextureType_SPECULAR:Int = $2



'	/** The texture is combined with the result of the ambient

'	 *  lighting equation.

'     */

    Const aiTextureType_AMBIENT:Int = $3



'	/** The texture is added To the result of the lighting

'	 *  calculation. It isn't influenced by incoming light.

'     */

    Const aiTextureType_EMISSIVE:Int = $4



'	/** The texture is a height map.

'	 *

'	 *  By convention, higher grey-scale values stand For

'	 *  higher elevations from the base height.

'    */

    Const aiTextureType_HEIGHT:Int = $5



'	/** The texture is a (tangent space) normal-map.

'	 *

'	 *  Again, there are several conventions For tangent-space

'	 *  normal maps. Assimp does (intentionally) Not 

'	 *  differenciate here.

'     */

    Const aiTextureType_NORMALS:Int = $6



'	/** The texture defines the glossiness of the material.

'	 *

'	 *  The glossiness is in fact the exponent of the specular

'	 *  (phong) lighting equation. Usually there is a conversion

'	 *  Function defined To map the linear color values in the

'	 *  texture To a suitable exponent. Have fun.

 '   */

    Const aiTextureType_SHININESS:Int = $7



'	/** The texture defines per-pixel opacity.

'	 *

'	 *  Usually 'white' means opaque and 'black' means 

'	 *  'transparency'. Or quite the opposite. Have fun.

'    */

    Const aiTextureType_OPACITY:Int = $8



'	/** Displacement texture

'	 *

'	 *  The exact purpose And format is application-dependent.

 '    *  Higher color values stand For higher vertex displacements.

'    */

    Const aiTextureType_DISPLACEMENT:Int = $9



'	/** Lightmap texture (aka Ambient Occlusion)

'	 *

'	 *  Both 'Lightmaps' and dedicated 'ambient occlusion maps' are

'	 *  covered by this material property. The texture contains a

'	 *  scaling value For the Final color value of a pixel. It's

'	 *  intensity is Not affected by incoming light.

 '   */

    Const aiTextureType_LIGHTMAP:Int = $A



'	/** Reflection texture

'	 *

'	 * Contains the color of a perfect mirror reflection.

'	 * Rarely used, almost nevery For real-time applications.

 '   */

    Const aiTextureType_REFLECTION:Int = $B



'	/** Unknown texture

'	 *

'	 *  A texture reference that does Not match any of the definitions 

'	 *  above is considered To be 'unknown'. It is still imported,

'	 *  but is excluded from any further postprocessing.

 '   */

    Const aiTextureType_UNKNOWN:Int = $C
