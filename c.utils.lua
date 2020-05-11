screenW, screenH = guiGetScreenSize()
scaleValue = math.max(math.floor(screenH / 1080), 0.5)

function pixels(q)
    return (scaleValue * q)
end

local _cursorP = getCursorPosition
function getCursorPosition(absolute)
    local x, y, worldx, worldy, worldz = _cursorP()
    if absolute then
        x = x * screenW
        y = y * screenH
    end
    return x, y, worldx, worldy, worldz
end

function isHoverBox(x, y, w, h)
    if not isCursorShowing() then return false end
    local mx, my = getCursorPosition(true)
    return ((mx >= x and mx <= x + w) and (my >= y and my <= y + h))
end
