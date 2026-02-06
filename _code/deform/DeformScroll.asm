; ---------------------------------------------------------------------------
; Deform scanlines correctly using a list (S3K/SCE version)
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
