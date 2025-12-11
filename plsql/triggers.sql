-- ========================
-- TRG_PROJET_BEFORE_INSERT
-- ========================

CREATE OR REPLACE TRIGGER trg_projet_before_insert
BEFORE INSERT ON PROJET
FOR EACH ROW
BEGIN
    IF :NEW.budget <= 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Budget doit être supérieur à 0');
    END IF;

    IF :NEW.date_fin < :NEW.date_debut THEN
        RAISE_APPLICATION_ERROR(-20008, 'date_fin doit être >= date_debut');
    END IF;
END;
/

-- ========================
-- TRG_AFFECTATION_BEFORE_INSERT
-- ========================

CREATE OR REPLACE TRIGGER trg_affectation_before_insert
BEFORE INSERT ON AFFECTATION_EQUIP
FOR EACH ROW
DECLARE
    v_etat VARCHAR2(20);
BEGIN
    SELECT etat INTO v_etat
    FROM EQUIPEMENT
    WHERE id_equipement = :NEW.id_equipement;

    IF v_etat <> 'Disponible' THEN
        RAISE_APPLICATION_ERROR(-20009,
            'Équipement non disponible. État actuel : ' || v_etat);
    END IF;
END;
/

-- ========================
-- TRG_AFFECTATION_AFTER_INSERT
-- ========================

CREATE OR REPLACE TRIGGER trg_affectation_after_insert
AFTER INSERT ON AFFECTATION_EQUIP
FOR EACH ROW
BEGIN
    UPDATE EQUIPEMENT
    SET etat = 'OCCUPÉ'
    WHERE id_equipement = :NEW.id_equipement;
END;
/

-- ========================
-- TRG_AFFECTATION_AFTER_DELETE
-- ========================

CREATE OR REPLACE TRIGGER trg_affectation_after_delete
AFTER DELETE ON AFFECTATION_EQUIP
FOR EACH ROW
BEGIN
    UPDATE EQUIPEMENT
    SET etat = 'Disponible'
    WHERE id_equipement = :OLD.id_equipement;
END;
/

-- ========================
-- TRG_EXPERIENCE_AFTER_INSERT
-- ========================
CREATE OR REPLACE TRIGGER trg_experience_after_insert
AFTER INSERT ON EXPERIENCE
FOR EACH ROW
BEGIN
    INSERT INTO LOG_OPERATION(table_concernee, operation, utilisateur, description)
    VALUES (
        'EXPERIENCE',
        'INSERT',
        USER,
        'Nouvelle expérience ' || :NEW.id_exp || 
        ' pour le projet projet ' || :NEW.id_projet
    );
END;
/

-- ========================
-- TRG_CHERCHEUR_CRYPTER_NOM
-- ========================
CREATE OR REPLACE TRIGGER trg_chercheur_crypter_nom
BEFORE INSERT OR UPDATE ON CHERCHEUR
FOR EACH ROW
BEGIN
    :NEW.nom := crypter_champs(:NEW.nom);
END;
/


-- ========================
-- TRG_ECHANTILLON_BEFORE_INSERT
-- ========================
CREATE OR REPLACE TRIGGER trg_echantillon_before_insert
BEFORE INSERT ON ECHANTILLON
FOR EACH ROW
DECLARE
    v_date_realisation EXPERIENCE.date_realisation%TYPE;
BEGIN
    SELECT date_realisation INTO v_date_realisation
    FROM EXPERIENCE
    WHERE id_exp = :NEW.id_exp;

    IF :NEW.date_prelevement < v_date_realisation THEN
        RAISE_APPLICATION_ERROR(-20110, 'date_prelevement doit être >= date_realisation.');
    END IF;
END;
/
