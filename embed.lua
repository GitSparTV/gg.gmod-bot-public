local EmbedM = {}
EmbedM.__index = EmbedM

local stringsub = string.sub
function EmbedM:Title(t)
	if #t > 256 then
		t = stringsub(t, 1, 256)
	end

	self.embed.title = t
end

function EmbedM:Description(t)
	if #t > 2048 then
		t = stringsub(t, 1, 2048)
	end

	self.embed.description = t
end

function EmbedM:URLTitle(url)
	self.embed.url = url
end

function EmbedM:Time(time)
	self.embed.timestamp = time
end

function EmbedM:Color(color)
	self.embed.color = color
end

function EmbedM:Footer(text)
	local footer = self.embed.footer

	if not footer then
		footer = {}
		self.embed.footer = footer
	end

	if #text > 2048 then
		text = stringsub(text, 1, 2048)
	end

	footer.text = text
end

function EmbedM:FooterIcon(icon)
	local footer = self.embed.footer

	if not footer then
		footer = {}
		self.embed.footer = footer
	end

	footer.icon_url = icon
	footer.proxy_icon_url = icon
end

function EmbedM:Image(url)
	self.embed.image = {
		url = url,
		proxy_url = url,
	}
end

function EmbedM:Thumbnail(url)
	self.embed.thumbnail = {
		url = url,
		proxy_url = url,
	}
end

function EmbedM:Video(url)
	self.embed.video = {
		url = url
	}
end

function EmbedM:Author(user, url)
	self.embed.author = {
		name = user.tag,
		url = url,
		icon_url = user.avatarURL
	}
end

function EmbedM:Header(text, url)
	self.embed.author = {
		name = text,
		url = url
	}
end

function EmbedM:Field(title, text, inline)
	local fields = self.embed.fields

	if not fields then
		fields = {}
		self.embed.fields = fields
	end

	if #title > 256 then
		title = stringsub(title, 1, 256)
	end

	if #text > 1024 then
		text = stringsub(text, 1, 1024)
	end

	fields[#fields + 1] = {
		name = title,
		value = text,
		inline = inline or false
	}
end

function EmbedM:Export()
	return self.embed
end

local setmetatable = setmetatable
local function CreateEmbed()
	return setmetatable({
		embed = {}
	}, EmbedM)
end

return {CreateEmbed = CreateEmbed}
