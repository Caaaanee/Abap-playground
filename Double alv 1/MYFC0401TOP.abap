PROGRAM sapmyfc0401.

DATA: ok_code  TYPE sy-ucomm,
      gv_subrc TYPE sy-subrc.
*tabstrip
CONTROLS ts_tab TYPE TABSTRIP.
DATA: gv_dynnr TYPE sy-dynnr.

*alv
DATA:
  go_dock  TYPE REF TO cl_gui_docking_container,
  go_split TYPE REF TO cl_gui_splitter_container.

DATA:
  go_con1 TYPE REF TO cl_gui_container,
  go_con2 TYPE REF TO cl_gui_container.

DATA:
  go_grid1 TYPE REF TO cl_gui_alv_grid,
  go_grid2 TYPE REF TO cl_gui_alv_grid.

* customer list
TABLES zsfc0491.

*spfli list
TABLES ysfc0401.

*sflight list
TABLES ysfc0402.

*alv
DATA gs_layo TYPE lvc_s_layo.

* get sflight
DATA: gs_sbook TYPE sbook,
      gt_sbook LIKE TABLE OF gs_sbook.
*get scarr
DATA: gs_scarr TYPE scarr,
      gt_scarr LIKE TABLE OF gs_scarr.

*alv event
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.

    CLASS-METHODS on_double_click1 FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.
    CLASS-METHODS on_double_click2 FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.

ENDCLASS.

DATA: go_hand1 TYPE REF TO lcl_handler,
      go_hand2 TYPE REF TO lcl_handler.
*CREATE OBJECT go_hand1.
*CREATE OBJECT go_hand2.