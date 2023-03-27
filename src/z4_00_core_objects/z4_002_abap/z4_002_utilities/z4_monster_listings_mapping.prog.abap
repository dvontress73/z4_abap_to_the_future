*&---------------------------------------------------------------------*
*& Report  Z_MONSTER_LISTINGS_MAPPING
*&---------------------------------------------------------------------*
* The idea is that all the code samples in the book should (SHOCK HORROR)
* actually work. What a radical idea.
* So.... this program will give you an ALV list of all the listings and
* let you drill down to the code in question.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* Data Declarations
*--------------------------------------------------------------------*
INCLUDE z4_monster_mapping_top.

**********************************************************************
* Selection Screen
**********************************************************************
* Monster Header Data
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: s_chap FOR sy-tabix.

SELECTION-SCREEN END OF BLOCK blk1.

* Display Options
SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-002.

PARAMETERS: p_vari  LIKE disvariant-variant.

SELECTION-SCREEN END OF BLOCK blk2.


**********************************************************************
* Initialisation
**********************************************************************
INITIALIZATION.
  PERFORM initalisation.

*--------------------------------------------------------------------*
* Start-of-Selection
*--------------------------------------------------------------------*
START-OF-SELECTION.
  "This nonsense is the only way I can avoid getting bogus syntax
  "errors when doing a syntax check on the local class implementations
  go_selections = NEW #( is_chap = s_chap[]
                         ip_vari = p_vari ).

  IF zcl_bc_system_environment=>is_production( ) = abap_true.
    PERFORM production_run.
  ELSE.
    PERFORM non_production_run.
  ENDIF.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST                                 *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_layouts USING cl_salv_layout=>restrict_none CHANGING p_vari.

*&---------------------------------------------------------------------*
*&      Form  F4_LAYOUTS
*&---------------------------------------------------------------------*
FORM f4_layouts USING    pud_restrict TYPE salv_de_layout_restriction
                CHANGING pcd_layout   TYPE disvariant-variant.

  DATA: ls_layout TYPE salv_s_layout_info,
        ls_key    TYPE salv_s_layout_key.

  ls_key-report = sy-repid.

  ls_layout = cl_salv_layout_service=>f4_layouts( s_key    = ls_key
                                                  layout   = pcd_layout
                                                  restrict = pud_restrict ).

  pcd_layout = ls_layout-layout.

ENDFORM.                    " F4_LAYOUTS

**********************************************************************
* Class Implementations
**********************************************************************
INCLUDE z4_monster_map_cio1.

*&---------------------------------------------------------------------*
*&      Form  INITALISATION
*&---------------------------------------------------------------------*
FORM initalisation ##NEEDED.

ENDFORM.                    " INITALISATION
*&---------------------------------------------------------------------*
*& Form PRODUCTION_RUN
*&---------------------------------------------------------------------*
* In production we never want a short dump, but the "design by contract"
* things would just confuse the user
*&---------------------------------------------------------------------*
FORM production_run.

  TRY.
      lcl_application=>main( ).
    CATCH cx_sy_no_handler INTO DATA(lo_no_handler).
      "An exception was raised that was not caught at any point in the call stack
      DATA(ld_error_class) = |Fatal Error concerning Class { lo_no_handler->classname } - Please Call the Helpdesk|.
      MESSAGE ld_error_class TYPE 'I'.
    CATCH cx_root ##catch_all."#EC NEED_CX_ROOT
      "We do not know what was happened, output a message instead of dumping
      MESSAGE 'Report in Trouble - please call helpdesk' TYPE 'I'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form NON_PRODUCTION_RUN
*&---------------------------------------------------------------------*
* Development / Test / Quality Assurance
* Here we DO want short dumps so we can analyse them, and we want the design by
* contract messages to make it obvious there is a bug and the code should not
* go to production
* Put another the way the two DBC exceptions are impossible errors I am actively
* looking to cause a dump. If any other sort of dump occurs then it is something
* I am not expecting and I want to know all about it
*&---------------------------------------------------------------------*
FORM non_production_run.

  TRY.
      lcl_application=>main( ).
    CATCH zcx_violated_precondition INTO DATA(lo_precondition).
      "A bug was detected at the start of a subroutine - the caller of the
      "subroutine is at fault
      lo_precondition->mo_error_log->popup( ).
    CATCH zcx_violated_postcondition INTO DATA(lo_postcondition).
      "A bug was detected at the end of a subroutine - the subroutine is
      "at fault
      lo_postcondition->mo_error_log->popup( ).
  ENDTRY.

ENDFORM.
