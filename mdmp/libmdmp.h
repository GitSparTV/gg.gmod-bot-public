typedef intptr_t libcerror_error_t;

typedef intptr_t libbfio_handle_t;

typedef intptr_t libmdmp_error_t;

typedef intptr_t libmdmp_file_t;

typedef intptr_t libmdmp_stream_t;

typedef void FILE;

typedef struct libmdmp_file_header libmdmp_file_header_t;

struct libmdmp_file_header
{
    /* The version
     */
    uint16_t version;

    /* The number of streams
     */
    uint32_t number_of_streams;

    /* The streams directory offset
     */
    uint32_t streams_directory_offset;
};

typedef struct libmdmp_internal_file libmdmp_internal_file_t;

typedef struct libmdmp_io_handle libmdmp_io_handle_t;

typedef intptr_t libcdata_array_t;

typedef intptr_t libfdata_stream_t;

typedef int64_t off64_t;

typedef uint64_t size64_t;

struct libmdmp_io_handle
{
    /* The version
     */
    uint16_t version;

    /* Value to indicate if abort was signalled
     */
    int abort;
};

struct libmdmp_internal_file
{
    /* The IO handle
     */
    libmdmp_io_handle_t *io_handle;

    /* The file IO handle
     */
    libbfio_handle_t *file_io_handle;

    /* Value to indicate if the file IO handle was created inside the library
     */
    uint8_t file_io_handle_created_in_library;

    /* Value to indicate if the file IO handle was opened inside the library
     */
    uint8_t file_io_handle_opened_in_library;

    /* The file header
     */
    libmdmp_file_header_t *file_header;

    /* The streams array
     */
    libcdata_array_t *streams_array;
};

typedef struct libmdmp_stream_descriptor libmdmp_stream_descriptor_t;

struct libmdmp_stream_descriptor
{
    /* The type
     */
    uint32_t type;

    /* The data stream
     */
    libfdata_stream_t *data_stream;
};

typedef struct libmdmp_stream_io_handle libmdmp_stream_io_handle_t;

struct libmdmp_stream_io_handle
{
    /* The stream
     */
    libmdmp_stream_t *stream;

    /* Value to indicate the IO handle is open
     */
    uint8_t is_open;

    /* The current access flags
     */
    int access_flags;
};

typedef unsigned int ULONG32;
typedef unsigned long long ULONG64;
typedef unsigned long DWORD;
typedef DWORD RVA;

typedef struct tagVS_FIXEDFILEINFO
{
    DWORD   dwSignature;            /* e.g. 0xfeef04bd */
    DWORD   dwStrucVersion;         /* e.g. 0x00000042 = "0.42" */
    DWORD   dwFileVersionMS;        /* e.g. 0x00030075 = "3.75" */
    DWORD   dwFileVersionLS;        /* e.g. 0x00000031 = "0.31" */
    DWORD   dwProductVersionMS;     /* e.g. 0x00030010 = "3.10" */
    DWORD   dwProductVersionLS;     /* e.g. 0x00000031 = "0.31" */
    DWORD   dwFileFlagsMask;        /* = 0x3F for version "0.42" */
    DWORD   dwFileFlags;            /* e.g. VFF_DEBUG | VFF_PRERELEASE */
    DWORD   dwFileOS;               /* e.g. VOS_DOS_WINDOWS16 */
    DWORD   dwFileType;             /* e.g. VFT_DRIVER */
    DWORD   dwFileSubtype;          /* e.g. VFT2_DRV_KEYBOARD */
    DWORD   dwFileDateMS;           /* e.g. 0 */
    DWORD   dwFileDateLS;           /* e.g. 0 */
} VS_FIXEDFILEINFO;

typedef struct _MINIDUMP_LOCATION_DESCRIPTOR {
    ULONG32 DataSize;
    RVA Rva;
} MINIDUMP_LOCATION_DESCRIPTOR;

typedef unsigned short WCHAR;
typedef struct _MINIDUMP_STRING {
    ULONG32 Length;         // Length in bytes of the string
    WCHAR   Buffer [0];     // Variable size buffer
} MINIDUMP_STRING, *PMINIDUMP_STRING;

