-- VERIFIER_DISPONIBILITE_EQUIPMENT

CREATE OR REPLACE FUNCTION verifier_disponibilite_equipement(p_id_equipement NUMBER)
RETURN NUMBER
IS
    v_etat EQUIPEMENT.etat%TYPE;
BEGIN
    SELECT etat
    INTO v_etat
    FROM EQUIPEMENT
    WHERE id_equipement = p_id_equipement;

    IF v_etat = 'Disponible' THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Équipement inconnu : ' || p_id_equipement);
    WHEN OTHERS THEN
        RAISE;
END verifier_disponibilite_equipement;

-- MOYENNE_MESURES_EXPERIENCE

CREATE FUNCTION moyenne_mesures_experience(p_id_experience NUMBER)
RETURN NUMBER
IS
    v_moyenne NUMBER;
BEGIN
    SELECT AVG(mesure)
    INTO v_moyenne
    FROM ECHANTILLON
    WHERE id_exp = p_id_experience;

    IF v_moyenne IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002,
            "Aucune mesure trouvée pour l'expérience" || p_id_experience);
    END IF;

    RETURN v_moyenne;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Expérience inconnue : ' || p_id_experience);

    WHEN OTHERS THEN
        RAISE;
END moyenne_mesures_experience;
/