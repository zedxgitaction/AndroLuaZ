require "import"
require "locale"
import "console"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "com.androlua.*"
import "java.io.*"
import "android.text.method.*"
import "android.net.*"
import "android.content.*"
import "android.graphics.drawable.*"
import "androidx.appcompat.app.AppCompatDialog"
import "com.google.android.material.dialog.MaterialAlertDialogBuilder"
import "com.jesse205.androluax.LuaMaterialDialog"
import "com.google.android.material.textfield.TextInputEditText"
import "com.google.android.material.textfield.TextInputLayout"
import "bin"
import "autotheme"
import "DialogHelper"

-- Turnstile solver module (WebView + CDP fallback)
-- Turnstile 验证码求解模块
require "turnstile"

--首先添加一下，避免后期重复添加
local classes = require "javaapi.android"
local androidXAndMaterialClasses=require "javaapi.androidXAndMaterialClasses"
local classesLength=#classes
for key,value in ipairs(androidXAndMaterialClasses) do
  classes[key+classesLength]=value
end
activity.setTitle('AndroLuaZ+')

activity.setTheme(autotheme())

import "res"
require "layout"

function onVersionChanged(n, o)

  local dlg = MaterialAlertDialogBuilder(activity)
  local title = t("dlg_update") .. " " .. o .. " > " .. n
  local msg = t("changelog_3_4") .. "\n\n" ..
    t("changelog_3_3") .. "\n\n" ..
    t("changelog_3_2") .. "\n\n" ..
    t("changelog_3_1") .. "\n\n" ..
    t("changelog_3_0") .. "\n\n" ..
    t("changelog_2_1") .. "\n\n" ..
    t("changelog_2_0") .. "\n\n" ..
    t("changelog_1_5") .. "\n\n" ..
    t("changelog_1_4") .. "\n\n" ..
    t("changelog_1_3") .. "\n\n" ..
    t("changelog_5018") .. "\n\n" ..
    t("changelog_5017") .. "\n\n" ..
    t("changelog_5016_12") .. "\n\n" ..
    t("changelog_5016_11") .. "\n\n" ..
    t("changelog_5016_10") .. "\n\n" ..
    t("changelog_5016") .. "\n\n" ..
    t("changelog_5015") .. "\n\n" ..
    t("changelog_5014") .. "\n\n" ..
    t("changelog_5013") .. "\n\n" ..
    t("changelog_5012") .. "\n\n" ..
    t("changelog_5011") .. "\n\n" ..
    t("changelog_5010") .. "\n\n" ..
    t("changelog_5009") .. "\n\n" ..
    t("changelog_5008") .. "\n\n" ..
    t("changelog_5007") .. "\n\n" ..
    t("changelog_5006") .. "\n\n" ..
    t("changelog_5005") .. "\n\n" ..
    t("changelog_5004") .. "\n\n" ..
    t("changelog_5003") .. "\n\n" ..
    t("changelog_5002") .. "\n\n" ..
    t("changelog_5001") .. "\n\n" ..
    t("changelog_5000") .. "\n\n" ..
    t("changelog_444") .. "\n\n" ..
    t("changelog_443") .. "\n\n" ..
    t("changelog_442") .. "\n\n" ..
    t("changelog_441") .. "\n\n" ..
    t("changelog_440") .. "\n\n" ..
    t("changelog_436") .. "\n\n" ..
    t("changelog_435") .. "\n\n" ..
    t("changelog_434") .. "\n\n" ..
    t("changelog_433") .. "\n\n" ..
    t("changelog_432") .. "\n\n" ..
    t("changelog_431") .. "\n\n" ..
    t("changelog_430") .. "\n\n" ..
    t("changelog_426") .. "\n\n" ..
    t("changelog_425") .. "\n\n" ..
    t("changelog_424") .. "\n\n" ..
    t("changelog_423") .. "\n\n" ..
    t("changelog_422") .. "\n\n" ..
    t("changelog_421") .. "\n\n" ..
    t("changelog_420") .. "\n\n" ..
    t("changelog_419") .. "\n\n" ..
    t("changelog_418") .. "\n\n" ..
    t("changelog_417") .. "\n\n" ..
    t("changelog_416") .. "\n\n" ..
    t("changelog_415") .. "\n\n" ..
    t("changelog_414") .. "\n\n" ..
    t("changelog_413") .. "\n\n" ..
    t("changelog_412") .. "\n\n" ..
    t("changelog_411") .. "\n\n" ..
    t("changelog_410") .. "\n\n" ..
    t("changelog_4025") .. "\n\n" ..
    t("changelog_4024") .. "\n\n" ..
    t("changelog_4023") .. "\n\n" ..
    t("changelog_4022") .. "\n\n" ..
    t("changelog_4021") .. "\n\n" ..
    t("changelog_4020") .. "\n\n" ..
    t("changelog_4019") .. "\n\n" ..
    t("changelog_4018") .. "\n\n" ..
    t("changelog_4017") .. "\n\n" ..
    t("changelog_4016") .. "\n\n" ..
    t("changelog_4015") .. "\n\n" ..
    t("changelog_4014") .. "\n\n" ..
    t("changelog_4013") .. "\n\n" ..
    t("changelog_4012") .. "\n\n" ..
    t("changelog_4011") .. "\n\n" ..
    t("changelog_4010") .. "\n\n" ..
    t("changelog_4009") .. "\n\n" ..
    t("changelog_4008") .. "\n\n" ..
    t("changelog_4007") .. "\n\n" ..
    t("changelog_4006") .. "\n\n" ..
    t("changelog_4005") .. "\n\n" ..
    t("changelog_4004") .. "\n\n" ..
    t("changelog_4003") .. "\n\n" ..
    t("changelog_4002") .. "\n\n" ..
    t("changelog_4001") .. "\n\n" ..
    t("changelog_4000") .. "\n\n" ..
    t("changelog_4000rc4") .. "\n\n" ..
    t("changelog_4000rc3") .. "\n\n" ..
    t("changelog_4000rc2") .. "\n\n" ..
    t("changelog_4000a4") .. "\n\n" ..
    t("changelog_4000a3") .. "\n\n" ..
    t("changelog_4000a2") .. "\n\n" ..
    t("changelog_4000rc1") .. "\n\n" ..
    t("changelog_4000b4") .. "\n\n" ..
    t("changelog_4000b3") .. "\n\n" ..
    t("changelog_4000b2") .. "\n\n" ..
    t("changelog_4000b") .. "\n\n" ..
    t("changelog_4000a") .. "\n\n" ..
    t("changelog_365") .. "\n\n" ..
    t("changelog_364") .. "\n\n" ..
    t("changelog_363") .. "\n\n" ..
    t("changelog_362") .. "\n\n" ..
    t("changelog_361") .. "\n\n" ..
    t("changelog_360") .. "\n\n" ..
    t("changelog_359") .. "\n\n" ..
    t("changelog_358") .. "\n\n" ..
    t("changelog_357") .. "\n\n" ..
    t("changelog_356") .. "\n\n" ..
    t("changelog_355") .. "\n\n" ..
    t("changelog_354") .. "\n\n" ..
    t("changelog_353") .. "\n\n" ..
    t("changelog_352") .. "\n\n" ..
    t("changelog_35") .. "\n\n" ..
    t("changelog_345") .. "\n\n" ..
    t("changelog_343") .. "\n\n" ..
    t("changelog_342") .. "\n\n" ..
    t("changelog_341") .. "\n\n" ..
    t("changelog_340") .. "\n\n" ..
    t("changelog_335") .. "\n\n" ..
    t("changelog_334") .. "\n\n" ..
    t("changelog_333") .. "\n\n" ..
    t("changelog_332") .. "\n\n" ..
    t("changelog_331") .. "\n\n" ..
    t("changelog_33") .. "\n\n" ..
    t("changelog_326") .. "\n\n" ..
    t("changelog_325") .. "\n\n" ..
    t("changelog_324") .. "\n\n" ..
    t("changelog_323") .. "\n\n" ..
    t("changelog_322") .. "\n\n" ..
    t("changelog_321") .. "\n\n" ..
    t("changelog_32") .. "\n\n" ..
    t("changelog_31") .. "\n\n" ..
    t("changelog_300") .. "\n\n" ..
    t("changelog_210") .. "\n\n" ..
    t("changelog_204") .. "\n\n" ..
    t("changelog_203") .. "\n\n" ..
    t("changelog_202") .. "\n\n" ..
    t("changelog_201") .. "\n\n" ..
    t("changelog_20") .. "\n\n" ..
    t("changelog_more")
  if o == "" then
    title = t("dlg_welcome") .. n
    msg = t("welcome_about") .. "\n" .. t("welcome_agreement_title") .. "\n" .. t("welcome_agreement_text") .. "\n\n" .. msg
  end
  dlg.setTitle(title)

  dlg.setMessage(msg)
  dlg.setPositiveButton(t("btn_ok"), nil)
  dlg.setNegativeButton(t("btn_help"), { onClick = func.help })
  dlg.setNeutralButton(t("btn_donate"), { onClick = func.donation })
  DialogHelper.enableTextIsSelectable(dlg.show())
