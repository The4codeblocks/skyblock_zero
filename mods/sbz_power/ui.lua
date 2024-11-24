local t = sbz_api.power_tick -- ticks/second
local tph = t * 60 * 60      -- ticks/hour

function sbz_power.round_power(n)
    return math.round(n * 100) / 100
end

--- Converts cj into cjh (kinda like kwh irl)
--- NOT PRECISE, you can make precise functions if you need them
---@param cj number
---@return number
function sbz_power.cj2cjh(cj)
    return sbz_power.round_power(cj / tph)
end

--- Converts cjh into cj (kinda like kwh irl)
--- NOT PRECISE, you can make precise functions if you need them
---@param cjh number
---@return number
function sbz_power.cjh2cj(cjh)
    return sbz_power.round_power(cjh * tph)
end

---@param consumed { n:number, text: string }
---@param max {n:number, text:string }
---@return string
local function bar(consumed, max, x, y, w, h, title, tooltip_text)
    local offx, offy = 0.5, 0.5
    local title_off, text_off = 0.5, 0.3

    h = h - offy

    local small_x,
    small_y,
    small_w,
    small_h = offx, title_off + offy, 1, h - offy * 2

    local offd = 0.2

    local full_height = (consumed.n / max.n) * small_h

    return ([[
    container[%s,%s]
    tooltip[0,0;%s,%s;%s]
    box[0,0;%s,%s;#001100]
    box[%s,%s;%s,%s;#00FF00FF]

    box[%s,%s;%s,%s;#001100]
    box[%s,%s;%s,%s;#00FF00]


    label[0.2,0.4;%s]
    label[%s,%s;%s]
    label[%s,%s;%s]

    container_end[]
    ]]):format(
        x, y,
        w, h + title_off, minetest.formspec_escape(tooltip_text),
        w, h + title_off,                                                       -- first box
        small_x - offd, small_y - offd, small_w + offd * 2, small_h + offd * 2, -- the deco to the second box
        small_x, small_y, small_w, small_h,                                     -- second box, it's the background box
        small_x, (small_y + small_h) - full_height, small_w, full_height + 0.1, -- the filled in box
        title,
        small_x + small_w + text_off, small_y, max.text,
        small_x + small_w + text_off,
        (small_y + small_h) - math.min(full_height, small_h - 0.5), consumed.text
    )
end



---@generic formspec: string
---@param consumed number
---@param max number
---@param x number
---@param y number
---@param postfix string
---@param title string
---@return formspec
function sbz_power.bar(consumed, max, x, y, postfix, title, tooltip_text)
    return bar({ n = consumed, text = consumed .. " " .. postfix }, { n = max, text = max .. " " .. postfix }, x, y, 5, 5,
        title, tooltip_text)
end

function sbz_power.battery_fs(consumed, max)
    return "formspec_version[7]size[5,5]" ..
        bar(
            { n = consumed, text = ("%s CjH (%s Cj)"):format(sbz_power.cj2cjh(consumed), consumed) },
            { n = max, text = ("%s CjH (%s Cj)"):format(sbz_power.cj2cjh(max), max) },
            0, 0, 5, 5, "Storage", "CjH = \"The amount of Cj that can be sustained for 1 hour.\""
        )
end

function sbz_power.liquid_storage_fs(has, max)
    return "formspec_version[7]size[5,5]" ..
        bar(
            { n = has, text = has .. " source blocks" },
            { n = max, text = max .. " source blocks" },
            0, 0, 5, 5, "Liquid Storage", ""
        )
end