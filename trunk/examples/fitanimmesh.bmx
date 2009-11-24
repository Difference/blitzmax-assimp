SuperStrict
Import sidesign.minib3d
'Import "../libs/mb3d/minib3d.bmx"

Type minmax3D
	Field maxx#,maxy#,maxz#
	Field minx#,miny#,minz#
End Type


Function FitAnimMesh(m:tEntity,x#,y#,z#,w#,h#,d#,uniform:Int=False)
	Local scalefactor#
	Local xoff#,yoff#,zoff#
	
	
	Local gFactor#=100000.0

	Local mm:minmax3D=New minmax3D
	
	mm.maxx=-100000
	mm.maxy=-100000
	mm.maxz=-100000

	mm.minx=100000
	mm.miny=100000
	mm.minz=100000


	getAnimMeshMinMax m,mm
	
	'DebugLog "getAnimMeshMinMax " + String(mm.minx).ToInt() + ", " + String(mm.miny).ToInt() + ", " + String(mm.minz).ToInt() + ", " +..
	'String(mm.maxx).ToInt() + ", " + String(mm.Maxy).ToInt() + ", " + String(mm.maxz).ToInt()	
	
	
	Local xspan#=(mm.maxx-mm.minx)
	Local yspan#=(mm.maxy-mm.miny)
	Local zspan#=(mm.maxz-mm.minz)

	Local xscale#=w/xspan
	Local yscale#=h/yspan
	Local zscale#=d/zspan
	
	
	'DebugLog "Scales: " + xscale + " , " +  yscale + " , " + zscale + " , " 
	
	
	
	If uniform
		If xscale<yscale
			yscale=xscale
		Else
			xscale=yscale
		EndIf
	
		If zscale<xscale
			xscale=zscale
			yscale=zscale			
		Else
			zscale=xscale
		EndIf
	
	
	EndIf	
	
	
	'DebugLog "Scales: " + String(xscale).ToInt() + " , " +  String(yscale).ToInt() + " , " + String(zscale).ToInt() + " , " 
	

	xoff#=-mm.minx*xscale-(xspan/2.0)*xscale+x+w/2.0
	yoff#=-mm.miny*yscale-(yspan/2.0)*yscale+y+h/2.0
	zoff#=-mm.minz*zscale-(zspan/2.0)*zscale+z+d/2.0

	doFitAnimMesh(m,xoff,yoff,zoff,xscale,yscale,zscale)	

'	Delete mm

End Function


Function MyFitEntity(e:tEntity,xoff#,yoff#,zoff#,xscale#,yscale#,zscale#)

		Local x#,y#,z#
		Local x2#,y2#,z2#
		Local txoff#,tyoff#,tzoff#

		TFormPoint(0,0,0,e,Null)

		x2=TFormedX()
		y2=TFormedY()
		z2=TFormedZ()


		TFormPoint(x2+xoff,y2+yoff,z2+zoff,Null,e)
		
		txoff=TFormedX() 
		tyoff=TFormedY()
		tzoff=TFormedZ()
		
		Local m:tMesh = tMesh(e)

		If m	'only if it's a mesh

			For Local sc:Int=1 To CountSurfaces(m)
			Local s:tsurface =GetSurface(m,sc)	
				
				For Local vc:Int=0 To CountVertices(s)-1
	
									
					x=VertexX(s,vc)
					y=VertexY(s,vc)
					z=VertexZ(s,vc)
									
					VertexCoords s,vc,x*xscale+txoff,y*yscale+tyoff,z*zscale+tzoff
	
				Next 	
			Next 
		EndIf

	PositionEntity e,EntityX(e)*xscale,EntityY(e)*yscale,EntityZ(e)*zscale

End Function

Function doFitAnimMesh(m:tentity,xoff#,yoff#,zoff#,xscale#,yscale#,zscale#)
	Local c:Int
	Local childcount:Int=CountChildren(m)
	
	If childcount
		
		For c=1 To childcount
			'MyFitEntity m,xoff#,yoff#,zoff#,xscale#,yscale#,zscale#
			doFitAnimMesh GetChild(m,c),xoff#,yoff#,zoff#,xscale#,yscale#,zscale#
		Next
	'Else
	EndIf

	MyFitEntity m,xoff#,yoff#,zoff#,xscale#,yscale#,zscale#
	
	
End Function


Function doFitAnimMeshOLD(m:tentity,xoff#,yoff#,zoff#,xscale#,yscale#,zscale#)
	Local c:Int
	Local childcount:Int=CountChildren(m)
	
	If childcount
		
		For c=1 To childcount
			MyFitEntity m,xoff#,yoff#,zoff#,xscale#,yscale#,zscale#
			doFitAnimMesh GetChild(m,c),xoff#,yoff#,zoff#,xscale#,yscale#,zscale#
		Next
	Else

		MyFitEntity m,xoff#,yoff#,zoff#,xscale#,yscale#,zscale#
	
	EndIf
End Function



Function getAnimMeshMinMax#(m:tEntity,mm:minmax3D)
	Local c:Int
	Local wfac#,hfac#,dfac#
	'Local tfactor
	Local cc:Int=CountChildren(m)
	
	If m.class = "Mesh" 
		mm = getEntityMinMax(tmesh(m),mm)
	'Else
	'	DebugLog "Class ----------------------- " + m.class
	EndIf	
	
	If cc
		For c=1 To cc
			getAnimMeshMinMax(GetChild(m,c),mm)
		Next
'	Else

	EndIf
	
	


	
	
End Function




Function getEntityMinMax:minmax3D(m:tMEsh,mm:minmax3D)
	Local x#,y#,z#
	Local sc:Int
	Local vc:Int
	Local s:tsurface	

	

	
	For sc=1 To CountSurfaces(m)
		s=GetSurface(m,sc)	
			
		For vc=0 To CountVertices(s)-1

				
				TFormPoint(VertexX(s,vc),VertexY(s,vc),VertexZ(s,vc),m,Null)
				
				x=TFormedX() 
				y=TFormedY()
				z=TFormedZ()
		
				
				If x<mm.minx Then mm.minx=x
				If y<mm.miny Then mm.miny=y
				If z<mm.minz Then mm.minz=z				

				If x>mm.maxx Then mm.maxx=x
				If y>mm.maxy Then mm.maxy=y
				If z>mm.maxz Then mm.maxz=z				

		Next 	
	Next 

	Return mm
End Function