end



--activity.setTheme(android.R.style.Theme_Holo_Light)
local version = Build.VERSION.SDK_INT;
local h = tonumber(os.date("%H"))
function ext(f)
  local f=io.open(f)
  if f then
    f:close()
    return true
  end
  return false
end

local theme
if h <= 6 or h >= 22 then
  theme = activity.getLuaExtDir("fonts") .. "/night.lua"
 else
  theme = activity.getLuaExtDir("fonts") .. "/day.lua"
end
if not ext(theme) then
  theme = activity.getLuaExtDir("fonts") .. "/theme.lua"
end

local function day()
  if version >= 21 then
    return (android.R.style.Theme_Material_Light)
   else
    return (android.R.style.Theme_Holo_Light)
  end
end

local function night()
  if version >= 21 then
    return (android.R.style.Theme_Material)
   else
    return (android.R.style.Theme_Holo)
  end
end
local p = {}
local e = pcall(loadfile(theme, "bt", p))
if e then
  for k, v in pairs(p) do
    if k == "theme" then
      if v == "day" then
        activity.setTheme(day())
       elseif v == "night" then
        activity.setTheme(night())
      end
     else
      layout.main[2][k] = v
    end
  end
end
activity.getWindow().setSoftInputMode(0x10)

--activity.getSupportActionBar().show()

luahist = luajava.luadir .. "/lua.hist"
luadir = luajava.luaextdir .. "/" or "/sdcard/androlua/"
luaconf = luajava.luadir .. "/lua.conf"
luaproj = luajava.luadir .. "/lua.proj"
pcall(dofile, luaconf)
pcall(dofile, luahist)
history = history or {}
luapath = luapath or luadir .. "new.lua"
luadir = luapath:match("^(.-)[^/]+$")
pcall(dofile, luaproj)
luaproject = luaproject
if luaproject then
  local p = {}
  local e = pcall(loadfile(luaproject .. "init.lua", "bt", p))
  if e then
    activity.setTitle(tostring(p.appname))
    Toast.makeText(activity, t("toast_open_project") .. p.appname, Toast.LENGTH_SHORT ).show()
  end
end

activity.getSupportActionBar().setDisplayShowHomeEnabled(false)
luabindir = luajava.luaextdir .. "/bin/"
code = [===[
require "import"
import "android.widget.*"
import "android.view.*"

]===]
pcode = [[
require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

--activity.setTitle('AndroLua+')
activity.setTheme(R.style.Theme_Material3_DynamicColors_DayNight)
activity.setContentView(loadlayout("layout"))
]]

lcode = [[
{
  LinearLayout,
  orientation="vertical",
  layout_width="fill",
  layout_height="fill",
  {
    TextView,
    gravity="center",
    text="Hello AndroLua+",
    layout_width="fill",
    layout_height="fill",
  },
}
]]
upcode = [[
user_permission={
  "INTERNET",
  "WRITE_EXTERNAL_STORAGE",
}
]]

