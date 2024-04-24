myButton = nil

function init()
  connect(g_app, { onFps = refresh })

  myTopRightButton = modules.client_topmenu.addRightGameToggleButton('myTopRightButton', tr('MyWindow'), '/images/topbuttons/inventory', toggle)
  myTopRightButton:setOn(true)

  myWindow = g_ui.loadUI('question7', modules.game_interface.getRightPanel())
  myWindow:disableResize()
  myPanel = myWindow:getChildById('contentsPanel')

  myButton = myPanel:getChildById('myButton')
  local function resetButtonPosition()
    local position = myButton:getPosition()
    local size = myButton:getSize()
    local parentPosition = myButton:getParent():getPosition()
    local parentSize = myButton:getParent():getSize()
    
    -- Reset the button's x position and get a new random y position,
    -- being careful to keep the button within the parent's bounds.
    local newRelativeHeight = math.random(0, (parentSize.height - size.height))
    position.x = parentPosition.x + parentSize.width - size.width
    position.y = parentPosition.y + size.height + newRelativeHeight
    myButton:setPosition(position)
  end
  myButton.onClick = resetButtonPosition

  myWindow:setup()
  
  -- Every 100ms, move the button to the left.
  cycleEvent(moveButton, 100)
end

function terminate()
  myButton:destroy()
  myWindow:destroy()
end

function moveButton()
  local position = myButton:getPosition()
  position.x = position.x - 5
  
  -- Stop the button when it hits the left edge of the parent.
  local parentPosition = myButton:getParent():getPosition()
  if position.x < parentPosition.x then
      position.x = parentPosition.x
  end

  myButton:setPosition(position)
end

function toggle()
  if myButton:isOn() then
    myWindow:close()
    myButton:setOn(false)
  else
    myWindow:open()
    myButton:setOn(true)
  end
end

function onMiniWindowClose()
  myButton:setOn(false)
end
