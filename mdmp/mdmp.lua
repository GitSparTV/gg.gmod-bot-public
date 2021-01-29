local ffi = require("ffi")
ffi.cdef(io.open("./mdmp/libmdmp.h"):read("*a"))
local C = ffi.C
local mdmp = ffi.load("libmdmp")
if not mdmp then return false, "libmdmp not found" end
local errorp = ffi.new("libcerror_error_t *[1]")

local function mdmp_assert(result)
	if result == -1 then
		local error_internal = ffi.cast("libcerror_internal_error *", errorp[0])

		if error_internal.messages == nil or error_internal.sizes == nil then
			error("Unable to get error from libmdmp")

			return
		end

		local trace = {}

		for i = 0, error_internal.number_of_messages - 1 do
			trace[i] = ffi.string(error_internal.messages[i], error_internal.sizes[i])
		end

		trace = table.concat(trace, "\n", 0)

		if len == -1 then
			error()
		end

		mdmp.libmdmp_error_free(errorp)
		error(trace, 3)
	end
end

local MemAddress

do
	local bittohex = bit.tohex
	local stringupper = string.upper

	function MemAddress(n)
		return "0x" .. stringupper(bittohex(n, 8))
	end
end

local streams = {
	[4] = true,
	[6] = true,
	[7] = true,
	[10] = true,
	[15] = true,
}

local ReadExceptionInfo

do
	local sets = require("./mdmp/mdmp_exception_sets")
	local fficopy, ffisizeof, ffinew = ffi.copy, ffi.sizeof, ffi.new

	function ReadExceptionInfo()
		local buf = streams[6][1]
		local exception = ffinew("MINIDUMP_EXCEPTION_STREAM")
		fficopy(exception, buf, ffisizeof("MINIDUMP_EXCEPTION_STREAM"))
		local record = exception.ExceptionRecord
		local code = record.ExceptionCode
		local codename = sets[1][code]
		local description = sets[2][codename] or "No description"

		if code == 0xC0000005 then
			local info = record.ExceptionInformation
			description = description .. "\n" .. "Access violation " .. (info[0] == 1 and "writing" or "reading") .. " location " .. MemAddress(info[1])
		end

		return MemAddress(code), codename, description, record.ExceptionAddress
	end
end

-- local function ReadRVA(f, RVA, size)
-- 	ffi.C.fseek(f, RVA, 0)
-- 	local addr = ffi.new("uint8_t[?]", size)
-- 	assert(ffi.C.fread(addr, 1, size, f) == size)
-- 	return ffi.string(addr, size)
-- end
local testfile = io.open("test.txt", "wb")

local function ReadModules(f)
	local buf = streams[4][1]
	local k = buf[0]
	buf = buf + 1
	local modules = ffi.new("MINIDUMP_MODULE[?]", k)
	ffi.copy(modules, buf, ffi.sizeof("MINIDUMP_MODULE") * k)
	local ret_modules = {}

	for i = 0, k - 1 do
		local module = modules[i]
		C.fseek(f, module.ModuleNameRva, 0)
		local namelen = ffi.new("ULONG32[1]")
		assert(C.fread(namelen, ffi.sizeof("ULONG32"), 1, f) == 1)
		namelen = namelen[0]
		assert(namelen > 0)
		namelen = namelen / 2
		local name = ffi.new("WCHAR[?]", namelen)
		assert(C.fread(name, ffi.sizeof("WCHAR"), namelen, f) == namelen)
		local charname = ffi.new("uint8_t[?]", namelen)

		for i = 0, namelen - 1 do
			charname[i] = bit.band(name[i], 0xff)
		end

		ret_modules[i] = {ffi.string(charname, namelen), module.BaseOfImage, module.SizeOfImage}
	end

	return ret_modules
end

local GetSystemInfo

