-- ========================
-- TEST JOURNALISER_ACTION
-- ========================

DECLARE
    v_count_before NUMBER;
    v_count_after  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_before FROM LOG_OPERATION;

    journaliser_action(
        p_table_concernee => 'TABLE_CONCERNEE',
        p_operation       => 'INSERT',
        p_utilisateur     => USER,
        p_description     => 'Test de journalisation'
    );

    SELECT COUNT(*) INTO v_count_after FROM LOG_OPERATION;

    IF v_count_after = v_count_before + 1 THEN
        DBMS_OUTPUT.PUT_LINE('TEST journaliser_action : OK');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST journaliser_action : ÉCHEC');
    END IF;

    DELETE FROM LOG_OPERATION
    WHERE description = 'Test de journalisation';

    COMMIT;
END;
/

-- ========================
-- TEST AJOUTER_PROJET
-- ========================

DECLARE
    v_id_chercheur NUMBER;
BEGIN
    INSERT INTO CHERCHEUR(nom, prenom, specialite, date_embauche)
    VALUES ('Test', 'Test', 'Test', SYSDATE - 1)
    RETURNING id_chercheur INTO v_id_chercheur;

    ajouter_projet(
        p_titre             => 'Test',
        p_domaine           => 'Test',
        p_budget            => 50000,
        p_date_debut        => SYSDATE,
        p_date_fin          => SYSDATE + 1,
        p_id_chercheur_resp => v_id_chercheur
    );

    DBMS_OUTPUT.PUT_LINE('TEST ajouter_projet : OK');

    DELETE FROM PROJET WHERE titre = 'Test';
    DELETE FROM CHERCHEUR WHERE id_chercheur = v_id_chercheur;

    COMMIT;
END;
/

-- ========================
-- TEST AFFECTER_EQUIPMENT
-- ========================

DECLARE
    v_id_projet     NUMBER;
    v_id_chercheur  NUMBER;
    v_id_equipement NUMBER;
BEGIN
    INSERT INTO CHERCHEUR(nom, prenom, specialite, date_embauche)
    VALUES ('Test', 'Test', 'Test', SYSDATE - 1)
    RETURNING id_chercheur INTO v_id_chercheur;

    INSERT INTO PROJET(titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES ('Test', 'Test', 10000, SYSDATE - 1, SYSDATE + 1, v_id_chercheur)
    RETURNING id_projet INTO v_id_projet;

    INSERT INTO EQUIPEMENT(nom, categorie, date_acquisition, etat)
    VALUES ('Test', 'Test', SYSDATE - 1, 'Disponible')
    RETURNING id_equipement INTO v_id_equipement;

    affecter_equipement(
        p_id_projet     => v_id_projet,
        p_id_equipement => v_id_equipement,
        p_date_affect   => SYSDATE,
        p_duree_jours   => 5
    );

    DBMS_OUTPUT.PUT_LINE('TEST affecter_equipement : OK');

    DELETE FROM AFFECTATION_EQUIP WHERE id_projet = v_id_projet;
    DELETE FROM EQUIPEMENT WHERE id_equipement = v_id_equipement;
    DELETE FROM PROJET WHERE id_projet = v_id_projet;
    DELETE FROM CHERCHEUR WHERE id_chercheur = v_id_chercheur;

    COMMIT;
END;
/