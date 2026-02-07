# SONIC-CLEAN-ENGINE-S.C.E.-

# Как добавить ещё уровней?

Чтобы добавить новый уровень, нужно проделать несколько несложных шагов:
1. Изменить количество уровней
2. Создать файлы нового уровня
3. Добавить соответствующие данные новой зоны в различных файлах
# Первые шаги
## Берём файлы

Для примера, мы скопируем уже имеющийся Levels/DEZ и переименуем его в AIZ, не из воздуха же файлы брать?

Не забудьте также переименовать файлы в папке Levels/AIZ, а также содержимое `.asm` файлов в ней. 

Вот список файлов в которые нужно внести замену DEZ на AIZ:
* Levels/AIZ/Debug/AIZ1 - Debug List.asm
* Levels/AIZ/Events/AIZ1 - Events.asm
* Levels/AIZ/Palettes/AIZ1 - Animation Palette Scripts.asm
- Levels/AIZ/Tiles/Animated/AIZ1 - Animation PLC Scripts.asm

А также для:
- Levels/AIZ/Pointers/AIZ1 - Pointers.asm
- Levels/AIZ/Pointers/AIZ1 - Pointers.asm
- Levels/AIZ/Pointers/AIZ1 - Pointers.asm
- Levels/AIZ/Pointers/AIZ1 - Pointers.asm
Пока не меняйте в ним `mus_DEZ1` на `mus_AIZ1`, мы это сделаем в [гайде по добавлению музыки](типа_гайд).
## Вносим изменения в код

