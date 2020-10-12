local ffi = require("ffi")
local dis = import("discordutil")
local bot = import("botutil")
local CMD_HIDEFROMHELP, CMD_FILTERISBLACKLIST, CMD_RAWCONTENT = 1, 2, 4

local function PermAll()
	return true
end

local PermAdmins

do
	local disIsAdmin = dis.IsAdmin

	function PermAdmins(m)
		return disIsAdmin(m)
	end
end

local Commands = {}
local CM = {}
CM.__index = CM

function CM:Alias(alias)
	Commands[alias] = self
	local a = self.aliases
	a[#a + 1] = alias
end

function CM:Desc(desc)
	self.description = desc
end

function CM:Permission(perm)
	local p = self.permissions
	p[#p + 1] = perm
end

function CM:Filter(f)
	self.filters[f] = true
	self.filtersused = true
end

function CM:Callback(c)
	self.callback = c
end

do
	local bitband, disIsAdmin, stringlower = bit.band, dis.IsAdmin, string.lower

	function CM:CheckPerms(channel, cat, member)
		if self.filtersused and not disIsAdmin(member) then
			cat = stringlower(cat)

			if bitband(self.flags, CMD_FILTERISBLACKLIST) ~= 0 then
				local f = self.filters
				if f[channel] or f[cat] then return false end
			else
				local f = self.filters
				if not f[channel] and not f[cat] then return false end
			end
		end

		local p = self.permissions

		for i = 1, #p do
			if p[i](member) then return true end
		end

		return false
	end
end

do
	local bitbor = bit.bor

	function CM:AddFlag(flag)
		self.flags = bitbor(self.flags, flag)
	end
end

local function New(name)
	local c = setmetatable({
		name = name,
		aliases = {},
		description = "",
		permissions = {},
		filters = {},
		filtersused = false,
		flags = 0,
	}, CM)

	Commands[name] = c
	Commands[#Commands + 1] = c

	return c
end

local Parse

do
	local buffer = ffi.typeof("char [?]")
	local fficopy, ffistring = ffi.copy, ffi.string

	function Parse(s, len)
		local t, tlen, lastspace, openquote, closequote, quotefixup = {}, 0, 0, 0, false, false

		do
			local caret = 0

			while caret < len do
				local char = s[caret]

				if not closequote and char == 32 then
					do
						local sublen = caret - lastspace

						if sublen ~= 0 then
							tlen = tlen + 1
							t[tlen] = ffistring(s + lastspace, sublen)
						end
					end

					lastspace = caret + 1
				elseif char == 34 then
					if caret ~= 0 and s[caret - 1] == 92 then
						quotefixup = true
						goto skip
					end

					if closequote then
						do
							local sublen = caret - openquote
							tlen = tlen + 1

							if quotefixup then
								local buf = buffer(sublen)
								local p = buf
								local qcar, lastq = openquote, openquote

								while qcar < caret do
									local qchar = s[qcar]

									if qchar == 34 and qcar ~= openquote and s[qcar - 1] == 92 then
										local qlen = qcar - lastq - 1
										fficopy(p, s + lastq, qlen)
										p = p + qlen
										p[0], p = 34, p + 1
										lastq = qcar + 1
									end

									qcar = qcar + 1
								end

								if caret ~= lastq then
									local qlen = qcar - lastq
									fficopy(p, s + lastq, qlen)
									p = p + qlen
								end

								t[tlen] = ffistring(buf, p - buf)
							else
								do
									local sublen = openquote - 1 - lastspace

									if sublen ~= 0 then
										t[tlen] = ffistring(s + lastspace, sublen)
										tlen = tlen + 1
									end
								end

								t[tlen] = ffistring(s + openquote, sublen)
							end
						end

						lastspace = caret + 1
						closequote = false
					else
						closequote = true
						openquote = caret + 1
					end
				end

				::skip::
				caret = caret + 1
			end
		end

		if len ~= lastspace then
			t[tlen + 1] = ffistring(s + lastspace, len - lastspace)
		end

		return t
	end
end

do
	local cmd = New("help")
	cmd:Desc("Shows all available commands. `!help`")
	cmd:Permission(PermAll)

	do
		local ipairs, tableconcat = ipairs, table.concat
		local bitband = bit.band

		cmd:Callback(function(msg)
			local e = bot.CreateEmbed()
			e:Title("Toolgun Help")
			local t, len = {}, 0
			local member = msg.member

			for k, v in ipairs(Commands) do
				if bitband(v.flags, CMD_HIDEFROMHELP) == 0 then
					local p = v.permissions

					for i = 1, #p do
						if p[i](member) then
							len = len + 1
							local aliases = ""

							if #v.aliases ~= 0 then
								local a = v.aliases

								for ai = 1, #a do
									t[len + ai - 1] = "`!" .. a[ai] .. "`"
								end

								aliases = " (" .. tableconcat(t, ", ", len, len + #a - 1) .. ")"
							end

							t[len] = "​`!" .. v.name .. "`" .. aliases .. "\n> ​ ​ ​ ​" .. v.description .. "\n"
							break
						end
					end
				end
			end

			local desc = tableconcat(t, "\n", 1, len)

			if #desc < 2000 then
				e:Description(desc)
			else
				e:Description(tableconcat(t, "\n", 1, math.floor(len / 2)))
			end

			if dis.IsAdmin(msg.member) then
				if #desc < 2000 then
					bot.Reply(msg, {
						content = dis.Mention(msg.member),
						embed = e:Export()
					})
				else
					local e2 = bot.CreateEmbed()
					e2:Description(tableconcat(t, "\n", math.floor(len / 2), len))

					bot.Reply(msg, {
						content = dis.Mention(msg.member),
						embed = e:Export()
					})

					bot.Reply(msg, {
						embed = e2:Export()
					})
				end
			else
				dis.GetChannel("general"):send({
					content = dis.Mention(msg.member),
					embed = e:Export()
				})
			end
		end)
	end
end

local Run

do
	local tableremove = table.remove
	local stringsub, stringlower = string.sub, string.lower
	local bitband = bit.band
	local tochar = ffi.typeof("const char *")

	function Run(msg)
		if stringsub(msg.content, 1, 1) ~= "!" then return false end
		local cc = msg.content
		local args = Parse(tochar(cc), #cc)
		local command = stringlower(stringsub(tableremove(args, 1), 2))
		local n = string.find(command, "\n", 1, true)

		if n then
			table.insert(args, 1, command:sub(n + 1))
			command = command:sub(1, n-1)
		end

		local cmd = Commands[command]
		if not cmd then return false end

		if cmd:CheckPerms(msg.channel.name, msg.channel.category.name, msg.member) then
			cmd.callback(msg, args, stringsub(bitband(cmd.flags, CMD_RAWCONTENT) ~= 0 and msg.content or cc, #command + 3))

			return true
		end

		return false
	end
end

return {
	New = New,
	Run = Run,
	CMD_HIDEFROMHELP = CMD_HIDEFROMHELP,
	CMD_FILTERISBLACKLIST = CMD_FILTERISBLACKLIST,
	CMD_RAWCONTENT = CMD_RAWCONTENT,
	PermAll = PermAll,
	PermAdmins = PermAdmins,
}
