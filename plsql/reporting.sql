-- ========================
-- PROCÉDURE
-- ========================

-- RAPPORT_PROJETS_PAR_CHERCHEUR

CREATE OR REPLACE PROCEDURE rapport_projets_par_chercheur(p_id_chercheur NUMBER)
IS
    v_budget_total NUMBER := 0;
BEGIN
    FOR projet_rec IN (SELECT id_projet, titre, domaine, budget
        FROM PROJET
        WHERE id_chercheur_resp = p_id_chercheur)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Projet : ' || projet_rec.titre || 
            ' | Domaine : ' || projet_rec.domaine || 
            ' | Budget : ' || projet_rec.budget);
        v_budget_total := v_budget_total + projet_rec.budget;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Budget total des projets : ' || v_budget_total);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur rapport_projets_par_chercheur : ' || SQLERRM);
END rapport_projets_par_chercheur;

-- ========================
-- FONCTION
-- ========================

-- BUDGET_MOYEN_PAR_DOMAINE

CREATE OR REPLACE TYPE t_budget_domaine AS OBJECT (
    domaine VARCHAR2(50),
    budget_moyen NUMBER
);

CREATE OR REPLACE TYPE t_budget_domaine_table AS TABLE OF t_budget_domaine;

CREATE OR REPLACE FUNCTION budget_moyen_par_domaine
RETURN t_budget_domaine_table
IS
    v_result t_budget_domaine_table := t_budget_domaine_table();
BEGIN
    FOR r IN (SELECT domaine, AVG(budget) AS budget_moyen
        FROM PROJET
        GROUP BY domaine)
    LOOP
        v_result.EXTEND;
        v_result(v_result.COUNT) := t_budget_domaine(r.domaine, r.budget_moyen);
    END LOOP;

    RETURN v_result;
END budget_moyen_par_domaine;