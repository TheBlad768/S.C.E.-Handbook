# SONIC-CLEAN-ENGINE-S.C.E.-

To display text on a plane, we can use one of the ready-made functions in the SCE library.

The first function is `Draw_PlaneText`, which displays simple text with a size of 8x8 pixels, meaning that the size of a single character cannot exceed one tile.

Using this code is very easy:

```
		; load text
		lea	Main_Text(pc),a1			; load text address to a1
		locVRAM	(VRAM_Plane_A_Name_Table+$D38),d1	; set plane address
		move.w	#make_art_tile($50F,1,FALSE),d3		; VRAM (art position, palette line, priority)
		jsr	(Draw_PlaneText).w
```

In register `a1` we have the address of our text, in `d1` the address of the plan to which we want to load the text, in `d3` we have the address of the text graphics in VRAM.


We can also use a simple macro:

```
		; load text
		DrawPlaneText	Main_Text, (VRAM_Plane_A_Name_Table+$D38), $50F, 1, FALSE
```


The second function is `Draw_PlaneText_Advanced`, which is used to display text of any size, not just 8x8 pixels. But the size of the character must still be a multiple of 8.

Using the code is also very easy:

```
		; load text
		lea	Main_Text(pc),a1			; load text address to a1
		locVRAM	(VRAM_Plane_A_Name_Table+$D38),d1	; set plane address

		; horizontal and vertical character size (size/8-1)
		move.l	#words_to_long( \
			bytesToXcnt(((32)+(tile_width-1)),tile_width), \
			bytesToXcnt(((32)+(tile_height-1)),tile_height) \
		),d2
		move.w	#make_art_tile($50F,1,FALSE),d3		; VRAM
		jsr	(Draw_PlaneText).w
```


Alternatively, we can use a simple macro:

```
		; load text
		DrawPlaneTextAdvanced	Main_Text, (VRAM_Plane_A_Name_Table+$D38), 32, 32, $50F, 1, FALSE
```

In register `a1`, we have the address of our text; in `d1`, we have the address of the plan onto which we want to load the text; in `d2`, we need to specify the horizontal and vertical character size; and in `d3`, we have the address of the text graphics in VRAM.


Analysis of additional flags in the text data:

```
Main_Text:
		dc.b "Hello1"
		dc.b draw_planetext.nextline|1, draw_planetext.palette_line_1		; next line, select palette line
		dc.b "Hello2"
		dc.b draw_planetext.end							; stop loading characters
```

`Hello1` will be drawn on the first line of the palette at address $50F in VRAM. The size of the characters in VRAM will be 32x32 pixels (the code works as a mapping function, it does not scale the text itself).

The `draw_planetext.nextline` flag will move the starting position of the plan to the next row.

The `draw_planetext.palette_line_1` flag will change the first line of the palette to the second line of the palette (0, 1, 2, 3 line). That is, instead of $50F, we will now have $250F.

`Hello2` will be drawn on the next row and will use a different palette line

The `draw_planetext.end` flag tells the program to stop loading characters and finish executing the program. That is, simply `exit from program`


## The letters on the title card are not displayed

[Here is a guide on how to work with title cards.](test)