do
	local ProcessorArchToName = {
		[0] = "x86",
		"MIPS", "Alpha", "PPC", "ShX", "ARM", "Intel Itanium", "Alpha x64", "MSIL", "x64", "Windows x64 on 32-bit UEFI (EFI-IA32)", "Neutral processor architecture.", "ARM x64", "Windows x64 on 32-bit ARM", "ARM x64 with emulating the x86";
		[0xFFFF] = "Unknown processor",
	}

	function GetSystemInfo()
		local buf = streams[7][1]
		local sysinfo = ffi.new("MINIDUMP_SYSTEM_INFO")
		ffi.copy(sysinfo, buf, ffi.sizeof("MINIDUMP_SYSTEM_INFO"))

		return ProcessorArchToName[sysinfo.ProcessorArchitecture], sysinfo.MajorVersion .. "." .. sysinfo.MinorVersion, sysinfo.NumberOfProcessors
	end
end

local function ReadMiscInfo()
	local buf = streams[15][1]

	if streams[15][2] == 1364 then
		local misc = ffi.new("MINIDUMP_MISC_INFO_5")
		ffi.copy(misc, buf, ffi.sizeof("MINIDUMP_MISC_INFO_5"))

		return misc.ProcessUserTime, misc.ProcessorMaxMhz / 1000
	end

	return "Unimplemented MINIDUMP_MISC_INFO", 0
end

local function ReadComment()
	local buf = streams[10][1]
	buf = ffi.string(buf, streams[10][2])
	print(buf)
	local percent, total, free = string.match(buf, "%-System Memory%-\n%s*Usage: (%d+)%%\n%s*Total: ([%d.]+[KMG]B) Physical, [%d.]+[KMG]B Paged, [%d.]+[KMG]B Virtual\n%s*Free: ([%d.]+[KMG]B) Physical, [%d.]+[KMG]B Paged, [%d.]+[KMG]B Virtual")
	local luatrace = string.match(buf, "%-Lua Stack Traces%-\n%s*(.-)\n\n")
	local noerror = string.match(buf, "%-No Error Message%-")
	local workingset = string.match(buf, "Working Set: ([%d.]+[KMG]B)")

	return percent, total, free, luatrace, noerror, workingset
end

local function FindModuleFromExection(exception, modules)
	for i = 0, #modules - 1 do
		local module = modules[i]
		local base = module[2]

		if base < exception then
			local diff = exception - base
			if diff < module[3] then return module[1], diff end
		end
	end

	return false
end

local function ReadDump()
	local f = C.fopen("./mdmp/analyze.mdmp", "rb")

	if f == nil then
		error("Couldn't open file")

		return
	end

	local FILE = ffi.new("libmdmp_file_t *[1]")
	mdmp_assert(mdmp.libmdmp_file_initialize(FILE, errorp))
	mdmp_assert(mdmp.libmdmp_file_open(FILE[0], "./mdmp/analyze.mdmp", 1, errorp))
	local res = ffi.new("int[1]")
	mdmp_assert(mdmp.libmdmp_file_get_number_of_streams(FILE[0], res, errorp))
	res = res[0]

	for i = 0, res - 1 do
		local stream = ffi.new("libmdmp_stream_t *[1]")
		mdmp_assert(mdmp.libmdmp_file_get_stream(FILE[0], i, stream, errorp))
		stream = stream[0]
		local type = ffi.new("uint32_t [1]")
		mdmp_assert(mdmp.libmdmp_stream_get_type(stream, type, errorp))
		type = type[0]

		if not streams[type] then
			goto cont
		end

		local size = ffi.new("size64_t [1]")
		mdmp_assert(mdmp.libmdmp_stream_get_size(stream, size, errorp))
		size = size[0]
		-- print("Stream [" .. i .. "]", "Size: " .. tostring(size), "Type: " .. tostring(type) .. " (" .. (StreamTypes[tonumber(type)] or tonumber(type)) .. ")")
		local buf = ffi.new("uint32_t [?]", size, 0)
		mdmp_assert(mdmp.libmdmp_stream_read_buffer(stream, buf, size, errorp))

		streams[type] = {buf, size}

		::cont::
	end

	local ExceptionCode, ExceptionCodename, ExceptionDescription, ExceptionAddress = ReadExceptionInfo()
	local Modules = ReadModules(f)
	local found = false

	for i = 0, #Modules - 1 do
		if string.find(Modules[1], "hl2.exe", 1, true) then
			found = true
			break
		end
	end

	if not found then
		error("Not a GMod dump")
	end

	local What, RelativeAddr = FindModuleFromExection(ExceptionAddress, Modules)
	local Arch, OSVersion, NumOfCores = GetSystemInfo()
	local ProcessUserTime, ProccesorMaxSpeed = ReadMiscInfo()
	local RAMPercent, RAMTotal, RAMFree, LuaTrace, NoError, WorkingSet = ReadComment()
	mdmp_assert(mdmp.libmdmp_error_free(errorp))
	mdmp_assert(mdmp.libmdmp_file_free(FILE, errorp))

	return ExceptionCode and MemAddress(ExceptionCode), ExceptionCodename, ExceptionDescription, ExceptionAddress and MemAddress(ExceptionAddress), What, RelativeAddr and MemAddress(RelativeAddr), Arch, OSVersion, NumOfCores, ProcessUserTime, ProccesorMaxSpeed, RAMPercent, RAMTotal, RAMFree, LuaTrace, NoError, WorkingSet