__attribute__((packed)) typedef struct _MINIDUMP_MODULE  {
  ULONG64                      BaseOfImage;
  ULONG32                      SizeOfImage;
  ULONG32                      CheckSum;
  ULONG32                      TimeDateStamp;
  RVA                          ModuleNameRva;
  VS_FIXEDFILEINFO             VersionInfo;
  MINIDUMP_LOCATION_DESCRIPTOR CvRecord;
  MINIDUMP_LOCATION_DESCRIPTOR MiscRecord;
  ULONG64                      Reserved0;
  ULONG64                      Reserved1;
} MINIDUMP_MODULE, *PMINIDUMP_MODULE;

typedef struct _MINIDUMP_MODULE_LIST {
  ULONG32         NumberOfModules;
  MINIDUMP_MODULE Modules[0];
} MINIDUMP_MODULE_LIST, *PMINIDUMP_MODULE_LIST;

typedef struct _MINIDUMP_EXCEPTION  {
    ULONG32 ExceptionCode;
    ULONG32 ExceptionFlags;
    ULONG64 ExceptionRecord;
    ULONG64 ExceptionAddress;
    ULONG32 NumberParameters;
    ULONG32 __unusedAlignment;
    ULONG64 ExceptionInformation [ 15 ];
} MINIDUMP_EXCEPTION, *PMINIDUMP_EXCEPTION;

typedef struct MINIDUMP_EXCEPTION_STREAM {
    ULONG32 ThreadId;
    ULONG32  __alignment;
    MINIDUMP_EXCEPTION ExceptionRecord;
    MINIDUMP_LOCATION_DESCRIPTOR ThreadContext;
} MINIDUMP_EXCEPTION_STREAM, *PMINIDUMP_EXCEPTION_STREAM;

typedef unsigned short USHORT;
typedef unsigned char UCHAR;

//
// The minidump system information contains processor and
// Operating System specific information.
// 

//
// CPU information is obtained from one of two places.
//
//  1) On x86 computers, CPU_INFORMATION is obtained from the CPUID
//     instruction. You must use the X86 portion of the union for X86
//     computers.
//
//  2) On non-x86 architectures, CPU_INFORMATION is obtained by calling
//     IsProcessorFeatureSupported().
//

typedef union _CPU_INFORMATION {

    //
    // X86 platforms use CPUID function to obtain processor information.
    //
    
    struct {

        //
        // CPUID Subfunction 0, register EAX (VendorId [0]),
        // EBX (VendorId [1]) and ECX (VendorId [2]).
        //
        
        ULONG32 VendorId [ 3 ];
        
        //
        // CPUID Subfunction 1, register EAX
        //
        
        ULONG32 VersionInformation;

        //
        // CPUID Subfunction 1, register EDX
        //
        
        ULONG32 FeatureInformation;
        

        //
        // CPUID, Subfunction 80000001, register EBX. This will only
        // be obtained if the vendor id is "AuthenticAMD".
        //
        
        ULONG32 AMDExtendedCpuFeatures;

    } X86CpuInfo;

    //
    // Non-x86 platforms use processor feature flags.
    //
    
    struct {

        ULONG64 ProcessorFeatures [ 2 ];
        
    } OtherCpuInfo;

} CPU_INFORMATION, *PCPU_INFORMATION;
        
typedef struct _MINIDUMP_SYSTEM_INFO {

    //
    // ProcessorArchitecture, ProcessorLevel and ProcessorRevision are all
    // taken from the SYSTEM_INFO structure obtained by GetSystemInfo( ).
    //
    
    USHORT ProcessorArchitecture;
    USHORT ProcessorLevel;
    USHORT ProcessorRevision;

    union {
        USHORT Reserved0;
        struct {
            UCHAR NumberOfProcessors;
            UCHAR ProductType;
        };
    };

    //
    // MajorVersion, MinorVersion, BuildNumber, PlatformId and
    // CSDVersion are all taken from the OSVERSIONINFO structure
    // returned by GetVersionEx( ).
    //
    
    ULONG32 MajorVersion;
    ULONG32 MinorVersion;
    ULONG32 BuildNumber;
    ULONG32 PlatformId;

    //
    // RVA to a CSDVersion string in the string table.
    //
    
    RVA CSDVersionRva;

    union {
        ULONG32 Reserved1;
        struct {
            USHORT SuiteMask;
            USHORT Reserved2;
        };
    };

    CPU_INFORMATION Cpu;

} MINIDUMP_SYSTEM_INFO, *PMINIDUMP_SYSTEM_INFO;

