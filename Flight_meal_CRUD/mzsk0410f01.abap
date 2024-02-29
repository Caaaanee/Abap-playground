*&---------------------------------------------------------------------*
*& Include          MZSK0410F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_object_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object USING VALUE(p_name)
                        CHANGING go_con TYPE REF TO cl_gui_custom_container
                           go_alv TYPE REF TO cl_gui_alv_grid.

  "Create container
  CREATE OBJECT go_con
    EXPORTING
      container_name              = p_name
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE a001(zmcfc04). "Create container error
  ENDIF.

  "Create alv
  CREATE OBJECT go_alv
    EXPORTING
      i_parent          = go_con
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE a002(zmcfc04). "Create ALV ERROR
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CO_FIX
*&      <-- GS_LAYO
*&---------------------------------------------------------------------*
FORM set_layo  USING VALUE(p_fix)
                     VALUE(p_sel)
               CHANGING cs_layo TYPE lvc_s_layo.

  CALL FUNCTION 'ZFFC04_16'
    EXPORTING
      iv_cwidth   = p_fix
      iv_zebra    = p_fix
      iv_sel      = p_sel
    IMPORTING
      es_alv_layo = cs_layo.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_display USING VALUE(p_name)
                  CHANGING p_alv TYPE REF TO cl_gui_alv_grid
                        p_tab p_fcat p_sort.

  CALL METHOD p_alv->set_table_for_first_display
    EXPORTING
      i_structure_name              = p_name
      is_layout                     = gs_layo
    CHANGING
      it_outtab                     = p_tab
      it_fieldcatalog               = p_fcat
      it_sort                       = p_sort
*     it_filter                     =
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE a003(zmcfc04). "Display error
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_booking_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&      --> ZSFC04100
*&---------------------------------------------------------------------*
FORM get_booking_list  TABLES ct_list LIKE  gt_list
                       USING VALUE(p_info) TYPE zsfc04100
                             VALUE(pt_book) LIKE gt_book
                             VALUE(pt_cust) LIKE gt_cust
                             VALUE(pt_class) LIKE gt_class.
  "Get booking list
  CLEAR ct_list[].
  SELECT bookid, customid, name, custtype, class, fldate, connid, carrid
    INTO CORRESPONDING FIELDS OF TABLE @ct_list
    FROM zcdsfc0409
    WHERE carrid = @p_info-carrid
    AND connid = @p_info-connid
    AND fldate = @p_info-fldate
    AND bookid IN @pt_book
    AND customid IN @pt_cust
    AND class IN @pt_class
    AND cancelled <> @co_fix.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE s015(zmcfc04).
    RETURN.
  ENDIF.

  "Get text & delete
  PERFORM get_req_data TABLES ct_list
                       USING pt_book p_info.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_default
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> ZSFC04100_BOOKID
*&      <-- GT_BOOK
*&---------------------------------------------------------------------*
FORM set_default USING VALUE(p_sign) VALUE(p_option)
                        VALUE(p_cond) TYPE zsfc04100.

  "Set bookid default
  CLEAR: gt_book, gt_cust, gt_class.
  IF p_cond-bookid IS NOT INITIAL.
    PERFORM set_range_default USING p_cond-bookid p_sign p_option
                              CHANGING gt_book gs_book.
  ENDIF.
  "Set customid default
  IF p_cond-customid  IS NOT INITIAL.
    PERFORM set_range_default USING p_cond-customid p_sign p_option
                              CHANGING gt_cust gs_cust.
  ENDIF.

  "Set default class
  PERFORM class_default USING zsfc04100 p_sign p_option co_fix
                        CHANGING gt_class gs_class.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_req_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_LIST
*&      --> P_INFO
*&---------------------------------------------------------------------*
FORM get_req_data  TABLES ct_list LIKE gt_list
                   USING VALUE(pt_book) LIKE gt_book
                         VALUE(p_info) TYPE zsfc04100.

  "Get domain info
  IF gt_dom IS INITIAL.
    PERFORM get_domain_text USING  ct_list-mstat  ct_list-custtype ct_list-class
                            CHANGING gt_dom.
  ENDIF.

  "Get loop
  LOOP AT ct_list.
    "carrname 할당
    ct_list-carrname = gv_carrname.

    "Get mstat
    PERFORM get_req_list TABLES ct_list.

    "Get mstat text
    PERFORM get_text USING gt_dom ct_list-mstat 'ZDFC04MSTAT'
                            CHANGING gs_dom ct_list-mstat_t.
    "Get custtype text
    PERFORM get_text USING gt_dom ct_list-custtype 'S_CUSTTYPE'
                         CHANGING gs_dom ct_list-custtype_t.
    "Get class text
    PERFORM get_text USING gt_dom ct_list-class 'S_CLASS'
                     CHANGING gs_dom ct_list-class_t.

    MODIFY ct_list.
    CLEAR ct_list.
  ENDLOOP.

  "delete
  PERFORM delete_status TABLES ct_list
                        USING p_info.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_fix_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_fix_text USING VALUE(p_domain)
                        VALUE(p_key)
                  CHANGING ct_dom LIKE gt_dom.

  DATA: lt_dom LIKE gt_dom.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = p_domain
    TABLES
      values_tab      = lt_dom
