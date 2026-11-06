-- Reference implementation: Ru <-> world conversion.

local function ToWorld(
    Ru: { X: number, Y: number }?, y: number?, m: string?
): (CFrame | Vector3)
    local r = Ru or { X = 0, Y = 0 }
    local c = { X = r.X, Y = r.Y }
    y = y or 0
    m = m or "Vector3"

    if c.X ~= c.X or math.abs(c.X) == math.huge then
        warn("Ru.X is not a finite number")
        c.X = 0
    end
    if c.Y ~= c.Y or math.abs(c.Y) == math.huge then
        warn("Ru.Y is not a finite number")
        c.Y = 0
    end

    -- "+ 0" normalizes -0 to 0.
    c.X = math.round(c.X) + 0
    c.Y = math.round(c.Y) + 0

    c.X *= 72
    c.Y *= 72

    return m == "Vector3" and Vector3.new(c.X, y, c.Y)
        or CFrame.new(c.X, y, c.Y)
end

local function ToRoom(World: CFrame | Vector3): ({ X: number, Y: number }, number)
    if typeof(World) ~= "Vector3" and typeof(World) ~= "CFrame" then
        warn("invalid data type", typeof(World))
        return { X = 0, Y = 0 }, 0
    end

    local x, y = World.X / 72, World.Z / 72
    local yWorld = World.Y

    x = math.round(x) + 0
    y = math.round(y) + 0

    return { X = x, Y = y }, yWorld
end