function onSongStart()
    setProperty('camZooming', true)
end

function onBeatHit()
    if curBeat == 24 or curBeat == 51 or curBeat == 40 or curBeat == 147 or curBeat == 252 or curBeat == 276 or curBeat == 300 then
        setProperty('camZoomingMult', false)
    elseif curBeat == 27 or curBeat == 93 or curBeat == 123 or curBeat == 204 or curBeat == 255 or curBeat == 279 then
        setProperty('camZoomingMult', true)
    end
end