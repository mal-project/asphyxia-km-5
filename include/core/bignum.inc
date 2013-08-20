.const
bn2Bytes				PROTO	:DWORD,:DWORD
bn2Hex					PROTO	:DWORD,:DWORD
bn2Str					PROTO	:DWORD,:DWORD
bnAdd					PROTO	:DWORD,:DWORD
bnAddAbsDw				PROTO	:DWORD,:DWORD
bnBits					PROTO	:DWORD
bnClear					PROTO	:DWORD
bnSetZero				EQU		<bnClear>
bnCmp					PROTO	:DWORD,:DWORD
bnCmpAbs				PROTO	:DWORD,:DWORD
bnCreate				PROTO
bnCreatei				PROTO	:SDWORD
bnDec					PROTO	:DWORD
bnDestroy				PROTO	:DWORD
bnDiv					PROTO	:DWORD,:DWORD,:DWORD,:DWORD
bnDivDw					PROTO	:DWORD,:DWORD,:DWORD
bnDivpow2				PROTO	:DWORD,:DWORD,:DWORD
bnFermatpt				PROTO	:DWORD
bnFinish				PROTO
bnGCD					PROTO	:DWORD,:DWORD,:DWORD
bnInc					PROTO	:DWORD
bnInit					PROTO	:DWORD
bnLCM					PROTO	:DWORD,:DWORD,:DWORD
bnMod					PROTO	:DWORD,:DWORD,:DWORD
bnModExp				PROTO	:DWORD,:DWORD,:DWORD,:DWORD
bnPowMod				EQU		<bnModExp>
bnModInv				PROTO	:DWORD,:DWORD,:DWORD
bnMulpow2				PROTO	:DWORD,:DWORD,:DWORD
bnMontyModExp			PROTO	:DWORD,:DWORD,:DWORD,:DWORD
bnMov					PROTO	:DWORD,:DWORD
bnCopy					EQU		<bnMov>
bnMovsx					PROTO	:DWORD,:SDWORD
bnMovzx					PROTO	:DWORD,:DWORD
bnMul					PROTO	:DWORD,:DWORD,:DWORD
bnMul10					PROTO	:DWORD
bnMulDw					PROTO	:DWORD,:DWORD
bnMulMod				PROTO	:DWORD,:DWORD,:DWORD,:DWORD
bnMulpow2				PROTO	:DWORD,:DWORD,:DWORD
bnShl					PROTO	:DWORD,:DWORD
bnShl1					PROTO	:DWORD
bnShr					PROTO	:DWORD,:DWORD
bnShr1					PROTO	:DWORD
bnSquare				PROTO	:DWORD
bnSub					PROTO	:DWORD,:DWORD
bnTrialDiv				PROTO	:DWORD
bnXchg					PROTO	:DWORD,:DWORD
bnXGCD					PROTO	:DWORD,:DWORD,:DWORD,:DWORD
Bytes2bn				PROTO	:DWORD,:DWORD,:DWORD,:DWORD
Hex2bn					PROTO	:DWORD,:DWORD
Str2bn					PROTO	:DWORD,:DWORD
bn2BytesEx				PROTO	:DWORD,:DWORD
Bytes2bnEx				PROTO	:DWORD,:DWORD,:DWORD,:DWORD

_a_ textequ <align 16>

BN struct
	dwSize DWORD ?
	bSigned DWORD ?
	dwArray DWORD ?;,?,?,?,?,? ;BN_MAX_DWORD
BN ends
pBN typedef ptr BN

BN_DEFAULT_BITS equ 1024
;BN_LOOP_UNROLL equ 8

bnCreateX macro args:VARARG
	for arg,<args>
		invoke bnCreate
		mov &arg,eax
	endm
	bnDestroyX macro; args:VARARG
		for arg,<args>
			invoke bnDestroy,&arg
		endm
	endm 
endm


bnStackCreate macro args_locals:VARARG
	mov edx,BN_ALLOC_BYTES
	xor ecx,ecx
	for arg,<args_locals>
		sub esp,edx
		add ecx,edx
		mov &arg,esp
	endm
	mov edx,esp
	push edi
	xor eax,eax
	mov edi,edx
	shr ecx,2
	rep stosd
	pop edi
	inc eax
	for arg,<args_locals>
		mov edx,&arg
		mov [edx],eax
	endm
	bnStackFree macro
	LOCAL ii
		mov ecx,BN_ALLOC_BYTES
		ii = 0
		for arg,<args_locals>
			ii = ii + 1
		endm
		imul ecx,ii
		add esp,ecx
	endm

endm

BN_IS_ZERO macro bnreg:req
	exitm <(([bnreg].BN.dwSize == 1) && ([bnreg].BN.dwArray[0] == 0))>
endm 

;ABSolute
BN_IS_ONE macro bnreg:req
	exitm <(([bnreg].BN.dwSize == 1) && ([bnreg].BN.dwArray[0] == 1))>
endm 

BN_IS_EVEN macro bnreg:req
	exitm <(!([bnreg].BN.dwArray[0] & 1))>
endm

BN_IS_ODD macro bnreg:req
	exitm <([bnreg].BN.dwArray[0] & 1)>
endm

