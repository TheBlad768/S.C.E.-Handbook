# SONIC-CLEAN-ENGINE-S.C.E.-TUTORIALS-

# Как добавить новый Splash Screen?

# Создание файлов

Для начала в папке [Screens](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/Clone-Driver-v2/Screens) создать папку `Splash`. 

Теперь в папке `Splash`  создадим текстовый файл под именем `Splash.asm` и вставим в него этот готовый код:

```m68k
; ---------------------------------------------------------------------------
; Splash Screen
; ---------------------------------------------------------------------------

Splash_VDP:
		dc.w $8004								; disable HInt, HV counter, 8-color mode
		dc.w $8200+(VRAM_Plane_A_Name_Table>>10)				; set foreground nametable address
		dc.w $8300+(VRAM_Plane_B_Name_Table>>10)				; set window nametable address
		dc.w $8400+(VRAM_Plane_B_Name_Table>>13)				; set background nametable address
		dc.w $8700+(0<<4)							; set background color (line 3; color 0)
		dc.w $8B00								; full-screen horizontal and vertical scrolling
		dc.w $8C81								; set 40cell screen size, no interlacing, no s/h
		dc.w $9001								; 64x32 cell nametable area
		dc.w $9100								; set window H position at default
		dc.w $9200								; set window V position at default
		dc.w 0									; end marker

; =============== S U B R O U T I N E =======================================

SplashScreen:
		music	mus_Stop							; stop music
		jsr	(Clear_KosPlus_Module_Queue).w					; clear KosPlusM PLCs
		ResetDMAQueue								; clear DMA queue
		jsr	(Pal_FadeToBlack).w
		disableInts
		move.l	#VInt,(V_int_addr).w
		move.l	#HInt,(H_int_addr).w
		disableScreen
		jsr	(Clear_DisplayData).w
		lea	Splash_VDP(pc),a1
		jsr	(Load_VDP).w
		jsr	(Clear_Palette).w
		clearRAM Object_RAM, Object_RAM_end					; clear the object RAM
		clearRAM Lag_frame_count, Lag_frame_count_end				; clear variables
		clearRAM Camera_RAM, Camera_RAM_end					; clear the camera RAM
		clearRAM Oscillating_variables, Oscillating_variables_end		; clear variables

		; clear
		move.b	d0,(Water_full_screen_flag).w
		move.b	d0,(Water_flag).w
		move.b	d0,(HUD_RAM.status).w
		move.b	d0,(Update_HUD_timer).w						; clear time counter update flag
		move.w	d0,(Current_zone_and_act).w
		move.w	d0,(Apparent_zone_and_act).w
		move.b	d0,(Last_star_post_hit).w
		move.b	d0,(Debug_mode_flag).w

		; load main art
		QueueKosPlusModule	ArtKosPM_Splash, 0

		; load main mapping
		EniDecomp	MapEni_Splash, RAM_start, 0, 0, FALSE			; decompress Enigma mappings
		copyTilemap	VRAM_Plane_A_Name_Table, 320, 224

		; load main palette
		lea	(Pal_Splash).l,a1
		lea	(Target_palette).w,a2
		jsr	(PalLoad_Line16).w

		; set
		move.l	#VInt_Fade,(V_int_ptr).w					; set VInt pointer

.waitplc
		st	(V_int_flag).w							; set VInt flag
		jsr	(Process_KosPlus_Queue).w
		jsr	(Wait_VSync.skip).w
		jsr	(Process_KosPlus_Module_Queue).w
		tst.w	(KosPlus_modules_left).w
		bne.s	.waitplc							; wait for KosPlusM queue to clear

		; next
		move.l	#VInt_Main,(V_int_ptr).w					; set VInt pointer
		jsr	(Wait_VSync).w
		enableScreen
		jsr	(Pal_FadeFromBlack).w

		; set
		move.w	#3*60,(Demo_timer).w						; set to wait for 3 seconds

.loop
		jsr	(Wait_VSync).w

		; check exit
		tst.b	(Ctrl_1_pressed).w
		bmi.s	.exit								; if start was pressed, skip ahead
		tst.w	(Demo_timer).w
		bne.s	.loop

.exit

		; exit
		move.b	#GameModeID_LevelSelectScreen,(Game_mode).w			; set screen mode to Level Select (SCE)
		rts
```

