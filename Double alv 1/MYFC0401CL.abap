*&---------------------------------------------------------------------*
*& Include          MYFC0401CL
*&---------------------------------------------------------------------*

CLASS lcl_handler IMPLEMENTATION.
  METHOD on_double_click1.

    IF e_column-fieldname = 'CUSTOMID'.

      "선택한 예약 정보 가져오기
      READ TABLE gt_sbook INDEX e_row-index INTO gs_sbook.
      PERFORM get_customer_list USING gs_sbook-customid
                                CHANGING zsfc0491.

      CALL SCREEN 101 STARTING AT 10 10.
      CLEAR: gs_sbook, zsfc0491.

    ELSEIF e_column-fieldname = 'CARRID'.
      "선택한 예약 정보 가져오기

      READ TABLE gt_scarr INDEX e_row-index INTO gs_scarr.
      SELECT SINGLE *
        FROM spfli
        INTO CORRESPONDING FIELDS OF ysfc0401
        WHERE carrid = gs_scarr-carrid.

      SELECT SINGLE *
        FROM sflight
        INTO CORRESPONDING FIELDS OF ysfc0402
        WHERE carrid = gs_scarr-carrid.

      IF ysfc0401-carrid IS INITIAL.
        MESSAGE s004(zmcfc04). "일치하는 항공사 정보가 없습니다.
        RETURN.
      ENDIF.

      CALL SCREEN 102 STARTING AT 10 10.
      CLEAR: gs_scarr, ysfc0401, ysfc0402.

    ENDIF.

  ENDMETHOD.

  METHOD on_double_click2.

    IF e_column-fieldname = 'CUSTOMID'.

      "선택한 예약 정보 가져오기
      READ TABLE gt_sbook INDEX e_row-index INTO gs_sbook.
      PERFORM get_customer_list USING gs_sbook-customid
                                CHANGING zsfc0491.

      CALL SCREEN 101 STARTING AT 10 10.
      CLEAR: gs_sbook, zsfc0491.

    ELSEIF e_column-fieldname = 'CARRID'.
      "선택한 예약 정보 가져오기

      READ TABLE gt_sbook INDEX e_row-index INTO gs_sbook.
      SELECT SINGLE *
        FROM spfli
        INTO CORRESPONDING FIELDS OF ysfc0401
        WHERE carrid = gs_sbook-carrid.

      SELECT SINGLE *
        FROM sflight
        INTO CORRESPONDING FIELDS OF ysfc0402
        WHERE carrid = gs_sbook-carrid.

      IF ysfc0402-carrid IS INITIAL.
        MESSAGE s004(zmcfc04). "일치하는 항공사 정보가 없습니다.
        RETURN.
      ENDIF.

      CALL SCREEN 102 STARTING AT 10 10.
      CLEAR: gs_sbook, ysfc0401, ysfc0402.

    ENDIF.

  ENDMETHOD.



ENDCLASS.