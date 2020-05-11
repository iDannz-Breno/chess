local chess = {
    color = {
        bg1 = tocolor(235, 236, 208, 255),
        bg2 = tocolor(119, 149, 86, 255),
        border = tocolor(255, 255, 255, 255),
        team = {
            [1] = tocolor(87, 84, 82, 255),
            [2] = tocolor(250, 250, 250, 255),
        },
    },
    
    pieces = {
        ['rook'] = {
            icon = 'icons/rook.png',
        },
        ['knight'] = {
            icon = 'icons/knight.png',
        },
        ['bishop'] = {
            icon = 'icons/bishop.png',
        },
        ['queen'] = {
            icon = 'icons/queen.png',
        },
        ['king'] = {
            icon = 'icons/king.png',
        },
        ['pawn'] = {
            icon = 'icons/pawn.png',
        },
    },
    team = {-- maybe multiplayer later (?)
        [1] = 'Machine',
        [2] = getPlayerName(localPlayer),
    },
    matrix = {
        -- [x] = {
        -- [y] = {name = 'pieces[~]', team = {1 or 2}}
        -- }
        [1] = {
            [1] = {name = 'rook', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'rook', team = 2},
        },
        [2] = {
            [1] = {name = 'knight', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'knight', team = 2},
        },
        [3] = {
            [1] = {name = 'bishop', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'bishop', team = 2},
        },
        [4] = {
            [1] = {name = 'queen', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'queen', team = 2},
        
        },
        [5] = {
            [1] = {name = 'king', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'king', team = 2},
        },
        [6] = {
            [1] = {name = 'bishop', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'bishop', team = 2},
        },
        [7] = {
            [1] = {name = 'knight', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'knight', team = 2},
        },
        [8] = {
            [1] = {name = 'rook', team = 1},
            [2] = {name = 'pawn', team = 1},
            [7] = {name = 'pawn', team = 2},
            [8] = {name = 'rook', team = 2},
        },
    },
    
    -- other stuff (will be assigned below)
    drag = nil,
    hover = nil,
    hoverBox = nil,
}


local myTeam = 2
local stringformat = string.format

function resizeChess(size)
    size = size and pixels(size) or pixels(768)
    
    chess.x = (screenW / 2) - (size / 2)
    chess.y = (screenH / 2) - (size / 2)
    chess.size = size
end

function toggleChess(state)
    if state then
        addEventHandler('onClientRender', root, drawChess)
        addEventHandler('onClientClick', root, onClick)
    else
        removeEventHandler('onClientRender', root, drawChess)
        removeEventHandler('onClientClick', root, onClick)
    end
    chess.drawing = state
end

local letters = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'}

