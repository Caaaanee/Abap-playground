*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_OBJECT_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_object_0100 OUTPUT.
  IF go_con IS INITIAL.
    PERFORM create_object USING 'CON'
                                CHANGING go_con go_alv.
  ENDIF.

  PERFORM set_field_catalog.
  SET HANDLER lcl_handler=>on_double_click FOR go_alv.
  "display
  PERFORM set_display USING 'ZSFC04101'
                      CHANGING go_alv gt_list gt_fcat gt_sort.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'S101'.
  SET TITLEBAR 'T101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'S200'.
  SET TITLEBAR 'T200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CRETE_OBJECT_200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE crete_object_200 OUTPUT.
  IF go_con2 IS  INITIAL.
    PERFORM create_object USING 'MENU'
                          CHANGING go_con2 go_alv2.
  ENDIF.
  PERFORM set_display USING 'ZSFC04103'
                      CHANGING go_alv2 gt_menu gt_fcat2 gt_sort2.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  SET PF-STATUS 'S102'.
  SET TITLEBAR 'T102'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
  SET PF-STATUS 'S103'.
  SET TITLEBAR 'T103'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0104 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0104 OUTPUT.
  SET PF-STATUS 'S104'.
  SET TITLEBAR 'T104'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0105 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  SET PF-STATUS 'S105'.
  SET TITLEBAR 'T105'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_OBJECT_0105 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_object_0105 OUTPUT.

  IF go_con3 IS  INITIAL.
   PERFORM create_object USING 'STATUS'
                          CHANGING go_con3 go_alv3.
  ENDIF.
  PERFORM set_display USING 'ZTSK04REQ'
                      CHANGING go_alv3 gt_info gt_fcat3 gt_sort3.
ENDMODULE.