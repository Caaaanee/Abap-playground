*&---------------------------------------------------------------------*
*& Include MZSK0410TOP                              - Module Pool      SAPMZSK0410
*&---------------------------------------------------------------------*
PROGRAM sapmzsk0410.

*공통변수
DATA: gv_subrc TYPE sy-subrc,
      ok_code  TYPE sy-ucomm,
      gv_date  TYPE sy-datum,
      gv_rdate LIKE gv_date.

*상수
CONSTANTS co_fix(1) VALUE 'X'.

*Condition
TABLES zsfc04100.

DATA: gt_book  TYPE RANGE OF sbook-bookid,
      gs_book  LIKE LINE OF gt_book,
      gt_cust  TYPE RANGE OF sbook-customid,
      gs_cust  LIKE LINE OF gt_cust,
      gt_class TYPE RANGE OF sbook-class,
      gs_class LIKE LINE OF gt_class.

**Booking List
TABLES zsfc04101.
DATA: gt_list TYPE zsfc04101_t,
      gs_list LIKE LINE OF gt_list,
      gv_carrname TYPE scarr-carrname.

*Ref list
TABLES zsfc04102.
TABLES ztsk04req.
DATA: gs_info TYPE ztsk04req,
      gt_info LIKE TABLE OF gs_info.

*menu list
DATA: gt_menu TYPE ZSFC04103_t,
      gs_menu LIKE LINE OF gt_menu.

*booking ALV
DATA: go_con TYPE REF TO cl_gui_custom_container,
      go_alv TYPE REF TO cl_gui_alv_grid.

"Menu alv
DATA: go_con2 TYPE REF TO cl_gui_custom_container,
      go_alv2 TYPE REF TO cl_gui_alv_grid.

"Status alv
DATA: go_con3 TYPE REF TO cl_gui_custom_container,
      go_alv3 TYPE REF TO cl_gui_alv_grid.

*sort
DATA: gs_sort  TYPE lvc_s_sort,
      gt_sort  LIKE TABLE OF gs_sort,
      gt_sort2 LIKE TABLE OF gs_sort,
      gt_sort3 LIKE TABLE OF gs_sort.

*LAYOUT
DATA: gs_layo  TYPE lvc_s_layo.

*FIELD LAYOUT
DATA: gt_fcat  TYPE lvc_t_fcat,
      gs_fcat  LIKE LINE OF gt_fcat,
      gt_fcat2 TYPE lvc_t_fcat,
      gs_fcat2 LIKE LINE OF gt_fcat2,
      gt_fcat3 TYPE lvc_t_fcat,
      gs_fcat3 LIKE LINE OF gt_fcat3.

*DOMAIN
DATA: gs_dom TYPE dd07v,
      gt_dom LIKE TABLE OF gs_dom.

"Class
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_double_click FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.
ENDCLASS.


*Customer list
TABLES zsfc0491.

*Flight list
TABLES zsfc04104.

"SPFLI list
TABLES zsfc04105.