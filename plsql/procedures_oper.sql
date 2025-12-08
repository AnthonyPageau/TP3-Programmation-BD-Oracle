-- ========================
--JOURNALISER_ACTION
-- ========================

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

-- BLOC DE TEST

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
--AJOUTER_PROJET
-- ========================

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
        RAISE_APPLICATION_ERROR(-20002, 'Le chercheur a déjà 3 projets');
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

-- BLOC DE TEST

DECLARE
    v_id_chercheur NUMBER;
BEGIN
    INSERT INTO CHERCHEUR(nom, prenom, specialite, date_embauche)
    VALUES ('Test', 'Test', 'Test', SYSDATE - 30)
    RETURNING id_chercheur INTO v_id_chercheur;

    ajouter_projet(
        p_titre             => 'Test',
        p_domaine           => 'Test',
        p_budget            => 50000,
        p_date_debut        => SYSDATE,
        p_date_fin          => SYSDATE + 20,
        p_id_chercheur_resp => v_id_chercheur
    );

    DBMS_OUTPUT.PUT_LINE('TEST ajouter_projet : OK');

    DELETE FROM PROJET WHERE titre = 'Test';
    DELETE FROM CHERCHEUR WHERE id_chercheur = v_id_chercheur;

    COMMIT;
END;
/

-- ========================
-- AFFECTER_EQUIPEMENT
-- ========================

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
        RAISE_APPLICATION_ERROR(-20003, 'Equipement indisponible');
    END IF;

    INSERT INTO AFFECTATION_EQUIP(id_projet, id_equipement, date_affectation, duree_jours)
    VALUES (p_id_projet, p_id_equipement, p_date_affect, p_duree_jours);

    COMMIT;

    journaliser_action('AFFECTATION_EQUIPEMENT', 'INSERT', USER,
        'Affectation equipement ' || p_id_equipement || ' au projet ' || p_id_projet);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur affecter_equipement : ' || SQLERRM);
        ROLLBACK;
END;

-- BLOC DE TEST

DECLARE
    v_id_projet     NUMBER;
    v_id_chercheur  NUMBER;
    v_id_equipement NUMBER;
BEGIN
    INSERT INTO CHERCHEUR(nom, prenom, specialite, date_embauche)
    VALUES ('Test', 'Test', 'Test', SYSDATE - 50)
    RETURNING id_chercheur INTO v_id_chercheur;

    INSERT INTO PROJET(titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES ('Test', 'Test', 20000, SYSDATE - 1, SYSDATE + 1, v_id_chercheur)
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