*     VALUES_DD07L    =
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE a005(zmcfc04). "domain error
  ENDIF.

  INSERT LINES OF lt_dom INTO TABLE ct_dom.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_LIST
*&---------------------------------------------------------------------*
FORM delete_status  TABLES ct_list LIKE gt_list
                     USING p_info LIKE zsfc04100.

  IF  p_info-mstat = 'A'.
    DELETE ct_list[] WHERE mstat <> 'A'.
  ELSEIF p_info-mstat = 'B'.
    DELETE ct_list[] WHERE mstat <> 'B'.
  ELSEIF p_info-mstat = 'C'.
    DELETE ct_list[] WHERE mstat <> 'C'.

  ENDIF.


  "Radio Button Check
  PERFORM radio_check TABLES ct_list
                      USING p_info-cust_b p_info-cust_p co_fix.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> CT_LIST_CLASS
*&      <-- GT_DOM3
*&      <-- GS_DOM3
*&      <-- CT_LIST_CLASS_T
*&---------------------------------------------------------------------*
FORM get_text USING VALUE(pt_dom) LIKE gt_dom
                        VALUE(p_key) VALUE(p_name)
                  CHANGING cs_dom LIKE gs_dom
                           cv_text.
  "Get text
  CALL FUNCTION 'ZFFC04_18'
    EXPORTING
      iv_value       =  p_key
      iv_name        = p_name
   IMPORTING
     EV_TEXT        = cv_text
    TABLES
      tt_dom         = pt_dom
            .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_req_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_req_list TABLES pt_list LIKE gt_list.


  "기내식 최신 현황 가져오기
  PERFORM get_number_req TABLES pt_list
                         CHANGING gs_info.

  pt_list-mstat = gs_info-mstat.

  IF pt_list-mstat IS INITIAL.
    pt_list-mstat = 'A'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_req_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&      <-- ZSFC04102
*&---------------------------------------------------------------------*
FORM get_req_detail  TABLES ct_list LIKE gt_list
                     USING VALUE(p_alv) TYPE REF TO cl_gui_alv_grid
                     CHANGING cs_info TYPE zsfc04102
                              cv_subrc TYPE sy-subrc.

  CLEAR cv_subrc.
  "선택된 행 가져오기
  PERFORM get_index_row TABLES ct_list USING p_alv
                        CHANGING cv_subrc.
  IF cv_subrc <> 0. RETURN.ENDIF.

  IF ct_list-mstat = 'A'.
    cv_subrc = 3.
    MESSAGE s046(zmcfc04). "아직 신청한 기내식이 없습니다.
    RETURN.
  ENDIF.

  "Get menu info
  PERFORM set_pobup_101 TABLES ct_list
                        CHANGING cs_info.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pobup_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_LIST
