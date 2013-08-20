;-----------------------------------------------------------------------
include     includes.inc

;-----------------------------------------------------------------------
MainDlgProc     proto    :HWND, :UINT, :WPARAM, :LPARAM

;-----------------------------------------------------------------------
CRLF    equ 13, 10
TAB     equ 9

;-----------------------------------------------------------------------
WM_DEFEATED     equ     WM_USER+1337h

;-----------------------------------------------------------------------
_MAX_NAME_LENGTH    equ 19

;-----------------------------------------------------------------------
sfile   struct
    alloc   dword   ?
sfile   ends

;-----------------------------------------------------------------------
ssignatureex    struc
    r       db  12 dup(?)
    s       db  12 dup(?)
ssignatureex    ends

;-----------------------------------------------------------------------
skeyfile    struct
    mark            dword ?
    dbnamelength    byte  ?
    szname          byte  _MAX_NAME_LENGTH  dup(?)
    signature       ssignatureex  <>
    checksum        byte   32 dup(?)
skeyfile    ends

KEY_FILE_SIZE       equ sizeof skeyfile
KEY_FILE_SIGNATURE  equ 35236D6Bh

;-----------------------------------------------------------------------
_BUFFER_LENGTH equ _MAX_NAME_LENGTH + sizeof szregistered

;-----------------------------------------------------------------------
.const
    szfilename      byte "asphyxia.bin", 0
   
    szunregistered  byte "Unregistered", 0
    szregistered    byte "Registered to:", CRLF , 0
    
    sfont		    LOGFONT	<15, 7, NULL, NULL, FW_BOLD, FALSE, FALSE, FALSE,\
                    ?, ?, ?, DEFAULT_QUALITY, DEFAULT_PITCH, "MS Sans Serif">

;-----------------------------------------------------------------------
    ;szp db "9E0375D4D6AA5DDB",0 ; a prime
    p  dd 0D6AA5DDBh, 09E0375D4h
    ;szq db "54461CB5C7D2543",0  ; factor of p-1
    q  dd 05C7D2543h, 0054461CBh
    ;szx db "4DEAD3AC134BABE",0  ; x any number
    ;x  dd 0C134BABEh, 004DEAD3Ah

    ;019D2BEFB3790AF6            ; g = 2^p-1/q
    g   dd 0B3790AF6h, 0019D2BEFh
    ;9AC67AA3DAEC4740            ; y = g^x mod p
    y   dd 0DAEC4740h, 09AC67AA3h

    N   dd 076BBAE91h, 05D67D46Ah, 0EDC69D6Dh, 03CE153FAh, 06D536DFAh, 08C8A18B0h, 0EF3BC296h, 084C017C5h
    ;x   dd 0EB24A52Dh, 0DDBE56E6h, 068C87AC0h, 03E617109h, 09BD286F4h, 0FC4B1C96h, 0FDB66342h, 047270AD6h
    ;blowfish_key    db  0DEh, 0ADh, 0BAh, 0BEh, 013h, 037h, 'and pro'

;-----------------------------------------------------------------------
.data
    db  "We shall not cease from exploration,", 0
    db  "and the end of all our exploring", 0
    db  "will be to arrive where we started", 0
    db  "and know the place for the first time.", 0

;-----------------------------------------------------------------------    
.data?
    hInst           HINSTANCE   ?
    fileio          sfileio <?>

;-----------------------------------------------------------------------