local BitmapDrawable = luajava.bindClass("android.graphics.drawable.BitmapDrawable")
m = {
  { MenuItem,
    title = t("menu_run"),
    id = "play",
    icon = "ic_play",
    singleColor=true },
  { MenuItem,
    title = t("menu_undo"),
    id = "undo",
    icon = "ic_undo",
    singleColor=true },
  { MenuItem,
    title = t("menu_redo"),
    id = "redo",
    icon = "ic_redo",
    singleColor=true },
  { MenuItem,
    title = t("menu_open"),
    id = "file_open", },
  { MenuItem,
    title = t("menu_recent"),
    id = "file_history", },
  { SubMenu,
    title = t("menu_file"),
    { MenuItem,
      title = t("menu_save"),
      id = "file_save", },
    { MenuItem,
      title = t("menu_new"),
      id = "file_new", },
    { MenuItem,
      title = t("menu_compile"),
      id = "file_build", },
  },
  { SubMenu,
    title = t("menu_project"),
    { MenuItem,
      title = t("menu_open"),
      id = "project_open", },
    { MenuItem,
      title = t("menu_package"),
      id = "project_build", },
    { MenuItem,
      title = t("menu_new"),
      id = "project_create", },
    { MenuItem,
      title = t("menu_export"),
      id = "project_export", },
    { MenuItem,
      title = t("menu_properties"),
      id = "project_info", },
  },
  { SubMenu,
    title = t("menu_code"),
    { MenuItem,
      title = t("menu_format"),
      id = "code_format", },
    { MenuItem,
      title = t("menu_import_analysis"),
      id = "code_import", },
    { MenuItem,
      title = t("menu_check"),
      id = "code_check", },
  },
  { SubMenu,
    title = t("menu_goto"),
    { MenuItem,
      title = t("menu_search"),
      id = "goto_seach", },
    { MenuItem,
      title = t("menu_goto_line"),
      id = "goto_line", },
    { MenuItem,
      title = t("menu_navigate"),
      id = "goto_func", },
  },
  { MenuItem,
    title = t("menu_plugin"),
    id = "plugin", },
  { SubMenu,
    title = t("menu_more"),
    { MenuItem,
      title = t("menu_layout_helper"),
      id = "more_helper", },
    { MenuItem,
      title = t("menu_log"),
      id = "more_logcat", },
    { MenuItem,
      title = t("menu_java_browser"),
      id = "more_java", },
    { MenuItem,
      title = t("menu_help"),
      id = "more_help", },
    { MenuItem,
      title = t("menu_manual"),
      id = "more_manual", },
    { MenuItem,
      title = t("menu_support_author"),
      id = "more_donation", },
    { MenuItem,
      title = t("menu_contact_author"),
      id = "more_qq", },
    { MenuItem,
      title = t("menu_about"),
      id = "more_about", },
  },
}
optmenu = {}
function onCreateOptionsMenu(menu)
  loadmenu(menu, m, optmenu, 3)
end

function switch2(s)
  return function(t)
    local f = t[s]
    if not f then
      for k, v in pairs(t) do
        if s.equals(k) then
          f = v
          break
        end
      end
    end
    f = f or t.default2
    return f and f()
  end
end

function donothing()
  print(t("toast_feature_in_development"))
end

luaprojectdir = luajava.luaextdir .. "/project/"
function create_project()
  local appname = project_appName.getText().toString()
  local packagename = project_packageName.getText().toString()
  local f = File(luaprojectdir .. appname)
  if f.exists() then
    print(t("toast_project_exists"))
    return
  end
  if not f.mkdirs() then
    print(t("toast_project_create_failed"))
    return

  end
  luadir = luaprojectdir .. appname .. "/"
  write(luadir .. "init.lua", string.format("appname=\"%s\"\nappver=\"1.0\"\npackagename=\"%s\"\n%s", appname, packagename, upcode))
  write(luadir .. "main.lua", pcode)
  write(luadir .. "layout.aly", lcode)
  --project_dlg.hide()
  luapath = luadir .. "main.lua"
  read(luapath)
end

function update(s)
  bin_dlg.setMessage(s)
end

function callback(s)
  bin_dlg.hide()
  bin_dlg.Message = ""
  if not s:find("success") and not s:find("成功") then
    create_error_dlg()
    error_dlg.Message = s
    error_dlg.show()
  end
end

function reopen(path)
  local f = io.open(path, "r")
  if f then
    local str = f:read("*all")
    if tostring(editor.getText()) ~= str then
      editor.setText(str, true)
    end
    f:close()
  end
end

