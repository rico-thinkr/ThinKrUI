local mediaPath="Interface\\AddOns\\ThinKrUI\\media\\"
-- 设置字体，材质 文件路径
local media = {
  ["font"]=mediaPath.."font.ttf", --字体
  ["font2"]=mediaPath.."font.ttf", --备用字体（这才是主字体)
  ["backdrop"]=mediaPath.."ChatFrameBackground", --默认背景
  ["glow"] = mediaPath.."glowTex", --发光/阴影材质
  ["gradient"] = mediaPath.."gradient",--梯度材质
  ["roleIcons"] =mediaPath.. "UI-LFG-ICON-ROLES", --角色图标
  ["texture"] = mediaPath.."statusbar", -- 状态条材质
  ["slider"]=mediaPath.."UI-CastingBar-Spark"
}

print (media.font)
