local util_Decompress = util.Decompress
local istable = istable
local tostring = tostring
local util_Compress = util.Compress
local math_ceil = math.ceil
local string_sub = string.sub
local table_insert = table.insert
local writeUInt = net.WriteUInt
local writeData = net.WriteData
local readUInt = net.ReadUInt
local readData = net.ReadData

WKLib.networking = WKLib.networking or {}

function WKLib.networking.ReadChunks()
	local chunks = readUInt(16)
	local data = {}

	for i = 1, chunks do
		local chunk = {}
		local index = readUInt(16)
		local bytes = readUInt(16)
		chunk = readData(bytes)

		data[index] = chunk
	end

	return WKLib.networking.DecompressChunks(data)
end

function WKLib.networking.DecompressChunks(data)
	local compressed = ""

	for i = 1, #data do
		compressed = compressed .. data[i]
	end

	return util_Decompress(compressed)
end

function WKLib.networking.WriteChunks(data)
	data = WKLib.networking.CompressToChunks(data)

	local chunks = #data

	writeUInt(chunks, 16)

	for i = 1, chunks do
		local chunk = data[i]
		local bytes = #chunk

		writeUInt(i, 16)
		writeUInt(bytes, 16)
		writeData(chunk, bytes)
	end
end

function WKLib.networking.CompressToChunks(data)
	if istable(data) then
		data = WKLib.pon.encode(data)
	else
		data = tostring(data)
	end

	local compressed = util_Compress(data)
	local bytes = #compressed
	local chunks = math_ceil(bytes / 65533)
	local compressedChunks = {}

	for i = 1, chunks do
		local chunk = string_sub(compressed, (i - 1) * 65533 + 1, i * 65533)
		table_insert(compressedChunks, chunk)
	end

	return compressedChunks
end