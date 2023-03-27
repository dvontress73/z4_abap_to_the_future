*"* use this source file for your ABAP unit test classes
*--------------------------------------------------------------------*
* Listing 07.23: - BUnit Test Definition
*--------------------------------------------------------------------*
CLASS ltc_explode_all_heads DEFINITION FINAL FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.
  PUBLIC SECTION.
    INTERFACES zif_4_monster_c.
    ALIASES:
    bo_key      FOR zif_4_monster_c~sc_bo_key,
    node        FOR zif_4_monster_c~sc_node,
    association FOR zif_4_monster_c~sc_association,
    action      FOR zif_4_monster_c~sc_action,
    attribute   FOR zif_4_monster_c~sc_node_attribute.

  PRIVATE SECTION.
    DATA: mo_header TYPE REF TO /bobf/if_bunit_data_node,
          mo_result TYPE REF TO /bobf/if_bunit_action_result ##NEEDED.

    METHODS:
      "IT SHOULD
      explode_all_the_heads FOR TESTING RAISING cx_static_check,
      given_monster,
      when_explode_action_occurs,
      then_heads_should_explode.

*--------------------------------------------------------------------*
* One Haunted Castle contains the ghost of a servant who was falsely accused of losing valuable dishes. She was killed
* and thrown into the well in the castle. Her ghost now haunts the castle at night, counting dishes in a mournful tone;
* she reaches nine before shrieking and returning to the well.
*--------------------------------------------------------------------*
ENDCLASS.

*--------------------------------------------------------------------*
* Listing 07.24: - BUnit Test Implementation
*--------------------------------------------------------------------*
CLASS ltc_explode_all_heads IMPLEMENTATION.

  METHOD explode_all_the_heads.

    given_monster( ).
    when_explode_action_occurs( ).
    then_heads_should_explode( ).

  ENDMETHOD.

  METHOD given_monster.

    mo_header = /bobf/cl_bunit=>create_root( bo_key ).

  ENDMETHOD.

  METHOD when_explode_action_occurs.

    mo_result = mo_header->execute_action( action-monster_header-explode_all_heads ).

  ENDMETHOD.

  METHOD then_heads_should_explode.

    DATA(lo_assert) = /bobf/cl_bunit=>assert( ).

    lo_assert->node( mo_header )->attribute( attribute-monster_header-no_of_heads )->equals( 0 ).

  ENDMETHOD.

ENDCLASS.
