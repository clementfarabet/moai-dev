
-- Detect res:
local width  = MOAIEnvironment.horizontalResolution 
local height = MOAIEnvironment.verticalResolution 
print('Configuration:')
print(' - Resolution: ' .. width .. 'x' .. height)
print(' - Working dir: ' .. MOAIFileSystem.getWorkingDirectory())

-- Window+Layer
MOAISim.openWindow('Test', width, height)

viewport = MOAIViewport.new()
viewport:setSize(width,height)
viewport:setScale(width,-height)

layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAISim.pushRenderPass(layer)

-- Test texture:
quad = MOAIGfxQuad2D.new()
quad:setTexture('test.jpg')
quad:setRect(-width/2,-height/2,width/2,height/2)
quad:setUVRect ( 0, 0, 1, 1 )

prop = MOAIProp2D.new()
prop:setDeck(quad)
prop:setLoc(0,0)
layer:insertProp(prop)

-- Test animations:
c = MOAICoroutine.new()
c:run(function()
   while true do
      MOAICoroutine.blockOnAction( prop:moveScl(.1, .1, 2) )
      MOAICoroutine.blockOnAction( prop:moveScl(-.1, -.1, 2) )
   end
end)

-- Test text:
font = MOAIFont.new()
font:load('Gotham-Book.ttf')

text = MOAITextBox.new()
text:setRect(-width/2,-200,width/2,200)
text:setLoc(0,0)
text:setTextSize(128)
text:setFont(font)
text:setColor(1,1,1,0.8)
text:setAlignment(MOAITextBox.CENTER_JUSTIFY)
text:setString('Welcome to MOAI on OSX!')
layer:insertProp(text)
text:spool()

-- Test window resize:
MOAIGfxDevice.setListener(MOAIGfxDevice.EVENT_RESIZE, function(nwidth, nheight)
   width,height = nwidth,nheight
   viewport:setSize(width,height)
   viewport:setScale(width,-height)
   quad:setRect(-width/2,-height/2,width/2,height/2)
   text:setRect(-width/2,-200,width/2,200)
end)

-- Test touch:
MOAIInputMgr.device.pointer:setCallback(function(x,y)
   print('mouse moving to: '.. x..','..y)
end)
MOAIInputMgr.device.mouseLeft:setCallback(function(down)
   print('button left clicked (down='..tostring(down)..')') 
end)
MOAIInputMgr.device.keyboard:setCallback(function(key,down)
   print('key ' .. key .. ' pressed (down='..tostring(down)..')') 
end)

