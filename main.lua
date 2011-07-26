--***********************************************************************************************--
--***********************************************************************************************--

-- ===========
-- PUZZLE APP
-- ===========

-- Created by Jonathan Beebe.
-- http://jonbeebe.net
-- @jonathanbeebe

-- File: main.lua
--
-- Version 1.0
--
-- Copyright (C) 2011 ANSCA Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
-- Published changes made to this software and associated documentation and module files (the
-- "Software") may be used and distributed by ANSCA, Inc. without notification. Modifications
-- made to this software and associated documentation and module files may or may not become
-- part of an official software release. All modifications made to the software will be
-- licensed under these same terms and conditions.

--***********************************************************************************************--
--***********************************************************************************************--


-- Set below to false if performance lags
local shadowOn = true

-- When you place a puzzle piece, it checks to see if you're within a certain
-- pixel range to the final spot that piece is supposed to go. If you place
-- the piece within that range, the app assumes you meant to put it at exactly
-- the right spot and auto-adjusts to fit at exactly the right location.

-- Value below needs to be adjusted once tested on device with proper dimensions
-- (I only had an iPod touch to test on).

local placementBuffer = 8

-- Below is another "cushion" setting so when you tap the piece, it will rotate.
-- Because a finger is subject to much more movement than a mouse pointer, this
-- also needs to be adjusted once tested on the proper device:

local rotateBuffer = 7

--

local ui = require( "ui" )
local screenGroup = display.newGroup()
local puzzleNum = 1

--

