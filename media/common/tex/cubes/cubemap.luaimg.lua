
local function make_cubemap_from_function(name, sz, func)
    function gen_mipmaps(img)
        local tab = {}
        local counter = 1
        local w = img.width
        local h = img.height
        while w>1 or h>1 do
            tab[counter] = img:scale(vec(w, h), "BOX")
            w = w == 1 and 1 or ceil(w/2)
            h = h == 1 and 1 or ceil(h/2)
            counter = counter + 1
        end
        return tab
    end
    pos_x = gen_mipmaps(make(vec(sz, sz), 3, function(p_) local p = p_/(sz - 1) * 2 - 1; return func(vec3( 1, p.y, -p.x)) end))
    neg_x = gen_mipmaps(make(vec(sz, sz), 3, function(p_) local p = p_/(sz - 1) * 2 - 1; return func(vec3(-1, p.y, p.x)) end))
    pos_y = gen_mipmaps(make(vec(sz, sz), 3, function(p_) local p = p_/(sz - 1) * 2 - 1; return func(vec3(p.x,  1, -p.y)) end))
    neg_y = gen_mipmaps(make(vec(sz, sz), 3, function(p_) local p = p_/(sz - 1) * 2 - 1; return func(vec3(p.x, -1, p.y)) end))
    pos_z = gen_mipmaps(make(vec(sz, sz), 3, function(p_) local p = p_/(sz - 1) * 2 - 1; return func(vec3(p.x, p.y,  1)) end))
    neg_z = gen_mipmaps(make(vec(sz, sz), 3, function(p_) local p = p_/(sz - 1) * 2 - 1; return func(vec3(-p.x, p.y, -1)) end))
    dds_save_cube(name, "R8G8B8", pos_x, neg_x, pos_y, neg_y, pos_z, neg_z)
end

-- http://www.hoist-point.com/soccerball.htm
local beta = deg(acos(1 / math.sqrt(5)))
black_planes = {
    vec(0, 0, 1),
    quat(0 * 72, vec(0, 0, 1)) * quat(beta, vec(1, 0, 0)) * vec(0, 0, 1),
    quat(1 * 72, vec(0, 0, 1)) * quat(beta, vec(1, 0, 0)) * vec(0, 0, 1),
    quat(2 * 72, vec(0, 0, 1)) * quat(beta, vec(1, 0, 0)) * vec(0, 0, 1),
    quat(3 * 72, vec(0, 0, 1)) * quat(beta, vec(1, 0, 0)) * vec(0, 0, 1),
    quat(4 * 72, vec(0, 0, 1)) * quat(beta, vec(1, 0, 0)) * vec(0, 0, 1),
}
local tab = {}
local black = vec(0.01, 0.01, 0.01)
local white = vec(.8, .8, .8)

make_cubemap_from_function("soccer_ball.dds", 1024, function (pos)
    pos = norm(pos)
    for i = 1, 6 do
        tab[i] = deg(acos(dot(black_planes[i], pos)))
        tab[i + 6] = deg(acos(dot(-black_planes[i], pos)))
    end
    local outside = false
    for i = 1, 6 do
        if abs(dot(black_planes[i], pos)) < .189 then
            outside = true
        end
    end
    if not outside then return black end
    table.sort(tab)

    if abs(tab[3] - tab[4]) <= 1 then
        return black
    end
    return white
end)

make_cubemap_from_function("spots.dds", 1024, function (pos)
    pos = norm(pos)
    for i = 1, 6 do
        if abs(dot(black_planes[i], pos)) > 0.93 then
            return white
        end
    end
    return black
end)