*&      <-- CS_INFO
*&---------------------------------------------------------------------*
FORM set_pobup_101  TABLES ct_list LIKE gt_list
                    CHANGING cs_info TYPE zsfc04102.




  "기내식 최신 현황 가져오기
  PERFORM get_number_req TABLES ct_list
                         CHANGING gs_info.

  "메뉴에 따른 식사 가져오기
  PERFORM get_menu_number USING gs_info
                          CHANGING cs_info.

  "메뉴 텍스트 가져오기
  PERFORM get_text_meal USING cs_info-starter
                        CHANGING cs_info-atext.

  PERFORM get_text_meal USING cs_info-maincourse
                          CHANGING cs_info-mtext.

  PERFORM get_text_meal USING cs_info-dessert
                          CHANGING cs_info-dtext.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_text_meal
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_text_meal USING VALUE(p_number)
                   CHANGING cv_text.

  CALL FUNCTION 'ZFFC04_15'
    EXPORTING
      iv_num  = p_number
    IMPORTING
      ev_text = cv_text.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_req_menu
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM add_req_menu TABLES ct_list LIKE gt_list
                         ct_menu LIKE gt_menu
                         ct_info LIKE gt_info
                  USING VALUE(p_alv) TYPE REF TO cl_gui_alv_grid
                  CHANGING cv_subrc TYPE sy-subrc
                           cs_info TYPE zsfc04101
                           cs_req TYPE ztsk04req.

  CLEAR cv_subrc.
  "선택된 행 가져오기
  PERFORM get_index_row TABLES ct_list USING p_alv CHANGING cv_subrc.

  IF cv_subrc = 1.
    MESSAGE s047(zmcfc04). "신청가능한 항공편 예약을 선택하세요
    RETURN.
  ELSEIF cv_subrc = 2.
    MESSAGE s012(zmcfc04). "정보 하나만 선택하세요
    RETURN.
  ENDIF.

  "Booking info 넘겨주기
  PERFORM get_info_in_add TABLES ct_list ct_menu ct_info
                          CHANGING cs_info cv_subrc.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_index_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_index_row TABLES ct_list
                   USING VALUE(p_alv) TYPE REF TO cl_gui_alv_grid
                   CHANGING cv_subrc TYPE sy-subrc.
  DATA lv_index TYPE lvc_index.
  CLEAR cv_subrc.

  CALL FUNCTION 'ZFFC04_17'
    EXPORTING
      io_alv       = p_alv
    IMPORTING
      ev_index     = lv_index
    EXCEPTIONS
      no_exist_row = 1
      too_many_row = 2
      OTHERS       = 3.
  IF sy-subrc = 1.
    cv_subrc = 1.
    MESSAGE s011(zmcfc04). "정보 선택하세요
  ELSEIF sy-subrc = 2.
    cv_subrc = 2.
    MESSAGE s012(zmcfc04). "정보 하나만 선택하세요
  ENDIF.

  READ TABLE ct_list INDEX lv_index INTO ct_list.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form loop_menu
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_MENU
*&      --> CT_LIST
*&      --> ZSFC04102
*&---------------------------------------------------------------------*
FORM loop_menu  TABLES ct_menu LIKE gt_menu
                       ct_list LIKE gt_list
                USING VALUE(p_list) TYPE zsfc04102.

  LOOP AT ct_menu.

    "Carrname 할당
    ct_menu-carrname = ct_list-carrname.

    "메뉴 텍스트 가져오기
    IF ct_menu-starter = p_list-starter.
      ct_menu-atext = p_list-atext.
    ELSE.
      PERFORM get_text_meal USING ct_menu-starter
                    CHANGING ct_menu-atext.
    ENDIF.

    IF ct_menu-maincourse = p_list-maincourse.
      ct_menu-mtext = p_list-mtext.
    ELSE.
      PERFORM get_text_meal USING ct_menu-maincourse
                                CHANGING ct_menu-mtext.
    ENDIF.

    IF ct_menu-dessert = p_list-dessert.
      ct_menu-dtext = p_list-dtext.
    ELSE.
      PERFORM get_text_meal USING ct_menu-dessert
                               CHANGING ct_menu-dtext.
    ENDIF.

    MODIFY ct_menu.
    CLEAR ct_menu.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_menu_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MENU
*&      --> GS_INFO
*&---------------------------------------------------------------------*
FORM save_menu_info  TABLES ct_menu LIKE gt_menu
                     USING VALUE(ps_info) TYPE ztsk04req
                           VALUE(p_alv) TYPE REF TO cl_gui_alv_grid
                            VALUE(ps_list) TYPE zsfc04101
                     CHANGING cv_subrc TYPE sy-subrc.

  CLEAR cv_subrc.

  PERFORM get_index_row TABLES ct_menu
                        USING p_alv
                         CHANGING cv_subrc.

  IF cv_subrc = 1 OR cv_subrc = 2. RETURN. ENDIF.

  PERFORM insert_req TABLES ct_menu
                      USING ps_info ps_list
                      CHANGING cv_subrc.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_MENU
*&      --> PS_INFO
*&      <-- CV_SUBRC
*&---------------------------------------------------------------------*
FORM insert_req  TABLES ct_menu LIKE gt_menu
                 USING VALUE(ps_info) TYPE ztsk04req
                      VALUE(ps_list) TYPE zsfc04101
                 CHANGING cv_subrc TYPE sy-subrc.


  CLEAR cv_subrc.

  "정보 확인
  PERFORM get_info_with_req USING ps_list
                        CHANGING ps_info.

  "Mstat = B : Update
  IF ps_list-mstat = 'B' OR ps_list-mstat = 'C'.

    PERFORM get_update USING ps_info gv_rdate
                        CHANGING cv_subrc.
    IF cv_subrc = 1. RETURN. ENDIF.
  ENDIF.

  "Mstat <> B : Insert
  PERFORM get_insert TABLES ct_menu
                     USING ps_list cv_subrc.
  IF cv_subrc = 5.
    COMMIT WORK.
    MESSAGE s049(zmcfc04). " 기내식 신청 완료했습니다.
    LEAVE TO SCREEN 0.
  ELSEIF cv_subrc = 6.
    MESSAGE s050(zmcfc04). "기내식 신청 실패했습니다.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_number_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_LIST
