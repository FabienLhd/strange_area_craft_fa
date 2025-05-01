INSERT INTO items (name, label, weight, rare, can_remove) VALUES
-- Plans
('plan_handgun', 'Plan Arme de Poing', 0.25, 0, 1), -- voir pour drop dans supérette faible pourcentage
('plan_shotgun', 'Plan Fusil à Pompe', 0.25, 0, 1), -- voir pour drop dans fleeca faible pourcentage
('plan_autogun', 'Plan Arme Automatique', 0.25, 0, 1), -- voir pour drop dans bijouterie faible pourcentage
 
-- Pièces pour armes de poing
('barrel_handgun', 'Canon Pistolet', 1.0, 0, 1),
('slide_handgun', 'Culasse Pistolet', 1.0, 0, 1),
('hammer_handgun', 'Percuteur Pistolet', 0.5, 0, 1),
('trigger_handgun', 'Gâchette Pistolet', 0.5, 0, 1),
('grip_handgun', 'Crosse Pistolet', 1.0, 0, 1),

-- Pièces pour fusils à pompe
('barrel_shotgun', 'Canon Fusil à Pompe', 1.0, 0, 1),
('slide_shotgun', 'Culasse Fusil à Pompe', 1.0, 0, 1),
('hammer_shotgun', 'Percuteur Fusil à Pompe', 0.5, 0, 1),
('trigger_shotgun', 'Gâchette Fusil à Pompe', 0.5, 0, 1),
('grip_shotgun', 'Crosse Fusil à Pompe', 1.5, 0, 1),

-- Pièces pour armes automatiques
('barrel_autogun', 'Canon Arme Automatique', 1.0, 0, 1),
('slide_autogun', 'Culasse Arme Automatique', 1.0, 0, 1),
('hammer_autogun', 'Percuteur Arme Automatique', 0.5, 0, 1),
('trigger_autogun', 'Gâchette Arme Automatique', 0.5, 0, 1),
('grip_autogun', 'Crosse Arme Automatique', 1.5, 0, 1),

-- Métaux de craft 
('titanium', 'Titane', 1, 0, 1); -- voir pour drop dans supérette
('steel', 'Acier', 1, 0, 1); -- voir pour drop dans supérette


-- Création des colonnes pour gérer la progression de l'user
ALTER TABLE users
ADD COLUMN total_craft_fa INT(11) DEFAULT 0,
ADD COLUMN palier_craft_fa INT(11) DEFAULT 0;