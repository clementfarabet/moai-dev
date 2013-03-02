
-- Detect res:
local width  = MOAIEnvironment.horizontalResolution 
local height = MOAIEnvironment.verticalResolution 
print('Configuration:')
print(' - Resolution: ' .. width .. 'x' .. height)

----------------------------------------------------------------------------
-- Window+Layer
--
MOAISim.openWindow('Test', width, height)

viewport = MOAIViewport.new()
viewport:setSize(width,height)
viewport:setScale(width,-height)

layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAISim.pushRenderPass(layer)

----------------------------------------------------------------------------
-- Test
--
quad = MOAIGfxQuad2D.new()
quad:setTexture('/Users/clement/Desktop/test.jpg')
quad:setRect(-width/2,-height/2,width/2,height/2)
quad:setUVRect ( 0, 0, 1, 1 )

prop = MOAIProp2D.new()
prop:setDeck(quad)
prop:setLoc(0,0)
layer:insertProp(prop)
print('everything loaded!')

c = MOAICoroutine.new()
c:run(function()
   while true do
      MOAICoroutine.blockOnAction( prop:moveScl(.1, .1, 2) )
      MOAICoroutine.blockOnAction( prop:moveScl(-.1, -.1, 2) )
   end
end)

