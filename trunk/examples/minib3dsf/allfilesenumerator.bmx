SuperStrict

'Import scheutz.assimp

Function enumFiles(list:TList,dir:String,skipExt:TList)
	
	Local folder:Int=ReadDir(dir)
	Local file:String
	
	Repeat
		
		file=NextFile(folder)
	
		If (file <> ".") And (file <> "..") And (file)
			Local fullPath:String=RealPath(dir+"/"+file)
		
			If FileType(fullPath)=FILETYPE_DIR
				enumFiles(list,fullPath,skipExt)
			Else
				'DebugLog ExtractExt(fullPath)
				'If aiIsExtensionSupported(fullPath)
				
					
					'DebugStop
				
					If Not skipExt.Contains(Lower(ExtractExt(fullPath)))	' Filter out nff for now
							' assimp author is looking into a fix
						list.AddLast(fullPath)
					EndIf
				
				'EndIf
			End If	
		End If
		
	Until (file=Null)
	
	CloseDir folder
	'FlushMem
	
End Function