*&      <-- GS_INFO
*&---------------------------------------------------------------------*
FORM get_number_req  TABLES pt_list LIKE gt_list
                     CHANGING cs_info TYPE ztsk04req.

  CLEAR cs_info.
  SELECT * FROM ztsk04req
    INTO CORRESPONDING FIELDS OF cs_info
    WHERE  carrid = pt_list-carrid
    AND connid = pt_list-connid
    AND bookid = pt_list-bookid
    AND fldate = pt_list-fldate
    ORDER BY endda DESCENDING reqdt DESCENDING.
    EXIT.
  ENDSELECT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_menu_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_INFO
*&      <-- CS_INFO
*&---------------------------------------------------------------------*
FORM get_menu_number  USING VALUE(ps_info) TYPE ztsk04req
                      CHANGING cs_info TYPE zsfc04102.
  CLEAR cs_info.
  SELECT SINGLE menunumber starter maincourse dessert
    FROM smenu
    INTO CORRESPONDING FIELDS OF cs_info
    WHERE menunumber = ps_info-mealnumber.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_date
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_DATE
*&---------------------------------------------------------------------*
FORM get_date  CHANGING cv_date LIKE gv_date.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = gv_date
      days      = 1
      months    = 0
      signum    = '-'
      years     = 0
    IMPORTING
      calc_date = cv_date.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_info_with_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_LIST
