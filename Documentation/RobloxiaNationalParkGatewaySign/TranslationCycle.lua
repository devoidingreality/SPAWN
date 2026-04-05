--[[
	Made by █████ 🌟 💫 
	03/29/2023 17:52:32

	Contact Information: █████████@robloxia.org

	Info: This is used for the digital gateway sign at the National Park of Robloxia. Every few seconds, the text morphs between different languages.
]]

local HttpService = game:GetService("HttpService")

local Languages: {[string]: {string}}
local TypoMaps: {[string]: {[string]: {string}}}

-- async fetch
local function fetchJsonAsync(url: string, callback)
	task.spawn(function()
		local success, response = pcall(function() return HttpService:GetAsync(url) end)

		if success then
			callback(HttpService:JSONDecode(response))
		else
			warn("Failed to fetch JSON from", url .. ". Error:", response)
			callback({})
		end
	end)
end

-- wait until both JSONs are loaded
local function fetchAll(callback)
	local results = {}
	local loaded = 0
	local function tryCallback()
		loaded += 1
		if loaded == 2 then
			callback(results[1], results[2])
		end
	end

	fetchJsonAsync("https://cdn.robloxia.org/robloxia-national-park/languages.json", function(data)
		results[1] = data
		tryCallback()
	end)
	
	fetchJsonAsync("https://cdn.robloxia.org/robloxia-national-park/typo_maps.json", function(data)
		results[2] = data
		tryCallback()
	end)
end

fetchAll(function(fetchedLanguages, fetchedTypoMaps)
	Languages = fetchedLanguages
	TypoMaps = fetchedTypoMaps

	local currentLanguage = "English"
	local currentA, currentB = Languages.English[1], Languages.English[2]

	local function ewait(t: number?)
		local t = t or 0
		task.wait(t + math.random() * t * 0.5)
	end

	local function utf8Chars(str)
		local chars = {}
		for _, c in utf8.codes(str) do
			table.insert(chars, utf8.char(c))
		end
		return chars
	end

	local function lcs(a: string, b: string): string
		local aChars = utf8Chars(a)
		local bChars = utf8Chars(b)
		local m, n = #aChars, #bChars
		local dp = {}

		for i = 0, m do
			dp[i] = {}
			for j = 0, n do
				dp[i][j] = 0
			end
		end

		for i = 1, m do
			for j = 1, n do
				if aChars[i] == bChars[j] then
					dp[i][j] = dp[i-1][j-1] + 1
				else
					dp[i][j] = math.max(dp[i-1][j], dp[i][j-1])
				end
			end
		end

		local i, j = m, n
		local result = {}
		while i > 0 and j > 0 do
			if aChars[i] == bChars[j] then
				table.insert(result, 1, aChars[i])
				i -= 1
				j -= 1
			elseif dp[i-1][j] > dp[i][j-1] then
				i -= 1
			else
				j -= 1
			end
		end

		return table.concat(result)
	end

	local function diff(a: string, b: string)
		local aChars, bChars = utf8Chars(a), utf8Chars(b)
		local l = utf8Chars(lcs(a, b))

		local i, j, k = 1, 1, 1
		local ops = {}

		while i <= #aChars or j <= #bChars do
			local ca, cb, cl = aChars[i], bChars[j], l[k]

			if ca == cl and cb == cl then
				table.insert(ops, {type = "keep", char = ca})
				i += 1
				j += 1
				k += 1
			elseif ca ~= cl then
				table.insert(ops, {type = "delete", char = ca})
				i += 1
			elseif cb ~= cl then
				table.insert(ops, {type = "insert", char = cb})
				j += 1
			end
		end

		return ops
	end

	local function maybeTypo(char: string)
		if math.random() < 0.05 then
			local charIsLatin = TypoMaps["English"][char:lower()] ~= nil

			if math.random() < 0.97 or not charIsLatin then
				local langTypos: {{string}} = TypoMaps[currentLanguage] or TypoMaps["English"]
				local neighbors: {string} = langTypos[char:lower()]
				if neighbors and #neighbors > 0 then
					return neighbors[math.random(#neighbors)]:upper()
				end
			else
				return char:lower()
			end
		end
	end

	local function applyOpsAnimated(a: string, b: string, setText, TextLabel: TextLabel)
		local buffer = utf8Chars(a)
		local ops = diff(a, b)
		local pos = 1

		TextLabel.TextColor3 = Color3.new(0, 0.2, 0)

		for _, op in ipairs(ops) do
			if op.type == "keep" then
				pos += 1
			elseif op.type == "delete" then
				table.remove(buffer, pos)
			elseif op.type == "insert" then
				local intendedChar = op.char
				local typoChar = maybeTypo(intendedChar)

				if typoChar and typoChar ~= intendedChar then
					table.insert(buffer, pos, typoChar)
					setText(table.concat(buffer))
					TextLabel.TextColor3 = Color3.new(1, 0, 0)
					ewait(0.52)

					table.remove(buffer, pos)
					setText(table.concat(buffer))
					TextLabel.TextColor3 = Color3.new(0, 0.2, 0)
					ewait(0.21)
				end

				table.insert(buffer, pos, intendedChar)
				pos += 1
			end
			setText(table.concat(buffer))
			if op.type ~= "keep" then ewait(op.type == "delete" and 0.02 or op.type == "insert" and 0.04) end
		end

		task.wait(math.random(3, 8) / 10)
		TextLabel.TextColor3 = Color3.new(0, 0, 0)
	end

	local function updateSignA(text: string) script.Parent.WELCOME.Text = text end
	local function updateSignB(text: string) script.Parent.TITLE.Text = text end

	local function animateBoth(a1, b1, A, a2, b2, B)
		local done = 0
		local bindable = Instance.new("BindableEvent")

		local function finished()
			done += 1
			if done == 2 then
				bindable:Fire()
			end
		end

		task.spawn(function() applyOpsAnimated(a1, b1, updateSignA, A) finished() end)
		task.spawn(function() applyOpsAnimated(a2, b2, updateSignB, B) finished() end)

		bindable.Event:Wait()
		bindable:Destroy()
	end

	while true do
		for name, lang in pairs(Languages) do
			local nextA = lang[1]
			local nextB = lang[2]
			currentLanguage = name

			local A, B = currentA, currentB

			animateBoth(A, nextA, script.Parent.WELCOME, B, nextB, script.Parent.TITLE)

			currentA = nextA
			currentB = nextB

			task.wait(5)
		end
	end
end)
