;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
INCLUDE_SIGN    equ FALSE

;-----------------------------------------------------------------------
include     windows.inc
include     macros.asm
include     xmacros.mac

includes    user32, kernel32, sha1

include     bignum.inc
includelib  bignum.lib

include     dsa.inc

;-----------------------------------------------------------------------
.data?
    public_key  spublic    <?>
    IF  INCLUDE_SIGN
    private_key sprivate   <?>
    ENDIF
    signature   ssignature <?>
    sha1        ssha1_ctx  <>

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
    dsa_H   proc    lpH, lpmessage, dwlen:byte
        invoke  sha1_init, addr sha1
        invoke  sha1_update, addr sha1, lpmessage, dwlen
        invoke  sha1_final, addr sha1
        mov     edx, lpH
        invoke  Bytes2bn, eax, 4*5, [edx], FALSE
        ret
    dsa_H   endp

;-----------------------------------------------------------------------
IF  INCLUDE_SIGN
    dsa_sign    proc    lpmessage, dwlen:byte, lpsignature_r, lpsignature_s
        local   temp1, k, H, r, s
        
        bnCreateX   temp1, k, H, r, s
        
        invoke  bnMovzx, k, 3
        
        ;to sign a message:
        ;   r = (g^k mod p) mod q
        invoke  bnPowMod, public_key.g, k, public_key.p, r
        invoke  bnMod, r, public_key.q, r
        
        ;   s = k^-1*(H(m)+x*r)) mod q
        invoke  bnModInv, k, public_key.q, k          ; k^-1
        
                                                    ; temp1 = x * r
        invoke  bnMulMod, private_key.x, r, public_key.q, temp1

        invoke  dsa_H, addr H, lpmessage, dwlen
        
        ; H + x*r mod q
        invoke  bnAdd, H, temp1
        invoke  bnMod, H, public_key.q, H
        
        ; s = (H+x*r * k^-1) mod q
        invoke  bnMulMod, H, k, public_key.q, s
        
        invoke  bn2Bytes, s, lpsignature_s
        invoke  bn2Bytes, r, lpsignature_r
        
        bnDestroyX
        
        ret
    dsa_sign    endp
ENDIF
;-----------------------------------------------------------------------    
    dsa_verify  proc    lpmessage, dwlen:byte, lpr, lps
        local   w, u1, u2, v, H, r, s

        bnCreateX   w, u1, u2, v, H, r, s
       
        invoke  Bytes2bn, lpr, 8, r, FALSE
        invoke  Bytes2bn, lps, 8, s, FALSE
        
        ; reject if r > q or s > q or r = 0, s = 0
        ; w = s^-1 mod q
        ; u1 = H(m)*w mod q
        ; u2 = r*w mod q
        ; v = (g^u1*y^u2 mod p) mod q
        ; v == r

        ; w = s^-1 mod q
        invoke  bnModInv, s, public_key.q, w

        ; u1 = H*w mod q
        invoke  dsa_H, addr H, lpmessage, dwlen
        invoke  bnMulMod, H, w, public_key.q, u1
        
        ; u2 = r*w mod q
        invoke  bnMulMod, r, w, public_key.q, u2
        
        ; g^u1 mod p
        invoke  bnPowMod, public_key.g, u1, public_key.p, u1
        
        ; y^u2 mod p
        invoke  bnPowMod, public_key.y, u2, public_key.p, u2
        
        ; g^u1 * y^u2
        invoke  bnMulMod, u1, u2, public_key.p, v
        invoke  bnMod, v, public_key.q, v
        
        invoke  bnCmp, v, r
        ;.if     !eax
        ;    invoke  MessageBox, 0, SADD("fucking great!"), SADD("good!"), MB_ICONINFORMATION
        ;.else
        ;    invoke  MessageBox, 0, SADD("Something wrong men"), SADD("nope"), MB_ICONERROR
        ;.endif
        mov     ebx, eax

        bnDestroyX
        mov     eax, ebx
        ret
    dsa_verify  endp

;-----------------------------------------------------------------------
    dsa_init    proc
        
        invoke  bnCreate
        mov     public_key.p, eax

        invoke  bnCreate
        mov     public_key.q, eax

        invoke  bnCreate
        mov     public_key.g, eax

        invoke  bnCreate
        mov     public_key.y, eax
        
        IF  INCLUDE_SIGN
        invoke  bnCreate
        mov     private_key.x, eax
        ENDIF

        ret
    dsa_init    endp

;-----------------------------------------------------------------------    
    dsa_setparams   proc    lpp, lpq, lpg, lpy, lpx
        local   h, q, r
        
        invoke  Bytes2bn, lpp, 8, public_key.p, FALSE
        invoke  Bytes2bn, lpq, 8, public_key.q, FALSE
        invoke  Bytes2bn, lpg, 8, public_key.g, FALSE
        invoke  Bytes2bn, lpy, 8, public_key.y, FALSE
        
        IF  INCLUDE_SIGN
        invoke  Bytes2bn, lpx, 8, private_key.x, FALSE
        ENDIF
       
        ret
    dsa_setparams   endp

;-----------------------------------------------------------------------
    end
;-----------------------------------------------------------------------
