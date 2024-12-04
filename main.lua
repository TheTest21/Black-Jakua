-- Black Jack bitches

function love.load()
    love.window.setTitle("Black Jack") -- Black Jack MF
    ico = love.image.newImageData("logo.png")
	love.window.setIcon(ico)
    love.graphics.setBackgroundColor(.125, .671, .282, 1)
    love.window.setMode(400, 350) -- Set window size
    love.audio.setVolume(0.2)

--  Fonts
    titleFont = love.graphics.newFont("Kenney Blocks.ttf", 50)
    mainFont = love.graphics.newFont("Kenney Pixel.ttf", 20)
    winFont = love.graphics.newFont("Kenney Pixel.ttf", 30)

--  Sounds
    clickSound = love.audio.newSource("other/click.ogg", "static")
    music = love.audio.newSource("other/blackjack.mp3", "stream")
    win = love.audio.newSource("other/win.mp3", "static")
    music:setLooping(true)
    love.audio.play(music)

    images = {} -- Table to store card images

    -- Load images for all cards (1 to 13 for each suit)
    for suitIndex, suit in ipairs({'clubs', 'diamonds', 'hearts', 'spades'}) do
        for rank = 1, 13 do
            local cardName = rank .. "_" .. suit
            images[cardName] = love.graphics.newImage('other/' .. cardName .. '.png')
        end
    end

    function TakeCard(hand) -- Function to draw a card
        table.insert(hand, table.remove(cards, love.math.random(#cards)))
    end
    function getTotal(hand)
        local total = 0
        local hasAce = false
    
        for cardIndex, card in ipairs(hand) do
            if card.rank > 10 then
                total = total + 10
            else
                total = total + card.rank
            end
            if card.rank == 1 then
                hasAce = true
            end
        end
    
        if hasAce and total <= 11 then
            total = total + 10
        end
    
        return total
    end
    
    local buttonY = 230
    local buttonHeight = 25
    local textOffsetY = 6
    
    buttonHit = {
        x = 10,
        y = buttonY,
        width = 53,
        height = buttonHeight,
        text = 'Hit!',
        textOffsetX = 16,
        textOffsetY = textOffsetY,
    }
    
    buttonStand = {
        x = 70,
        y = buttonY,
        width = 53,
        height = buttonHeight,
        text = 'Stand',
        textOffsetX = 8,
        textOffsetY = textOffsetY,
    }
    
    buttonPlayAgain = {
        x = 10,
        y = buttonY,
        width = 113,
        height = buttonHeight,
        text = 'Play again',
        textOffsetX = 24,
        textOffsetY = textOffsetY,
    }
    
    
    function isMouseInButton(button)
    
        return love.mouse.getX() >= button.x
        and love.mouse.getX() < button.x + button.width
        and love.mouse.getY() >= button.y
        and love.mouse.getY() < button.y + button.height
    end
    
    function reset()
        cards = {}
        for suitIndex, suit in ipairs({'clubs', 'diamonds', 'hearts', 'spades'}) do
            for rank = 1, 13 do
                table.insert(cards, {suit = suit, rank = rank})
            end
        end
    
        -- give the cards
        whatugot = {}
        TakeCard(whatugot)
        TakeCard(whatugot)
    
        whatbitchgot = {}
        TakeCard(whatbitchgot)
        TakeCard(whatbitchgot)
    
        roundOver = false -- is track over check
    end
    
    reset()
end
function love.mousereleased() -- click shit
    if not roundOver then
        if isMouseInButton(buttonHit) then
            TakeCard(whatugot)
            if getTotal(whatugot) >= 21 then
                roundOver = true
            end
            clickSound:play()
        elseif isMouseInButton(buttonStand) then
            clickSound:play()
            roundOver = true
        end

        if roundOver then
            while getTotal(whatbitchgot) < 17 do
                TakeCard(whatbitchgot)
            end
        end
    elseif isMouseInButton(buttonPlayAgain) then
        love.audio.stop(music) -- Stop the current music instance
        music:seek(0) -- Reset the music position to the beginning
        love.audio.play(music) -- Play the music again

        clickSound:play()
        reset()
    end
end



function love.draw() -- All the graphics here
    tittle = love.graphics.newImage('other/other.png')
    love.graphics.draw(tittle,120,45)
    love.graphics.setFont(mainFont)
    -- Draw each card in a hand
    local function drawCard(card, x, y)
        love.graphics.setColor(1, 1, 1)
        -- Get the image name (like '13_spades')
        local cardName = card.rank .. "_" .. card.suit
        -- Check if the image exists
        if images[cardName] then
            -- Draw the card image
            love.graphics.draw(images[cardName], x, y)
        end
    end
    
    local cardSpacing =60
    local marginX = 10

    -- Draw your hand
    for cardIndex, card in ipairs(whatugot) do
        drawCard(card, ((cardIndex - 1) * cardSpacing) + marginX, 140)
    end

    images['card_face_down'] = love.graphics.newImage('other/card_face_down.png')

    -- Draw the dealer's hand
    for cardIndex, card in ipairs(whatbitchgot) do
        if not roundOver and cardIndex == 1 then
            -- Hide the first card if the round isn't over
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(images['card_face_down'], ((cardIndex - 1) * cardSpacing) + marginX, 30)
        else
            drawCard(card, ((cardIndex - 1) * cardSpacing) + marginX, 30)
        end
    end

    
    local function drawWinner(message)
        love.graphics.setFont(winFont)
        love.graphics.print(message, 10, 268)
        love.graphics.setFonta(mainFont)
    end

    if roundOver then
        function hasHandWon(thisHand, otherHand)
            return getTotal(thisHand) <= 21
            and (
                getTotal(otherHand) > 21
                or getTotal(thisHand) > getTotal(otherHand)
            )
        end
    if hasHandWon(whatugot, whatbitchgot) then
        win:play()
        win:stop()
        drawWinner("You win!!")
    elseif hasHandWon(whatbitchgot, whatugot) then
        drawWinner('Dealer wins')
    else
        drawWinner('Draw')
    end
end

love.graphics.setColor(0, 0, 0)

if roundOver then
    love.graphics.print('Total: '..getTotal(whatbitchgot), marginX, 10)
else
    love.graphics.print('Total: ?', marginX, 10)
end

love.graphics.print('Total: '..getTotal(whatugot), marginX, 120)

local function drawButton(button)
    -- Removed: local buttonY = 230
    -- Removed: local buttonHeight = 25

    if isMouseInButton(button) then
        love.graphics.setColor(1, .8, .3)
    else
        love.graphics.setColor(1, .5, .2)
    end

    love.graphics.rectangle('fill', button.x, button.y, button.width, button.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(button.text, button.x + button.textOffsetX, button.y + button.textOffsetY)
end

if not roundOver then
    drawButton(buttonHit)
    drawButton(buttonStand)
else
    drawButton(buttonPlayAgain)
end
end