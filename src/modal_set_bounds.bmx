'-----------------------

Function modal_update_set_bounds( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.center Then Return
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	If MouseHit( 1 ) And SHIFT
		'get input
		data.append_bound( img_x, img_y, False )
		If ed.bounds_symmetrical
			data.prepend_bound( img_x, img_y, True )
		End If
		data.update()
	End If
	If Not SHIFT
		If MouseDown( 1 )
			If Not ed.mouse_1 'starting drag
				ed.drag_nearest_i = data.find_nearest_bound( img_x, img_y )
				ed.drag_mirrored = ed.bounds_symmetrical
				If( ed.drag_mirrored )
					ed.drag_counterpart_i = data.find_symmetrical_counterpart( ed.drag_nearest_i )
				End If
			Else 'mouse_down_1 'continuing drag
				data.modify_bound( ed.drag_nearest_i, img_x, img_y, False )
				If ed.drag_mirrored
					data.modify_bound( ed.drag_counterpart_i, img_x, img_y, True )
				End If
			End If
			ed.mouse_1 = True
		Else
			If ed.mouse_1 'finishing drag
				data.modify_bound( ed.drag_nearest_i, img_x, img_y, False )
				If ed.drag_mirrored
					data.modify_bound( ed.drag_counterpart_i, img_x, img_y, True )
				End If
			End If
			ed.mouse_1 = False
		End If
	End If
	If CONTROL And ALT
		If ed.mouse_2 'dragging
			For Local i% = 0 Until data.ship.bounds.length Step 2
				data.ship.bounds[i]   :+ img_x - ed.last_img_x
				data.ship.bounds[i+1] :- img_y - ed.last_img_y
			Next
			data.update()
			ed.last_img_x = img_x
			ed.last_img_y = img_y
		End If
		If MouseDown( 2 )
			If Not ed.mouse_2 'drag start
				ed.last_img_x = img_x
				ed.last_img_y = img_y
			End If
			ed.mouse_2 = True
		Else
			ed.mouse_2 = False
		End If
	End If
	If KeyHit( KEY_BACKSPACE )
		data.remove_nearest_bound( img_x, img_y, ed.bounds_symmetrical )
		data.update()
	End If
End Function

Function modal_draw_set_bounds( ed:TEditor, data:TData, sprite:TSprite, draw_ghost_add_preview% = False, draw_nearest_bound_indicator% = False )
	If Not data.ship.center Then Return
	'get input
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'screen position of coordinate to be potentially added
	Local x% = sprite.sx + img_x*sprite.scale 
	Local y% = sprite.sy + img_y*sprite.scale
	'screen position of a coordinate similar to previous, but reflected over y-axis of current center point
	Local xr%, yr%, cx%, cy%
	'existing center
	cx = sprite.sx + data.ship.center[1]*sprite.scale
	cy = sprite.sy + data.ship.center[0]*sprite.scale
	xr = x
	yr = y - 2*(y - cy)
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	If data.ship.bounds
		Local xy%[data.ship.bounds.length]
		For Local i% = 0 Until data.ship.bounds.length Step 2
			xy[i] = sprite.sx + (data.ship.bounds[i] + data.ship.center[1])*sprite.scale
			xy[i+1] = sprite.sy + (-data.ship.bounds[i+1] + data.ship.center[0])*sprite.scale
		Next
		Local ni% = data.find_nearest_bound( img_x, img_y )
		If ni <> -1
			mouse_str :+ coord_string( data.ship.bounds[ni], data.ship.bounds[ni+1] )+"~n"
		EndIf
		Local si% = -1
		If ed.bounds_symmetrical
			si = data.find_symmetrical_counterpart( ni )
		End If
		SetAlpha( 1 )
		'draw bg's of lines and dots
		SetColor( 0, 0, 0 )
		SetLineWidth( 4 )
		For Local i% = 0 Until xy.length Step 2
			DrawOval( xy[i]-5, xy[i+1]-5, 10, 10 )
			If draw_nearest_bound_indicator
				SetAlpha( 0.40 )
				DrawOval( xy[ni]-10, xy[ni+1]-10, 20, 20 )
				If si <> -1
					DrawOval( xy[si]-10, xy[si+1]-10, 20, 20 )
				End If
				SetAlpha( 1 )
			End If
			If i > 0 
				DrawLine( xy[i], xy[i+1], xy[i-2], xy[i-1] )
			End If
		Next
		If draw_ghost_add_preview
			SetAlpha( 0.40 )
			If ed.bounds_symmetrical
				DrawOval( x-5, y-5, 10, 10 )
				DrawOval( xr-5, yr-5, 10, 10 )
				DrawLine( xy[xy.length-2], xy[xy.length-1], x, y )
				DrawLine( x, y, xr, yr )
				DrawLine( xr, yr, xy[0], xy[1] )
			Else
				DrawOval( x-5, y-5, 10, 10 )
				DrawLine( xy[xy.length-2], xy[xy.length-1], x, y )
				DrawLine( x, y, xy[0], xy[1] )
			End If
			SetAlpha( 1 )
		Else
			DrawLine( xy[xy.length-2], xy[xy.length-1], xy[0], xy[1] )
		End If
		'draw fg's of lines and dots
		SetColor( 255, 255, 255 )
		SetLineWidth( 2 )
		For Local i% = 0 Until xy.length Step 2
			DrawOval( xy[i]-4, xy[i+1]-4, 8, 8 )
			If draw_nearest_bound_indicator
				SetAlpha( 0.40 )
				DrawOval( xy[ni]-8, xy[ni+1]-8, 16, 16 )
				If si <> -1
					DrawOval( xy[si]-8, xy[si+1]-8, 16, 16 )
				End If
				SetAlpha( 1 )
			End If
			If i > 0 
				DrawLine( xy[i], xy[i+1], xy[i-2], xy[i-1] )
			End If
		Next
		If draw_ghost_add_preview
			SetAlpha( 0.40 )
			If ed.bounds_symmetrical
				DrawOval( x-4, y-4, 8, 8 )
				DrawOval( xr-4, yr-4, 8, 8 )
				DrawLine( xy[xy.length-2], xy[xy.length-1], x, y )
				DrawLine( x, y, xr, yr )
				DrawLine( xr, yr, xy[0], xy[1] )
			Else
				DrawOval( x-4, y-4, 8, 8 )
				DrawLine( xy[xy.length-2], xy[xy.length-1], x, y )
				DrawLine( x, y, xy[0], xy[1] )
			End If
			SetAlpha( 1 )
		Else
			DrawLine( xy[xy.length-2], xy[xy.length-1], xy[0], xy[1] )
		End If
	End If 
	'mouse crosshairs
	draw_crosshairs( x, y, 16 )
	''mouse text output
	'img_x :- data.ship.center[1]
	'img_y :- data.ship.center[0]
	'mouse_str :+ coord_string( img_x, -img_y ) + "~n"
	SetAlpha( 1 )
End Function