function drawChess()
    local boxSize = pixels(chess.size / 8)
    
    local lineWidth = boxSize / 10
    dxDrawLine(chess.x, chess.y - lineWidth / 2, chess.x + chess.size, chess.y - lineWidth / 2, chess.color.border, lineWidth)
    dxDrawLine(chess.x, chess.y + lineWidth / 2 + chess.size, chess.x + chess.size, chess.y + lineWidth / 2 + chess.size, chess.color.border, lineWidth)
    dxDrawLine(chess.x - lineWidth / 2, chess.y - lineWidth, chess.x - lineWidth / 2, chess.y + lineWidth + chess.size, chess.color.border, lineWidth)
    dxDrawLine(chess.x + lineWidth / 2 + chess.size, chess.y - lineWidth, chess.x + lineWidth / 2 + chess.size, chess.y + lineWidth + chess.size, chess.color.border, lineWidth)
    
    dxDrawRectangle(chess.x + chess.size + lineWidth * 1.5, (chess.y + chess.size / 2) - boxSize, boxSize * 4, boxSize * 2, tocolor(255, 255, 255, 255))
    
    local movingThisPiece = nil
    local thisID = 0
    local tempMatrix = {x = {}, y = {}}
    
    for yy = 1, 8 do
        for xx = 1, 8 do
            local padding = pixels(25)
            thisID = thisID + 1
            
            local x = chess.x + (xx - 1) * boxSize
            local y = chess.y + (yy - 1) * boxSize
            
            local color
            if xx % 2 == 1 then
                color = yy % 2 == 1 and chess.color.bg1 or chess.color.bg2
            else
                color = yy % 2 == 0 and chess.color.bg1 or chess.color.bg2
            end
            
            dxDrawRectangle(x, y, boxSize, boxSize, color)
            
            local reverseColor = color == chess.color.bg1 and chess.color.bg2 or chess.color.bg1
            
            local hover = isHoverBox(x, y, boxSize, boxSize)
            
            local pieceHere = chess.matrix[xx] and chess.matrix[xx][yy]
            
            if pieceHere then
                local pieceName = pieceHere.name
                local team = pieceHere.team
                
                local color = chess.color.team[team]
                
                if hover then
                    if myTeam == pieceHere.team then
                        chess.hover = {
                            pieceName = pieceName,
                            posID = thisID,
                            team = pieceHere.team,
                            matrix = {x = xx, y = yy},
                        }
                        padding = pixels(30)
                    end
                else
                    if chess.hover and (chess.hover.pieceName == pieceName) and (chess.hover.posID == thisID) then
                        chess.hover = nil
                    end
                end
                if chess.drag then
                    if (chess.drag.pieceName == pieceHere.name) and (chess.drag.matrix.x == xx and chess.drag.matrix.y == yy) then
                        color = tocolor(200, 200, 0, 200)
                    end
                end
                dxDrawImage(x + padding / 2, y + padding / 2, boxSize - padding, boxSize - padding, chess.pieces[pieceName].icon, 0, 0, 0, color)
                dxDrawText(pieceName, x, y, x + boxSize, y + boxSize, reverseColor, 1, 'default-bold', 'center', 'bottom')
            end
                        
            if hover then
                chess.hoverBox = {x = xx, y = yy}
            else
                if chess.hoverBox and chess.hoverBox == thisID then
                    chess.hoverBox = nil
                end
            end
            
            if chess.drag and chess.tips then
                if chess.tips[xx] and chess.tips[xx][yy] then
                    dxDrawCircle(x + boxSize / 2, y + boxSize / 2, boxSize / 4, 0, 360, tocolor(30, 30, 30, 100), tocolor(30, 30, 30, 100))
                end
            -- dxDrawText(inspect({hoverBox = chess.hoverBox, hover = chess.hover}), 1500, 200)
            end
                        
            if yy == 1 then
                dxDrawText(xx, x, y - boxSize * 2, x + boxSize, y + boxSize, color, 3, 'default-bold', 'center', 'center')
            end
            
            if xx == 1 then
                -- dxDrawText(yy, x - boxSize * 2, y, x + boxSize, y + boxSize, color, 3, 'default-bold', 'center', 'center')
                dxDrawText(letters[yy], x - boxSize * 2, y, x + boxSize, y + boxSize, color, 3, 'default-bold', 'center', 'center')
            end
            
            dxDrawText(letters[yy] .. xx, x, y, x + boxSize, y + boxSize, reverseColor, 1, 'default-bold', 'center', 'top')
        end
    end
    chess.matriced = tempMatrix
    
    local cx, cy = getCursorPosition(true)
    if chess.drag then
        local chessPiece = chess.drag.pieceName
        local dragTeam = chess.drag.team
        local color = chess.color[dragTeam]
        local boxSize = boxSize
        local padding = pixels(25)
        
        dxDrawImage((cx + padding / 2) - boxSize / 2, (cy + padding / 2) - boxSize / 2, boxSize - padding, boxSize - padding, chess.pieces[chessPiece].icon, 0, 0, 0, color)
    end
-- dxDrawText(inspect(chess.drag), cx + 25, cy, 0, 0, tocolor(255, 0, 0, 255), 1, 'default-bold')
end

function isPosWithinFriendly(xx, yy)
    -- do return false end
    if xx > 8 or xx <= 0 then return true end
    if yy > 8 or yy <= 0 then return true end
    local matrix = chess.matrix
    return matrix[xx][yy] and (matrix[xx][yy].team == myTeam)
end

function isPosWithinEnemy(xx, yy)
    -- do return false end
    if xx > 8 or xx <= 0 then return true end
    if yy > 8 or yy <= 0 then return true end
    local matrix = chess.matrix
    return matrix[xx][yy] and (matrix[xx][yy].team ~= myTeam)
end

