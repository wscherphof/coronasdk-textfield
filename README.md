# coronasdk-textfield

Dressed-up native textfields for the Corona SDK

## Usage

### 1. Install
Setup [lua-loader](https://github.com/wscherphof/lua-loader) and then just `npm install coronasdk-textfield`

### 2. Require
```lua
local TextField = require("coronasdk-textfield")
```

### 3. Have fun
```lua
local function loginform (width, sendbutton)
  local group = display.newGroup()

  local uid = TextField:new("User name", width, {returnKey = "next"})
  group:insert(uid)

  local pwd = TextField:new("Password", width, {returnKey = "send", isSecure = true})
  group:insert(pwd)
  pwd.y = uid.y + uid.contentHeight

  local function newvalue ()
    if #uid:value() > 0 and #pwd:value() > 0 then
      sendbutton:show()
    else
      sendbutton:hide()
    end
  end
  uid:on("change", newvalue)
  pwd:on("change", newvalue)

  uid:on("submit", function ()
    if #uid:value() < 1 then
      uid:focus()
    else
      pwd:focus()
    end
  end)

  pwd:on("submit", function ()
    if #uid:value() < 1 then
      uid:focus()
    elseif #pwd:value() < 1 then
      pwd:focus()
    else
      authenticate(uid:value(), pwd:value())
    end
  end)

  sendbutton:on("release", function ()
    pwd:emit("submit")
  end)

  function group:reset ()
    uid:reset()
    pwd:reset()
  end

  return group
end
```
The above example shows most of the functions and events in the API. There are a few more options in `:new ()` (see the code).
And you could choose interfere with some action when the textfield gets focused, e.g.:
```lua
  local function focus (field)
    if 16 ~= group.y then
      transition.to(group, {
        time = 400,
        transition = easing.outExpo,
        y = 16,
        onComplete = function () field:start() end
      })
    else
      field:start()
    end
  end
  uid:on("focus", focus)
  pwd:on("focus", focus)
```
Notice that you then have to call `:start()` to kick off the keyboard input functionality. If there's no listener for the `"focus"` event, the keyboard gets kicked off automatically.

## Limitations
- Only styling for [Android](http://developer.android.com/design/building-blocks/text-fields.html) (iOS probably added soonly)
- Fixed height of 48 content pixels; fork to change, but then experiment with the positioning in the `focus ()` function 

## License
[GNU Lesser General Public License (LGPL)](http://www.gnu.org/licenses/lgpl-3.0.txt)
