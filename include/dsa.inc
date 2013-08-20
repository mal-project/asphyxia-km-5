;-----------------------------------------------------------------------
spublic struct
    p   dword   ?
    q   dword   ?
    g   dword   ?
    y   dword   ?
spublic ends

;-----------------------------------------------------------------------
sprivate    struct
    x   dword   ?
sprivate    ends

;-----------------------------------------------------------------------
ssignature  struct
    r   dword   ?
    s   dword   ?
ssignature  ends

;-----------------------------------------------------------------------
dsa_init      proto
dsa_setparams proto   p:dword, q:dword, g:dword, y:dword, x:dword
dsa_verify    proto   lpmessage:dword, dwlen:byte, lpr:dword, lps:dword
dsa_sign      proto   lpmessage:dword, dwlen:byte, lpr:dword, lps:dword

;-----------------------------------------------------------------------
