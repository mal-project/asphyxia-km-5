; 8/11/2009 ------------------------------------------------------------
; +------------u  n  t  i  l----r  e  a  c  h----v  o  i  d------------¦
; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
; ¦            ¦¦        _   ¦¦            ¦¦           ¯¦¦       ¯    ¦
; ¦  ________  ¦¦___      ¯¯¯¦¦  ________  ¦¦            ¦¦¦_        ¯¦¦
; ¦     _      ¦¦   ¯        ¦¦           _¦¦        _   ¦¦   _        ¦
; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
; a         s         p         h        y         x         i         a
;
; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦

;-----------------------------------------------------------------------       
.code
;-----------------------------------------------------------------------
    decrypt_rsa_blowfishkey proc    lpview
        local   _c, _e, _x, _N, _M
        bnCreateX   _c, _e, _x, _N, _M
        
        ; M = c^e mod N
        mov     ebx, lpview
        invoke  Bytes2bn, addr (skeyfile ptr [ebx]).checksum, 32, _c, FALSE

        invoke  Bytes2bn, addr N, 32, _N, FALSE
        
        invoke  bnMovzx, _e, 10001h
        
        invoke  bnPowMod, _c, _e, _N, _M
        
        ;invoke  Bytes2bn, addr x, 32, _x, FALSE
        ;invoke  bnPowMod, _M, _x, _N, _c
        
        invoke  bn2Bytes, _M, addr (skeyfile ptr [ebx]).checksum
        
        bnDestroyX
        
        ret
    decrypt_rsa_blowfishkey endp

;-----------------------------------------------------------------------
    verify_checksum proc    lpview
        local   sha1:ssha1_ctx

        mov     ebx, lpview
        invoke  sha1_init, addr sha1
        invoke  sha1_update, addr sha1, ebx, sizeof skeyfile-32
        invoke  sha1_final, addr sha1
        
        mov     ecx, 5
        lea     esi, sha1
        lea     edi, (skeyfile ptr [ebx]).checksum
        repne   scasb
        setnz   al
        
        ret
    verify_checksum endp
    
;-----------------------------------------------------------------------
    file_open   proc
        invoke  _createfile, addr szfilename, _FILEIO_READWRITE, OPEN_EXISTING, FILE_MAP_COPY, NULL, addr fileio
        .if     !eax
            mov     ebx, fileio.hview
            invoke  decrypt_rsa_blowfishkey, ebx
            invoke  blowfish_init, addr (skeyfile ptr [ebx]).checksum, 20
            invoke  blowfish_decrypt, fileio.hview, sizeof skeyfile-32, 0
            
            invoke  verify_checksum, ebx

        .else
            xor     eax, eax
        
        .endif
        ret
    file_open   endp

;-----------------------------------------------------------------------
    file_close  proc
        invoke  _closefile, addr fileio
        ret
    file_close  endp

;-----------------------------------------------------------------------
    basic_check    proc    lpview
        mov     ebx, lpview
        lea     eax, (skeyfile ptr [ebx]).szname
        invoke  szLen, eax
        .if     eax <= _MAX_NAME_LENGTH && al == byte ptr (skeyfile ptr [ebx]).dbnamelength
            xor     eax, eax
        .else
            xor     eax, eax
            dec     eax
        .endif
        
        ret
    basic_check endp

;-----------------------------------------------------------------------
    core    proc    hwnd

        ; open, decrypt and decompress key file
        invoke  file_open
        .if     eax
            mov     ebx, fileio.hview
            .if     dword ptr (skeyfile ptr [ebx]).mark == KEY_FILE_SIGNATURE

                invoke  basic_check, fileio.hview
                .if     !eax
                    
                    invoke  dsa_init
                    invoke  dsa_setparams, addr p, addr q, addr g, addr y, 0
                    ;invoke  dsa_sign, addr szname, sizeof szname, addr _signature_x.r, addr _signature_x.s
                    invoke  dsa_verify, addr (skeyfile ptr [ebx]).szname, byte ptr (skeyfile ptr [ebx]).dbnamelength, addr (skeyfile ptr [ebx]).signature.r, addr (skeyfile ptr [ebx]).signature.s
                    .if     !eax
                    
                        invoke  SendMessage, hwnd, WM_DEFEATED, 0, 0
                    
                    .endif
                    
                .endif
                
            .endif

            invoke  file_close
        .endif
    
        ret
    core    endp

;-----------------------------------------------------------------------