В качестве примера, в папку `Splash`  я скопирую папки Enigma Map и KosinskiPM Art [отсюда](https://github.com/TheBlad768/Sonic-1-in-Sonic-3-S.C.E.-/tree/flamedriver/Screens/Sega/S3K), а [Palettes](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/Clone-Driver-v2/Screens/Level%20Select/Palettes "Palettes") скопирую из [Level Select](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/Clone-Driver-v2/Screens/Level%20Select "Level Select"). 

Если хотите сделать свою графику для Splash Screen, то вот тут `гайд как это сделать`.

# Прописываем графические данные

Сначала нам нужно добавить графические данные для Splash Screen. В папке [Data](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/Clone-Driver-v2/Data "Data") нужно будет добавить это в следующие файлы:

> [!TIP]
> Если не знайте куда влепить эти строки, то вставьте их перед строками Level Select

Для графики это [Kosinski Plus Module Data.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/blob/Clone-Driver-v2/Data/Kosinski%20Plus%20Module%20Data.asm "Kosinski Plus Module Data.asm")

```
; ===========================================================================
; Kosinski Plus Module compressed Splash screen graphics
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	ArtKosPM_Splash, "Screens/Splash/KosinskiPM Art/Foreground.kospm"
```

Для маппингов это [Enigma Data.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/blob/Clone-Driver-v2/Data/Enigma%20Data.asm "Enigma Data.asm")

```
; ===========================================================================
; Enigma compressed Splash screen data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	MapEni_Splash, "Screens/Splash/Enigma Map/Foreground.eni"
```

Для палитры это [Palette Data.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/blob/Clone-Driver-v2/Data/Palette%20Data.asm "Palette Data.asm")

```
; ===========================================================================
; Palette Splash screen data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	Pal_Splash, "Screens/Splash/Palettes/1.pal"
```
# Изменяем код

Осталось внести изменения в код: прописать пути к графике и добавить новый игровой режим. Ниже будет инструкция как это сделать или просмотреть изменения в коммите на GitHub [ТУТ](https://github.com/Nichloya/Sonic-Clean-Engine-S.C.E.-Extended-/commit/7b0651c7c2229bdf41811d974231aafbace5bcb5).

```diff
+ Добавьте зелёные строки, начинающиеся с плюса (сам плюс добавлять не надо).
- Красные строки наоборот, вы должны удалить.
```

Сначала подключим наш `Splash.asm`, добавив его в список includes в [Engine/Includes.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/blob/Clone-Driver-v2/Engine/Includes.asm).

```diff
 ; ---------------------------------------------------------------------------
 ; Objects data pointers
 ; ---------------------------------------------------------------------------

		include "Data/Objects Data.asm"

+; ---------------------------------------------------------------------------
+; Splash screen modules
+; ---------------------------------------------------------------------------
+
+		include "Screens/Splash/Splash.asm"
+
 ; ---------------------------------------------------------------------------
 ; Level Select screen modules
 ; ---------------------------------------------------------------------------

		include "Screens/Level Select/Level Select.asm"

```

Дальше в [Engine/Constants.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/blob/Clone-Driver-v2/Engine/Constants.asm) добавим наш новый экран в список констант `Game mode routines`

```diff
 ; ---------------------------------------------------------------------------
 ; Game mode routines
 ; ---------------------------------------------------------------------------

 offset := Game_Modes
 ptrsize := 1
 idstart := 0

+GameModeID_SplashScreen =					id(GameMode_SplashScreen)			; 0
 GameModeID_LevelSelectScreen =					id(GameMode_LevelSelectScreen)			; 0
 GameModeID_LevelScreen =					id(GameMode_LevelScreen)			; 4
 GameModeID_ContinueScreen =					id(GameMode_ContinueScreen)			; 8

 GameModeFlag_TitleCard =					7						; flag bit
 GameModeID_TitleCard =						setBit(GameModeFlag_TitleCard)			; flag mask
```


Теперь нужно включить экран в `Game mode routines`. Это находится в [Engine/Core/Security Startup 2.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/blob/Clone-Driver-v2/Engine/Core/Security%20Startup%202.asm)

Добавим его в список игровых режимов:

```diff
 ; ---------------------------------------------------------------------------
 ; Main game mode array
 ; ---------------------------------------------------------------------------

 Game_Modes:
+		GameModeEntry SplashScreen						; Splash mode
		GameModeEntry LevelSelectScreen					; Level Select mode (SCE)
		GameModeEntry LevelScreen						; Zone play mode
		GameModeEntry ContinueScreen					; Continue mode
```

Макрос `GameModeEntry` будет использовать вставленную переменную для поиска экрана. Поэтому названия должы быть одинаковые.

## Меняем начальный режим игры (необязательно)

 Если вы хотите чтобы игра начиналась со Splash Screen, а не Level Select, то измените эту строчку кода в том же `Security Startup 2.asm`

```m68k
move.b	#GameModeID_LevelSelectScreen,(Game_mode).w
```

На эту строчку кода:

```m68k
move.b	#GameModeID_SplashScreen,(Game_mode).w
```

Вместо `Level Select` теперь первым будет грузиться наш новый `Splash Screen`.

# Посмотреть другие гайды

[Вернуться на главную страницу](../)