function read(path)

  local f = io.open(path, "r")
  if f == nil then
    --Toast.makeText(activity, "打开文件出错."..path, Toast.LENGTH_LONG ).show()
    error()
    return
  end
  local str = f:read("*all")
  f:close()
  if str~="" then
    local c=string.byte(str);
    if c <= 0x1c and c>= 0x1a and c!=" " and c!="\t" then
      Toast.makeText(activity, t("toast_cannot_open_compiled") .. path, Toast.LENGTH_LONG ).show()
      return
    end
  end
  editor.setText(str)

  activity.getSupportActionBar().setSubtitle(".." .. path:match("(/[^/]+/[^/]+)$"))
  luapath = path
  if history[luapath] then
    editor.setSelection(history[luapath])
  end
  table.insert(history, 1, luapath)
  for n = 2, #history do
    if n > 50 then
      history[n] = nil
     elseif history[n] == luapath then
      table.remove(history, n)
    end
  end
  write(luaconf, string.format("luapath=%q", path))
  if luaproject and path:find(luaproject, 1, true) then
    --Toast.makeText(activity, "打开文件."..path, Toast.LENGTH_SHORT ).show()
    activity.getSupportActionBar().setSubtitle(path:sub(#luaproject))
    return
  end

  local dir = luadir
  local p = {}
  local e = pcall(loadfile(dir .. "init.lua", "bt", p))
  while not e do
    dir, n = dir:gsub("[^/]+/$", "")
    if n == 0 then
      break
    end
    e = pcall(loadfile(dir .. "init.lua", "bt", p))
  end

  if e then
    activity.setTitle(tostring(p.appname))
    luaproject = dir
    activity.getSupportActionBar().setSubtitle(path:sub(#luaproject))
    write(luaproj, string.format("luaproject=%q", luaproject))
    --Toast.makeText(activity, "打开工程."..p.appname, Toast.LENGTH_SHORT ).show()
   else
    activity.setTitle("AndroLuaZ+")
    luaproject = nil
    write(luaproj, "luaproject=nil")
    --Toast.makeText(activity, "打开文件."..path, Toast.LENGTH_SHORT ).show()
  end
end

function write(path, str)
  local sw = io.open(path, "wb")
  if sw then
    sw:write(str)
    sw:close()
   else
    Toast.makeText(activity, t("toast_save_failed") .. path, Toast.LENGTH_SHORT ).show()
  end
  return str
end

function save()
  history[luapath] = editor.getSelectionEnd()
  local str = ""
  local f = io.open(luapath, "r")
  if f then
    str = f:read("*all")
    f:close()
  end
  local src = editor.getText().toString()
  if src ~= str then
    write(luapath, src)
  end
  return src
end

function click(s)
  func[s.getText()]()
end

function create_lua()
  luapath = luadir .. create_e.getText().toString() .. ".lua"
  if not pcall(read, luapath) then
    f = io.open(luapath, "a")
    f:write(code)
    f:close()
    table.insert(history, 1, luapath)
    editor.setText(code)
    write(luaconf, string.format("luapath=%q", luapath))
    Toast.makeText(activity, t("toast_new_file") .. luapath, Toast.LENGTH_SHORT ).show()
   else
    Toast.makeText(activity, t("toast_open_file") .. luapath, Toast.LENGTH_SHORT ).show()
  end
  write(luaconf, string.format("luapath=%q", luapath))
  activity.getSupportActionBar().setSubtitle(".." .. luapath:match("(/[^/]+/[^/]+)$"))
  --create_dlg.hide()
end

function create_dir()
  luadir = luadir .. create_e.getText().toString() .. "/"
  if File(luadir).exists() then
    Toast.makeText(activity, t("toast_folder_exists") .. luadir, Toast.LENGTH_SHORT ).show()
   elseif File(luadir).mkdirs() then
    Toast.makeText(activity, t("toast_folder_created") .. luadir, Toast.LENGTH_SHORT ).show()
   else
    Toast.makeText(activity, t("toast_create_failed") .. luadir, Toast.LENGTH_SHORT ).show()
  end
end

function create_aly()
  luapath = luadir .. create_e.getText().toString() .. ".aly"
  if not pcall(read, luapath) then
    f = io.open(luapath, "a")
    f:write(lcode)
    f:close()
    table.insert(history, 1, luapath)
    editor.setText(lcode)
    write(luaconf, string.format("luapath=%q", luapath))
    Toast.makeText(activity, t("toast_new_file") .. luapath, Toast.LENGTH_SHORT ).show()
   else
    Toast.makeText(activity, t("toast_open_file") .. luapath, Toast.LENGTH_SHORT ).show()
  end
  write(luaconf, string.format("luapath=%q", luapath))
  activity.getSupportActionBar().setSubtitle(".." .. luapath:match("(/[^/]+/[^/]+)$"))
  --create_dlg.hide()
end

function open(p)
  if p == luadir then
    return nil
  end
  if p:find("%.%./") then
    luadir = luadir:match("(.-)[^/]+/$")
    list(listview, luadir)
   elseif p:find("/") then
    luadir = luadir .. p
    list(listview, luadir)
   elseif p:find("%.alp$") then
    imports(luadir .. p)
    open_dlg.hide()
   else
    read(luadir .. p)
    open_dlg.hide()
  end
end

function sort(a, b)
  if string.lower(a) < string.lower(b) then
    return true
   else
    return false
  end
end

function adapter(t)
  return ArrayListAdapter(activity, android.R.layout.simple_list_item_1, String(t))
end

function list(v, p)
  local f = File(p)
  if not f then
    open_title.setText(p)
    local adapter = ArrayAdapter(activity, android.R.layout.simple_list_item_1, String {})
    v.setAdapter(adapter)
    return
  end

  local fs = f.listFiles()
  fs = fs or String[0]
  Arrays.sort(fs)
  local t = {}
  local td = {}
  local tf = {}
  if p ~= "/" then
    table.insert(td, "../")
  end
  for n = 0, #fs - 1 do
    local name = fs[n].getName()
    if fs[n].isDirectory() then
      table.insert(td, name .. "/")
     elseif name:find("%.lua$") or name:find("%.aly$") or name:find("%.alp$") then
      table.insert(tf, name)
    end
  end
  table.sort(td, sort)
  table.sort(tf, sort)
  for k, v in ipairs(tf) do
    table.insert(td, v)
  end
  open_title.setText(p)
  --local adapter=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String(td))
  --v.setAdapter(adapter)
  open_dlg.setItems(td)
end

function list2(v, p)
  local adapter = ArrayListAdapter(activity, android.R.layout.simple_list_item_1, String(history))
  v.setAdapter(adapter)
  plist = history
end

function export(pdir)
  require "import"
  import "java.util.zip.*"
  import "java.io.*"
  local function copy(input, output)
    local b = byte[2 ^ 16]
    local l = input.read(b)
    while l > 1 do
      output.write(b, 0, l)
      l = input.read(b)
    end
    input.close()
  end

  local f = File(pdir)
  local date = os.date("%y%m%d%H%M%S")
  local tmp = activity.getLuaExtDir("backup") .. "/" .. f.Name .. "_" .. date .. ".alp"
  local p = {}
  local e, s = pcall(loadfile(f.Path .. "/init.lua", "bt", p))
  if e then
    if p.mode then
      tmp = string.format("%s/%s_%s_%s-%s.%s", activity.getLuaExtDir("backup"), p.appname,p.mode, p.appver:gsub("%.", "_"), date,p.ext or "alp")
     else
      tmp = string.format("%s/%s_%s-%s.%s", activity.getLuaExtDir("backup"), p.appname, p.appver:gsub("%.", "_"), date,p.ext or "alp")
    end
  end
  local out = ZipOutputStream(FileOutputStream(tmp))
  local using={}
  local using_tmp={}
  function addDir(out, dir, f)
    local ls = f.listFiles()
    --entry=ZipEntry(dir)
    --out.putNextEntry(entry)
    for n = 0, #ls - 1 do
      local name = ls[n].getName()
      if name:find("%.apk$") or name:find("%.luac$") or name:find("^%.") then
       elseif p.mode and name:find("%.lua$") and name ~= "init.lua" then
        local ff=io.open(ls[n].Path)
        local ss=ff:read("a")
        ff:close()
        for u in ss:gmatch([[require *%b""]]) do
          if using_tmp[u]==nil then
            table.insert(using,u)
            using_tmp[u]=true
          end
        end
        local path, err = console.build(ls[n].Path)
        if path then
          entry = ZipEntry(dir .. name)
          out.putNextEntry(entry)
          copy(FileInputStream(File(path)), out)
          os.remove(path)
         else
          error(err)
        end
       elseif p.mode and name:find("%.aly$") then
        name = name:gsub("aly$", "lua")
        local path, err = console.build_aly(ls[n].Path)
        if path then
          entry = ZipEntry(dir .. name)
          out.putNextEntry(entry)
          copy(FileInputStream(File(path)), out)
          os.remove(path)
         else
          error(err)
        end
       elseif ls[n].isDirectory() then
        addDir(out, dir .. name .. "/", ls[n])
       else
        entry = ZipEntry(dir .. name)
        out.putNextEntry(entry)
        copy(FileInputStream(ls[n]), out)
      end
    end
  end

  addDir(out, "", f)
  local ff=io.open(f.Path.."/.using","w")
  ff:write(table.concat(using,"\n"))
  ff:close()
  entry = ZipEntry(".using")
  out.putNextEntry(entry)
  copy(FileInputStream(f.Path.."/.using"), out)

  out.closeEntry()
  out.close()
  return tmp
end

function getalpinfo(path,data)
  local app = {}
  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", app)()
  local str = string.format(t("alp_name") .. ": %s\
" .. t("alp_version") .. ": %s\
" .. t("alp_package") .. ": %s\
" .. t("alp_author") .. ": %s\
" .. t("alp_description") .. ": %s\
" .. t("alp_path") .. ": %s",
  app.appname,
  app.appver,
  app.packagename,
  app.developer,
  app.description,
  data
  )
  return str, app.mode
end

function imports(path,data)
  create_imports_dlg()
  imports_path=path
  local mode
  imports_dlg.Message, mode = getalpinfo(path,data)
  if mode == "plugin" or path:match("^([^%._]+)_plugin") then
    imports_dlg.setTitle(t("dlg_import_plugin"))
    imports_title=t("dlg_import_plugin")
   elseif mode == "build" or path:match("^([^%._]+)_build") then
    imports_dlg.setTitle(t("dlg_package_install"))
    imports_title=t("dlg_package_install")
  end
  imports_dlg.show()
end

function importx(path, tp)
  require "import"
  import "java.util.zip.*"
  import "java.io.*"
  local function copy(input, output)
    local b = byte[2 ^ 16]
    local l = input.read(b)
    while l > 1 do
      output.write(b, 0, l)
      l = input.read(b)
    end
    output.close()
  end

  local f = File(path)
  local app = {}
  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", app)()

  local s = app.appname or f.Name:match("^([^%._]+)")
  local out = activity.getLuaExtDir("project") .. "/" .. s

  if tp == "build" then
    out = activity.getLuaExtDir("bin/.temp") .. "/" .. s
   elseif tp == "plugin" then
    out = activity.getLuaExtDir("plugin") .. "/" .. s
  end
  local d = File(out)
  if autorm then
    local n = 1
    while d.exists() do
      n = n + 1
      d = File(out .. "-" .. n)
    end
  end
  if not d.exists() then
    d.mkdirs()
  end
  out = out .. "/"
  local zip = ZipFile(f)
  local entries = zip.entries()
  for entry in enum(entries) do
    local name = entry.Name
    local tmp = File(out .. name)
    local pf = tmp.ParentFile
    if not pf.exists() then
      pf.mkdirs()
    end
    if entry.isDirectory() then
      if not tmp.exists() then
        tmp.mkdirs()
      end
     else
      copy(zip.getInputStream(entry), FileOutputStream(out .. name))
    end
  end
  zip.close()
  function callback2(s)
    LuaUtil.rmDir(File(activity.getLuaExtDir("bin/.temp")))
    bin_dlg.hide()
    bin_dlg.Message = ""
    if s==nil or (not s:find("success") and not s:find("成功")) then
      create_error_dlg()
      error_dlg.Message = s
      error_dlg.show()
    end
  end

  if tp == "build" then
    bin(out)
    return out
   elseif tp == "plugin" then
    Toast.makeText(activity, t("toast_import_plugin") .. s, Toast.LENGTH_SHORT ).show()
    return out
  end
  luadir = out
  luapath = luadir .. "main.lua"
  read(luapath)
  Toast.makeText(activity, t("toast_import_project") .. luadir, Toast.LENGTH_SHORT ).show()
  return out
end

func = {}
func.open = function()
  save()
  create_open_dlg()
  list(listview, luadir)
  open_dlg.show()
end
func.new = function()
  save()
  create_create_dlg()
  create_dlg.setMessage(luadir)
  create_dlg.show()
end

func.history = function()
  save()
  create_open_dlg2()
  list2(listview2)
  open_edit.Text = ""
  open_dlg2.show()
end

func.create = function()
  save()
  create_project_dlg()
  project_dlg.show()
end
func.openproject = function()
  save()
  activity.newActivity("project")
  --[[
      create_open_dlg2()
      list2(listview2, luaprojectdir)
      open_edit.Text=""
      open_dlg2.show()]]
end

func.export = function()
  save()
  if luaproject then
    local name = export(luaproject)
    Toast.makeText(activity, t("toast_project_exported") .. name, Toast.LENGTH_SHORT ).show()
   else
    Toast.makeText(activity, t("toast_only_project_export"), Toast.LENGTH_SHORT ).show()
  end
end

func.save = function()
  save()
  Toast.makeText(activity, t("toast_file_saved") .. luapath, Toast.LENGTH_SHORT ).show()
end

func.play = function()
  if func.check(true) then
    return
  end
  save()
  if luaproject then
    activity.newActivity(luaproject .. "main.lua")
   else
    activity.newActivity(luapath)
  end
end
func.undo = function()
  editor.undo()
end
func.redo = function()
  editor.redo()
end
func.format = function()
  editor.format()
end
func.check = function(b)
  local src = editor.getText()
  src = src.toString()
  if luapath:find("%.aly$") then
    src = "return " .. src
  end
  local _, data = loadstring(src)

  if data then
    local _, _, line, data = data:find(".(%d+).(.+)")
    editor.gotoLine(tonumber(line))
    Toast.makeText(activity, line .. ":" .. data, Toast.LENGTH_SHORT ).show()
    return true
   elseif b then
   else
    Toast.makeText(activity, t("toast_no_syntax_error"), Toast.LENGTH_SHORT ).show()
  end
end

func.navi = function()
  create_navi_dlg()
  local str = editor.getText().toString()
  local fs = {}
  indexs = {}
  for s, i in str:gmatch("([%w%._]* *=? *function *[%w%._]*%b())()") do
    i = utf8.len(str, 1, i) - 1
    s = s:gsub("^ +", "")
    table.insert(fs, s)
    table.insert(indexs, i)
    fs[s] = i
  end
  navi_dlg.setItems(String(fs))
  --local adapter = ArrayAdapter(activity, android.R.layout.simple_list_item_1, )
  --navi_list.setAdapter(adapter)
  navi_dlg.show()
end

func.seach = function()
  editor.search()
end

func.gotoline = function()
  editor.gotoLine()
end

func.luac = function()
  save()
  local path, str = console.build(luapath)
  if path then
    Toast.makeText(activity, t("toast_compile_complete") .. path, Toast.LENGTH_SHORT ).show()
   else
    Toast.makeText(activity, t("toast_compile_error") .. str, Toast.LENGTH_SHORT ).show()
  end
end

func.build = function()
  save()
  if not luaproject then
    Toast.makeText(activity, t("toast_only_project_package"), Toast.LENGTH_SHORT ).show()
    return
  end
  bin(luaproject .. "/")
end

buildfile = function()
  Toast.makeText(activity, t("toast_packaging"), Toast.LENGTH_SHORT ).show()
  task(bin, luaPath.getText().toString(), appName.getText().toString(), appVer.getText().toString(), packageName.getText().toString(), apkPath.getText().toString(), function(s)
    status.setText(s or t("toast_package_error"))
  end)
end

func.info = function()
  if not luaproject then
    Toast.makeText(activity, t("toast_only_project_properties"), Toast.LENGTH_SHORT ).show()
    return
  end
  activity.newActivity("projectinfo", { luaproject })
end

func.logcat = function()
  activity.newActivity("logcat")
end

func.help = function()
  activity.newActivity("help")
end

func.java = function()
  activity.newActivity("javaapi/main")
end

func.manual = function()
  activity.newActivity("luadoc")
end

func.helper = function()
  save()
  isupdate = true
  activity.newActivity("layouthelper/main", { luaproject, luapath })
end

func.donation = function()
  xpcall(function()
    local url = "alipayqr://platformapi/startapp?saId=10000007&clientVersion=3.7.0.0718&qrcode=https://qr.alipay.com/apt7ujjb4jngmu3z9a"
    activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)));
  end,
  function()
    local url = "https://qr.alipay.com/apt7ujjb4jngmu3z9a";
    activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)));
  end)
