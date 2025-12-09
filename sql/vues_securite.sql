-- ========================
-- V_PROJETS_PUBLICS
-- ========================

CREATE OR REPLACE VIEW v_projet_publics AS
SELECT 
    id_projet,
    titre,
    domaine,
    budget,
    date_debut,
    date_fin,
    id_chercheur_resp
FROM PROJET
WHERE date_fin < SYSDATE;
/

CREATE OR REPLACE VIEW v_resultats_experience AS
SELECT 
    e.id_exp,
    e.titre_exp,
    e.date_realisation,
    e.statut,
    p.titre AS titre_projet,
    p.domaine AS domaine_projet,
    c.nom AS nom_chercheur,
    c.prenom AS prenom_chercheur,
    COUNT(ec.id_echantillon) AS nb_echantillons,
    AVG(ec.mesure) AS moyenne_mesure,
    e.resultat AS resultat_exp,
    (p.date_fin - p.date_debut) AS duree_projet
FROM EXPERIENCE e
JOIN PROJET p
      ON e.id_projet = p.id_projet
JOIN CHERCHEUR c
      ON p.id_chercheur_resp = c.id_chercheur
LEFT JOIN ECHANTILLON ec
      ON ec.id_exp = e.id_exp
GROUP BY 
    e.id_exp, e.titre_exp, e.date_realisation, e.statut,
    p.titre, p.domaine, c.nom, c.prenom,
    e.resultat, p.date_fin, p.date_debut;
/

GRANT SELECT ON v_projet_publics TO LECT_LAB;
GRANT SELECT ON v_resultats_experience TO LECT_LAB;


GRANT EXECUTE ON budget_moyen_par_domaine TO LECT_LAB;
GRANT EXECUTE ON statistiques_equipements TO LECT_LAB;

GRANT EXECUTE ON ajouter_projet TO GEST_LAB;
GRANT EXECUTE ON affecter_equipement TO GEST_LAB;
GRANT EXECUTE ON planifier_experience TO GEST_LAB;
GRANT EXECUTE ON journaliser_action TO GEST_LAB;
/
