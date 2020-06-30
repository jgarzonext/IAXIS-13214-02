create or replace PROCEDURE p_dim_usuario
IS
    v_usu_id        NUMBER;
    v_fec_reg   DATE := TRUNC (sysdate);


    CURSOR cur_usuario IS

        select null USU_GRUPO,
          u.cusuari USU_USUARIO,
          u.tusunom USU_USUARIO_DESC,
          trunc(axis.f_sysdate) FECHA_REGISTRO,
          DECODE(U.CBLOQUEO, 1, 'BLOQUEADO', 'ACTIVO' ) ESTADO, -- CBLOQUEO  /bloquiado - Activo
          trunc(axis.f_sysdate) START_ESTADO,
          trunc(axis.f_sysdate) END_ESTADO,
          trunc(axis.f_sysdate) FECHA_CONTROL,
          trunc(axis.f_sysdate) FECHA_INICIAL,
          trunc(axis.f_sysdate) FECHA_FIN,
          to_char(substr(nvl(rc.cpadre, u.cdelega), 3,2)) SUCUR,
          null   CLASE,
          u.sperson CODIGOPERSONA
          from axis.usuarios u
          left join axis.redcomercial rc on u.cdelega = rc.cagente and rc.ctipage > 3;

BEGIN

	SELECT MAX(usu_id) INTO v_usu_id FROM dim_usuario;

    FOR reg IN cur_usuario
    LOOP

	v_usu_id := v_usu_id + 1;

        UPDATE dim_usuario
           SET estado = 'INACTIVO',
               end_estado = v_fec_reg,
               fecha_control = v_fec_reg
         WHERE estado = 'ACTIVO'
          and usu_usuario = reg.usu_usuario;

            INSERT INTO DIM_USUARIO
                VALUES (v_usu_id,
                        reg.usu_grupo,
                        reg.usu_usuario,
                        reg.usu_usuario_Desc,
                        v_fec_reg,
                        reg.estado,
                        v_fec_reg,
                        v_fec_reg,
                        v_fec_reg,
                        v_fec_reg,
                        v_fec_reg,
                        reg.sucur,
                        reg.clase,
                        reg.codigopersona);

    END LOOP;

    COMMIT;

END p_dim_usuario;