end

key2 = [[N_9Rrnm8jJcdcXs7TQsXQBVA8Liq8mhU]]

key = [[QRDW1jiyM81x-T8RMIgeX1g_v76QSo6a]]
function joinQQGroup(key)
  import "android.content.Intent"
  import "android.net.Uri"
  local intent = Intent();
  intent.setData(Uri.parse("mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3D" .. key));
  activity.startActivity(intent);
end

func.qq = function()
  joinQQGroup(key)
end

func.about = function()
  onVersionChanged("", "")
end

func.fiximport = function()
  save()
  activity.newActivity("javaapi/fiximport", { luaproject, luapath })
end

func.plugin = function()
  activity.newActivity("plugin/main", { luaproject, luapath })
end

function onOptionsItemSelected(item)
  onMenuItemSelected(item.getItemId(), item)
end

function onMenuItemSelected(id, item)
  switch2(item) {
    default2 = function()
      print("功能开发中。。。")
    end,
    [optmenu.play] = func.play,
    [optmenu.undo] = func.undo,
    [optmenu.redo] = func.redo,
    [optmenu.file_open] = func.open,
    [optmenu.file_history] = func.history,
    [optmenu.file_save] = func.save,
    [optmenu.file_new] = func.new,
    [optmenu.file_build] = func.luac,
    [optmenu.project_open] = func.openproject,
    [optmenu.project_build] = func.build,
    [optmenu.project_create] = func.create,
    [optmenu.project_export] = func.export,
    [optmenu.project_info] = func.info,
    [optmenu.code_format] = func.format,
    [optmenu.code_check] = func.check,
    [optmenu.code_import] = func.fiximport,
    [optmenu.goto_line] = func.gotoline,
    [optmenu.goto_func] = func.navi,
    [optmenu.goto_seach] = func.seach,
    [optmenu.more_helper] = func.helper,
    [optmenu.more_logcat] = func.logcat,
    [optmenu.more_java] = func.java,
    [optmenu.more_help] = func.help,
    [optmenu.more_manual] = func.manual,
    [optmenu.more_donation] = func.donation,
    [optmenu.more_qq] = func.qq,
    [optmenu.more_about] = func.about,
    [optmenu.plugin] = func.plugin,
  }