function getPossibleMovements()
    local start = getTickCount()
    local drag = chess.drag
    if drag then
        local dragItem = drag.pieceName
        local dragX = drag.matrix.x
        local dragY = drag.matrix.y
        
        local tips = {}
        
        if dragItem == 'pawn' then
            
            for i = 1, 2 do
                if isPosWithinFriendly(dragX, dragY - i) then break end
                if isPosWithinEnemy(dragX, dragY - i + 1) then break end
                
                if not tips[dragX] then tips[dragX] = {} end
                tips[dragX][dragY - i] = true
            end
        
        elseif dragItem == 'rook' then
            
            for i = 1, dragY - 1 do
                if isPosWithinFriendly(dragX, dragY - i) then break end
                if isPosWithinEnemy(dragX, dragY - i + 1) then break end
                
                if not tips[dragX] then tips[dragX] = {} end
                tips[dragX][dragY - i] = true
            end
            for i = 1, 8 - dragY do
                if isPosWithinFriendly(dragX, dragY + i) then break end
                if isPosWithinEnemy(dragX, dragY + i - 1) then break end
                
                if not tips[dragX] then tips[dragX] = {} end
                tips[dragX][dragY + i] = true
            end
            for i = 1, 8 - dragX do
                if isPosWithinFriendly(dragX + i, dragY) then break end
                if isPosWithinEnemy(dragX + i - 1, dragY) then break end
                
                if not tips[dragX + i] then tips[dragX + i] = {} end
                tips[dragX + i][dragY] = true
            end
            for i = 1, dragX - 1 do
                if isPosWithinFriendly(dragX - i, dragY) then break end
                if isPosWithinEnemy(dragX - i, dragY) then break end
                
                if not tips[dragX - i] then tips[dragX - i] = {} end
                tips[dragX - i][dragY] = true
            end
        
        elseif dragItem == 'knight' then
            
            if not isPosWithinFriendly(dragX - 2, dragY + 1) then
                if not tips[dragX - 2] then tips[dragX - 2] = {} end
                tips[dragX - 2][dragY + 1] = true
            end
            if not isPosWithinFriendly(dragX - 2, dragY - 1) then
                if not tips[dragX - 2] then tips[dragX - 2] = {} end
                tips[dragX - 2][dragY - 1] = true
            end
            if not isPosWithinFriendly(dragX + 2, dragY - 1) then
                if not tips[dragX + 2] then tips[dragX + 2] = {} end
                tips[dragX + 2][dragY - 1] = true
            end
            if not isPosWithinFriendly(dragX + 2, dragY + 1) then
                if not tips[dragX + 2] then tips[dragX + 2] = {} end
                tips[dragX + 2][dragY + 1] = true
            end
            if not isPosWithinFriendly(dragX + 1, dragY + 2) then
                if not tips[dragX + 1] then tips[dragX + 1] = {} end
                tips[dragX + 1][dragY + 2] = true
            end
            if not isPosWithinFriendly(dragX + 1, dragY - 2) then
                if not tips[dragX + 1] then tips[dragX + 1] = {} end
                tips[dragX + 1][dragY - 2] = true
            end
            if not isPosWithinFriendly(dragX - 1, dragY - 2) then
                if not tips[dragX - 1] then tips[dragX - 1] = {} end
                tips[dragX - 1][dragY - 2] = true
            end
            if not isPosWithinFriendly(dragX - 1, dragY + 2) then
                if not tips[dragX - 1] then tips[dragX - 1] = {} end
                tips[dragX - 1][dragY + 2] = true
            end
        
        elseif dragItem == 'bishop' then
            
            for i = 1, 8 do
                if isPosWithinFriendly(dragX + i, dragY - i) then break end
                
                if not tips[dragX + i] then tips[dragX + i] = {} end
                tips[dragX + i][dragY - i] = true
                if isPosWithinEnemy(dragX + i, dragY - i) then break end
            end
            for i = 1, 8 do
                if isPosWithinFriendly(dragX + i, dragY + i) then break end
                
                if not tips[dragX + i] then tips[dragX + i] = {} end
                tips[dragX + i][dragY + i] = true
                if isPosWithinEnemy(dragX + i, dragY + i) then break end
            end
            for i = 1, 8 do
                if isPosWithinFriendly(dragX - i, dragY - i) then break end
                
                if not tips[dragX - i] then tips[dragX - i] = {} end
                tips[dragX - i][dragY - i] = true
                if isPosWithinEnemy(dragX - i, dragY - i) then break end
            end
            for i = 1, 8 do
                if isPosWithinFriendly(dragX - i, dragY + i) then break end
                if not tips[dragX - i] then tips[dragX - i] = {} end
                tips[dragX - i][dragY + i] = true
                if isPosWithinEnemy(dragX - i, dragY + i) then break end
            end
        
        elseif dragItem == 'king' then
            
            if not isPosWithinFriendly(dragX, dragY - 1) then
                if not tips[dragX] then tips[dragX] = {} end
                tips[dragX][dragY - 1] = true
            end
            if not isPosWithinFriendly(dragX + 1, dragY - 1) then
                if not tips[dragX + 1] then tips[dragX + 1] = {} end
                tips[dragX + 1][dragY - 1] = true
            end
            if not isPosWithinFriendly(dragX - 1, dragY - 1) then
                if not tips[dragX - 1] then tips[dragX - 1] = {} end
                tips[dragX - 1][dragY - 1] = true
            end
            if not isPosWithinFriendly(dragX + 1, dragY + 1) then
                if not tips[dragX + 1] then tips[dragX + 1] = {} end
                tips[dragX + 1][dragY + 1] = true
            end
            if not isPosWithinFriendly(dragX - 1, dragY + 1) then
                if not tips[dragX - 1] then tips[dragX - 1] = {} end
                tips[dragX - 1][dragY + 1] = true
            end
            if not isPosWithinFriendly(dragX, dragY + 1) then
                if not tips[dragX] then tips[dragX] = {} end
                tips[dragX][dragY + 1] = true
            end
            if not isPosWithinFriendly(dragX + 1, dragY) then
                if not tips[dragX + 1] then tips[dragX + 1] = {} end
                tips[dragX + 1][dragY] = true
            end
            if not isPosWithinFriendly(dragX - 1, dragY) then
                if not tips[dragX - 1] then tips[dragX - 1] = {} end
                tips[dragX - 1][dragY] = true
            end
        
        elseif dragItem == 'queen' then
            
            local exec = 0
            for i = 1, dragY - 1 do
                if isPosWithinFriendly(dragX, dragY - i) then break end
                if isPosWithinEnemy(dragX, dragY - i + 1) then break end
                
                if not tips[dragX] then tips[dragX] = {} end
                tips[dragX][dragY - i] = true
            end
            for i = 1, 8 - dragY do
                if isPosWithinFriendly(dragX, dragY + i) then break end
                if isPosWithinEnemy(dragX, dragY + i - 1) then break end
                
                if not tips[dragX] then tips[dragX] = {} end
                tips[dragX][dragY + i] = true
            end
            for i = 1, 8 - dragX do
                if isPosWithinFriendly(dragX + i, dragY) then break end
                if isPosWithinEnemy(dragX + i - 1, dragY) then break end
                
                if not tips[dragX + i] then tips[dragX + i] = {} end
                tips[dragX + i][dragY] = true
            end
            for i = 1, dragX - 1 do
                if isPosWithinFriendly(dragX - i, dragY) then break end
                if isPosWithinEnemy(dragX - i, dragY) then break end
                
                if not tips[dragX - i] then tips[dragX - i] = {} end
                tips[dragX - i][dragY] = true
            end
            for i = 1, 8 do
                if isPosWithinFriendly(dragX + i, dragY - i) then break end
                
                if not tips[dragX + i] then tips[dragX + i] = {} end
                tips[dragX + i][dragY - i] = true
                if isPosWithinEnemy(dragX + i, dragY - i) then break end
            end
            for i = 1, 8 do
                if isPosWithinFriendly(dragX + i, dragY + i) then break end
                
                if not tips[dragX + i] then tips[dragX + i] = {} end
                tips[dragX + i][dragY + i] = true
                if isPosWithinEnemy(dragX + i, dragY + i) then break end
            end
            for i = 1, 8 do
                if isPosWithinFriendly(dragX - i, dragY - i) then break end
                
                if not tips[dragX - i] then tips[dragX - i] = {} end
                tips[dragX - i][dragY - i] = true
                if isPosWithinEnemy(dragX - i, dragY - i) then break end
            end
            for i = 1, 8 do
                if isPosWithinFriendly(dragX - i, dragY + i) then break end
                if not tips[dragX - i] then tips[dragX - i] = {} end
                tips[dragX - i][dragY + i] = true
                if isPosWithinEnemy(dragX - i, dragY + i) then break end
            end
        end
        
        outputChatBox(inspect{'tick: ', getTickCount() - start})
        return tips
    end
    return false
end

function onClick(btn, state)
    local isLeft = btn == 'left'
    local pressed = state == 'down'
    
    if isLeft and pressed then
        
        local hover = chess.hover
        if hover then
            if hover.team == myTeam then
                
                chess.drag = {
                    pieceName = hover.pieceName,
                    team = hover.team,
                    matrix = hover.matrix
                }
                
                chess.tips = getPossibleMovements()-- update only once
            end
        end
    
    elseif isLeft and not pressed then
        local hoverBox = chess.hoverBox
        
        if hoverBox and chess.drag then
            if chess.tips and chess.tips[hoverBox.x] and chess.tips[hoverBox.x][hoverBox.y] then
                local newX = hoverBox.x
                local newY = hoverBox.y
                
                local oldX = chess.drag.matrix.x
                local oldY = chess.drag.matrix.y
                
                chess.matrix[newX][newY] = chess.matrix[oldX][oldY]
                chess.matrix[oldX][oldY] = nil
                
                outputChatBox(inspect({x = newX, y = newY}))
            
            end
        end
        chess.drag = nil
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    resizeChess(screenH * 0.8)
    toggleChess(not chess.drawing)
    fadeCamera(false)
    showCursor(true)
end)
