CLASS lsc_ZI_ALUMNIREGISTRATION DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_ALUMNIREGISTRATION IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
    " Loop through the buffer to check data before it hits the database
    LOOP AT zcl_alumni_utility=>mt_alumni_create INTO DATA(ls_alumni).

      IF ls_alumni-email_address NS '@'.
        " If the email does NOT contain '@', abort the save!
        APPEND VALUE #( %msg = new_message(
                                 id       = 'ZALUMNI_MSG' " Your message class
                                 number   = '001'         " 'Invalid Email'
                                 severity = if_abap_behv_message=>severity-error ) ) TO reported-alumni.

        APPEND VALUE #( alumniid = ls_alumni-alumni_id ) TO failed-alumni.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
 METHOD save.
    " This one line triggers the actual database updates
    zcl_alumni_utility=>save_to_database( ).
  ENDMETHOD.

  METHOD cleanup.
    zcl_alumni_utility=>cleanup( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
