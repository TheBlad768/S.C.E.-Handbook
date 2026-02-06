# SONIC-CLEAN-ENGINE-S.C.E.-

Если вы по какой-то причине не хотите использовать функцию деформации из Sonic 3 & Knuckles, то здесь есть альтернативный адаптированный код для S3K/SCE от MarkeyJester.

\
Вот ссылка на официальный пост на SSRG:

https://sonicresearch.org/community/index.php?threads/how-to-work-with-background-deformation.4607/#post-68237

\
Здесь адаптированный код `DeformScroll` для SCE:

```asm
; ---------------------------------------------------------------------------
; Deform scanlines correctly using a list
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DeformScroll:
		lea	(H_scroll_buffer).w,a1			; load H-scroll buffer
		move.w	#$00E0,d6				; prepare number of scanlines
		move.w	(Camera_Y_pos_BG_copy).w,d5		; load Y position
		move.l	(Camera_X_pos_copy).w,d1		; prepare FG X position
		neg.l	d1					; reverse position

DS_FindStart:
		move.w	(a4)+,d0				; load scroll speed address
		beq.s	DS_Last					; if the list is finished, branch
		movea.w	d0,a5					; set scroll speed address
		sub.w	(a4)+,d5				; subtract size
		bpl.s	DS_FindStart				; if we haven't reached the start, branch
		neg.w	d5					; get remaining size
		sub.w	d5,d6					; subtract from total screen size
		bmi.s	DS_EndSection				; if the screen is finished, branch

DS_NextSection:
		subq.w	#$01,d5					; convert for dbf
		move.w	(a5),d1					; load X position

DS_NextScanline:
		move.l	d1,(a1)+				; save scroll position
		dbf	d5,DS_NextScanline			; repeat for all scanlines
		move.w	(a4)+,d0				; load scroll speed address
		beq.s	DS_Last					; if the list is finished, branch
		movea.w	d0,a5					; set scroll speed address
		move.w	(a4)+,d5				; load size

DS_CheckSection:
		sub.w	d5,d6					; subtract from total screen size
		bpl.s	DS_NextSection				; if the screen is not finished, branch

DS_EndSection:
		add.w	d5,d6					; get remaining screen size and use that instead

DS_Last:
		subq.w	#$01,d6					; convert for dbf
		bmi.s	DS_Finish				; if finished, branch
		move.w	(a5),d1					; load X position

DS_LastScanlines:
		move.l	d1,(a1)+				; save scroll position
		dbf	d6,DS_LastScanlines			; repeat for all scanlines

DS_Finish:
		rts						; return
```

\
MarkeyJester также сделал обновлённую версию DeformScroll, но никогда не выпускал это официально. Вы можете использовать этот код без каких либо проблем.

```asm
; ---------------------------------------------------------------------------
; Deform scanlines correctly using a list
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DeformScroll:
		lea	(H_scroll_buffer).w,a1			; load H-scroll buffer
		move.w	(Camera_Y_pos_BG_copy).w,d5		; load Y position
		move.l	(Camera_X_pos_copy).w,d1		; prepare FG X position
		neg.l	d1					; reverse position
		move.w	#224,d6					; total screen height
		lea	(a4),a5					; set initial address to be 0 (if empty, scroll will be 0)
		lea	.Copy(pc),a6				; load copy list

	.Start:
		move.w	(a4)+,d0				; load scroll speed address
		beq.s	.Last					; if the list is finished, branch
		movea.w	d0,a5					; set scroll speed address
		sub.w	(a4)+,d5				; subtract size
		bhs.s	.Start					; if we haven't reached the start, branch
		add.w	d5,d6					; subtract from total screen height
		bhs.s	.End					; if finished, branch
		neg.w	d5					; convert to positive (to counter the neg below)

	.Next:
		move.w	(a5),d1					; load BG X position
		neg.w	d5					; x2 bytes for every x1 scanline
		add.w	d5,d5					; ''
		jsr	(a6,d5.w)				; write scanlines
		move.w	(a4)+,d0				; load next scroll speed address
		beq.s	.Last					; if the list is finished, branch
		movea.w	d0,a5					; set scroll speed address
		move.w	(a4)+,d5				; load next size
		sub.w	d5,d6					; subtract from remaining screen height
		bhs.s	.Next					; if still more length after, repeat
		neg.w	d5					; convert for subtraction below

	.End:
		sub.w	d5,d6					; restore remaining height

	.Last:
		move.w	(a5),d1					; load X position
		neg.w	d6					; x2 bytes for every x1 scanline
		add.w	d6,d6					; ''
		jmp	(a6,d6.w)				; write scanlines

		rept	224
		move.l	d1,(a1)+				; write scroll position
		endm
	.Copy:	rts						; done
```

\
Готовые asm библиотеки также лежат в [этой папке](../../_code/deform)

\
Пример использования кода в SCE:

```asm
; ---------------------------------------------------------------------------
; DEZ events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenInit:

		; update FG
		jsr	(Reset_TileOffsetPositionActual).w
		jmp	(Refresh_PlaneFull).w

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenEvent:
		move.w	(Screen_shaking_offset).w,d0		; shake foreground
		add.w	d0,(Camera_Y_pos_copy).w
		jmp	(DrawTilesAsYouMove).w

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundInit:
		bsr.s	DEZ1_Deform

		; update BG
		jsr	(Reset_TileOffsetPositionEff).w
		jsr	(Refresh_PlaneFull).w

		; deform
		lea	DEZ1_BGDeformArray(pc),a4
		jmp	(DeformScroll).w

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundEvent:
		tst.b	(Background_event_flag).w
		bne.s	DEZ1_Transition
		bsr.s	DEZ1_Deform

.deform
		lea	DEZ1_BGDeformArray(pc),a4
		jsr	(DeformScroll).w

		jmp	(ShakeScreen_Setup).w
; ---------------------------------------------------------------------------

DEZ1_Transition:
		clr.b	(Background_event_flag).w
		rts

; =============== S U B R O U T I N E =======================================

DEZ1_Deform:

		; yscroll
		move.w	(Camera_Y_pos_copy).w,d0		; load Y position
		asr.w	#6,d0					; divide by $40
		move.w	d0,(Camera_Y_pos_BG_copy).w		; set speed

		; xscroll
		move.w	(Camera_X_pos_copy).w,d0		; load X position
		neg.w	d0					; reverse direction
		asr.w	#$03,d0					; divide by 8
		move.w	d0,(H_scroll_table).w			; set speed 1

		move.w	(Camera_X_pos_copy).w,d0		; load X position
		neg.w	d0					; reverse direction
		asr.w	#$02,d0					; divide by 4
		move.w	d0,(H_scroll_table+2).w			; set speed 2
		rts

; =============== S U B R O U T I N E =======================================

DEZ1_BGDeformArray:
		dc.w H_scroll_table,  $70			; top 70 scroll
		dc.w H_scroll_table+2,  $70			; bottom 70 scroll
		dc.w $0000					; end marker
```


## Посмотреть другие гайды

[Вернуться на главную страницу](../)
