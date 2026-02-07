# SONIC-CLEAN-ENGINE-S.C.E.-

# Как добавить новый Splash Screen?

Для начала нам нужно открыть папку `Screens` и создать новую папку например `Splash` с нашим новым Splash Screen. Затем мы должны создать текстовый файл и переименовать его в `Splash.asm`

И затем вставить этот готовый код:

\
```asm
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
		move.b	#GameModeID_LevelSelectScreen,(Game_mode).w				; set screen mode to Level Select (SCE)
		rts
```

# Пример изменений

```diff
+ Добавьте зелёные строки, начинающиеся с плюса (сам плюс добавлять не надо).
- Красные строки наоборот, вы должны удалить.
```

Затем нам нужно открыть `Includes.asm` в основной папке `Engine` и найти список включаемых экранов

```diff
; ---------------------------------------------------------------------------
; Level Select screen modules
; ---------------------------------------------------------------------------

		include "Screens/Level Select/Level Select.asm"

; ---------------------------------------------------------------------------
; Level screen modules
; ---------------------------------------------------------------------------

		include "Screens/Level/Level.asm"
```

Теперь нам нужно добавить наш Splash Screen в этот список includes


```diff
+ ; ---------------------------------------------------------------------------
+ ; Splash screen modules
+ ; ---------------------------------------------------------------------------
+
+		include "Screens/Splash/Splash.asm"

; ---------------------------------------------------------------------------
; Level Select screen modules
; ---------------------------------------------------------------------------

		include "Screens/Level Select/Level Select.asm"

; ---------------------------------------------------------------------------
; Level screen modules
; ---------------------------------------------------------------------------

		include "Screens/Level/Level.asm"
```

Дальше нам нужно открыть `Constants.asm` и добавить наш новый экран в список констант Game mode routines

```diff
; ---------------------------------------------------------------------------
; Game mode routines
; ---------------------------------------------------------------------------

offset := Game_Modes
ptrsize := 1
idstart := 0

GameModeID_LevelSelectScreen =					id(GameMode_LevelSelectScreen)			; 0
GameModeID_LevelScreen =					id(GameMode_LevelScreen)			; 4

GameModeFlag_TitleCard =					7						; flag bit
GameModeID_TitleCard =						setBit(GameModeFlag_TitleCard)			; flag mask
```

Это должно выглядеть так

```diff
; ---------------------------------------------------------------------------
; Game mode routines
; ---------------------------------------------------------------------------

offset := Game_Modes
ptrsize := 1
idstart := 0

+ GameModeID_SplashScreen =					id(GameMode_SplashScreen)			; 0
GameModeID_LevelSelectScreen =					id(GameMode_LevelSelectScreen)			; 4
GameModeID_LevelScreen =					id(GameMode_LevelScreen)			; 8

GameModeFlag_TitleCard =					7						; flag bit
GameModeID_TitleCard =						setBit(GameModeFlag_TitleCard)			; flag mask
```

Теперь нужно включить экран в Game mode routines. Это находится по пути `Engine/Core' и нужно открыть `Security Startup 2.asm`

Здесь будет список экранов

```diff
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

Game_Modes:
		GameModeEntry LevelSelectScreen						; Level Select mode (SCE)
		GameModeEntry LevelScreen						; Zone play mode
```

Сделайте так

```diff
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

Game_Modes:
+		GameModeEntry SplashScreen						; Splash mode
		GameModeEntry LevelSelectScreen						; Level Select mode (SCE)
		GameModeEntry LevelScreen						; Zone play mode
```

Макрос GameModeEntry будет использовать вставленную переменную для поиска экрана. Поэтому названия должы быть одинаковые.


Если вы хотите изменить начальный экран загрузки, то измените эту строчку в том же `Security Startup 2.asm`

```asm
		move.b	#GameModeID_LevelSelectScreen,(Game_mode).w			; set screen mode to Level Select (SCE)
```

На эту строчку

```asm
		move.b	#GameModeID_SplashScreen,(Game_mode).w			; set screen mode to Splash Screen
```

Теперь вместо Level Select первым будет грузиться Splash Screen

\
Теперь нужно добавить данные для Splash Screen. Нужно открыть папку `Data` и включить наши данные

\
Для графики это `Kosinski Plus Module Data.asm`


```diff
; ===========================================================================
; Kosinski Plus Module compressed Splash screen graphics
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	ArtKosPM_Splash, "Screens/Splash/KosinskiPM Art/Foreground.kospm"
```

Для маппингов это `Enigma Data.asm`


```diff
; ===========================================================================
; Enigma compressed Splash screen data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	MapEni_Splash, "Screens/Splash/Enigma Map/Foreground.eni"
```


Для палитры это `Palette Data.asm`

```diff
; ===========================================================================
; Palette Splash screen data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	Pal_Splash, "Screens/Splash/Palettes/1.pal"
```

\
Как создавать файлы для Splash Screen смотрите в `этом гайде`


## Посмотреть другие гайды

[Вернуться на главную страницу](../)