end

activity.setContentView(loadlayout(layout.main))

function onCreate(s)
  --[[ local intent=activity.getIntent()
    local uri=intent.getData()
    if not s and uri and uri.getPath():find("%.alp$") then
      imports(uri.getPath())
    else]]
  if pcall(read, luapath) then
    last = last or 0
    if last < editor.getText().length() then
      editor.setSelection(last)
    end
   else
    luapath = activity.LuaExtDir .. "/new.lua"
    if not pcall(read, luapath) then
      write(luapath, code)
      pcall(read, luapath)
    end
  end
  --end
end

function onNewIntent(intent)
  local uri = intent.getData()
  if uri and uri.getPath():find("%.alp$") then
    local data = intent.getData();
    if (data ~= nil)
      local path = data.getPath();
      if (path ~= null)
        if ("content" == (data.getScheme()))
          local ins = activity.getContentResolver().openInputStream(data);
          local path2 = activity.getLuaExtPath("cache", File(data.getPath()).getName());
          local out = FileOutputStream(path2);
          LuaUtil.copyFile(ins, out);
          out.close();
          imports(path2,data);
          return ;
        end
        local idx = path.indexOf("/storage/emulated/");
        if (idx > 0)
          path = path.substring(idx);
        end
        imports(path,data);
      end
    end
  end
end


function onResult(name, path)
  --print(name,path)
  if name == "project" then
    luadir = path .. "/"
    read(path .. "/main.lua")
   elseif name == "projectinfo" then
    activity.setTitle(path)
  end
end

function onActivityResult(req, res, intent)
  if res == 10000 then
    read(luapath)
    editor.format()
    return
  end
  if res ~= 0 then
    local data = intent.getStringExtra("data")
    local _, _, path, line = data:find("\n[	 ]*([^\n]-):(%d+):")
    if path == luapath then
      editor.gotoLine(tonumber(line))
    end
    local classes = require "javaapi.android"

    local c = data:match("a nil value %(global '(%w+)'%)")
    if c then
      local cls = {}
      c = "%." .. c .. "$"
      for k, v in ipairs(classes) do
        if v:find(c) then
          table.insert(cls, string.format("import %q", v))
        end
      end
      if #cls > 0 then
        create_import_dlg()
        import_dlg.setItems(cls)
        import_dlg.show()
      end
    end

  end
end

function onStart()
  reopen(luapath)
  if isupdate then
    editor.format()
  end
  isupdate = false
end

function onStop()
  save()
  --Toast.makeText(activity, "文件已保存."..luapath, Toast.LENGTH_SHORT ).show()
  local f = io.open(luaconf, "wb")
  f:write( string.format("luapath=%q\nlast=%d", luapath, editor. getSelectionEnd() ))
  f:close()
  local f = io.open(luahist, "wb")
  f:write(string.format("history=%s", dump(history)))
  f:close()