local loadNewPuzzle = function()
	math.randomseed(os.time())
	local mRand = math.random
	
	local pzObject = {}
	local pzShadow = {}
	local pzMask = {}
	local pzGlow, glowTween
	
	local bgImage
	local puzzlePreview
	local dimRect
	
	-- ui buttons
	local newPuzzleBtn
	local previewBtn
	local solveItBtn
	
	local isDragging
	local isSelected = false
	local lastPiece, finalPiece
	local lastShadow, finalShadow
	
	local placedCount = 0
	local maxPieces = 25
	
	local isReady = false
	
	local halfW = display.contentCenterX
	local halfH = display.contentCenterY
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local resetReference = function( index )
		local i = index
		
		-- SET PUZZLE REFERENCE POINT DEPENDING ON MASK PIECE
		local max1 = 5
		local max2 = 10
		local max3 = 15
		local max4 = 20
		local max5 = 25
		local xRef, yRef
		
		if i <= max1 then
			xRef = -250 + ( i * 100 - 50 )
			yRef = -250 + 50
			
		elseif i > max1 and i <= max2 then
			xRef = -250 + ( (i - max1) * 100 - 50 )
			yRef = -250 + ( 2 * 100 - 50 )
		
		elseif i > max2 and i <= max3 then
			xRef = -250 + ( (i - max2) * 100 - 50 )
			yRef = -250 + ( 3 * 100 - 50 )
		
		elseif i > max3 and i <= max4 then
			xRef = -250 + ( (i - max3) * 100 - 50 )
			yRef = -250 + ( 4 * 100 - 50 )
		
		elseif i > max4 and i <= max5 then
			xRef = -250 + ( (i - max4) * 100 - 50 )
			yRef = -250 + ( 5 * 100 - 50 )
		end
		
		pzObject[i].xReference = xRef
		pzObject[i].yReference = yRef
		
		--SHADOW
		if shadowOn then
			pzShadow[i].xReference = xRef
			pzShadow[i].yReference = yRef
		end
	
		pzObject[i].top = pzObject[i].y - 50
		pzObject[i].bottom = pzObject[i].y + 50
		pzObject[i].left = pzObject[i].x - 50
		pzObject[i].right = pzObject[i].x + 50
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local checkLocation = function( index )
		local i = index
		
		pzObject[i].xReference = 0
		pzObject[i].yReference = 0
		
		local xCenter = 300
		local yCenter = 674--512
		
		-- Allow a little deviation (so they don't have to be pixel perfect)
		local left = xCenter - placementBuffer
		local right = xCenter + placementBuffer
		local top = yCenter - placementBuffer
		local bottom = yCenter + placementBuffer
		
		--print( "Object[" .. i .. "] x: " .. pzObject[i].x .. ", but needs: " .. left .. " - " .. right )
		--print( "Object[" .. i .. "] y: " .. pzObject[i].y .. ", but needs: " .. top .. " - " .. bottom )
		
		if pzObject[i].x > left and pzObject[i].x < right and pzObject[i].y > top and pzObject[i].y < bottom
			and pzObject[i].rotation == 0 and pzObject[i] == finalPiece then
			-- PUZZLE PIECE IS IN CORRECT SPOT!
			print( "Puzzle piece placed!" )
			
			-- Increment placed count
			placedCount = placedCount + 1
			
			-- Check to see if puzzle is complete
			if placedCount == maxPieces then
				--THE PUZZLE IS FINISHED! DO COOL EFFECT
				solveItBtn.isActive = false
				previewBtn.isActive = false
				
				local i = 1
				
				local function nextPiece()
					i = i + 1
					if i <= maxPieces then
						transition.to( pzObject[i], { time=50, alpha=1.0, onComplete=nextPiece } )
					end
				end
				transition.to( pzObject[i], { time=50, alpha=1.0, onComplete=nextPiece } )
			end
			
			-- Correct any deviation
			pzObject[i].canMove = false
			pzObject[i].x = xCenter
			pzObject[i].y = yCenter
			pzObject[i].rotation = 0
			pzObject[i].alpha = 0.65
			
			-- Reset reference points again
			resetReference( i )
			
			return true
		else
			-- NOT PLACED IN PROPER LOCATION:
			
			resetReference( i )
				
			return false
		end
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local createPuzzle = function()
		local i
		local puzzleFile = "puzzle" .. puzzleNum .. ".png"
		
		puzzlePreview = display.newImageRect( puzzleFile, 500, 500 )
		puzzlePreview.x = 300; puzzlePreview.y = 512
		puzzlePreview.alpha = 0
		puzzlePreview.isVisible = false
		
		for i=1,maxPieces,1 do
			pzObject[i] = display.newImageRect( puzzleFile, 500, 500 )
			
			--SHADOW
			if shadowOn then
				pzShadow[i] = display.newImageRect( "shadow.png", 500, 500 )
			
				--SHADOW
				screenGroup:insert( pzShadow[i] )
			end
			
			screenGroup:insert( pzObject[i] )
			
			pzObject[i].x = 300; pzObject[i].y = 674 --512
			
			--SHADOW
			if shadowOn then
				pzShadow[i].x = 300; pzShadow[i].y = 674
				pzShadow[i].alpha = 0.5
				pzShadow[i].isVisible = false
			end
			
			-- SET MASK
			local maskFile = "mask" .. i .. ".png"
			pzMask[i] = graphics.newMask( maskFile )
			
			pzObject[i]:setMask( pzMask[i] )
			
			--SHADOW
			if shadowOn then
				pzShadow[i]:setMask( pzMask[i] )
			end
			
			pzObject[i].canMove = true
			
			resetReference( i )
			
			local touchPz = function( event )
			
				if not isSelected and event.phase == "began" and event.x > pzObject[i].left and event.x < pzObject[i].right and
					event.y > pzObject[i].top and event.y < pzObject[i].bottom and pzObject[i].canMove then
					
					isSelected = true
					
					lastPiece = pzObject[i]
					
					--SHADOW
					if shadowOn then
						lastShadow = pzShadow[i]
					end
					
					isDragging = true
				
				elseif event.phase == "ended" then
					
					-- ROTATE IF TAPPED IN PLACE:
					local left = event.xStart - rotateBuffer
					local right = event.xStart + rotateBuffer
					local top = event.yStart - rotateBuffer
					local bottom = event.yStart + rotateBuffer
					
					if finalPiece and finalPiece == pzObject[i] and event.x > left and event.x < right
						and event.y > top and event.y < bottom then
						
						local curRot = pzObject[i].rotation
						
						curRot = curRot + 45
						if curRot >= 360 then curRot = 0; end
						
						pzObject[i].rotation = curRot
						
						--SHADOW
						if shadowOn then
							pzShadow[i].rotation = curRot
						end
					end
					
					lastPiece = nil
					
					--SHADOW
					if shadowOn then
						lastShadow = nil
					end
					
					checkLocation( i )
					
					--resetReference( i )
				end
			end
			
			pzObject[i]:addEventListener( "touch", touchPz )
		end
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local startDrag = function( event )
		if isReady then
			if event.phase == "began" then
				
				finalPiece = lastPiece
				
				if shadowOn then
					finalShadow = lastShadow
				end
				
				if finalPiece then
					--SHADOW
					if shadowOn then
						finalShadow.isVisible = true
						finalShadow:toFront()
					end
					
					finalPiece:toFront()
					pzGlow:toFront()
					
					finalPiece.xScale = 1.02
					finalPiece.yScale = 1.02
					
					--SHADOW
					if shadowOn then
						finalShadow.xScale = 1.02
						finalShadow.yScale = 1.02
					end
					
					if glowTween then transition.cancel( glowTween ); end
					
					pzGlow.alpha = 0
					pzGlow.isVisible = true
					glowTween = transition.to( pzGlow, { time=500, alpha=0.4 } )
				end
			
			elseif event.phase == "ended" then
				isDragging = false
				isSelected = false
				pzGlow.isVisible = false
				pzGlow.alpha = 0
				if glowTween then transition.cancel( glowTween ); end
				
				if finalPiece then
					finalPiece.xScale = 1.0
					finalPiece.yScale = 1.0
				end
				
				--SHADOW
				if finalShadow then
					finalShadow.isVisible = false
					finalShadow.xScale = 1.0
					finalShadow.yScale = 1.0
				end
			end
			
			if isDragging and finalPiece then
				finalPiece.x = event.x
				finalPiece.y = event.y
				if shadowOn then
					finalShadow.x = event.x + 2
					finalShadow.y = event.y + 3
				end
				pzGlow.x = event.x
				pzGlow.y = event.y
			end
		end
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local scatterPuzzle = function()
		local i = 1
			
		local randX = mRand( 100, 500 )
		local randY = mRand( 100, 400 )
		
		local j = mRand( 1, 8 )
		local endRot = 0
		
		if j == 1 then
			endRot = 0
		
		elseif j == 2 then
			endRot = 45
		
		elseif j == 3 then
			endRot = 90
		
		elseif j == 4 then
			endRot = 135
		
		elseif j == 5 then
			endRot = 180
		
		elseif j == 6 then
			endRot = 225
		
		elseif j == 7 then
			endRot = 270
		
		elseif j == 8 then
			endRot = 315
		
		end
		
		local function nextPiece()
			local j = mRand( 1, 8 )
		
			local endRot = 0
		
			if j == 1 then
				endRot = 0
			
			elseif j == 2 then
				endRot = 45
			
			elseif j == 3 then
				endRot = 90
			
			elseif j == 4 then
				endRot = 135
			
			elseif j == 5 then
				endRot = 180
			
			elseif j == 6 then
				endRot = 225
			
			elseif j == 7 then
				endRot = 270
			
			elseif j == 8 then
				endRot = 315
			
			end
			
			i = i + 1
			
			if i <= maxPieces then
				local randX = mRand( 100, 500 )
				local randY = mRand( 100, 350 )
			
				transition.to( pzObject[i], { time=50, x=randX, y=randY, rotation=endRot, onComplete=nextPiece } )
		
				if shadowOn then
					transition.to( pzShadow[i], { time=50, x=randX, y=randY, rotation=endRot, onComplete=nextPiece } )
				end
			else
				-- activate buttons
				newPuzzleBtn.isActive = true
				previewBtn.isActive = true
				solveItBtn.isActive = true
				
				-- ready for dragging pieces around
				isReady = true
				Runtime:addEventListener( "touch", startDrag )
			end
		end
		
		transition.to( pzObject[i], { time=50, x=randX, y=randY, rotation=endRot, onComplete=nextPiece } )
		
		if shadowOn then
			transition.to( pzShadow[i], { time=50, x=randX, y=randY, rotation=endRot, onComplete=nextPiece } )
		end
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local drawBackground = function()
		bgImage = display.newImageRect( "greybackground.png", 600, 1024 )
		bgImage.x = 300; bgImage.y = 512
		
		screenGroup:insert( bgImage )
		
		dimRect = display.newRect( screenGroup, 0, 0, display.contentWidth, display.contentHeight )
		dimRect:setFillColor( 0, 0, 0, 255 )
		dimRect.alpha = 0
		dimRect.isVisible = false
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local createGlow = function()
		pzGlow = display.newImage( "glow.png", 200, 200 )
		pzGlow.alpha = 0
		pzGlow.isVisible = false
		
		screenGroup:insert( pzGlow )
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local touchNewPuzzleBtn = function( event )
		if event.phase == "release" and newPuzzleBtn.isActive then
			newPuzzleBtn.isActive = false
			
			nextPuzzle()
		end
	end
	
	local touchPreviewBtn = function( event )
		if event.phase == "release" and previewBtn.isActive then
			previewBtn.isActive = false
			
			Runtime:removeEventListener( "touch", startDrag )
			
			local startTouchEvent = function()
				
				local function closePreview( event )
					if event.phase == "ended" and not previewBtn.isActive then
						previewBtn.isActive = true
						dimRect.alpha = 0
						dimRect.isVisible = false
						puzzlePreview.alpha = 0
						puzzlePreview.isVisible = false
						
						Runtime:removeEventListener( "touch", closePreview )
						Runtime:addEventListener( "touch", startDrag )
					end
				end
				
				Runtime:addEventListener( "touch", closePreview )
				
				puzzlePreview.isVisible = true
				transition.to( puzzlePreview, { time=200, alpha=1.0 } )
			end
			
			dimRect:toFront()
			puzzlePreview:toFront()
			
			dimRect.isVisible = true
			transition.to( dimRect, { time=500, alpha=0.85, onComplete=startTouchEvent } )
		end
	end
	
	local touchSolveItBtn = function( event )
		if event.phase == "release" and solveItBtn.isActive then
			solveItBtn.isActive = false
			previewBtn.isActive = false
			
			local i = maxPieces
			local xCenter = 300
			local yCenter = 674
			
			local function nextPiece()
				finalPiece = pzObject[i]
				checkLocation( i )
				
				i = i - 1
				
				if i > 0 then
					if pzObject[i].canMove then
						pzObject[i].xReference = 0
						pzObject[i].yReference = 0
						
						transition.to( pzObject[i], { time=50, x=xCenter, y=yCenter, rotation=0, onComplete=nextPiece } )
					else
						nextPiece()
					end
				else
					i = i + 1
					placedCount = maxPieces
					checkLocation( i )
				end
			end
			
			pzObject[i].xReference = 0
			pzObject[i].yReference = 0
			
			transition.to( pzObject[i], { time=50, x=xCenter, y=yCenter, rotation=0, onComplete=nextPiece } )
		end
	end
	
	
	local createMenu = function()
		-- NEW PUZZLE BUTTON
		newPuzzleBtn = ui.newButton{
			defaultSrc = "newpuzzlebtn.png",
			defaultX = 162,
			defaultY = 56,
			overSrc = "newpuzzlebtn-over.png",
			overX = 162,
			overY = 56,
			onEvent = touchNewPuzzleBtn,
			id = "newPuzzleButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		newPuzzleBtn.x = 129; newPuzzleBtn.y = 975
		screenGroup:insert( newPuzzleBtn )
		
		
		-- PREVIEW BUTTON
		previewBtn = ui.newButton{
			defaultSrc = "previewbtn.png",
			defaultX = 162,
			defaultY = 56,
			overSrc = "previewbtn-over.png",
			overX = 162,
			overY = 56,
			onEvent = touchPreviewBtn,
			id = "previewButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		previewBtn.x = 300; previewBtn.y = 975
		screenGroup:insert( previewBtn )
		
		
		-- SOLVE IT BUTTON
		solveItBtn = ui.newButton{
			defaultSrc = "solveitbtn.png",
			defaultX = 162,
			defaultY = 56,
			overSrc = "solveitbtn-over.png",
			overX = 162,
			overY = 56,
			onEvent = touchSolveItBtn,
			id = "solveItButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		solveItBtn.x = 471; solveItBtn.y = 975
		screenGroup:insert( solveItBtn )
	end
	
	--===================================================================================
	--
	--
	--===================================================================================
	
	local appInit = function()
		drawBackground()
		createPuzzle()
		createGlow()
		createMenu(); newPuzzleBtn.isActive = false; previewBtn.isActive = false; solveItBtn.isActive = false
		
		timer.performWithDelay( 3000, scatterPuzzle, 1 )
		--Runtime:addEventListener( "touch", startDrag )
		
		dimRect:toFront()
		puzzlePreview:toFront()
	end
	
	appInit()
end

loadNewPuzzle()

nextPuzzle = function()
	if puzzleNum == 4 then	
		puzzleNum = 1
	else
		puzzleNum = puzzleNum + 1
	end
	
	-- Remove event listeners:
	Runtime:removeEventListener( "touch", startDrag )
	
	local unloadScreenGroup = function()
		-- Remove objects from screenGroup:
		local i
		
		for i=screenGroup.numChildren,1,-1 do
			local child = screenGroup[i]
			child.parent:remove( child )
			child = nil
		end
		
		loadNewPuzzle()
		transition.to( screenGroup, { time=500, alpha=1.0 } )
	end
	
	-- Fade screenGroup Away
	transition.to( screenGroup, { time=500, alpha=0, onComplete=unloadScreenGroup } )
end
