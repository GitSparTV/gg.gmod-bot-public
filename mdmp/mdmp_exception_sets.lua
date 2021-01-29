-- local StreamTypes = {
-- 	[0] = "UnusedStream",
-- 	[1] = "ReservedStream0",
-- 	[2] = "ReservedStream1",
-- 	[3] = "ThreadListStream",
-- 	[4] = "ModuleListStream",
-- 	[5] = "MemoryListStream",
-- 	[6] = "ExceptionStream",
-- 	[7] = "SystemInfoStream",
-- 	[8] = "ThreadExListStream",
-- 	[9] = "Memory64ListStream",
-- 	[10] = "CommentStreamA",
-- 	[11] = "CommentStreamW",
-- 	[12] = "HandleDataStream",
-- 	[13] = "FunctionTableStream",
-- 	[14] = "UnloadedModuleListStream",
-- 	[15] = "MiscInfoStream",
-- 	[16] = "MemoryInfoListStream",
-- 	[17] = "ThreadInfoListStream",
-- 	[18] = "HandleOperationListStream",
-- 	[19] = "TokenStream",
-- 	[20] = "JavaScriptDataStream",
-- 	[21] = "SystemMemoryInfoStream",
-- 	[22] = "ProcessVmCountersStream",
-- 	[23] = "IptTraceStream",
-- 	[24] = "ThreadNamesStream",
-- 	[0x8000] = "ceStreamNull",
-- 	[0x8001] = "ceStreamSystemInfo",
-- 	[0x8002] = "ceStreamException",
-- 	[0x8003] = "ceStreamModuleList",
-- 	[0x8004] = "ceStreamProcessList",
-- 	[0x8005] = "ceStreamThreadList",
-- 	[0x8006] = "ceStreamThreadContextList",
-- 	[0x8007] = "ceStreamThreadCallStackList",
-- 	[0x8008] = "ceStreamMemoryVirtualList",
-- 	[0x8009] = "ceStreamMemoryPhysicalList",
-- 	[0x800A] = "ceStreamBucketParameters",
-- 	[0x800B] = "ceStreamProcessModuleMap",
-- 	[0x800C] = "ceStreamDiagnosisList",
-- 	[0xffff] = "LastReservedStream"
-- }
local ExceptionCodeToName = {
	[0x00000103] = "STILL_ACTIVE",
	[0xC0000005] = "EXCEPTION_ACCESS_VIOLATION",
	[0x80000002] = "EXCEPTION_DATATYPE_MISALIGNMENT",
	[0x80000003] = "EXCEPTION_BREAKPOINT",
	[0x80000004] = "EXCEPTION_SINGLE_STEP",
	[0xC000008C] = "EXCEPTION_ARRAY_BOUNDS_EXCEEDED",
	[0xC000008D] = "EXCEPTION_FLT_DENORMAL_OPERAND",
	[0xC000008E] = "EXCEPTION_FLT_DIVIDE_BY_ZERO",
	[0xC000008F] = "EXCEPTION_FLT_INEXACT_RESULT",
	[0xC0000090] = "EXCEPTION_FLT_INVALID_OPERATION",
	[0xC0000091] = "EXCEPTION_FLT_OVERFLOW",
	[0xC0000092] = "EXCEPTION_FLT_STACK_CHECK",
	[0xC0000093] = "EXCEPTION_FLT_UNDERFLOW",
	[0xC0000094] = "EXCEPTION_INT_DIVIDE_BY_ZERO",
	[0xC0000095] = "EXCEPTION_INT_OVERFLOW",
	[0xC0000096] = "EXCEPTION_PRIV_INSTRUCTION",
	[0xC0000006] = "EXCEPTION_IN_PAGE_ERROR",
	[0xC000001D] = "EXCEPTION_ILLEGAL_INSTRUCTION",
	[0xC0000025] = "EXCEPTION_NONCONTINUABLE_EXCEPTION",
	[0xC00000FD] = "EXCEPTION_STACK_OVERFLOW",
	[0xC0000026] = "EXCEPTION_INVALID_DISPOSITION",
	[0x80000001] = "EXCEPTION_GUARD_PAGE",
	[0xC0000008] = "EXCEPTION_INVALID_HANDLE",
	[0xC0000194] = "EXCEPTION_POSSIBLE_DEADLOCK",
	[0xC000013A] = "CONTROL_C_EXIT",
	[0x00000000] = "STATUS_WAIT_0",
	[0x00000080] = "STATUS_ABANDONED_WAIT_0",
	[0x000000C0] = "STATUS_USER_APC",
	[0x00000102] = "STATUS_TIMEOUT",
	[0x00010001] = "DBG_EXCEPTION_HANDLED",
	[0x00010002] = "DBG_CONTINUE",
	[0x40000005] = "STATUS_SEGMENT_NOTIFICATION",
	[0x40000015] = "STATUS_FATAL_APP_EXIT",
	[0x40010001] = "DBG_REPLY_LATER",
	[0x40010003] = "DBG_TERMINATE_THREAD",
	[0x40010004] = "DBG_TERMINATE_PROCESS",
	[0x40010005] = "DBG_CONTROL_C",
	[0x40010006] = "DBG_PRINTEXCEPTION_C",
	[0x40010007] = "DBG_RIPEXCEPTION",
	[0x40010008] = "DBG_CONTROL_BREAK",
	[0x40010009] = "DBG_COMMAND_EXCEPTION",
	[0x4001000A] = "DBG_PRINTEXCEPTION_WIDE_C",
	[0x80000026] = "STATUS_LONGJUMP",
	[0x80000029] = "STATUS_UNWIND_CONSOLIDATE",
	[0x80010001] = "DBG_EXCEPTION_NOT_HANDLED",
	[0xC000000D] = "STATUS_INVALID_PARAMETER",
	[0xC0000017] = "STATUS_NO_MEMORY",
	[0xC0000135] = "STATUS_DLL_NOT_FOUND",
	[0xC0000138] = "STATUS_ORDINAL_NOT_FOUND",
	[0xC0000139] = "STATUS_ENTRYPOINT_NOT_FOUND",
	[0xC0000142] = "STATUS_DLL_INIT_FAILED",
	[0xC00002B4] = "STATUS_FLOAT_MULTIPLE_FAULTS",
	[0xC00002B5] = "STATUS_FLOAT_MULTIPLE_TRAPS",
	[0xC00002C9] = "STATUS_REG_NAT_CONSUMPTION",
	[0xC0000374] = "STATUS_HEAP_CORRUPTION",
	[0xC0000409] = "STATUS_STACK_BUFFER_OVERRUN",
	[0xC0000417] = "STATUS_INVALID_CRUNTIME_PARAMETER",
	[0xC0000420] = "STATUS_ASSERTION_FAILURE",
	[0xC00004A2] = "STATUS_ENCLAVE_VIOLATION",
	[0xC0000515] = "STATUS_INTERRUPTED",
	[0xC0000516] = "STATUS_THREAD_NOT_RUNNING",
	[0xC0000718] = "STATUS_ALREADY_REGISTERED",
	[0xC015000F] = "STATUS_SXS_EARLY_DEACTIVATION",
	[0xC0150010] = "STATUS_SXS_INVALID_DEACTIVATION"
}