end

--创建对话框
function create_navi_dlg()
  if navi_dlg then
    return
  end
  navi_dlg = LuaMaterialDialog(activity)
  navi_dlg.setTitle(t("dlg_navigate"))
  navi_list=navi_dlg.ListView
  navi_list.onItemClick = function(parent, v, pos, id)
    editor.setSelection(indexs[pos + 1])
    navi_dlg.hide()
  end
  --navi_dlg.setView(navi_list)
end

function create_imports_dlg()
  if imports_dlg then
    return
  end
  imports_dlg = MaterialAlertDialogBuilder(activity)
  imports_dlg.setTitle(t("dlg_import"))
  imports_title=t("dlg_import")
  imports_dlg.setPositiveButton(t("btn_ok"), {
    onClick = function()
      --local path = imports_dlg.Message:match("路径: (.+)$")
      local path = imports_path
      local title = imports_title
      if title == t("dlg_package_install") then
        importx(path, "build")
       elseif title == t("dlg_import_plugin") then
        importx(path, "plugin")
       else
        importx(path)
      end
      imports_dlg.setTitle(t("dlg_import"))
      imports_title=t("dlg_import")
  end })
  imports_dlg.setNegativeButton(t("btn_cancel"), nil)
  imports_dlg=imports_dlg.create()
end

function create_delete_dlg()
  if delete_dlg then
    return
  end
  delete_dlg = LuaMaterialDialog(activity)
  delete_dlg.setTitle(t("dlg_delete"))
  delete_dlg.setPositiveButton(t("btn_ok"), {
    onClick = function()
      if luapath:find(delete_dlg.Message) then
        Toast.makeText(activity, t("toast_cannot_delete_open_file"), Toast.LENGTH_SHORT ).show()
       elseif LuaUtil.rmDir(File(delete_dlg.Message)) then
        Toast.makeText(activity, t("toast_deleted"), Toast.LENGTH_SHORT ).show()
        list(listview, luadir)
       else
        Toast.makeText(activity, t("toast_delete_failed"), Toast.LENGTH_SHORT ).show()
      end
  end })
  delete_dlg.setNegativeButton(t("btn_cancel"), nil)
end

function create_open_dlg()
  if open_dlg then
    return
  end
  open_dlg = LuaMaterialDialog(activity)
  open_dlg.setTitle(t("dlg_open"))
  open_title = TextView(activity)
  open_title.setPadding(res.dimension.attr.dialogPreferredPadding,0,res.dimension.attr.dialogPreferredPadding,0)
  listview = open_dlg.ListView
  listview.FastScrollEnabled = true

  listview.addHeaderView(open_title)
  listview.setOnItemClickListener(AdapterView.OnItemClickListener {
    onItemClick = function(parent, v, pos, id)
      open(v.Text)
    end
  })

  listview.onItemLongClick = function(parent, v, pos, id)
    if v.Text ~= "../" then
      create_delete_dlg()
      delete_dlg.setMessage(luadir .. v.Text)
      delete_dlg.show()
    end
    return true
  end

  --open_dlg.setItems{"空"}
  --open_dlg.setContentView(listview)
end

function create_open_dlg2()
  if open_dlg2 then
    return
  end
  open_dlg2 = LuaMaterialDialog(activity)
  --open_dlg2.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);

  open_dlg2.setTitle(t("dlg_recent_open"))
  open_dlg2.setView(loadlayout(layout.open2))

  --listview2=open_dlg2.ListView
  listview2.FastScrollEnabled = true
  --open_edit=EditText(activity)
  --listview2.addHeaderView(open_edit)

  open_edit.addTextChangedListener {
    onTextChanged = function(c)
      local s = tostring(c)
      if #s == 0 then
        listview2.setAdapter(adapter(plist))
      end
      local t = {}
      s = s:lower()
      for k, v in ipairs(plist) do
        if v:lower():find(s, 1, true) then
          table.insert(t, v)
        end
      end
      listview2.setAdapter(adapter(t))
    end
  }

  listview2.setOnItemClickListener(AdapterView.OnItemClickListener {
    onItemClick = function(parent, v, pos, id)
      if File(v.Text).exists() then
        luadir = v.Text:gsub("[^/]+$", "")
        read(v.Text)
        open_dlg2.hide()
       else
        listview2.adapter.remove(pos)
        table.remove(plist, id)
        Toast.makeText(activity, t("toast_file_not_exist"), 1000).show()
      end
    end
  })
end

function create_create_dlg()
  if create_dlg then
    return
  end
  create_dlg = MaterialAlertDialogBuilder(activity)
  create_dlg.setMessage(luadir)
  create_dlg.setTitle(t("dlg_new"))

  --create_e = EditText(activity)
  create_dlg.setView(loadlayout({
    LinearLayout;
    {
      EditText;
      id="create_e";
      layout_width="fill";
      layout_marginLeft=res.dimension.attr.dialogPreferredPadding;
      layout_marginRight=res.dimension.attr.dialogPreferredPadding;
    }
  }))
  create_dlg.setPositiveButton(".lua", { onClick = create_lua })
  create_dlg.setNegativeButton("dir", { onClick = create_dir })
  create_dlg.setNeutralButton(".aly", { onClick = create_aly })
  create_dlg=create_dlg.create()
end

function create_project_dlg()
  if project_dlg then
    return
  end
  project_dlg = MaterialAlertDialogBuilder(activity)
  project_dlg.setTitle(t("dlg_new_project"))
  project_dlg.setView(loadlayout(layout.project))
  project_dlg.setPositiveButton(t("btn_ok"), { onClick = create_project })
  project_dlg.setNegativeButton(t("btn_cancel"), nil)
  project_dlg=project_dlg.create()
end

function create_build_dlg()
  if build_dlg then
    return
  end
  build_dlg = AlertDialogBuilder(activity)
  build_dlg.setTitle(t("dlg_package"))
  build_dlg.setView(loadlayout(layout.build))
  build_dlg.setPositiveButton(t("btn_ok"), { onClick = buildfile })
  build_dlg.setNegativeButton(t("btn_cancel"), nil)

end

function create_bin_dlg()
  if bin_dlg then
    return
  end
  bin_dlg = ProgressDialog(activity);
  bin_dlg.setTitle(t("dlg_packaging"));
  bin_dlg.setMax(100);
end

import "android.content.*"
cm = activity.getSystemService(activity.CLIPBOARD_SERVICE)

