--[[
    ■■■■■ DynamicAPI
    ■   ■ Author: Sh1zok
    ■■■■  v0.2.0

MIT License

Copyright (c) 2025-2026 Sh1zok

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



local dynamicAPI = {}



function dynamicAPI:newDynamicModelPart(modelPart, parameters, onRenderFunction)
    --[[
        ASSERTATION
    ]]--
    assert(type(modelPart) == "ModelPart", "Invalid argument 1 to function newDynamicModelPart. Expected ModelPart, but got " .. type(modelPart))
    assert((type(parameters) == "table") or not parameters, "Invalid argument 2 to function newDynamicModelPart. Expected Table or nil, but got " .. type(parameters))
    assert((type(onRenderFunction) == "function") or not onRenderFunction, "Invalid argument 3 to function newDynamicModelPart. Expected Function or nil, but got " .. type(onRenderFunction))

    --[[
        INITIALIZATION
    ]]--
    local modelPartNativeParentType = modelPart:getParentType()
    local interface = {}
    if modelPartNativeParentType ~= "None" then modelPart:setParentType("None") end
    modelPart.preRender = onRenderFunction

    --[[
        INTERFACE
    ]]--
    function interface:setModelPart(newModelPart)
        assert(type(modelPart) == "ModelPart", "Invalid argument to function setModelPart. Expected ModelPart, but got " .. type(modelPart))

        if modelPartNativeParentType ~= "None" then modelPart:setParentType(modelPartNativeParentType) end
        modelPart = newModelPart
        modelPartNativeParentType = modelPart:getParentType()
        if modelPartNativeParentType ~= "None" then modelPart:setParentType("None") end

        return interface -- Returns interface for chaining
    end

    function interface:setParameters(newParameters)
        assert(type(newParameters) == "table", "Invalid argument to function setParameters. Expected Table, but got " .. type(newParameters))
        parameters = newParameters

        return interface -- Returns interface for chaining
    end

    function interface:setOnRender(newOnRenderFunction)
        assert(type(newOnRenderFunction) == "function", "Invalid argument to function setOnRender. Expected Function, but got " .. type(newOnRenderFunction))

        if onRenderFunction then onRenderFunction = nil end
        modelPart.preRender = newOnRenderFunction

        return interface -- Returns interface for chaining
    end

    function interface:getModelPart() return modelPart end
    function interface:getParameters() return parameters end

    function interface:remove()
        if modelPartNativeParentType ~= "None" then modelPart:setParentType(modelPartNativeParentType) end
        modelPart.preRender = nil
        modelPart = nil
        parameters = nil
        onRenderFunction = nil
        interface = nil
        return nil
    end

    return interface
end



return dynamicAPI
