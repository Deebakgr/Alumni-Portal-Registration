CLASS zcl_alumni_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

 PUBLIC SECTION.
    " 1. Declare a formal type here
    TYPES: ty_id TYPE n LENGTH 3.

    " Buffer Tables for Header
    CLASS-DATA: mt_alumni_create TYPE STANDARD TABLE OF zalumni_reg,
                mt_alumni_update TYPE STANDARD TABLE OF zalumni_reg,
                mt_alumni_delete TYPE STANDARD TABLE OF zalumni_reg.

    " Buffer Tables for Items
    CLASS-DATA: mt_degree_create TYPE STANDARD TABLE OF zalumni_degrees,
                mt_degree_update TYPE STANDARD TABLE OF zalumni_degrees,
                mt_degree_delete TYPE STANDARD TABLE OF zalumni_degrees.

    CLASS-METHODS:
      save_to_database,
      cleanup,
      " 2. Use the formal type in the parameters
      generate_alumni_id RETURNING VALUE(rv_id) TYPE ty_id,
      generate_degree_id IMPORTING iv_alumni_id TYPE ty_id
                         RETURNING VALUE(rv_id) TYPE ty_id.
ENDCLASS.

CLASS zcl_alumni_utility IMPLEMENTATION.

  METHOD save_to_database.
    " 1. Handle Creates and Updates
    IF mt_alumni_create IS NOT INITIAL.
      INSERT zalumni_reg FROM TABLE @mt_alumni_create.
    ENDIF.
    IF mt_alumni_update IS NOT INITIAL.
      UPDATE zalumni_reg FROM TABLE @mt_alumni_update.
    ENDIF.

    " 2. Handle Deletes WITH CASCADE! (This fixes your issue)
    IF mt_alumni_delete IS NOT INITIAL.
      " Delete the Header
      DELETE zalumni_reg FROM TABLE @mt_alumni_delete.

      " NEW CODE: Loop through and delete all matching items (Degrees)
      LOOP AT mt_alumni_delete INTO DATA(ls_alumni_del).
        DELETE FROM zalumni_degrees WHERE alumni_id = @ls_alumni_del-alumni_id.
      ENDLOOP.
    ENDIF.

    " 3. Handle specific Item Operations
    IF mt_degree_create IS NOT INITIAL.
      INSERT zalumni_degrees FROM TABLE @mt_degree_create.
    ENDIF.
    IF mt_degree_update IS NOT INITIAL.
      UPDATE zalumni_degrees FROM TABLE @mt_degree_update.
    ENDIF.
    IF mt_degree_delete IS NOT INITIAL.
      DELETE zalumni_degrees FROM TABLE @mt_degree_delete.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: mt_alumni_create, mt_alumni_update, mt_alumni_delete,
           mt_degree_create, mt_degree_update, mt_degree_delete.
  ENDMETHOD.

  METHOD generate_alumni_id.
    DATA: lv_max_active TYPE ty_id,
          lv_max_draft  TYPE ty_id,
          lv_max_orphan TYPE ty_id.

    " 1. Check Active records
    SELECT SINGLE FROM zalumni_reg FIELDS MAX( alumni_id ) INTO @lv_max_active.

    " 2. Check Draft records
    SELECT SINGLE FROM zalumni_reg_d FIELDS MAX( AlumniId ) INTO @lv_max_draft.

    " 3. NEW: Check for Ghost/Orphaned records in the Item table!
    SELECT SINGLE FROM zalumni_degrees FIELDS MAX( alumni_id ) INTO @lv_max_orphan.

    " 4. Find the absolute highest number across all three
    rv_id = lv_max_active.
    IF lv_max_draft > rv_id.
      rv_id = lv_max_draft.
    ENDIF.
    IF lv_max_orphan > rv_id.
      rv_id = lv_max_orphan.
    ENDIF.

    " 5. Increment and format
    rv_id = rv_id + 1.
    rv_id = |{ rv_id ALPHA = IN }|.
  ENDMETHOD.

  METHOD generate_degree_id.
    DATA: lv_max_active TYPE n LENGTH 3,
          lv_max_draft  TYPE n LENGTH 3.

    " 1. Check the Active Table for this specific Alumni
    SELECT SINGLE FROM zalumni_degrees
      FIELDS MAX( degree_id )
      WHERE alumni_id = @iv_alumni_id
      INTO @lv_max_active.

    " 2. Check the Draft Table
    " (Ensure 'zalumni_deg_d' matches your actual item draft table name)
    SELECT SINGLE FROM zalumni_deg_d
      FIELDS MAX( DegreeId )
      WHERE AlumniId = @iv_alumni_id
      INTO @lv_max_draft.

    " 3. Compare and use the absolute highest value
    IF lv_max_draft > lv_max_active.
      rv_id = lv_max_draft + 1.
    ELSE.
      rv_id = lv_max_active + 1.
    ENDIF.

    " Format with leading zeros
    rv_id = |{ rv_id ALPHA = IN }|.
  ENDMETHOD.

ENDCLASS.
