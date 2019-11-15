local awful = require('awful')
local right_panel = require('layout.right-panel')
local bottom_panel = require('layout.bottom-panel')

-- Create a wibox for each screen and add it
screen.connect_signal("request::desktop_decoration", function(s)
  if s.index == 1 then
    -- Create the right_panel
   s.right_panel = right_panel(s)
    -- Create the Top bar
    s.bottom_panel = bottom_panel(s, true)
  else
    -- Create the Top bar
    s.bottom_panel = bottom_panel(s, false)
  end
end)


showAgain = false
-- Hide bars when app go fullscreen
function updateBarsVisibility()
  for s in screen do
    if s.selected_tag then
      local fullscreen = s.selected_tag.fullscreenMode
      -- Order matter here for shadow
      s.bottom_panel.visible = not fullscreen
      if s.right_panel then
        if fullscreen and s.right_panel.visible then
          _G.screen.primary.right_panel:toggle()
          showAgain = true
        elseif not fullscreen and not s.right_panel.visible and showAgain then
          _G.screen.primary.right_panel:toggle()
          showAgain = false
        end
      end
    end
  end
end

_G.tag.connect_signal(
  'property::selected',
  function(t)
    updateBarsVisibility()
  end
)

_G.client.connect_signal(
  'property::fullscreen',
  function(c)
    if c.first_tag then
      c.first_tag.fullscreenMode = c.fullscreen
    end
    updateBarsVisibility()
  end
)

_G.client.connect_signal(
  'unmanage',
  function(c)
    if c.fullscreen then
      c.screen.selected_tag.fullscreenMode = false
      updateBarsVisibility()
    end
  end
)