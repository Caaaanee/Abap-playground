*&---------------------------------------------------------------------*
*& Include          MYFC0401F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_object_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0100 .

  CREATE OBJECT go_dock
    EXPORTING
      repid                       = 'SAPMYFC0401'
      dynnr                       = sy-dynnr
      side                        = cl_gui_docking_container=>dock_at_left
      extension                   = 1000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE a001(zmcfc04).
  ENDIF.

  CREATE OBJECT go_split
    EXPORTING
      parent            = go_dock
      rows              = 2
      columns           = 1
    EXCEPTIONS
      cntl_error        = 1
      cntl_system_error = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE a002(zmcfc04).
  ENDIF.

  CALL METHOD go_split->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_con2.

  CALL METHOD go_split->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_con1.

  CREATE OBJECT go_grid1
    EXPORTING
      i_parent          = go_con2
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE a002(zmcfc04).
  ENDIF.

  CREATE OBJECT go_grid2
    EXPORTING
      i_parent          = go_con1
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE a002(zmcfc04).
  ENDIF.

  CREATE OBJECT go_hand1.

  CREATE OBJECT go_hand2.

  SET HANDLER go_hand1->on_double_click1 FOR go_grid1.
  SET HANDLER go_hand2->on_double_click2 FOR go_grid2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_display .

  CALL METHOD go_grid1->set_table_for_first_display
    EXPORTING
*     i_buffer_active  = 'X'
*     i_bypassing_buffer            =
*     i_consistency_check           =
      i_structure_name = 'SCARR'
      is_layout        = gs_layo
    CHANGING
      it_outtab        = gt_SCARR.

  CALL METHOD go_grid2->set_table_for_first_display
    EXPORTING
*     i_buffer_active  =
*     i_bypassing_buffer            =
*     i_consistency_check           =
      i_structure_name = 'SBOOK'
      is_layout        = gs_layo
    CHANGING
      it_outtab        = gt_sbook.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_customer_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_SBOOK_CUSTOMID
*&      <-- ZSFC0491
*&---------------------------------------------------------------------*
FORM get_customer_list USING VALUE(p_id) TYPE scustom-id
                        CHANGING cs_info TYPE zsfc0491.

  CALL FUNCTION 'ZFFC04_11'
    EXPORTING
      iv_id   = p_id
    IMPORTING
      es_info = cs_info
*     EV_SUBRC       =
    .


ENDFORM.