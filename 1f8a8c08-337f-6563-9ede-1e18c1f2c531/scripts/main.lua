UEVR_UObjectHook.activate()

local api = uevr.api;
local params = uevr.params
local callbacks = params.sdk.callbacks
Preonce = false
Postonce = false

function Fix()
    uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
        local pawn = uevr.api:get_local_pawn()
        local player = pawn:get_full_name() .. ".FPVMesh"
        local fpmesh = string.gsub(player, "IndianaPlayerCharacter_BP_C ", "SkeletalMeshComponent ")
        local fpvmesh = api:find_uobject(fpmesh)
        fpvset = (fpvmesh.bRenderInMainPass)
        if fpvset == false then
            --print("Mod Applied")
        else
            local playerpos = pawn:get_full_name() .. ".GroundOffset"
            if string.find(player, "Default") then
                --print("Not Ready")
                Preonce = false
            else
                if Preonce == false then
                    local HeadClass = api:find_uobject("Class /Script/Engine.SkeletalMeshComponent")
                    local HeadInstances = UEVR_UObjectHook.get_objects_by_class(HeadClass)
                    for Index, HeadInstances in pairs(HeadInstances) do
                        for matchedText in string.gmatch(HeadInstances:get_full_name(), "IndianaPlayerCharacter_BP_C") do
                            GetHead = (HeadInstances:get_full_name())
                            if string.find(GetHead, ".Inventory.SkeletalMeshComponent_") then
                                --print(GetHead)
                                Fpweap = GetHead
                            end
                        end
                    end
                    local fppos = string.gsub(playerpos, "IndianaPlayerCharacter_BP_C ", "SceneComponent ")
                    --print(fpmesh)
                    --print(fppos)
                    local fpvpos = api:find_uobject(fppos)
                    local fpvweap = api:find_uobject(Fpweap)
                    fpvmesh:call("SetRenderInMainPass", false)
                    fpvweap.RelativeLocation.Z = -15.00
                    fpvweap.RelativeLocation.X = 15.00
                    fpvpos.RelativeLocation.Z = -25.0
                    fpvmesh.RelativeScale3D.X = 0.76
                    fpvmesh.RelativeScale3D.Y = 0.74
                    fpvmesh.RelativeScale3D.Z = 0.71
                    Preonce = false
                end
            end
        end
    end)
end

uevr.sdk.callbacks.on_script_reset(function()
    Preonce = false
    Postonce = false
end)

Fix()