*&---------------------------------------------------------------------*
*& Include          MYFC0401I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'ENTER'.

      CLEAR gt_scarr.
      SELECT carrid carrname currcode
        FROM scarr
        INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

      CLEAR gt_sbook.
      SELECT carrid connid fldate bookid customid custtype
        FROM sbook
        INTO CORRESPONDING FIELDS OF TABLE gt_sbook.






    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.
  CASE ok_code.
    WHEN 'ENTER'.
      LEAVE TO SCREEN 0.
    WHEN 'CLOSE'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.
  CASE ok_code.
    WHEN 'ENTER'.
      LEAVE TO SCREEN 0.
    WHEN 'CLOSE'.
      LEAVE TO SCREEN 0.
    WHEN 'TAB1' OR 'TAB2'. "Tab button.
      ts_tab-activetab = ok_code.
      CASE ok_code.
        WHEN 'TAB1'.
          SELECT SINGLE *
          FROM spfli
          INTO CORRESPONDING FIELDS OF ysfc0401
          WHERE carrid = gs_scarr-carrid.

        WHEN 'TAB2'.
          SELECT SINGLE *
          FROM sflight
          INTO CORRESPONDING FIELDS OF ysfc0402
          WHERE carrid = gs_scarr-carrid.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.