*&---------------------------------------------------------------------*
*& Include          MZSK0410CLASS
*&---------------------------------------------------------------------*
CLASS lcl_handler IMPLEMENTATION.
    METHOD on_double_click .
 
      IF e_column-fieldname = 'NAME'.
 *
        "선택한 Customer 정보 가져오기
        READ TABLE gt_list INDEX e_row-index INTO gs_list.
        PERFORM get_customer_list USING gs_list-customid
                                  CHANGING zsfc0491 gv_subrc.
        IF gv_subrc = 4. RETURN. ENDIF.
        PERFORM get_text_customer USING gs_list
                                  CHANGING zsfc0491.
 
        CALL SCREEN 102 STARTING AT 10 10.
        CLEAR: gs_list, zsfc0491.
 
      ELSEIF e_column-fieldname = 'FLDATE'.
        "선택한 Customer 정보 가져오기
        READ TABLE gt_list INDEX e_row-index INTO gs_list.
        PERFORM get_sflight_list USING gs_list
                                 CHANGING zsfc04104 gv_subrc.
        CALL SCREEN 103 STARTING AT 10 10.
        CLEAR: gs_list, zsfc04104.
 
      ELSEIF e_column-fieldname = 'CONNID'.
        "선택한 Customer 정보 가져오기
        READ TABLE gt_list INDEX e_row-index INTO gs_list.
        PERFORM get_spfli_info USING gs_list
                               CHANGING zsfc04105 gv_subrc.
        IF gv_subrc = 4. RETURN. ENDIF.
 
        PERFORM get_spfli_text USING zsfc04105-countryfr
                               CHANGING zsfc04105-countryfr_t.
 
        PERFORM get_spfli_text USING zsfc04105-countryto
                              CHANGING zsfc04105-countryto_t.
 
        CALL SCREEN 104 STARTING AT 10 10.
        CLEAR: gs_list, zsfc04105.
 
      ELSEIF e_column-fieldname = 'MSTAT_T'.
        "선택한 Customer 정보 가져오기
        READ TABLE gt_list INDEX e_row-index INTO gs_list.
        PERFORM get_req_mstat USING gs_list
                              CHANGING gt_info.
        IF sy-subrc IS NOT INITIAL.
          RETURN.
        ENDIF.
 
        CALL SCREEN 105 STARTING AT 20 20.
        CLEAR: gs_list.
      ENDIF.
 
 
    ENDMETHOD.
  ENDCLASS.
 *