typedef struct _MINIDUMP_MEMORY_DESCRIPTOR {
    ULONG64 StartOfMemoryRange;
    MINIDUMP_LOCATION_DESCRIPTOR Memory;
} MINIDUMP_MEMORY_DESCRIPTOR, *PMINIDUMP_MEMORY_DESCRIPTOR;

// DESCRIPTOR64 is used for full-memory minidumps where
// all of the raw memory is laid out sequentially at the
// end of the dump.  There is no need for individual RVAs
// as the RVA is the base RVA plus the sum of the preceeding
// data blocks.
typedef struct _MINIDUMP_MEMORY_DESCRIPTOR64 {
    ULONG64 StartOfMemoryRange;
    ULONG64 DataSize;
} MINIDUMP_MEMORY_DESCRIPTOR64, *PMINIDUMP_MEMORY_DESCRIPTOR64;

typedef long LONG;
typedef unsigned char BYTE;
typedef BYTE BOOLEAN;
typedef unsigned short WORD;
typedef unsigned long ULONG;
typedef long long LONG64;
typedef struct _SYSTEMTIME {
    WORD wYear;
    WORD wMonth;
    WORD wDayOfWeek;
    WORD wDay;
    WORD wHour;
    WORD wMinute;
    WORD wSecond;
    WORD wMilliseconds;
} SYSTEMTIME, *PSYSTEMTIME, *LPSYSTEMTIME;

typedef struct _TIME_ZONE_INFORMATION {
    LONG Bias;
    WCHAR StandardName[ 32 ];
    SYSTEMTIME StandardDate;
    LONG StandardBias;
    WCHAR DaylightName[ 32 ];
    SYSTEMTIME DaylightDate;
    LONG DaylightBias;
} TIME_ZONE_INFORMATION, *PTIME_ZONE_INFORMATION, *LPTIME_ZONE_INFORMATION;

typedef struct _XSTATE_FEATURE {
    DWORD Offset;
    DWORD Size;
} XSTATE_FEATURE, *PXSTATE_FEATURE;

typedef struct _XSTATE_CONFIG_FEATURE_MSC_INFO
{
    ULONG32 SizeOfInfo;
    ULONG32 ContextSize;
    ULONG64 EnabledFeatures;               
    XSTATE_FEATURE Features[64];
} XSTATE_CONFIG_FEATURE_MSC_INFO, *PXSTATE_CONFIG_FEATURE_MSC_INFO;

__attribute__((packed)) typedef struct _MINIDUMP_THREAD {
    ULONG32 ThreadId;
    ULONG32 SuspendCount;
    ULONG32 PriorityClass;
    ULONG32 Priority;
    ULONG64 Teb;
    MINIDUMP_MEMORY_DESCRIPTOR Stack;
    MINIDUMP_LOCATION_DESCRIPTOR ThreadContext;
} MINIDUMP_THREAD, *PMINIDUMP_THREAD;

typedef struct _MINIDUMP_MISC_INFO_5 {
    ULONG32 SizeOfInfo;
    ULONG32 Flags1;
    ULONG32 ProcessId;
    ULONG32 ProcessCreateTime;
    ULONG32 ProcessUserTime;
    ULONG32 ProcessKernelTime;
    ULONG32 ProcessorMaxMhz;
    ULONG32 ProcessorCurrentMhz;
    ULONG32 ProcessorMhzLimit;
    ULONG32 ProcessorMaxIdleState;
    ULONG32 ProcessorCurrentIdleState;
    ULONG32 ProcessIntegrityLevel;
    ULONG32 ProcessExecuteFlags;
    ULONG32 ProtectedProcess;
    ULONG32 TimeZoneId;
    TIME_ZONE_INFORMATION TimeZone;
    WCHAR   BuildString[260];
    WCHAR   DbgBldStr[40];
    XSTATE_CONFIG_FEATURE_MSC_INFO XStateData;    
    ULONG32 ProcessCookie;
} MINIDUMP_MISC_INFO_5, *PMINIDUMP_MISC_INFO_5;

