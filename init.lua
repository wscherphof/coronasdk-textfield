local EventEmitter = require("lua-events").EventEmitter

local TextField = {}

function TextField:new (hint, width, options)
  options = options or {}
  options.font = options.font or "Roboto-Regular"
  options.size = options.size or 18
  options.returnKey = options.returnKey
  options.isSecure = options.isSecure or false
  options.typeover = options.typeover or options.isSecure

  local group = EventEmitter:new(display.newGroup())
  local value = ""

  local spacer = display.newLine(group, 1,0, 1,48)
  spacer.isVisible = false

  local line = display.newLine(group, 1,40, 1,44)
  line:append(width,44, width,40)
  line:setColor(153, 153, 153)

  local probe = display.newText(group, "", 0, 0, options.font, options.size)
  local placeholdertext = display.newText(group, hint,
    9, 8, width - 13, probe.contentHeight,
    options.font, options.size)
  probe:removeSelf() probe = nil
  placeholdertext:setTextColor(153, 153, 153)

  local function setvalue (newvalue)
    local oldvalue = value
    value = newvalue
    if value ~= oldvalue then
      group:emit("change", value)
    end
    if "" == value then
      placeholdertext.text = hint
      placeholdertext:setTextColor(153, 153, 153)
      placeholdertext.isVisible = true
    else
      placeholdertext.isVisible = false
    end
  end

  local active
  local function finish ()
    if "" ~= value then
      local text = value
      if options.isSecure then text = string.gsub(value, ".", "•") end
      placeholdertext.text = text
      placeholdertext:setTextColor(0, 0, 0)
    end
    placeholdertext.isVisible = true
    line:setColor(153, 153, 153)
    line.width = 1
    active = false
  end

  local prev
  local function input (event)
    local phase = event.phase
    if "editing" == phase then
      setvalue(event.text)
    elseif "ended" == phase -- need test prev to mimic expexted behavior
    and "ended" ~= prev and "submitted" ~= prev then
      finish()
      event.target:removeSelf()
    elseif "submitted" == phase
    and "ended" ~= prev and "submitted" ~= prev then
      finish()
      event.target:removeSelf()
      group:emit("submit")
    end
    prev = phase
  end

  local function start () -- called by focus() or :on("focus")
    -- trial and error positioning ftw ;-)
    local left, top = placeholdertext:contentToLocal(placeholdertext.x, placeholdertext.y)
    local textfield = native.newTextField(-1 - left, 4 - top, width, 40)
    textfield.text = value
    textfield.font = native.newFont(options.font, options.size)
    textfield.hasBackground = false
    textfield.isSecure = options.isSecure
    if options.returnKey then textfield:setReturnKey(options.returnKey) end
    textfield:addEventListener("userInput", input)
    native.setKeyboardFocus(textfield)
  end

  local function focus ()
    if active then return end
    active = true
    line:setColor(0, 153, 204)
    line.width = 2
    local text = value
    if options.typeover then text = "" end
    setvalue(text)
    if 0 == #group:listeners("focus") then
      start()
    else
      group:emit("focus", group) -- listener should call :start()
    end
  end

  local function touch (event)
    if "ended" == event.phase then focus() end
    return true
  end placeholdertext:addEventListener("touch", touch)


  function group:focus ()
    focus()
  end

  function group:start ()
    if not active then
      print('WARNING - :start() only to be called from :on("focus", listener)')
      return
    end
    start()
  end

  function group:value ()
    return value
  end

  function group:reset ()
    setvalue("")
    finish()
    native.setKeyboardFocus(nil)
  end

  return group
end

return TextField