*&      <-- PS_INFO
*&---------------------------------------------------------------------*
FORM get_info_with_req  USING VALUE(p_list) TYPE zsfc04101
                        CHANGING cs_info TYPE ztsk04req.
  CLEAR cs_info.

  SELECT SINGLE carrid connid fldate bookid reqdt endda mealnumber mstat
  FROM ztsk04req
  INTO CORRESPONDING FIELDS OF cs_info
  WHERE carrid = p_list-carrid
  AND connid = p_list-connid
  AND bookid = p_list-bookid
  AND fldate = p_list-fldate
  AND mstat <> 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_insert
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_INFO
*&---------------------------------------------------------------------*
FORM get_insert  TABLES ct_menu LIKE gt_menu
                USING VALUE(ps_info) TYPE zsfc04101
                 CHANGING cv_subrc TYPE sy-subrc.

  DATA ls_insert TYPE ztsk04req.
  CLEAR: cv_subrc, ls_insert.
  ls_insert-carrid = ps_info-carrid.
  ls_insert-connid = ps_info-connid.
  ls_insert-fldate = ps_info-fldate.
  ls_insert-bookid = ps_info-bookid.
  ls_insert-reqdt = sy-datum.
  ls_insert-endda = '99991231'.
  ls_insert-mealnumber = ct_menu-menunumber.
  ls_insert-mstat = 'B'.
  INSERT ztsk04req FROM ls_insert.

  IF sy-subrc <> 0.
    ROLLBACK WORK.
    cv_subrc = 6.
  ELSE.
    cv_subrc = 5.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_update
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_INFO
*&      <-- CV_SUBRC
*&---------------------------------------------------------------------*
FORM get_update  USING VALUE(ps_info) TYPE ztsk04req
                       VALUE(p_date) LIKE gv_date
                 CHANGING cv_subrc TYPE sy-subrc.

  UPDATE ztsk04req SET endda = p_date
                       mstat = 'C'
                   WHERE carrid = ps_info-carrid
                   AND connid = ps_info-connid
                   AND fldate = ps_info-fldate
                   AND bookid = ps_info-bookid
                   AND reqdt = ps_info-reqdt.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    cv_subrc = 4.
    RETURN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_cond
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_cond  USING VALUE(p_list) TYPE zsfc04101
                  CHANGING ps_cond TYPE zsfc04100.
  "Cond move
  DATA: lv_class TYPE sbook-class.
  CLEAR ps_cond.
  MOVE p_list-carrid TO ps_cond-carrid.
  MOVE p_list-connid TO ps_cond-connid.
  MOVE p_list-fldate TO ps_cond-fldate.

  "Bookid move
  PERFORM set_range_default USING p_list-bookid 'I' 'EQ'
                                CHANGING gt_book gs_book.
  MOVE p_list-bookid TO ps_cond-bookid.


  "Customid move
  PERFORM set_range_default USING p_list-customid 'I' 'EQ'
                              CHANGING gt_cust gs_cust.
  MOVE p_list-customid TO ps_cond-customid.

  "Class move
  PERFORM set_button USING p_list-class 'Y' 'F' co_fix
                     CHANGING ps_cond-class_y ps_cond-class_f ps_cond-class_c.

  "custtype move
  PERFORM set_button USING p_list-custtype 'B' 'P' co_fix
                     CHANGING ps_cond-cust_b ps_cond-cust_p ps_cond-cust_a.

  "Status move
  zsfc04100-mstat = 'B'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_req_recently
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_INFO
*&      --> CS_INFO
*&---------------------------------------------------------------------*
FORM get_req_recently  TABLES ct_req LIKE gt_info
                       USING VALUE(p_list) TYPE zsfc04101.

  CLEAR ct_req.
  SELECT carrid connid fldate bookid reqdt endda mealnumber mstat
    FROM ztsk04req
     INTO CORRESPONDING FIELDS OF TABLE ct_req
    WHERE carrid = p_list-carrid
    AND connid = p_list-connid
    AND bookid = p_list-bookid
    ORDER BY reqdt DESCENDING endda DESCENDING.

  READ TABLE ct_req INDEX 1 INTO ct_req.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_req TABLES ct_list LIKE gt_list ct_info LIKE gt_info
                  USING p_alv TYPE REF TO cl_gui_alv_grid
                  CHANGING cv_subrc TYPE sy-subrc.

  CLEAR cv_subrc.
  DATA: lt_row_no TYPE lvc_t_roid.

  "선택된 행 가져오기
  PERFORM get_row_cancel USING p_alv CHANGING cv_subrc lt_row_no.
  IF lt_row_no IS INITIAL.
    cv_subrc = 1.
    MESSAGE s051(zmcfc04). "취소 가능한 기내식 신청 예약 건을 선택하세요
    RETURN.
  ENDIF.

  PERFORM get_loop_cancel TABLES ct_list ct_info USING lt_row_no
                          CHANGING cv_subrc.

  PERFORM cond_move TABLES ct_info ct_list.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_field_catalog.
  CLEAR: gt_fcat.

  "고개코드 삭제
  PERFORM field_catalog_list USING 'CUSTOMID' '' 'X'.

  "신청상태 삭제 및 텍스트 변경
  PERFORM field_catalog_list USING 'MSTAT' '' 'X'.
  PERFORM field_catalog_list USING 'MSTAT_T' 'MSTAT' ''.

  "고객 구분 삭제 및 텍스트 변경
  PERFORM field_catalog_list USING 'CUSTTYPE' '' 'X'.
  PERFORM field_catalog_list USING 'CUSTTYPE_T' 'CUSTTYPE' ''.
  "클래스 코드  삭제 및 텍스트 변경
  PERFORM field_catalog_list USING 'CLASS' '' 'X'.
  PERFORM field_catalog_list USING 'CLASS_T' 'CLASS' ''.
  "항공사 코드 삭제
  PERFORM field_catalog_list USING 'CARRID' '' 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_catalog_list USING VALUE(p_field)
                             VALUE(p_text)
                              VALUE(p_out).

  CALL FUNCTION 'ZFFC04_10'
    EXPORTING
      iv_field = p_field
      iv_text  = p_text
      iv_out   = p_out
    IMPORTING
      et_fcat  = gt_fcat
    CHANGING
      cs_fcat  = gs_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_default_cond
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- ZSFC04100
*&---------------------------------------------------------------------*
FORM set_default_cond  CHANGING p_cond TYPE zsfc04100.

  p_cond-carrid = 'AA'.
  p_cond-connid = '0017'.
  p_cond-fldate = '20240803'.

  p_cond-class_c = co_fix.
  p_cond-class_y = co_fix.
  p_cond-class_f = co_fix.
  p_cond-cust_a = co_fix.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form class_default
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM class_default USING VALUE(p_info) TYPE zsfc04100
                        VALUE(p_sign)
                        VALUE(p_option)
                        VALUE(p_fix)
                   CHANGING ct_class LIKE gt_class
                            cs_class LIKE gs_class.

  CLEAR: ct_class, cs_class.

  "Check box checking
  PERFORM check_box_default USING p_info-class_f p_fix p_sign p_option 'F'
                            CHANGING ct_class cs_class.

  PERFORM check_box_default USING p_info-class_c p_fix p_sign p_option 'C'
                              CHANGING ct_class cs_class.

  PERFORM check_box_default USING p_info-class_y p_fix p_sign p_option 'Y'
                             CHANGING ct_class cs_class.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form cond_check_class
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZSFC04100
*&---------------------------------------------------------------------*
FORM cond_check_class  USING VALUE(p_cond) TYPE zsfc04100
                        CHANGING cv_subrc TYPE sy-subrc.

  CLEAR cv_subrc.
  IF p_cond-class_f IS INITIAL AND p_cond-class_c IS INITIAL AND p_cond-class_y IS INITIAL.
    MESSAGE s041(zmcfc04). "클래스를 선택해주세요.
    CLEAR gt_list.
    cv_subrc = 1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form radio_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_LIST
