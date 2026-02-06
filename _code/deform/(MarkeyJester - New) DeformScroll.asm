; ---------------------------------------------------------------------------
; Deform scanlines correctly using a list (S3K/SCE version)
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