end

return ReadDump
-- do
-- 	local buf = streams[5][4]
-- 	local k = buf[0]
-- 	buf = buf + 1
-- 	local mems = ffi.new("MINIDUMP_MEMORY_DESCRIPTOR[?]", k)
-- 	ffi.copy(mems, buf, ffi.sizeof("MINIDUMP_MEMORY_DESCRIPTOR") * k)
-- 	for i = 0, k - 1 do
-- 		local mem = mems[i]
-- 		print("StartOfMemoryRange", mem.StartOfMemoryRange)
-- 		print("Memory", mem.Memory)
-- 		print("\tDataSize", mem.Memory.DataSize)
-- 		print("\tRva", mem.Memory.Rva)
-- 		C.fseek(f, mem.Memory.Rva, 0)
-- 		local addr = ffi.new("uint8_t[?]", mem.Memory.DataSize)
-- 		print("Read:",C.fread(addr, 1, mem.Memory.DataSize, f))
-- 		for I = 0, mem.Memory.DataSize - 1 do
-- 			io.write(addr[I], " ")
-- 		end
-- 		io.write("\n")
-- 		C.fclose(f)
-- 		return
-- 	end
-- end
-- do
-- 	local buf = streams[3][4]
-- 	local k = buf[0]
-- 	buf = buf + 1
-- 	local threads = ffi.new("MINIDUMP_THREAD[?]", k)
-- 	ffi.copy(threads, buf, ffi.sizeof("MINIDUMP_THREAD") * k)
-- 	for i = 0, k - 1 do
-- 		local thread = threads[i]
-- 		print("ThreadId", thread.ThreadId)
-- 		print("Priority", thread.Priority)
-- 		-- if thread.Priority == 1 then
-- 			-- print("Startofmemoryrange", string.format("0x%08X", tonumber(thread.StartOfMemoryRange)))
-- 			print(thread.ThreadContext.DataSize)
-- 			C.fseek(f, thread.ThreadContext.Rva, 0)
-- 			local addr = ffi.new("uint8_t[?]", thread.ThreadContext.DataSize)
-- 			print("Read:", C.fread(addr, 1, thread.ThreadContext.DataSize, f))
-- 			for I = 0, thread.ThreadContext.DataSize - 1 do
-- 				io.write(addr[I], " ")
-- 			end
-- 			io.write("\n")
-- 			C.fclose(f)
-- 			-- return
-- 		-- end
-- 		-- print("ThreadContext", thread.ThreadContext)
-- 		print()
-- 	end
-- end