Для начала нам нужно изменить количество уровней в [Engine/Settings.asm]([Engine/Settings.asm)

```
ZoneCount:				= 1	; set discrete zones are: DEZ
```

Меняем единицу на нужное нам количество.

```
ZoneCount:				= 2	; set discrete zones are: DEZ, New Zone
```

> [!TIP]
> Добавляйте по одному уровню выполнив все шаги, укажите сразу большое количество, то потом легко потеряйтесь и не получите никакого результата.

Если попытаться сейчас собрать ROM, то ничего не получится, так как сборщик ожидает ещё одного уровня и ищет его данные, которые мы ещё не добавили!

```console
The current RAM available $275C bytes.
Sonic 2 Clone Driver v2 RAM size is $3C5 bytes!
Assembler failed to execute.
> > > Objects/Main/Title Card/Text Data/VRAM - Text.asm(8) zonewarning(3): error: Size of TitleCardLetters_Index (1) does not match ZoneCount (2).
> > >                 fatal "Size of TitleCardLetters_Index (\{(._end-TitleCardLetters_Index)/(1*2)}) does not match ZoneCount (\{ZoneCount})."
fatal error, assembly terminated

**********************************************************************
*                                                                    *
*      There were build errors. See S3CE.log for more details.       *
*                                                                    *
**********************************************************************
```

# Добавляем данные

Просто скопируйте строки от DEZ и переименуйте их в AIZ, в следующем параграфе будет пример.

Нужно добавить данные новой зоны в существующие файлы:
- Data/Debug Pointers.asm
- Data/Levels Data.asm
- Data/Levels Events.asm
- Data/Palette Data.asm
- Data/Palette Pointers.asm
- Data/Pattern Load Cues.asm
- Data/Uncompressed Data.asm
- Engine/Constants.asm
- Objects/Main/Animals/Animals.asm
- Objects/Main/Egg Capsule/Egg Capsule.asm
- Objects/Main/Title Card/Text Data/VRAM - Text.asm
- Screens/Level Select/Level Setup.asm

# Пример изменений

Можете посмотреть изменения в этом параграфе или в коммитах на GitHub [ТУТ](https://github.com/Nichloya/Sonic-Clean-Engine-S.C.E.-Extended-/commit/ba6bcbc4962d853336950f894c7d24859b082f7e) и [ТУТ](https://github.com/Nichloya/Sonic-Clean-Engine-S.C.E.-Extended-/commit/e6bdac551d5c4ff7daa77b8b18e053d3394683ea).

```diff
+ Добавьте зелёные строки, начинающиеся с плюса (сам плюс добавлять не надо).
- Красные строки наоборот, вы должны удалить.
```

## Data/Debug Pointers.asm

```diff
		; DEZ
		include "Levels/DEZ/Debug/DEZ1 - Debug List.asm"
		
+		; AIZ
+		include "Levels/AIZ/Debug/AIZ1 - Debug List.asm"
```
## Data/Levels Data.asm

```diff
LevelLoadPointer:
		; DEZ
		include "Levels/DEZ/Pointers/DEZ1 - Pointers.asm"
		include "Levels/DEZ/Pointers/DEZ2 - Pointers.asm"
		include "Levels/DEZ/Pointers/DEZ3 - Pointers.asm"
		include "Levels/DEZ/Pointers/DEZ4 - Pointers.asm"

+		; AIZ
+		include "Levels/AIZ/Pointers/AIZ1 - Pointers.asm"
+		include "Levels/AIZ/Pointers/AIZ2 - Pointers.asm"
+		include "Levels/AIZ/Pointers/AIZ3 - Pointers.asm"
+		include "Levels/AIZ/Pointers/AIZ4 - Pointers.asm"

		zonewarning LevelLoadPointer,((Level_data_addr_RAM_end-Level_data_addr_RAM)*4)
```

```diff
; ===========================================================================
; Compressed level graphics - tile, primary patterns and block mappings
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	DEZ_8x8_KosPM, "Levels/DEZ/Tiles/Primary.kospm"
		incfile.b	DEZ_16x16_Unc, "Levels/DEZ/Blocks/Primary.unc"
		incfile.b	DEZ_128x128_KosP, "Levels/DEZ/Chunks/Primary.kosp"
		
+		incfile.b	AIZ_8x8_KosPM, "Levels/AIZ/Tiles/Primary.kospm"
+		incfile.b	AIZ_16x16_Unc, "Levels/AIZ/Blocks/Primary.unc"
+		incfile.b	AIZ_128x128_KosP, "Levels/AIZ/Chunks/Primary.kosp"
```

```diff
; ===========================================================================
; Level collision data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	DEZ_Solid_Unc, "Levels/DEZ/Collision/1.unc"		
+		incfile.b	AIZ_Solid_Unc, "Levels/AIZ/Collision/1.unc"
```

```diff
; ===========================================================================
; Level layout data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	DEZ1_Layout_Unc, "Levels/DEZ/Layout/1.unc"
		incfile.b	DEZ2_Layout_Unc, "Levels/DEZ/Layout/2.unc"
		incfile.b	DEZ3_Layout_Unc, "Levels/DEZ/Layout/3.unc"
		incfile.b	DEZ4_Layout_Unc, "Levels/DEZ/Layout/4.unc"


+		incfile.b	AIZ1_Layout_Unc, "Levels/AIZ/Layout/1.unc"
+		incfile.b	AIZ2_Layout_Unc, "Levels/AIZ/Layout/2.unc"
+		incfile.b	AIZ3_Layout_Unc, "Levels/AIZ/Layout/3.unc"
+		incfile.b	AIZ4_Layout_Unc, "Levels/AIZ/Layout/4.unc"	
```

```diff
; ===========================================================================
; Level objects data
; ===========================================================================

		; ObjectTerminat
		ObjectLayoutBoundary

;		Attribute	| Filename	| Folder

		incfile.bo	DEZ1_Objects_Unc, "Levels/DEZ/Object Pos/1.unc"
		incfile.bo	DEZ2_Objects_Unc, "Levels/DEZ/Object Pos/2.unc"
		incfile.bo	DEZ3_Objects_Unc, "Levels/DEZ/Object Pos/3.unc"
		incfile.bo	DEZ4_Objects_Unc, "Levels/DEZ/Object Pos/4.unc"

+		incfile.bo	AIZ1_Objects_Unc, "Levels/AIZ/Object Pos/1.unc"
+		incfile.bo	AIZ2_Objects_Unc, "Levels/AIZ/Object Pos/2.unc"
+		incfile.bo	AIZ3_Objects_Unc, "Levels/AIZ/Object Pos/3.unc"
+		incfile.bo	AIZ4_Objects_Unc, "Levels/AIZ/Object Pos/4.unc"	
```


```diff
; ===========================================================================
; Level rings data
; ===========================================================================

		; RingTerminat
		RingLayoutBoundary

;		Attribute	| Filename	| Folder

		incfile.br	DEZ1_Rings_Unc, "Levels/DEZ/Ring Pos/1.unc"
		incfile.br	DEZ2_Rings_Unc, "Levels/DEZ/Ring Pos/2.unc"
		incfile.br	DEZ3_Rings_Unc, "Levels/DEZ/Ring Pos/3.unc"
		incfile.br	DEZ4_Rings_Unc, "Levels/DEZ/Ring Pos/4.unc"

+		incfile.br	AIZ1_Rings_Unc, "Levels/AIZ/Ring Pos/1.unc"
+		incfile.br	AIZ2_Rings_Unc, "Levels/AIZ/Ring Pos/2.unc"
+		incfile.br	AIZ3_Rings_Unc, "Levels/AIZ/Ring Pos/3.unc"
+		incfile.br	AIZ4_Rings_Unc, "Levels/AIZ/Ring Pos/4.unc
```
## Data/Levels Events.asm
```diff
 		include "Levels/DEZ/Tiles/Animated/DEZ1 - Animation PLC Scripts.asm"
 		include "Levels/DEZ/Palettes/Animated/DEZ1 - Animation Palette Scripts.asm"
 		include "Levels/DEZ/Events/DEZ1 - Events.asm"
 		
+		; AIZ
+		include "Levels/AIZ/Tiles/Animated/AIZ1 - Animation PLC Scripts.asm"
+		include "Levels/AIZ/Palettes/Animated/AIZ1 - Animation Palette Scripts.asm"
+		include "Levels/AIZ/Events/AIZ1 - Events.asm"
```
## Data/Palette Data.asm
```diff
; ===========================================================================
; Palette Level screen data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.be	Pal_DEZ, "Levels/DEZ/Palettes/Death Egg Zone.pal"
		incfile.be	Pal_WaterDEZ, "Levels/DEZ/Palettes/Water Death Egg Zone.pal"
+		incfile.be	Pal_AIZ, "Levels/AIZ/Palettes/Angel Island Zone.pal"
+		incfile.be	Pal_WaterAIZ, "Levels/AIZ/Palettes/Water Angel Island Zone.pal"	

; ===========================================================================
; Animated palette Level screen data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	AnPal_PalDEZ12_1, "Levels/DEZ/Palettes/Animated/Palettes/1.pal"
		incfile.b	AnPal_PalDEZ12_2, "Levels/DEZ/Palettes/Animated/Palettes/2.pal"
+		incfile.b	AnPal_PalAIZ12_1, "Levels/AIZ/Palettes/Animated/Palettes/1.pal"
+		incfile.b	AnPal_PalAIZ12_2, "Levels/AIZ/Palettes/Animated/Palettes/2.pal"
```
## Data/Palette Pointers.asm

```diff
; Levels
  PalPtr_DEZ: palptr Pal_DEZ, 1 ; 2 - DEZ
  PalPtr_WaterDEZ: palptr Pal_WaterDEZ, 1 ; 3 - Water DEZ
+ PalPtr_AIZ: palptr Pal_AIZ, 1 ; 2 - AIZ
+ PalPtr_WaterAIZ: palptr Pal_WaterAIZ, 1 ; 3 - Water AIZ
```

## Data/Pattern Load Cues.asm
```diff
  PLCAnimals_DEZ1: plrlistheader
  		plreq $580, ArtKosPM_BlueFlicky
   		plreq $592, ArtKosPM_Chicken
  PLCAnimals_DEZ1_end

+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (Before)
+ ; ===========================================================================
+
+ PLC1_AIZ1_Before: plrlistheader
+ 		plreq $47E, ArtKosPM_GrayButton					; button
+ PLC1_AIZ1_Before_end
+
+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (After)
+ ; ===========================================================================
+
+ PLC2_AIZ1_After: plrlistheader
+		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
+ PLC2_AIZ1_After_end
+
+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (Before)
+ ; ===========================================================================
+
+ PLC1_AIZ2_Before: plrlistheader
+		plreq $47E, ArtKosPM_GrayButton					; button
+ PLC1_AIZ2_Before_end
+
+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (After)
+ ; ===========================================================================
+
+ PLC2_AIZ2_After: plrlistheader
+		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
+ PLC2_AIZ2_After_end
+
+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (Before)
+ ; ===========================================================================
+
+ PLC1_AIZ3_Before: plrlistheader
+		plreq $47E, ArtKosPM_GrayButton					; button
+ PLC1_AIZ3_Before_end
+
+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (After)
+ ; ===========================================================================
+
+ PLC2_AIZ3_After: plrlistheader
+		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
+ PLC2_AIZ3_After_end
+
+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (Before)
+ ; ===========================================================================
+
+ PLC1_AIZ4_Before: plrlistheader
+		plreq $47E, ArtKosPM_GrayButton					; button
+ PLC1_AIZ4_Before_end
+
+ ; ===========================================================================
+ ; Pattern load cues - Angel Island Zone (After)
+ ; ===========================================================================
+
+ PLC2_AIZ4_After: plrlistheader
+		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
+ PLC2_AIZ4_After_end
+
+ ; ===========================================================================
+ ; Level pattern load cues
+ ; Load animals graphics
+ ; ===========================================================================
+
+ ; ===========================================================================
+ ; Pattern load cues - Animals (AIZ1)
+ ; ===========================================================================
+
+ PLCAnimals_AIZ1: plrlistheader
+		plreq $580, ArtKosPM_BlueFlicky
+		plreq $592, ArtKosPM_Chicken
+ PLCAnimals_AIZ1_end
```
## Data/Uncompressed Data.asm
```diff
 incfile.b ArtUnc_AniDEZ__4, "Levels/DEZ/Tiles/Animated/Uncompressed Art/4.unc"
 incfile.b ArtUnc_AniDEZ__5, "Levels/DEZ/Tiles/Animated/Uncompressed Art/5.unc"
 incfile.b ArtUnc_AniDEZ__6, "Levels/DEZ/Tiles/Animated/Uncompressed Art/6.unc"

+ incfile.b ArtUnc_AniAIZ__3, "Levels/AIZ/Tiles/Animated/Uncompressed Art/3.unc"
+ incfile.b ArtUnc_AniAIZ__4, "Levels/AIZ/Tiles/Animated/Uncompressed Art/4.unc"
+ incfile.b ArtUnc_AniAIZ__5, "Levels/AIZ/Tiles/Animated/Uncompressed Art/5.unc"
+ incfile.b ArtUnc_AniAIZ__6, "Levels/AIZ/Tiles/Animated/Uncompressed Art/6.unc"
```
## Engine/Constants.asm
```diff
; Levels
  PalID_DEZ = id(PalPtr_DEZ) ; 2
  PalID_WaterDEZ = id(PalPtr_WaterDEZ) ; 3

+ PalID_AIZ = id(PalPtr_AIZ) ; 2
+ PalID_WaterAIZ = id(PalPtr_WaterAIZ) ; 3
```

```diff
; ---------------------------------------------------------------------------
; Levels
; ---------------------------------------------------------------------------

 LevelID_DEZ =							0						; Death Egg
+LevelID_AIZ =							0						; Angel Island
 LevelID_NULL =							$FF						; NULL
```

# Objects/Main/Animals/Animals.asm
```diff
Obj_Animal_ZoneAnimals:
  zoneanimals.b Flicky, Chicken ; DEZ
+ zoneanimals.b Flicky, Chicken ;

 zonewarning Obj_Animal_ZoneAnimals,(1*2)
```
# Objects/Main/Egg Capsule/Egg Capsule.asm
```diff
.subindex ; $A, $E, $10 only (sub_866BA, sub_866DA, sub_866EC)
  dc.l sub_866BA ; DEZ
+ dc.l sub_866BA ; DEZ

 zonewarning .subindex,(1*4)
```
## Objects/Main/Title Card/Text Data/VRAM - Text.asm
```diff
TitleCardLetters_Index: offsetTable
		offsetTableEntry.w TitleCard_DEZ	; 0
		offsetTableEntry.w TitleCard_AIZ	; 0

		zonewarning TitleCardLetters_Index,(1*2)

; find unique letters and load it to VRAM
TitleCard_DEZ:		titlecardLetters FALSE, "DEATH EGG"
	even
+TitleCard_AIZ:		titlecardLetters FALSE, "DEATH EGG"
+	even
```
## Screens/Level Select/Level Setup.asm
```diff
; Variables
  LevelSelect_ZoneCount:			= ZoneCount
  LevelSelect_ActDEZCount:		= 4						; DEZ
+ LevelSelect_ActAIZCount:		= 4						; AIZ
```

```diff
.maxacts
		dc.w LevelSelect_ActDEZCount-1	; DEZ
+		dc.w LevelSelect_ActAIZCount-1	; AIZ

		zonewarning .maxacts,(2*1)
```

```diff
LevelSelect_ActTextIndex: offsetTable
		offsetTableEntry.w LevelSelect_LoadAct1		; DEZ1
		offsetTableEntry.w LevelSelect_LoadAct2		; DEZ2
		offsetTableEntry.w LevelSelect_LoadAct3		; DEZ3
		offsetTableEntry.w LevelSelect_LoadAct4		; DEZ4

+		offsetTableEntry.w LevelSelect_LoadAct1		; AIZ1
+		offsetTableEntry.w LevelSelect_LoadAct2		; AIZ2
+		offsetTableEntry.w LevelSelect_LoadAct3		; AIZ3
+		offsetTableEntry.w LevelSelect_LoadAct4		; AIZ4

		zonewarning LevelSelect_ActTextIndex,(2*4)
```

```diff
; main text
LevelSelect_MainText:
		levselstr "   DEATH EGG          - ACT 1"
-		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
+		levselstr "   ANGEL ISLAND       - ACT 1"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
```

# Устранение проблем
## Количество уровней указано правильно, но LevelLoadPointer не видит уровни

```console
Assembler failed to execute.
> > > Data/Levels Data.asm(19) zonewarning(3): error: Size of LevelLoadPointer (1) does not match ZoneCount (2).
> > >                 fatal "Size of LevelLoadPointer (\{(._end-LevelLoadPointer)/((Level_data_addr_RAM_end-Level_data_addr_RAM)*4)}) does not match ZoneCount (\{ZoneCount})."
fatal error, assembly terminated
```

Скорее всего вы копируйте уровень из `S.C.E. (Alone)` в `S.C.E.-Extended`/`S1S3` или наоборот, поэтому нужно внести изменения в `/Levels/%имя_зоны%/Pointers/%имя_зоны% - Pointers.asm`, найдите там `; Players palette` и внесите изменения которые представлены ниже.
### Если у вас S.C.E. (Alone)
```
		; Sonic palette, Knuckles palette
		dc.b PalID_Sonic
		dc.b PalID_Sonic							; Unused

		; Water Sonic palette, Water Knuckles palette
		dc.b PalID_WaterSonic
		dc.b PalID_WaterSonic						; Unused

		; Players start location
		binclude "Levels/AIZ/Start Location/1.bin"
```
### Если у вас S.C.E.-Extended/S1S3

```
		; Players palette
		dc.b PalID_Sonic
		dc.b PalID_Knuckles

		; Players water palette
		dc.b PalID_WaterSonic
		dc.b PalID_WaterKnuckles

		; Players start location
		binclude "Levels/DEZ/Start Location/Sonic/1.bin"
		binclude "Levels/DEZ/Start Location/Knuckles/1.bin"
```

## Посмотреть другие гайды

[Вернуться на главную страницу](../)