function copyClip(str)
  local cd = ClipData.newPlainText("label", str)
  cm.setPrimaryClip(cd)
  Toast.makeText(activity, t("toast_copied_clipboard"), 1000).show()
end

function create_import_dlg()
  if import_dlg then
    return
  end
  import_dlg = LuaMaterialDialog(activity)
  import_dlg.Title = t("dlg_import_classes")
  import_dlg.setPositiveButton(t("btn_ok"), nil)

  import_dlg.ListView.onItemClick = function(l, v)
    copyClip(v.Text)
    import_dlg.hide()
    return true
  end
end

function create_error_dlg()
  if error_dlg then
    return
  end
  error_dlg = LuaMaterialDialog(activity)
  error_dlg.Title = t("dlg_error")
  error_dlg.setPositiveButton(t("btn_ok"), nil)
end

lastclick = os.time() - 2
function onKeyDown(e)
  local now = os.time()
  if e == 4 then
    if now - lastclick > 2 then
      --print("再按一次退出程序")
      Toast.makeText(activity, t("toast_press_again_exit"), Toast.LENGTH_SHORT ).show()
      lastclick = now
      return true
    end
  end
end
local cd1 = ColorDrawable(0x00ffffff)
local cd2 = ColorDrawable(0x88000088)

local pressed = android.R.attr.state_pressed;
local window_focused = android.R.attr.state_window_focused;
local focused = android.R.attr.state_focused;
local selected = android.R.attr.state_selected;

function click(v)
  editor.paste(v.Text)
end

function newButton(text)
  local sd = StateListDrawable()
  sd.addState({ pressed }, cd2)
  sd.addState({ 0 }, cd1)
  local btn = TextView()
  btn.TextSize = 20;
  local pd = btn.TextSize / 2
  btn.setPadding(pd, pd / 2, pd, pd / 4)
  btn.Text = text
  btn.setBackgroundDrawable(sd)
  btn.onClick = click
  return btn
end
local ps = { "(", ")", "[", "]", "{", "}", "\"", "=", ":", ".", ",", "_", "+", "-", "*", "/", "\\", "%", "#", "^", "$", "?", "&", "|", "<", ">", "~", ";", "'" };
for k, v in ipairs(ps) do
  ps_bar.addView(newButton(v))
end

local function adds()
  require "import"
  local classes = require "javaapi.android"
  local androidXAndMaterialClasses=require "javaapi.androidXAndMaterialClasses"
  local classesLength=#classes
  for key,value in ipairs(androidXAndMaterialClasses) do
    classes[key+classesLength]=value
  end
  local ms = { "onCreate",
    "onStart",
    "onResume",
    "onPause",
    "onStop",
    "onDestroy",
    "onActivityResult",
    "onResult",
    "onCreateOptionsMenu",
    "onOptionsItemSelected",
    "onClick",
    "onTouch",
    "onLongClick",
    "onItemClick",
    "onItemLongClick",
  }
  local buf = String[#ms + #classes]
  for k, v in ipairs(ms) do
    buf[k - 1] = v
  end
  local l = #ms
  for k, v in ipairs(classes) do
    buf[l + k - 1] = string.match(v, "%w+$")
  end
  return buf
end
task(adds, function(buf)
  editor.addNames(buf)
end)

local buf={}
local tmp={}
local curr_ms=luajava.astable(LuaActivity.getMethods())
for k,v in ipairs(curr_ms) do
  v=v.getName()
  if not tmp[v] then
    tmp[v]=true
    table.insert(buf,v)
  end
end
editor.addPackage("activity",buf)


function fix(c)
  local classes = require "javaapi.android"

  if c then
    local cls = {}
    c = "%." .. c .. "$"
    for k, v in ipairs(classes) do
      if v:find(c) then
        table.insert(cls, string.format("import %q", v))
      end
    end
    if #cls > 0 then
      create_import_dlg()
      import_dlg.setItems(cls)
      import_dlg.show()
    end
  end
end

function onKeyShortcut(keyCode, event)
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    switch(keyCode)
     case
      KeyEvent.KEYCODE_O
      func.open();
      return true;
     case
      KeyEvent.KEYCODE_P
      func.openproject();
      return true;
     case
      KeyEvent.KEYCODE_S
      func.save();
      return true;
     case
      KeyEvent.KEYCODE_E
      func.check();
      return true;
     case
      KeyEvent.KEYCODE_R
      func.play();
      return true;
     case
      KeyEvent.KEYCODE_N
      func.navi();
      return true;
     case
      KeyEvent.KEYCODE_U
      func.undo();
      return true;
     case
      KeyEvent.KEYCODE_I
      fix(editor.getSelectedText());
      return true;
    end
  end
  return false;
end

import "androidx.appcompat.view.ActionMode"
local _clipboardActionMode=nil
function onEditorSelectionChangedListener(view,status,start,end_)
if not(_clipboardActionMode) and status then
  local actionMode=luajava.new(ActionMode.Callback,
  {
    onCreateActionMode=function(mode,menu)
      _clipboardActionMode=mode
      mode.setTitle(android.R.string.selectTextMode)
      local array=activity.getTheme().obtainStyledAttributes({
        android.R.attr.actionModeSelectAllDrawable,
        android.R.attr.actionModeCutDrawable,
        android.R.attr.actionModeCopyDrawable,
        android.R.attr.actionModePasteDrawable,
      })

      menu.add(0,0,0,android.R.string.selectAll)
      .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
      .setIcon(array.getResourceId(0,0))

      menu.add(0,1,0,android.R.string.cut)
      .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
      .setIcon(array.getResourceId(1,0))

      menu.add(0,2,0,android.R.string.copy)
      .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
      .setIcon(array.getResourceId(2,0))

      menu.add(0,3,0,android.R.string.paste)
      .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
      .setIcon(array.getResourceId(3,0))

      array.recycle()
      return true
    end,
    onActionItemClicked=function(mode,item)
      switch (item.getItemId()) do
         case 0 then
          view.selectAll();
         case 1 then
          view.cut();
          mode.finish();
         case 2 then
          view.copy();
          mode.finish();
         case 3 then
          view.paste();
          mode.finish();
        end
        return false;
      end,
      onDestroyActionMode=function(mode)
        view.selectText(false)
        _clipboardActionMode=nil
      end,
    })
    activity.startSupportActionMode(actionMode)
   elseif _clipboardActionMode and not(status) then
    _clipboardActionMode.finish()
    _clipboardActionMode=nil
  end
end

editor.OnSelectionChangedListener=function(status,start,end_)
  onEditorSelectionChangedListener(editor,status,start,end_)
end