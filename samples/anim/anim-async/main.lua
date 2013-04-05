----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

MOAISim.openWindow ( "test", 320, 480 )


function httpGet(url, args, callback)
   -- Process args:
   local str = ''
   for k,v in pairs(args or {}) do
      if str == '' then
         str = str .. '?' .. k .. '=' .. tostring(v)
      else
         str = str .. '&' .. k .. '=' .. tostring(v)
      end
   end
   url = url .. str

   -- Routine:
   local fetch

   -- CB:
   local cb = function( task, responseCode )
      -- Result:
      local result = task:getString()
      if result and responseCode == 200 then
         callback(result)
      else
         fetch()
      end
   end
   
   -- Fetch URL:
   fetch = function()
      local task = MOAIHttpTask.new ()
      task:setVerb( MOAIHttpTask.HTTP_GET )
      task:setUrl( url )
      task:setTimeout( 10 )
      task:setUserAgent( "Moai" )
      task:setCallback(cb)
      task:performAsync()
   end
   fetch()
end


viewport = MOAIViewport.new ()
viewport:setSize ( 320, 480 )
viewport:setScale ( 320, -480 )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

gfxQuad = MOAIGfxQuad2D.new ()

tex = MOAIAsyncTexture.new()
tex:load("moai.png")

gfxQuad:setTexture ( tex )
gfxQuad:setRect ( -128, -128, 128, 128 )
gfxQuad:setUVRect ( 0, 0, 1, 1 )

httpGet("http://image01.ctvdigital.com/images/pub2upload/2/2008_1_15/mercury-far-side-first-imag.jpg", nil, 
	function(result)
		print('HTTP image loaded!')
	    local dataBuffer = MOAIDataBuffer.new()
        dataBuffer:setString(result)

		-- tex = MOAIAsyncTexture.new()
		tex:load(dataBuffer)
		-- gfxQuad:setTexture ( tex )
	end)

prop = MOAIProp2D.new ()
prop:setDeck ( gfxQuad )
layer:insertProp ( prop )

prop:moveRot ( 360, 30.5 )
