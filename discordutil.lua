local function Log(b)
	CLIENT._logger._level = b and 3 or 0
end

local function Mention(user)
	return "<@!" .. user.id .. ">"
end

local function Tag(user)
	return user.tag or user.user.tag
end

local function MessageLink(msg)
	return msg.link
end

local function ChannelName(obj)
	return obj.mentionString or obj.channel.mentionString
end

local ResolveID

do
	local stringfind, stringmatch = string.find, string.match

	function ResolveID(str)
		if stringfind(str, "<@!", 1, true) then
			return stringmatch(str, "%d+"), 1
		elseif stringfind(str, "<#", 1, true) then
			return stringmatch(str, "%d+"), 2
		elseif stringfind(str, "<@&", 1, true) then
			return stringmatch(str, "%d+"), 3
		elseif stringfind(str, "<@", 1, true) then
			return stringmatch(str, "%d+"), 4
		end

		return str, 0
	end
end

local GetChannel

do
	local lookup = {}

	function GetChannel(name)
		if lookup[name] then return lookup[name] end

		for c in SERVER.textChannels:iter() do
			if c.name == name then
				lookup[name] = c

				return c
			end
		end

		return nil
	end
end

local AddEmote, AddEmoteCallback

do
	local emoji = {
		alert = ":error:758776477754851399",
		clock = ":late:589133896952709131",
		stop = "🛑",
		zero = "0️⃣",
		erase = "🗑️",
		done = ":agree:589133885506322448",
		no = ":disagree:589133888769490954",
		date = "📅",
		new = "🆕",
		ok = "🆗",
		star = "⭐",
		restricted = "🚷",
		lock = "🔒",
		gmoderror = ":error:758776477754851399"
	}

	function AddEmote(msg, emote)
		msg:addReaction(emoji[emote])
	end
  
  function AddEmoteToList(lookupname, emote)
		emoji[lookupname] = emote
  end

	function AddEmoteCallback(msg, emote, callback, legacy)
		if not msg._EmoteCallbacks then
			msg._EmoteCallbacks = {}
		end

		msg._EmoteCallbacks[legacy and emote or emoji[emote]] = callback
	end
end

local function CallEmoteCallback(emote, msg, user)
	if not msg._EmoteCallbacks or not user then return end
	local ename = emote.emojiId and ":" .. emote.emojiHash or emote.emojiHash
	local c = msg._EmoteCallbacks[ename]

	if c then
		c(msg, user, ename)
	end
end

local FindMember, FindMemberByName

do
	function FindMember(str)
		for u in SERVER.members:iter() do
			if u.tag == str then return u end
		end

		return nil
	end

	function FindMemberByName(str)
		for u in SERVER.members:iter() do
			if u.name == str then return u end
		end

		return nil
	end
end

local everyone

do
	local cached_everyone

	function everyone()
		if cached_everyone then return cached_everyone end

		for r in SERVER.roles:iter() do
			if r.name == "@everyone" then
				cached_everyone = r

				return r
			end
		end

		return nil
	end
end

local GetRole

do
	local cache = {}

	function GetRole(role)
		if cache[role] then return cache[role] end

		for r in SERVER.roles:iter() do
			if r.name == role then
				cache[role] = r

				return r
			end
		end

		return nil
	end
end

local function GetAllRoles()
	return SERVER.roles:toArray()
end

local function HasRole(user, role)
	for r in user.roles:iter() do
		if r.name == role then return true end
	end

	return false
end

return {
	Log = Log,
	Mention = Mention,
	Tag = Tag,
	MessageLink = MessageLink,
	ChannelName = ChannelName,
	GetChannel = GetChannel,
	AddEmote = AddEmote,
  AddEmoteToList = AddEmoteToList,
	AddEmoteCallback = AddEmoteCallback,
	CallEmoteCallback = CallEmoteCallback,
	FindMember = FindMember,
	FindMemberByName = FindMemberByName,
	everyone = everyone,
	GetRole = GetRole,
	GetAllRoles = GetAllRoles,
	HasRole = HasRole,
	ResolveID = ResolveID,
}