local ExceptionCodeDescription = {
	["EXCEPTION_ACCESS_VIOLATION"] = [[
The thread tried to read from or write to a virtual address for which it does not have the appropriate access.]],
	["EXCEPTION_ARRAY_BOUNDS_EXCEEDED"] = [[
The thread tried to access an array element that is out of bounds and the underlying hardware supports bounds checking.]],
	["EXCEPTION_BREAKPOINT"] = [[
A breakpoint was encountered.]],
	["EXCEPTION_DATATYPE_MISALIGNMENT"] = [[
The thread tried to read or write data that is misaligned on hardware that does not provide alignment. For example, 16-bit values must be aligned on 2-byte boundaries; 32-bit values on 4-byte boundaries, and so on.]],
	["EXCEPTION_FLT_DENORMAL_OPERAND"] = [[
One of the operands in a floating-point operation is denormal. A denormal value is one that is too small to represent as a standard floating-point value.]],
	["EXCEPTION_FLT_DIVIDE_BY_ZERO"] = [[
The thread tried to divide a floating-point value by a floating-point divisor of zero.]],
	["EXCEPTION_FLT_INEXACT_RESULT"] = [[
The result of a floating-point operation cannot be represented exactly as a decimal fraction.]],
	["EXCEPTION_FLT_INVALID_OPERATION"] = [[
This exception represents any floating-point exception not included in this list.]],
	["EXCEPTION_FLT_OVERFLOW"] = [[
The exponent of a floating-point operation is greater than the magnitude allowed by the corresponding type.]],
	["EXCEPTION_FLT_STACK_CHECK"] = [[
The stack overflowed or underflowed as the result of a floating-point operation.]],
	["EXCEPTION_FLT_UNDERFLOW"] = [[
The exponent of a floating-point operation is less than the magnitude allowed by the corresponding type.]],
	["EXCEPTION_ILLEGAL_INSTRUCTION"] = [[
The thread tried to execute an invalid instruction.]],
	["EXCEPTION_IN_PAGE_ERROR"] = [[
The thread tried to access a page that was not present, and the system was unable to load the page. For example, this exception might occur if a network connection is lost while running a program over the network.]],
	["EXCEPTION_INT_DIVIDE_BY_ZERO"] = [[
The thread tried to divide an integer value by an integer divisor of zero.]],
	["EXCEPTION_INT_OVERFLOW"] = [[
The result of an integer operation caused a carry out of the most significant bit of the result.]],
	["EXCEPTION_INVALID_DISPOSITION"] = [[
An exception handler returned an invalid disposition to the exception dispatcher. Programmers using a high-level language such as C should never encounter this exception.]],
	["EXCEPTION_NONCONTINUABLE_EXCEPTION"] = [[
The thread tried to continue execution after a noncontinuable exception occurred.]],
	["EXCEPTION_PRIV_INSTRUCTION"] = [[
The thread tried to execute an instruction whose operation is not allowed in the current machine mode.]],
	["EXCEPTION_SINGLE_STEP"] = [[
A trace trap or other single-instruction mechanism signaled that one instruction has been executed.]],
	["EXCEPTION_STACK_OVERFLOW"] = [[
The thread used up its stack.]]
}

return {ExceptionCodeToName, ExceptionCodeDescription}
