--
-- suno.lua — AIMusic.so AI Music Generator for AndroLuaZ+
--
-- Generates music via the AIMusic.so API with automatic Turnstile solving.
-- Uses the built-in turnstile module for Cloudflare challenge bypass.
--
-- Usage:
--   local suno = require "suno"
--   suno.generate("happy upbeat song about coding")
--   suno.generateWithUI()  -- shows interactive UI
--

local M = {}

-- ── Config ────────────────────────────────────────────────────

local BASE = "https://api.aimusic.so"
local HEADERS = {
  ["Accept"] = "application/json, text/plain, */*",
  ["Content-Type"] = "application/json",
  ["User-Agent"] = "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36",
  ["Referer"] = "https://aimusic.so/app",
}

local MODELS = {"Prime"}
local MODEL_DESC = {Prime = "Fast, general purpose"}

local UID_PATH = activity.getFilesDir().toString() .. "/suno_uid.json"

-- ── JSON helper ───────────────────────────────────────────────

local cjson
pcall(function() cjson = require("cjson") end)

local function json_encode(tbl)
  if cjson then
    return cjson.encode(tbl)
  end
  -- fallback: use org.json
  local ok, jobj = pcall(luajava.newInstance, "org.json.JSONObject")
  if ok then
    for k, v in pairs(tbl) do
      pcall(jobj.put, jobj, k, v)
    end
    return jobj:toString()
  end
  return "{}"
end

local function json_decode(str)
  if not str or str == "" then return nil end
  if cjson then
    local ok, r = pcall(cjson.decode, str)
    if ok then return r end
  end
  local ok, jobj = pcall(luajava.newInstance, "org.json.JSONObject", str)
  if ok then
    local t = {}
    local keys = jobj:keys()
    while keys:hasNext() do
      local k = keys:next():toString()
      t[k] = jobj:get(k)
      if type(t[k]) == "userdata" then
        local s = t[k]:toString()
        if s:sub(1,1) == "{" or s:sub(1,1) == "[" then
          local d = json_decode(s)
          if d then t[k] = d end
        end
      end
    end
    return t
  end
  return nil
end

-- ── File helpers ──────────────────────────────────────────────

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

local function write_file(path, content)
  local f = io.open(path, "w")
  if not f then return false end
  f:write(content)
  f:close()
  return true
end

-- ── UID management ───────────────────────────────────────────

local function get_unique_id()
  -- Check cached UID first
  local cached = read_file(UID_PATH)
  if cached and #cached > 10 then
    local d = json_decode(cached)
    if d and d.uid then return d.uid end
  end

  -- Generate new UID via API
  local body, cookie, code = http.get(BASE .. "/api/auth/unique-id?canvas=1", nil, nil, HEADERS)
  if code == 200 then
    local resp = json_decode(body)
    if resp and resp.code == 200 and resp.data then
      write_file(UID_PATH, json_encode({uid = resp.data}))
      return resp.data
    end
  end

  -- Fallback: generate random UID locally
  local seed = tostring(os.time()) .. tostring(math.random(100000, 999999))
  local uid = string.format("%032x", math.random(0, 0xFFFFFFFF))
  write_file(UID_PATH, json_encode({uid = uid}))
  return uid
end

-- ── API calls ─────────────────────────────────────────────────

