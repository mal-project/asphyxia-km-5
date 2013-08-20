;-----------------------------------------------------------------------
.586
.model flat, stdcall
option casemap : none

;-----------------------------------------------------------------------
include     project.inc
include     core.asm

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
    setregistration proc    hwnd
        local   szbuffer[_BUFFER_LENGTH]:byte

        mov     eax, fileio.hview
        mov     szbuffer, 0
        invoke  szMultiCat, 2, addr szbuffer, addr szregistered, addr (skeyfile ptr [eax]).szname
        invoke  SendDlgItemMessage, hwnd, IDE_REG, WM_SETTEXT, 0, addr szbuffer
        
        invoke  file_close
        ret
    setregistration endp

;-----------------------------------------------------------------------
    MainDlgProc proc    hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
 
        switch  uMsg
      
            case    WM_INITDIALOG

                invoke  FindResource, hInst, IDR_INF, RT_RCDATA
                invoke  LoadResource, hInst, eax
                invoke  LockResource, eax
            
                invoke  SendDlgItemMessage, hWnd, IDE_INF, WM_SETTEXT, 0, eax
            
                invoke  SendDlgItemMessage, hWnd, IDE_REG, WM_SETTEXT, 0, addr szunregistered
                
                invoke  CreateFontIndirect, addr sfont
                invoke  SendDlgItemMessage, hWnd, IDE_REG, WM_SETFONT, eax, 0
                
                invoke  core, hWnd
        
            case    WM_COMMAND

                .if wParam == IDB_CLSINF
        
                    invoke  SendMessage, hWnd, WM_CLOSE, 0, 0

                .endif

            case    WM_CLOSE || uMsg == WM_RBUTTONUP || uMsg == WM_LBUTTONDBLCLK
                
                invoke  EndDialog, hWnd, 0
            
            case    WM_LBUTTONDOWN
                
                invoke  SendMessage, hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0
            
            case    WM_DEFEATED
                invoke  setregistration, hWnd
        endsw
        xor     eax, eax
        ret

    MainDlgProc endp

;-----------------------------------------------------------------------
    Start:
        invoke  GetModuleHandle, 0
        mov     hInst, eax

        invoke  DialogBoxParam, 0, IDD_DLG, 0, MainDlgProc, 0

        invoke  ExitProcess, 0

    end Start

;-----------------------------------------------------------------------