FILE *fopen( const char * filename, const char * mode );
int fclose( FILE *fp );
size_t fread ( void * ptr, size_t size, size_t count, FILE * stream );
int fseek(FILE *stream, long int offset, int whence);
size_t wcstombs (char* dest, const WCHAR* src, size_t max);

typedef wchar_t system_character_t;
typedef struct libcerror_internal_error libcerror_internal_error_t;

struct libcerror_internal_error
{
    /* The error domain
     */
    int domain;

    /* The error code
     */
    int code;

    /* The number of messages
     */
    int number_of_messages;

    /* A dynamic array containing the message strings
     */
    system_character_t **messages;

    /* A dynamic array containing the message string sizes
     * without the end-of-string character
     */
    size_t *sizes;
};

int libmdmp_check_file_signature(const char *filename, libcerror_error_t **error );

int libmdmp_check_file_signature_file_io_handle(libbfio_handle_t *file_io_handle, libmdmp_error_t **error );

int libmdmp_error_backtrace_fprint(libmdmp_error_t *error, FILE *stream );

int libmdmp_error_backtrace_sprint(libmdmp_error_t *error,char *string,size_t size );

int libmdmp_error_fprint(libmdmp_error_t *error,FILE *stream );

void libmdmp_error_free(libmdmp_error_t **error );

int libmdmp_error_sprint(libmdmp_error_t *error,char *string,size_t size );

int libmdmp_file_close(libmdmp_file_t *file,libmdmp_error_t **error );

int libmdmp_file_free(libmdmp_file_t **file,libmdmp_error_t **error );

int libmdmp_file_get_number_of_streams(libmdmp_file_t *file,int *number_of_streams,libmdmp_error_t **error );

int libmdmp_file_get_stream(libmdmp_file_t *file,int stream_index,libmdmp_stream_t **stream,libmdmp_error_t **error );

int libmdmp_file_get_stream_by_type(libmdmp_file_t *file,uint32_t stream_type,libmdmp_stream_t **stream,libmdmp_error_t **error );

int libmdmp_file_header_free(libmdmp_file_header_t **file_header,libcerror_error_t **error );

int libmdmp_file_header_initialize(libmdmp_file_header_t **file_header,libcerror_error_t **error );

int libmdmp_file_header_read_data(libmdmp_file_header_t *file_header,const uint8_t *data,size_t data_size,libcerror_error_t **error );

int libmdmp_file_header_read_file_io_handle(libmdmp_file_header_t *file_header,libbfio_handle_t *file_io_handle,libcerror_error_t **error );

int libmdmp_file_initialize(libmdmp_file_t **file,libmdmp_error_t **error );

int libmdmp_file_open(libmdmp_file_t *file,const char *filename,int access_flags,libmdmp_error_t **error );

int libmdmp_file_open_file_io_handle(libmdmp_file_t *file,libbfio_handle_t *file_io_handle,int access_flags,libmdmp_error_t **error );

int libmdmp_file_open_read(libmdmp_internal_file_t *internal_file,libbfio_handle_t *file_io_handle,libcerror_error_t **error );

int libmdmp_file_signal_abort(libmdmp_file_t *file,libmdmp_error_t **error );

int libmdmp_get_access_flags_read(void );

int libmdmp_get_codepage(int *codepage,libmdmp_error_t **error );

const char *libmdmp_get_version(   void );

int libmdmp_io_handle_clear(libmdmp_io_handle_t *io_handle,libcerror_error_t **error );

int libmdmp_io_handle_free(libmdmp_io_handle_t **io_handle,libcerror_error_t **error );

int libmdmp_io_handle_initialize(libmdmp_io_handle_t **io_handle,libcerror_error_t **error );

ssize_t libmdmp_io_handle_read_segment_data(intptr_t *data_handle,libbfio_handle_t *file_io_handle,int segment_index,int segment_file_index,uint8_t *segment_data,size_t segment_data_size,uint32_t segment_flags,uint8_t read_flags,libcerror_error_t **error );

int libmdmp_io_handle_read_streams_directory(libmdmp_io_handle_t *io_handle,libbfio_handle_t *file_io_handle,uint32_t streams_directory_offset,uint32_t number_of_streams,libcdata_array_t *streams_array,libcerror_error_t **error );