*&      --> P_INFO_CUST_B
*&      --> P_INFO_CUST_P
*&      --> CO_FIX
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM radio_check  TABLES ct_list LIKE gt_list
                  USING VALUE(p_cust_b) TYPE sbook-custtype
                         VALUE(p_cust_p) TYPE sbook-custtype
                         VALUE(p_fix).
  CASE p_fix.
    WHEN p_cust_b.
      DELETE ct_list[] WHERE custtype <> 'B'.
    WHEN p_cust_p.
      DELETE ct_list[] WHERE custtype <> 'P'.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sort USING VALUE(p_spos)
                    VALUE(p_fname)
                    VALUE(p_up).

  CALL FUNCTION 'ZFFC04_09'
    EXPORTING
      iv_spos     = p_spos
      iv_fname    = p_fname
      iv_up       = p_up
    IMPORTING
      et_alv_sort = gt_sort
    CHANGING
      cs_alv_sort = gs_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZSFC04101_CLASS
*&      --> P_
*&      --> P_
*&      --> CO_FIX
*&      <-- ZSFC04100_CLASS_Y
*&      <-- ZSFC04100_CLASS_F
*&      <-- ZSFC04100_CLSS_C
*&---------------------------------------------------------------------*
FORM set_button  USING VALUE(p_key)
                          VALUE(p_type1)
                          VALUE(p_type2)
                          VALUE(p_fix)
                 CHANGING c_type1
                          c_type2
                          c_type3.
  IF p_key = p_type1.
    c_type1 = p_fix.
  ELSEIF p_key = p_type2.
    c_type2 = p_fix.
  ELSE.
    c_type3 = p_fix.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_domain_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> CT_LIST_MSTAT
*&      --> P_
*&      --> CT_LIST_CUSTTYPE
*&      --> P_
*&      --> CT_LIST_CLASS
*&      <-- GT_DOM1
*&      <-- GT_DOM2
*&      <-- GT_DOM3
*&      <-- GS_DOM1
*&      <-- GS_DOM2
*&      <-- GS_DOM3
*&---------------------------------------------------------------------*
FORM get_domain_text  USING VALUE(p_mstat) TYPE ztsk04req-mstat
                               VALUE(p_cust) TYPE sbook-custtype
                               VALUE(p_class) TYPE sbook-class
                      CHANGING ct_dom.
  CLEAR ct_dom.

  "Mstat domain info
  PERFORM get_fix_text USING 'ZDFC04MSTAT' p_mstat
                        CHANGING ct_dom.
  "Custtype domain  info
  PERFORM get_fix_text USING 'S_CUSTTYPE' p_cust
                      CHANGING ct_dom.
  "Class domain  info
  PERFORM get_fix_text USING 'S_CLASS' p_class
                    CHANGING ct_dom.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_range_default
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_range_default USING VALUE(p_cond) VALUE(p_sign) VALUE(p_option)
                        CHANGING pt_range LIKE gt_book
                                 ps_range LIKE gs_book.


  CLEAR: ps_range, pt_range.
  ps_range-sign = p_sign.
  ps_range-option = p_option.
  ps_range-low = p_cond.
  APPEND ps_range TO pt_range.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_box_default
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_INFO_CLASS_F
*&      --> P_FIX
*&      --> P_SIGN
*&      --> P_OPTION
*&      --> P_
*&      <-- CT_CLASS
*&      <-- CS_CLASS
*&      <-- CASE
*&      <-- P_FIX
*&---------------------------------------------------------------------*
FORM check_box_default  USING VALUE(p_cond) VALUE(p_fix) VALUE(p_sign)
                              VALUE(p_option) VALUE(p_low)
                        CHANGING ct_class LIKE gt_class
                                 cs_class LIKE gs_class.

  CASE p_fix.
    WHEN p_cond.
      cs_class-sign = p_sign.
      cs_class-option = p_option.
      cs_class-low = p_low.
      APPEND cs_class TO ct_class.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_customer_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LIST_CUSTOMID
*&      <-- ZSFC0491
*&---------------------------------------------------------------------*
FORM get_customer_list USING VALUE(p_id) TYPE scustom-id
                        CHANGING cs_info TYPE zsfc0491
                                 cv_subrc TYPE sy-subrc.

  CALL FUNCTION 'ZFFC04_11'
    EXPORTING
      iv_id    = p_id
    IMPORTING
      es_info  = cs_info
      ev_subrc = cv_subrc.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_text_customer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LIST
*&      <-- ZSFC0491
*&---------------------------------------------------------------------*
FORM get_text_customer  USING VALUE(ps_list) LIKE gs_list
                        CHANGING cs_info TYPE zsfc0491.
  "Custtype text
  MOVE ps_list-custtype_t TO cs_info-custtype_t.

  "Country text
  PERFORM get_country_text USING cs_info-country
                            CHANGING cs_info-country_t.
  "Langu text
  PERFORM get_langu_text USING cs_info-langu
                            CHANGING cs_info-langu_t.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_cust_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_country_text USING VALUE(p_country) TYPE scustom-country
                      CHANGING cv_text.
  CALL FUNCTION 'ZFFC04_14'
    EXPORTING
      iv_country = p_country
    IMPORTING
      ev_text    = cv_text.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_langu_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CS_INFO_LANGU