local function api_get(path, uid, params)
  local url = BASE .. path
  if params then
    local qs = {}
    for k, v in pairs(params) do
      if v ~= nil then
        qs[#qs+1] = k .. "=" .. tostring(v)
      end
    end
    if #qs > 0 then
      url = url .. "?" .. table.concat(qs, "&")
    end
  end

  local headers = {}
  for k, v in pairs(HEADERS) do headers[k] = v end
  headers["uniqueId"] = uid

  local body, cookie, code = http.get(url, nil, nil, headers)
  if body then
    return json_decode(body)
  end
  return {code = -1, msg = "Network error"}
end

local function api_post(path, uid, data, verify_token)
  local url = BASE .. path
  local headers = {}
  for k, v in pairs(HEADERS) do headers[k] = v end
  headers["uniqueId"] = uid
  if verify_token then
    headers["verify"] = verify_token
  end

  local body_str = json_encode(data or {})
  local body, cookie, code = http.post(url, body_str, nil, nil, headers)
  if body then
    return json_decode(body)
  end
  return {code = -1, msg = "Network error"}
end

function M.getCountry(uid)
  local resp = api_get("/api/auth/getIpCountry", uid)
  if resp and resp.data then return resp.data end
  return "??"
end

function M.createSong(uid, prompt, opts)
  opts = opts or {}
  local data = {
    prompt = prompt,
    style = opts.style or "",
    title = opts.title or "",
    customMode = opts.custom_mode or false,
    instrumental = opts.instrumental or false,
    model = opts.model or "Prime",
    privateFlag = opts.private or false,
  }
  return api_post("/api/v1/suno/create", uid, data, opts.verify_token)
end

function M.loadPending(uid, record_ids)
  return api_post("/api/v1/suno/loadPendingRecordList", uid,
                   {pendingRecordIdList = record_ids})
end

function M.listRecords(uid, page)
  return api_get("/api/v1/suno/pageRecordList", uid, {pageNum = page or 1})
end

-- ── Polling ───────────────────────────────────────────────────

function M.pollUntilDone(uid, record_id, max_wait, interval, callback)
  max_wait = max_wait or 300
  interval = interval or 5
  local start = os.time()

  while os.time() - start < max_wait do
    local resp = M.loadPending(uid, {record_id})
    if resp and resp.code == 200 then
      local records = resp.data
      if records and #records > 0 then
        local rec = records[1]
        local state = rec.state or "unknown"
        local songs = (rec.data and rec.data.data) or {}
        local audio_ready = #songs > 0 and songs[1].audioUrl and songs[1].audioUrl ~= ""

        if callback then callback(state, audio_ready) end

        if state == "success" or state == "completed" or audio_ready then
          return rec, songs
        end
        if state == "failed" then
          return nil, {}
        end
      end
    end
    -- Sleep using Java Thread
    local Thread = luajava.bindClass("java.lang.Thread")
    Thread.sleep(interval * 1000)
  end
  return nil, {}
end

-- ── Real audio check ─────────────────────────────────────────

local IMAGE_EXTS = {jpg=1, jpeg=1, png=1, gif=1, webp=1, bmp=1}

local function is_image_url(url)
  if not url or url == "" then return false end
  local ext = url:lower():match("%.(%w+)[?#]?")
  return IMAGE_EXTS[ext] ~= nil or url:find("imageurl") or url:find("/cover")
end

local function is_real_audio(url)
  if not url or url == "" then return false end
  local u = url:lower():split("?")[1]
  if u:find("musicfile%.aimusic%.so") then return false end
  if is_image_url(u) then return false end
  return u:find("%.mp3") or u:find("%.wav") or u:find("%.ogg")
      or u:find("%.m4a") or u:find("tempfile") or u:find("aiquickdraw")
end

-- ── Resolve tempfile URLs ─────────────────────────────────────

function M.resolveTempfileUrl(song, uid)
  local audio = song.audioUrl or ""
  if is_real_audio(audio) then return song end

  local song_id = song.id or ""
  local title = (song.title or ""):lower()

  for page = 1, 3 do
    local Thread = luajava.bindClass("java.lang.Thread")
    Thread.sleep(1000)
    local resp = M.listRecords(uid, page)
    local records = resp and resp.data and resp.data.records or {}
    if #records == 0 then break end
    for _, rec in ipairs(records) do
      local songs_data = (rec.data and rec.data.data) or {}
      for _, s in ipairs(songs_data) do
        local cand = s.audioUrl or ""
        if is_real_audio(cand) then
          if s.id == song_id or (title ~= "" and title == (s.title or ""):lower()) then
            song.audioUrl = cand
            song.link = cand
            song.songUrl = cand
            if s.imageUrl then song.imageUrl = s.imageUrl end
            return song
          end
        end
      end
    end
  end
  return song
end

-- ── Turnstile solve wrapper ───────────────────────────────────

local function solve_turnstile()
  local ok, turnstile = pcall(require, "turnstile")
  if not ok or not turnstile.isAvailable then
    return nil, "Turnstile module not available"
  end

  -- Try to solve the Turnstile on aimusic.so/app
  local token, err = turnstile.solve("https://aimusic.so/app")
  return token, err
end

-- ── Main generate function ───────────────────────────────────

function M.generate(prompt, opts, callback)
  opts = opts or {}

  -- Get or create UID
  local uid = opts.uid or get_unique_id()

  -- Solve Turnstile
  local verify_token = opts.verify_token
  if not verify_token then
    if callback then callback("solving_turnstile", false) end
    local token, err = solve_turnstile()
    if token then
      verify_token = token
    else
      return nil, "Turnstile failed: " .. (err or "unknown")
    end
  end

  -- Create song
  if callback then callback("creating", false) end
  opts.verify_token = verify_token
  local resp = M.createSong(uid, prompt, opts)

  -- Check response
  if resp.code == 100001 or resp.code == 400 then
    return nil, "Turnstile verification failed"
  end
  if resp.code == 430 then
    return nil, "Credits exhausted"
  end
  if resp.code ~= 200 then
    return nil, "Error " .. tostring(resp.code) .. ": " .. tostring(resp.msg)
  end

  local record_id = resp.data
  if type(record_id) == "table" then
    record_id = record_id.recordId
  end
  if not record_id then
    return nil, "No record ID returned"
  end

  -- Poll until done
  if callback then callback("generating", false) end
  local rec, songs = M.pollUntilDone(uid, record_id, 300, 5,
    function(state, audio_ready)
      if callback then callback(state, audio_ready) end
    end
  )

  if not rec then
    return nil, "Generation failed or timed out"
  end

  -- Resolve tempfile URLs
  local resolved = {}
  for i, song in ipairs(songs) do
    resolved[i] = M.resolveTempfileUrl(song, uid)
  end

  -- Deduplicate
  local seen = {}
  local deduped = {}
  for _, s in ipairs(resolved) do
    local a = s.audioUrl or ""
    if a == "" or not seen[a] then
      seen[a] = true
      deduped[#deduped+1] = s
    end
  end

  return deduped, nil
end

-- ── Interactive UI ────────────────────────────────────────────

function M.generateWithUI()
  local uid = get_unique_id()
  local country = M.getCountry(uid)
  print("Country: " .. country)

  -- Prompt dialog
  local builder = luajava.newInstance("com.google.android.material.dialog.MaterialAlertDialogBuilder", activity)
  builder:setTitle("AIMusic.so — AI Music Generator")

  local EditText = luajava.bindClass("android.widget.EditText")
  local LinearLayout = luajava.bindClass("android.widget.LinearLayout")
  local InputType = luajava.bindClass("android.text.InputType")

  local layout = luajava.newInstance("android.widget.LinearLayout", activity)
  layout:setOrientation(LinearLayout.VERTICAL)
  layout:setPadding(48, 32, 48, 16)

  local input = luajava.newInstance("android.widget.EditText", activity)
  input:setHint("Describe your song...")
  input:setInputType(InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE)
  input:setMinLines(3)
  layout:addView(input)

  builder:setView(layout)
  builder:setPositiveButton("Generate", nil)
  builder:setNegativeButton("Cancel", nil)

  local dlg = builder:show()

  -- Override positive button to not dismiss immediately
  local DialogInterface = luajava.bindClass("android.content.DialogInterface")
  dlg:getButton(DialogInterface.BUTTON_POSITIVE):setOnClickListener(
    luajava.createProxy("android.view.View$OnClickListener", {
      onClick = function(v)
        local prompt = input:getText():toString()
        if prompt == "" then return end

        dlg:dismiss()

        -- Show progress
        local progBuilder = luajava.newInstance("com.google.android.material.dialog.MaterialAlertDialogBuilder", activity)
        progBuilder:setTitle("Generating...")
        progBuilder:setMessage("Solving Turnstile & creating song...")
        progBuilder:setCancelable(false)
        local progDlg = progBuilder:show()

        -- Run in background thread
        local Thread = luajava.bindClass("java.lang.Thread")
        local thread = Thread(luajava.createProxy("java.lang.Runnable", {
          run = function()
            local songs, err = M.generate(prompt, {uid = uid}, function(state, audio_ready)
              -- Update UI on main thread
              activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                run = function()
                  if progDlg:isShowing() then
                    progDlg:setMessage("Status: " .. state)
                  end
                end
              }))
            end)

            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
              run = function()
                if progDlg:isShowing() then progDlg:dismiss() end

                if not songs then
                  local errBuilder = luajava.newInstance("com.google.android.material.dialog.MaterialAlertDialogBuilder", activity)
                  errBuilder:setTitle("Error")
                  errBuilder:setMessage(err or "Unknown error")
                  errBuilder:setPositiveButton("OK", nil)
                  errBuilder:show()
                  return
                end

                -- Show results
                local resultBuilder = luajava.newInstance("com.google.android.material.dialog.MaterialAlertDialogBuilder", activity)
                resultBuilder:setTitle("Generated " .. #songs .. " track(s)")

                local resultText = ""
                for i, song in ipairs(songs) do
                  resultText = resultText .. "Track " .. i .. ": " .. (song.title or "Untitled") .. "\n"
                  if is_real_audio(song.audioUrl or "") then
                    resultText = resultText .. "  Audio: " .. song.audioUrl .. "\n"
                  end
                  if song.imageUrl then
                    resultText = resultText .. "  Cover: " .. song.imageUrl .. "\n"
                  end
                  resultText = resultText .. "\n"
                end

                resultBuilder:setMessage(resultText)
                resultBuilder:setPositiveButton("OK", nil)
                resultBuilder:show()
              end
            }))
          end
        }))
        thread:start()
      end
    })
  )
end

return M
