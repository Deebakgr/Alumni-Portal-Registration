CLASS lhc_Degree DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Degree.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Degree.
    METHODS read FOR READ IMPORTING keys FOR READ Degree RESULT result.
    METHODS rba_Alumniregistration FOR READ
      IMPORTING keys_rba FOR READ Degree\_AlumniRegistration FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_Degree IMPLEMENTATION.
  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zalumni_degrees WHERE alumni_id = @ls_entity-AlumniId AND degree_id = @ls_entity-DegreeId INTO @DATA(ls_db).
      IF ls_entity-%control-DegreeName = if_abap_behv=>mk-on. ls_db-degree_name = ls_entity-DegreeName. ENDIF.
      IF ls_entity-%control-GradYear = if_abap_behv=>mk-on. ls_db-grad_year = ls_entity-GradYear. ENDIF.
      ls_db-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_db-last_changed_at.
      APPEND ls_db TO zcl_alumni_utility=>mt_degree_update.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE zalumni_degrees( alumni_id = ls_key-AlumniId degree_id = ls_key-DegreeId ) TO zcl_alumni_utility=>mt_degree_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM zalumni_degrees FOR ALL ENTRIES IN @keys WHERE alumni_id = @keys-AlumniId AND degree_id = @keys-DegreeId INTO TABLE @DATA(lt_db).
      LOOP AT lt_db INTO DATA(ls_db).
        APPEND VALUE #( AlumniId = ls_db-alumni_id DegreeId = ls_db-degree_id DegreeName = ls_db-degree_name GradYear = ls_db-grad_year ) TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD rba_Alumniregistration.
    " Required for Fiori to navigate from item back to header
    LOOP AT keys_rba INTO DATA(ls_key_rba).
      APPEND VALUE #( source-%key = ls_key_rba-%key
                      target-AlumniId = ls_key_rba-AlumniId ) TO association_links.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