*&      <-- CS_INFO_LANGU_T
*&---------------------------------------------------------------------*
FORM get_langu_text  USING VALUE(p_langu) TYPE scustom-langu
                     CHANGING cv_text.

  CALL FUNCTION 'ZFFC04_13'
    EXPORTING
      iv_langu = p_langu
    IMPORTING
      ev_text  = cv_text.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_command .
  CASE ok_code.
    WHEN 'ENTER'.
      LEAVE TO SCREEN 0.
    WHEN 'CLOSE'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.
  PERFORM set_command.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form get_sflight_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LIST
*&      <-- ZSFC04104
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM get_sflight_list  USING VALUE(ps_list) LIKE gs_list
                       CHANGING cs_flight TYPE zsfc04104
                                cv_subrc TYPE sy-subrc.

  CLEAR: cv_subrc, cs_flight.
  SELECT SINGLE carrid connid fldate price currency planetype seatsmax
                seatsocc paymentsum seatsmax_b seatsocc_b seatsmax_f seatsocc_f
    FROM sflight
    INTO CORRESPONDING FIELDS OF cs_flight
    WHERE carrid = ps_list-carrid
    AND connid = ps_list-connid
    AND fldate = ps_list-fldate.

  MOVE ps_list-carrname TO cs_flight-carrname.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_spfli_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_spfli_info USING VALUE(p_list) LIKE gs_list
                    CHANGING cs_info TYPE zsfc04105
                             cv_subrc TYPE sy-subrc .

  CLEAR cs_info.
  SELECT SINGLE carrid connid countryfr cityfrom airpfrom countryto cityto
                airpto fltime deptime arrtime distance distid fltype period
    FROM spfli
    INTO CORRESPONDING FIELDS OF cs_info
    WHERE carrid = p_list-carrid
    AND connid = p_list-connid.

  IF sy-subrc <> 0.
    cv_subrc = 4.
  ENDIF.

  MOVE p_list-carrname TO cs_info-carrname.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_spfli_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZSFC04105
*&      <-- ZSFC04105
*&---------------------------------------------------------------------*
FORM get_spfli_text  USING VALUE(p_country)
                     CHANGING cv_text.

  CALL FUNCTION 'ZFFC04_14'
    EXPORTING
      iv_country = p_country
    IMPORTING
      ev_text    = cv_text.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_req_mstat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LIST
*&      <-- ZTSK04REQ
*&---------------------------------------------------------------------*
FORM get_req_mstat  USING VALUE(p_list) LIKE gs_list
                    CHANGING ct_info LIKE gt_info .

  CLEAR ct_info.
  SELECT carrid connid fldate bookid reqdt endda mealnumber mstat
    FROM ztsk04req
    INTO CORRESPONDING FIELDS OF TABLE ct_info
    WHERE carrid = p_list-carrid
    AND connid = p_list-connid
    AND fldate = p_list-fldate
    AND bookid = p_list-bookid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_book_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_book_info .
  "Class Check
  PERFORM cond_check_class USING zsfc04100
                            CHANGING gv_subrc.
  IF gv_subrc = 1. RETURN.ENDIF.

  "Set default
  PERFORM set_default USING 'I' 'EQ' zsfc04100.

  "Get booking lilst
  PERFORM get_booking_list TABLES gt_list
                            USING zsfc04100 gt_book gt_cust gt_class.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_recently_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_recently_list .
  "Get booking list
  PERFORM move_cond USING zsfc04101
                      CHANGING zsfc04100.
  CLEAR:zsfc04101.
  PERFORM get_booking_list TABLES gt_list
                            USING zsfc04100 gt_book gt_cust gt_class.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_row_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- CV_SUBRC
*&---------------------------------------------------------------------*
FORM get_row_cancel USING VALUE(p_alv) TYPE REF TO cl_gui_alv_grid
                    CHANGING cv_subrc TYPE sy-subrc
                              ct_row TYPE lvc_t_roid.
  "선택 행 가져오기
  CALL METHOD p_alv->get_selected_rows
    IMPORTING
