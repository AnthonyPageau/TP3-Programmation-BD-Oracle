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