off64_t libmdmp_io_handle_seek_segment_offset(intptr_t *data_handle,libbfio_handle_t *file_io_handle,int segment_index,int segment_file_index,off64_t segment_offset,libcerror_error_t **error );

int libmdmp_notify_set_stream(FILE *stream,libmdmp_error_t **error );

void libmdmp_notify_set_verbose( int verbose );

int libmdmp_notify_stream_close(libmdmp_error_t **error );

int libmdmp_notify_stream_open(const char *filename,libmdmp_error_t **error );

int libmdmp_set_codepage(int codepage,libmdmp_error_t **error );

int libmdmp_stream_descriptor_free(libmdmp_stream_descriptor_t **stream_descriptor,libcerror_error_t **error );

int libmdmp_stream_descriptor_initialize(libmdmp_stream_descriptor_t **stream_descriptor,libcerror_error_t **error );

int libmdmp_stream_descriptor_set_data_range(libmdmp_stream_descriptor_t *stream_descriptor,off64_t data_offset,size64_t data_size,libcerror_error_t **error );

int libmdmp_stream_free(libmdmp_stream_t **stream,libmdmp_error_t **error );

int libmdmp_stream_get_data_file_io_handle(libmdmp_stream_t *stream,libbfio_handle_t **file_io_handle,libmdmp_error_t **error );

int libmdmp_stream_get_offset(libmdmp_stream_t *stream,off64_t *offset,libmdmp_error_t **error );

int libmdmp_stream_get_size(libmdmp_stream_t *stream,size64_t *size,libmdmp_error_t **error );

int libmdmp_stream_get_start_offset(libmdmp_stream_t *stream,off64_t *start_offset,libmdmp_error_t **error );

int libmdmp_stream_get_type(libmdmp_stream_t *stream,uint32_t *type,libmdmp_error_t **error );

int libmdmp_stream_initialize(libmdmp_stream_t **stream,libmdmp_io_handle_t *io_handle,libbfio_handle_t *file_io_handle,libmdmp_stream_descriptor_t *stream_descriptor,libcerror_error_t **error );

int libmdmp_stream_io_handle_clone(libmdmp_stream_io_handle_t **destination_io_handle,libmdmp_stream_io_handle_t *source_io_handle,libcerror_error_t **error );

int libmdmp_stream_io_handle_close(libmdmp_stream_io_handle_t *io_handle,libcerror_error_t **error );

int libmdmp_stream_io_handle_exists(libmdmp_stream_io_handle_t *io_handle,libcerror_error_t **error );

int libmdmp_stream_io_handle_free(libmdmp_stream_io_handle_t **io_handle,libcerror_error_t **error );

int libmdmp_stream_io_handle_get_size(libmdmp_stream_io_handle_t *io_handle,size64_t *size,libcerror_error_t **error );

int libmdmp_stream_io_handle_initialize(libmdmp_stream_io_handle_t **io_handle,libmdmp_stream_t *stream,libcerror_error_t **error );

int libmdmp_stream_io_handle_is_open(libmdmp_stream_io_handle_t *io_handle,libcerror_error_t **error );

int libmdmp_stream_io_handle_open(libmdmp_stream_io_handle_t *io_handle,int flags,libcerror_error_t **error );

ssize_t libmdmp_stream_io_handle_read(libmdmp_stream_io_handle_t *io_handle,uint8_t *buffer,size_t size,libcerror_error_t **error );

off64_t libmdmp_stream_io_handle_seek_offset(libmdmp_stream_io_handle_t *io_handle,off64_t offset,int whence,libcerror_error_t **error );

ssize_t libmdmp_stream_io_handle_write(libmdmp_stream_io_handle_t *io_handle,const uint8_t *buffer,size_t size,libcerror_error_t **error );

ssize_t libmdmp_stream_read_buffer(libmdmp_stream_t *stream,void *buffer,size_t buffer_size,libmdmp_error_t **error );

ssize_t libmdmp_stream_read_buffer_at_offset(libmdmp_stream_t *stream,void *buffer,size_t buffer_size,off64_t offset,libmdmp_error_t **error );

off64_t libmdmp_stream_seek_offset(libmdmp_stream_t *stream,off64_t offset,int whence,libmdmp_error_t **error );
