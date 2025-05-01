Config = {}

-- Zone de craft des pièces
Config.CraftZone = {
    x = 596.44,
    y = -426.33,
    z = 17.62,
    radius = 1.5
}

-- Zone de craft finale
Config.CraftZone2 = {
    x = 596.55,
    y = -428.75,
    z = 17.62,
    radius = 1.5
}

Config.Blip = {
    Sprite = 140,
    Scale = 0.6, 
    Colour = 1, 
    Name = "Zone de fabrication étrange",
}

-- Définition des paliers et des exigences de progression
Config.CraftingTiers = {
    [1] = 10, -- +10
    [2] = 30, -- +20
    [3] = 60, -- +30
    [4] = 100, -- +40
    [5] = 150, -- +50
    [6] = 210 -- +60
}

-- Accède aux recettes des crafts
Config.CraftingRecipes = {
    -- Crafts des pièces d'armes - Palier 0
    ["barrel_handgun"] = {
        itemName = "barrel_handgun",
        label = "Canon pistolet",
        quantity = 1,
        requiredTier = 0,
        materials = {
            {name = "steel", label = "Acier", quantity = 2},
            {name = "titanium", label = "Titane", quantity = 1}
        }
    },
    ["slide_handgun"] = {
        itemName = "slide_handgun",
        label = "Culasse pistolet",
        quantity = 1,
        requiredTier = 0,
        materials = {
            {name = "steel", label = "Acier", quantity = 2},
            {name = "titanium", label = "Titane", quantity = 1}
        }
    },
    ["hammer_handgun"] = {
        itemName = "hammer_handgun",
        label = "Percuteur pistolet",
        quantity = 1,
        requiredTier = 0,
        materials = {
            {name = "iron", label = "Fer", quantity = 2},
            {name = "titanium", label = "Titane", quantity = 1}
        }
    },
    ["trigger_handgun"] = {
        itemName = "trigger_handgun",
        label = "Gâchette pistolet",
        quantity = 1,
        requiredTier = 0,
        materials = {
            {name = "iron", label = "Fer", quantity = 2},
            {name = "titanium", label = "Titane", quantity = 1}
        }
    },
    ["grip_handgun"] = {
        itemName = "grip_handgun",
        label = "Crosse pistolet",
        quantity = 1,
        requiredTier = 0,
        materials = {
            {name = "copper", label = "Cuivre", quantity = 2},
            {name = "titanium", label = "Titane", quantity = 1}
        }
    },
    -- Palier 4
    ["barrel_autogun"] = {
        itemName = "barrel_autogun",
        label = "Canon arme auto",
        quantity = 1,
        requiredTier = 4,
        materials = {
            {name = "steel", label = "Acier", quantity = 4},
            {name = "titanium", label = "Titane", quantity = 2}
        }
    },
    ["slide_autogun"] = {
        itemName = "slide_autogun",
        label = "Culasse arme auto",
        quantity = 1,
        requiredTier = 4,
        materials = {
            {name = "steel", label = "Acier", quantity = 4},
            {name = "titanium", label = "Titane", quantity = 2}
        }
    },
    ["hammer_autogun"] = {
        itemName = "hammer_autogun",
        label = "Percuteur arme auto",
        quantity = 1,
        requiredTier = 4,
        materials = {
            {name = "iron", label = "Fer", quantity = 4},
            {name = "titanium", label = "Titane", quantity = 2}
        }
    },
    ["trigger_autogun"] = {
        itemName = "trigger_autogun",
        label = "Gâchette arme auto",
        quantity = 1,
        requiredTier = 4,
        materials = {
            {name = "iron", label = "Fer", quantity = 4},
            {name = "titanium", label = "Titane", quantity = 2}
        }
    }, 
    ["grip_autogun"] = {
        itemName = "grip_autogun",
        label = "Crosse arme auto",
        quantity = 1,
        requiredTier = 4,
        materials = {
            {name = "copper", label = "Cuivre", quantity = 4},
            {name = "titanium", label = "Titane", quantity = 2}
        }
    },
    -- Palier 5
    ["barrel_shotgun"] = {
        itemName = "barrel_shotgun",
        label = "Canon fusil à pompe",
        quantity = 1,
        requiredTier = 5,
        materials = {
            {name = "steel", label = "Acier", quantity = 6},
            {name = "titanium", label = "Titane", quantity = 3}
        }
    },
    ["slide_shotgun"] = {
        itemName = "slide_shotgun",
        label = "Culasse fusil à pompe",
        quantity = 1,
        requiredTier = 5,
        materials = {
            {name = "steel", label = "Acier", quantity = 6},
            {name = "titanium", label = "Titane", quantity = 3}
        }
    },
    ["hammer_shotgun"] = {
        itemName = "hammer_shotgun",
        label = "Percuteur fusil à pompe",
        quantity = 1,
        requiredTier = 5,
        materials = {
            {name = "iron", label = "Fer", quantity = 6},
            {name = "titanium", label = "Titane", quantity = 3}
        }
    },
    ["trigger_shotgun"] = {
        itemName = "trigger_shotgun",
        label = "Gâchette fusil à pompe",
        quantity = 1,
        requiredTier = 5,
        materials = {
            {name = "iron", label = "Fer", quantity = 6},
            {name = "titanium", label = "Titane", quantity = 3}
        }
    },
    ["grip_shotgun"] = {
        itemName = "grip_shotgun",
        label = "Crosse fusil à pompe",
        quantity = 1,
        requiredTier = 5,
        materials = {
            {name = "copper", label = "Cuivre", quantity = 6},
            {name = "titanium", label = "Titane", quantity = 3}
        }
    },
    -- Palier 0
    ["ammo_pistol"] = {
        itemName = "ammo_pistol",
        label = "Munitions Pistolet",
        quantity = 1,
        requiredTier = 0,
        materials = {
            {name = "copper", label = "Cuivre", quantity = 1},
            {name = "steel", label = "Acier", quantity = 1}
        }
    },
    -- Palier 6
    ["ammo_shotgun"] = {
        itemName = "ammo_shotgun",
        label = "Munitions Pompe",
        quantity = 1,
        requiredTier = 6,
        materials = {
            {name = "iron", label = "Fer", quantity = 2},
            {name = "steel", label = "Acier", quantity = 2}
        }
    },

    -- Crafts d'armes avec les pièces - Palier 0
    ["WEAPON_SNSPISTOL"] = {
        itemName = "WEAPON_SNSPISTOL",
        label = "Pistolet SNS",
        quantity = 1,
        requiredTier = 0,
        materials = {
            {name = "barrel_handgun", quantity = 1},
            {name = "slide_handgun", quantity = 1},
            {name = "hammer_handgun", quantity = 1},
            {name = "trigger_handgun", quantity = 1},
            {name = "grip_handgun", quantity = 1}
        }
    },
        -- Palier 1
    ["WEAPON_PISTOL"] = {
        itemName = "WEAPON_PISTOL",
        label = "Pistolet",
        quantity = 1,
        requiredTier = 1,
        materials = {
            {name = "barrel_handgun", quantity = 1},
            {name = "slide_handgun", quantity = 1},
            {name = "hammer_handgun", quantity = 1},
            {name = "trigger_handgun", quantity = 1},
            {name = "grip_handgun", quantity = 1}
        }
    },
        -- Palier 2
    ["WEAPON_VINTAGEPISTOL"] = {
        itemName = "WEAPON_VINTAGEPISTOL",
        label = "Pistolet vintage",
        quantity = 1,
        requiredTier = 2,
        materials = {
            {name = "barrel_handgun", quantity = 1},
            {name = "slide_handgun", quantity = 1},
            {name = "hammer_handgun", quantity = 1},
            {name = "trigger_handgun", quantity = 1},
            {name = "grip_handgun", quantity = 1}
        }
    },
        -- Palier 3
    ["WEAPON_PISTOL50"] = {
        itemName = "WEAPON_PISTOL50",
        label = "Pistolet Cal.50 ",
        quantity = 1,
        requiredTier = 3,
        materials = {
            {name = "barrel_handgun", quantity = 1},
            {name = "slide_handgun", quantity = 1},
            {name = "hammer_handgun", quantity = 1},
            {name = "trigger_handgun", quantity = 1},
            {name = "grip_handgun", quantity = 1}
        }
    },
        -- Palier 4
    ["WEAPON_MACHINEPISTOL"] = {
        itemName = "WEAPON_MACHINEPISTOL",
        label = "Pistolet mitrailleur",
        quantity = 1,
        requiredTier = 4,
        materials = {
            {name = "barrel_autogun", quantity = 1},
            {name = "slide_autogun", quantity = 1},
            {name = "hammer_autogun", quantity = 1},
            {name = "trigger_autogun", quantity = 1},
            {name = "grip_autogun", quantity = 1}
        }
    },
        -- Palier 5
    ["WEAPON_DBSHOTGUN"] = {
        itemName = "WEAPON_DBSHOTGUN",
        label = "Fusil à pompe double canon",
        quantity = 1,
        requiredTier = 5,
        materials = {
            {name = "barrel_shotgun", quantity = 1},
            {name = "slide_shotgun", quantity = 1},
            {name = "hammer_shotgun", quantity = 1},
            {name = "trigger_shotgun", quantity = 1},
            {name = "grip_shotgun", quantity = 1}
        }
    },
    -- Palier 6
    ["WEAPON_MOLOTOV"] = {
        itemName = "WEAPON_MOLOTOV",
        label = "Cocktail molotov",
        quantity = 1,
        requiredTier = 6,
        materials = {
            {name = "caisse_tequila", label = "Caisse de tequila", quantity = 1},
            {name = "spray_remover", label = "Lingette nettoyante", quantity = 25},
            {name = "titanium", label = "Titane", quantity = 5}
        }
    }
}