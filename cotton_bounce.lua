--[[
    cotton_bounce.lua
    Author: Dane Rainbird (hello@danerainbird.me)
    Last Edited: 2024-04-01
    Purpose: An OBS Lua script that makes an image source bounce up and down. Originally intended for use specifically for Kimswoa, but can be used for any image source.
]]

obs = obslua

-- Global variables
source_name = ""
amplitude = 0
rotate_speed = 0
bounce_speed = 0
minY = 0
maxY = 0

-- Description displayed in the Scripts dialog window
function script_description()
    return [[Image Source Bounce!
             Makes an image source bounce up and down, and rotate slightly on it's axis!]]
end

-- Called every tick to update Cotton's position and rotation
function script_tick(seconds)
    -- Get the current scene
    local current_scene_as_source = obs.obs_frontend_get_current_scene()

    -- If the current scene is not nil
    if current_scene_as_source then
        -- Look for the source with the set value in the current scene
        local current_scene = obs.obs_scene_from_source(current_scene_as_source)
        local scene_item = obs.obs_scene_find_source_recursive(current_scene, source_name)

        -- If Cotton is found, update its position and rotation
        if scene_item then
            -- Get the position of Cotton
            local vec = obs.vec2()
            obs.obs_sceneitem_get_pos(scene_item, vec)

            -- Create a new position for Cotton
            local newVec = obs.vec2()

            -- Make Cotton bounce up and down
            local time = os.clock()

            newVec.x = vec.x
            newVec.y = vec.y + amplitude * math.sin(bounce_speed * time)

            -- Clamp the y-coordinate within a range to prevent Cotton from bouncing off the screen
            newVec.y = math.max(minY, math.min(maxY, newVec.y))

            -- Also make Cotton rotate left and right as it bounces
            local rotation = rotate_speed * math.sin(bounce_speed * time)
            obs.obs_sceneitem_set_rot(scene_item, rotation)

            -- Apply the new position and rotation to Cotton
            obs.obs_sceneitem_set_pos(scene_item, newVec)

        end
        obs.obs_source_release(current_scene_as_source)
    end
end

-- Called to set default values for settings
function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "source_name", "")
    obs.obs_data_set_default_int(settings, "amplitude", 1)
    obs.obs_data_set_default_double(settings, "bounce_speed", 5)
    obs.obs_data_set_default_double(settings, "rotate_speed", 1.5)
    obs.obs_data_set_default_int(settings, "minY", 0)
    obs.obs_data_set_default_int(settings, "maxY", 300)
end

-- Called to display properties in the OBS UI
function script_properties()
    props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Source name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int_slider(props, "amplitude", "Bounce amplitude", 0, 90, 1)
    obs.obs_properties_add_float_slider(props, "rotate_speed", "Rotate speed", 0, 10, 0.1)
    obs.obs_properties_add_float_slider(props, "bounce_speed", "Bounce speed", 0, 10, 0.1)
    obs.obs_properties_add_int(props, "minY", "Minimum y-coordinate", -100, 300, 1)
    obs.obs_properties_add_int(props, "maxY", "Maximum y-coordinate", 0, 300, 1)
    return props
end

-- Called after change of settings, or once on script load
function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    amplitude = obs.obs_data_get_int(settings, "amplitude")
    rotate_speed = obs.obs_data_get_double(settings, "rotate_speed")
    bounce_speed = obs.obs_data_get_double(settings, "bounce_speed")
    minY = obs.obs_data_get_int(settings, "minY")
    maxY = obs.obs_data_get_int(settings, "maxY")
end