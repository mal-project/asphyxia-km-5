;-----------------------------------------------------------------------
sha1_init       proto   :dword 
sha1_transform  proto   :dword
sha1_update     proto   :dword, :dword, :dword
sha1_final      proto   :dword

;-----------------------------------------------------------------------
ssha1_ctx    struct
    sha1_diggest db  20 dup(?)
    sha1_index   dd  ?
    sha1_length  dd  ?
    sha1_buffer  db  64 dup(?)
ssha1_ctx    ends

;-----------------------------------------------------------------------
