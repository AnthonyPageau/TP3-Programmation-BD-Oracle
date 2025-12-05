--JOURNALISER_ACTION

CREATE OR REPLACE PROCEDURE journaliser_action(
    p_table_concernee IN VARCHAR2,
    p_operation      IN VARCHAR2,
    p_utilisateur    IN VARCHAR2,
    p_description    IN VARCHAR2
) AS
BEGIN
    INSERT INTO LOG_OPERATION(table_concernee, operation, utilisateur, description)
    VALUES (p_table_concernee, UPPER(p_operation), p_utilisateur, p_description);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur journalisation : ' || SQLERRM);
        ROLLBACK;
END;

--AJOUTER_PROJET

CREATE OR REPLACE PROCEDURE ajouter_projet(
    p_titre            IN VARCHAR2,
    p_domaine          IN VARCHAR2,
    p_budget           IN NUMBER,
    p_date_debut       IN DATE,
    p_date_fin         IN DATE,
    p_id_chercheur_resp IN NUMBER
) AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM CHERCHEUR
    WHERE id_chercheur = p_id_chercheur_resp;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Chercheur responsable inexistant');
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM PROJET
    WHERE id_chercheur_resp = p_id_chercheur_resp
      AND (p_date_debut BETWEEN date_debut AND date_fin
           OR p_date_fin BETWEEN date_debut AND date_fin);

    IF v_count >= 3 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Le chercheur dirige déjà 3 projets simultanément');
    END IF;

    INSERT INTO PROJET(titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (p_titre, p_domaine, p_budget, p_date_debut, p_date_fin, p_id_chercheur_resp);

    COMMIT;

    journaliser_action('PROJET', 'INSERT', USER, 'Ajout du projet : ' || p_titre);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur ajouter_projet : ' || SQLERRM);
        ROLLBACK;
END;

-- AFFECTER_EQUIPEMENT

CREATE OR REPLACE PROCEDURE affecter_equipement(
    p_id_projet     IN NUMBER,
    p_id_equipement IN NUMBER,
    p_date_affect   IN DATE,
    p_duree_jours   IN NUMBER
) AS
    v_disponible NUMBER;
BEGIN
    v_disponible := verifier_disponibilite_equipement(p_id_equipement);

    IF v_disponible = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Equipement non disponible');
    END IF;

    INSERT INTO AFFECTATION_EQUIP(id_projet, id_equipement, date_affectation, duree_jours)
    VALUES (p_id_projet, p_id_equipement, p_date_affect, p_duree_jours);

    COMMIT;

    journaliser_action('AFFECTATION_EQUIP', 'INSERT', USER,
        'Affectation equipement ' || p_id_equipement || ' au projet ' || p_id_projet);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur affecter_equipement : ' || SQLERRM);
        ROLLBACK;
END;