*     et_index_rows =
      et_row_no = ct_row.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_info_in_add
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_INFO
*&      --> CT_MENU
*&      --> CT_INFO
*&      --> ZSFC04102
*&      <-- CS_INFO
*&      <-- CV_SUBRC
*&---------------------------------------------------------------------*
FORM get_info_in_add TABLES ct_list LIKE gt_list ct_menu LIKE gt_menu ct_info LIKE gt_info
                      CHANGING cs_info TYPE zsfc04101  cv_subrc TYPE sy-subrc.

  "Booking info 넘겨주기
  MOVE-CORRESPONDING ct_list TO cs_info.
  PERFORM get_req_recently TABLES ct_info
                            USING cs_info.

  "신청일 하루 전 가져오기
  gv_date = sy-datum.
  PERFORM get_date CHANGING gv_rdate.

  "오늘 신청 했다면 안됨.
  IF ct_list-mstat = 'B' AND ct_info-reqdt = sy-datum.
    cv_subrc = 3.
    MESSAGE s048(zmcfc04). "이미 신청한 기내식이 있습니다.
    RETURN.
  ELSEIF ct_list-fldate < gv_rdate. "기내식 신청은 출발일 기준 이틀 전까지만 신청 가능
    cv_subrc = 4.
    MESSAGE s055(zmcfc04). "기내식 신청은 항공기 출항 이틀 전까지 가능합니다.
    RETURN.
  ENDIF.

  PERFORM add_menu TABLES ct_list CHANGING ct_menu[] gv_date.
  PERFORM loop_menu TABLES ct_menu ct_list USING zsfc04102.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_menu
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_LIST_CARRID
*&      <-- CT_MENU
*&      <-- GV_DATE
*&---------------------------------------------------------------------*
FORM add_menu  TABLES ct_list LIKE gt_list
               CHANGING ct_menu LIKE gt_menu
                        cv_date TYPE sy-datum.

  "신청일 현재 일자 할당
  cv_date = sy-datum.

  "Menu add
  SELECT carrid menunumber starter maincourse dessert
    INTO CORRESPONDING FIELDS OF TABLE ct_menu
    FROM smenu
    WHERE carrid = ct_list-carrid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_loop_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_LIST
*&      --> CT_INFO
*&      --> LT_ROW_NO
*&      <-- CV_SUBRC
*&---------------------------------------------------------------------*
FORM get_loop_cancel TABLES ct_list LIKE gt_list ct_info LIKE gt_info
                      USING VALUE(pt_row_no) TYPE lvc_t_roid
                      CHANGING cv_subrc TYPE sy-subrc.
  DATA ls_row_no LIKE LINE OF pt_row_no.
  CLEAR cv_subrc.
  LOOP AT pt_row_no INTO ls_row_no.
    READ TABLE ct_list INDEX ls_row_no-row_id INTO ct_list.

    "취소는 출발 이틀전까지 가능
    IF ct_list-fldate < gv_rdate.
      ROLLBACK WORK.
      MESSAGE s056(zmcfc04). "기내식 취소는 출항 이틀 전까지 가능합니다.
      cv_subrc = 5.
      EXIT.
    ENDIF.

    "선택한 정보의 최신값 가져오기
    PERFORM get_req_recently TABLES ct_info USING ct_list.
    "신청일 현재일 or 신청완료 아님
    IF ct_list-mstat <> 'B' OR ct_info-reqdt = sy-datum.
      ROLLBACK WORK.
      MESSAGE s052(zmcfc04). "기내식 신청 취소가 불가능한 예약입니다
      cv_subrc = 2.
      EXIT.
    ENDIF.

    "정보 확인
    PERFORM get_update USING ct_info ct_info-endda CHANGING cv_subrc.
    IF cv_subrc = 4.
      MESSAGE s054(zmcfc04). "Update가 실패했습니다.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF cv_subrc = 0. COMMIT WORK. ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form cond_move
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CT_INFO
*&      --> CT_LIST
*&---------------------------------------------------------------------*
FORM cond_move  TABLES ct_info LIKE gt_info ct_list LIKE gt_list.

  "Cond move
  DATA: lv_class TYPE sbook-class.
  CLEAR zsfc04100.
  MOVE ct_info-carrid TO zsfc04100-carrid.
  MOVE ct_info-connid TO zsfc04100-connid.
  MOVE ct_info-fldate TO zsfc04100-fldate.

  "Bookid move
  PERFORM set_range_default USING ct_info-bookid 'I' 'EQ'
                                CHANGING gt_book gs_book.
  MOVE ct_info-bookid TO zsfc04100-bookid.

  "Class move
  PERFORM set_button USING ct_list-class 'Y' 'F' co_fix
                     CHANGING zsfc04100-class_y zsfc04100-class_f zsfc04100-class_c.

  "custtype move
  PERFORM set_button USING ct_list-custtype 'B' 'P' co_fix
                     CHANGING zsfc04100-cust_b zsfc04100-cust_p zsfc04100-cust_a.
  "Status move
  zsfc04100-mstat = 'C'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_carrname
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZSFC04100_CARRID
*&      <-- GV_CARRNAME
*&---------------------------------------------------------------------*
FORM get_carrname  USING VALUE(p_carrid) TYPE scarr-carrid
                   CHANGING cv_carrname TYPE scarr-carrname.
  CLEAR cv_carrname.
  SELECT SINGLE carrname
    FROM scarr
    INTO cv_carrname
    WHERE carrid = p_carrid.

ENDFORM.