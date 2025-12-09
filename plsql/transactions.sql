CREATE OR REPLACE PROCEDURE planifier_experience(
    p_id_projet       IN NUMBER,
    p_titre_exp       IN VARCHAR2,
    p_date_real       IN DATE,
    p_resultat        IN VARCHAR2,
    p_statut          IN VARCHAR2,
    p_id_equipement   IN NUMBER
)
AS
    v_id_exp NUMBER;
BEGIN
    BEGIN
        INSERT INTO EXPERIENCE(id_projet, titre_exp, date_realisation, resultat, statut)
        VALUES(p_id_projet, p_titre_exp, p_date_real, p_resultat, p_statut)
        RETURNING id_exp INTO v_id_exp;

        SAVEPOINT avant_affectation;

        BEGIN
            affecter_equipement(
                p_id_projet     => p_id_projet,
                p_id_equipement => p_id_equipement,
                p_date_affect   => p_date_real,
                p_duree_jours   => 1
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO avant_affectation;

                RAISE_APPLICATION_ERROR(
                    -20021,
                    'Échec lors affectation équipement : ' || SQLERRM
                );
        END;
        journaliser_action(
            'EXPERIENCE',
            'INSERT',
            USER,
            'Planification expérience ' || v_id_exp || ' pour projet ' || p_id_projet
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Expérience planifiée : ' || v_id_exp);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20022, 'Erreur planifier_experience : ' || SQLERRM);
    END;
END;
/
