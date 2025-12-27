--[[
    ■■■■■ HydraAPI
    ■   ■ Author: Sh1zok
    ■■■■  v0.1.1

MIT License

Copyright (c) 2025 Sh1zok

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--



local hydraAPI = {}



function hydraAPI:newHead(modelPart, parameters, matrixFunction)
    --[[
        INITIALIZATION
    ]]--
    assert(type(modelPart) == "ModelPart", "Invalid argument 1 to function newHead. Expected ModelPart, but got " .. type(modelPart))
    assert((type(parameters) == "table") or not parameters, "Invalid argument 2 to function newHead. Expected Table or nil, but got " .. type(parameters))
    assert((type(matrixFunction) == "function") or not matrixFunction, "Invalid argument 3 to function newHead. Expected Function or nil, but got " .. type(matrixFunction))
    modelPart:setParentType("NONE") -- Preparing modelPart



    --[[
        VARIABLES
    ]]--
    local interface = {}
    local headParameters = parameters or {strength = 1, speed = 1, maxTiltDegrees = 2.5}
    local headModelPart = modelPart
    local headRotPrevFrame, headPosPrevFrame, headScalePrevFrame = vec(0, 0, 0), vec(0, 0, 0), vec(1, 1, 1)
    local UUID = client:intUUIDToString(client:generateUUID())

    local headMatrixFunction = matrixFunction or function(parameters)
        local vanillaHeadRot = parameters.vanillaHeadRotation
        local headRotPrevFrame = parameters.headRotationPreviousFrame
        local vanillaHeadPos = parameters.vanillaHeadPosition
        local speed, strength, maxTiltDegrees = parameters.otherParameters.speed, parameters.otherParameters.strength, parameters.otherParameters.maxTiltDegrees

        local headRot = math.lerp(
            headRotPrevFrame,
            vanillaHeadRot * strength,
            math.min(8 / math.max(client:getFPS(), 1) * speed, 1)
        )
        headRot[3] = math.lerp(
            headRotPrevFrame[3],
            vanillaHeadRot[2] * maxTiltDegrees / 50,
            math.min(8 / math.max(client:getFPS(), 1) * speed, 1)
        )

        return headRot, -vanillaHeadPos, vec(1, 1, 1)
    end



    --[[
        HEAD PROCESSOR
    ]]--
    events.RENDER:register(function(delta, context, matrix)
        -- Checking the need to process the head matrix
        if not player:isLoaded() then return end
        if not context == "RENDER" or context == "FIRST_PERSON" or context == "MINECRAFT_GUI" then return end

        local vanillaHeadRotation = (vanilla_model.HEAD:getOriginRot() + 180) % 360 - 180
        local vanillaHeadPosition = vanilla_model.HEAD:getOriginPos()
        local vanillaHeadScale = vanilla_model.HEAD:getOriginScale()

        local headRotation, headPosition, headScale = headMatrixFunction({
            vanillaHeadRotation = vanillaHeadRotation,
            headRotationPreviousFrame = headRotPrevFrame,
            vanillaHeadPosition = vanillaHeadPosition,
            headPositionPreviousFrame = headPosPrevFrame,
            vanillaHeadScale = vanillaHeadScale,
            headScalePreviousFrame = headScalePrevFrame,
            renderParameters = {delta = delta, context = context, matrix = matrix},
            otherParameters = headParameters
        })
        if headRotation then headModelPart:setRot(headRotation) end
        if headPosition then headModelPart:setPos(headPosition) end
        if headScale then headModelPart:setScale(headScale) end

        headRotPrevFrame, headPosPrevFrame, headScalePrevFrame = headRotation, headPosition, headScale
    end, "HydraAPI.Head." .. UUID)



    --[[
        INTERFACE
    ]]--
    function interface:setModelPart(newModelPart)
        assert(type(modelPart) == "ModelPart", "Invalid argument to function setModelPart. Expected ModelPart, but got " .. type(modelPart))
        headModelPart = newModelPart

        return interface -- Returns interface for chaining
    end
    function interface:modelPart(newModelPart) return interface:setModelPart(newModelPart) end -- Alias

    function interface:setParameters(newParameters)
        assert(type(newParameters) == "table", "Invalid argument to function setParameters. Expected Table, but got " .. type(newParameters))
        headParameters = newParameters

        return interface -- Returns interface for chaining
    end
    function interface:parameters(newParameters) return interface:setParameters(newParameters) end -- Alias

    function interface:setMatrixFunction(newMatrixFunction)
        assert(type(newMatrixFunction) == "function", "Invalid argument to function setMatrixFunction. Expected Function, but got " .. type(newMatrixFunction))
        headMatrixFunction = newMatrixFunction

        return interface -- Returns interface for chaining
    end
    function interface:matrixFunction(newMatrixFunction) return interface:setMatrixFunction(newMatrixFunction) end -- Alias

    function interface:getModelPart() return headModelPart end
    function interface:getParameters() return headParameters end
    function interface:getMatrixFunction() return headMatrixFunction end
    function interface:getUUID() return UUID end

    function interface:remove()
        events.RENDER:remove("HydraAPI.Head." .. UUID)
        UUID, vanillaHeadRotPrevFrame, vanillaHeadPosPrevFrame, headModelPart, headParameters, headMatrixFunction, interface = nil, nil, nil, nil, nil, nil, nil

        return nil
    end



    return interface
end



return hydraAPI