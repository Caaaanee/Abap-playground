*&---------------------------------------------------------------------*
*& Include          MZSK0410I01
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
    WHEN 'SEARCH'.
      "Get book info
      PERFORM get_book_info.

    WHEN 'DETAIL'.

      "기내식 조회
      PERFORM get_req_detail TABLES gt_list USING go_alv
                              CHANGING zsfc04102 gv_subrc.
      IF gv_subrc = 0.
        CALL SCREEN 0101 STARTING AT 10 10.
      ENDIF.


    WHEN 'ADD'.
      "기내식 신청
      PERFORM add_req_menu TABLES gt_list gt_menu gt_info USING go_alv
                            CHANGING gv_subrc zsfc04101 gs_info.
      IF gv_subrc = 0.
        CALL SCREEN 200.
        PERFORM get_recently_list.
      ENDIF.

    WHEN 'CANCEL'.
      PERFORM delete_req TABLES gt_list gt_info USING go_alv CHANGING gv_subrc.

      IF gv_subrc = 0.
        PERFORM get_booking_list TABLES gt_list USING zsfc04100 gt_book gt_cust gt_class.
        MESSAGE s053(zmcfc04). "기내식 취소 완료했습니다.
      ENDIF.

    WHEN 'ENTER'.
    WHEN 'REFRESH'.
      CLEAR: zsfc04100, gt_list.
      PERFORM set_default_cond CHANGING zsfc04100.
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
  PERFORM set_command.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      "기내식 변경
      PERFORM save_menu_info TABLES gt_menu
                             USING gs_info go_alv2 zsfc04101
                             CHANGING gv_subrc.

      IF gv_subrc = 1.
        MESSAGE s011(zmcfc04). "정보를 선택하세요.
      ELSEIF gv_subrc = 2.
        MESSAGE s012(zmcfc04). "한가지 정보를 선택하세요.
      ENDIF.


    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.
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
  PERFORM set_command.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0104  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0104 INPUT.
  PERFORM set_command.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  PERFORM set_command.
ENDMODULE.