CLASS lhc_Alumni DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Alumni RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Alumni.
    METHODS earlynumbering_cba_Degrees FOR NUMBERING
      IMPORTING entities FOR CREATE Alumni\_Degrees.

    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Alumni.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Alumni.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Alumni.
    METHODS read FOR READ IMPORTING keys FOR READ Alumni RESULT result.
    METHODS lock FOR LOCK IMPORTING keys FOR LOCK Alumni.
    METHODS cba_Degrees FOR MODIFY IMPORTING entities_cba FOR CREATE Alumni\_Degrees.

    METHODS approvealumni FOR MODIFY
      IMPORTING keys FOR ACTION Alumni~approvealumni RESULT result.
    METHODS rejectalumni FOR MODIFY
      IMPORTING keys FOR ACTION Alumni~rejectalumni RESULT result.

    METHODS rba_Degrees FOR READ
      IMPORTING keys_rba FOR READ Alumni\_Degrees FULL result_requested RESULT result LINK association_links.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Alumni RESULT result.
    METHODS reviewalumni FOR MODIFY
      IMPORTING keys FOR ACTION alumni~reviewalumni RESULT result.
    METHODS deactivatealumni FOR MODIFY
      IMPORTING keys FOR ACTION alumni~deactivatealumni RESULT result.
ENDCLASS.

CLASS lhc_Alumni IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  " ====================================================================
  " EARLY NUMBERING (Fixes the Create Crash)
  " ====================================================================
  METHOD earlynumbering_create.
    LOOP AT entities INTO DATA(ls_entity).
      DATA(lv_new_id) = zcl_alumni_utility=>generate_alumni_id( ).

      APPEND VALUE #( %cid      = ls_entity-%cid
                      %is_draft = ls_entity-%is_draft
                      AlumniId  = lv_new_id ) TO mapped-alumni.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Degrees.
    LOOP AT entities INTO DATA(ls_entity).
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        DATA(lv_new_deg_id) = zcl_alumni_utility=>generate_degree_id( ls_entity-AlumniId ).

        APPEND VALUE #( %cid      = ls_target-%cid
                        %is_draft = ls_entity-%is_draft
                        AlumniId  = ls_entity-AlumniId
                        DegreeId  = lv_new_deg_id ) TO mapped-degree.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  " ====================================================================
  " STANDARD OPERATIONS
  " ====================================================================
  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      DATA(ls_db) = VALUE zalumni_reg(
        client         = sy-mandt
        alumni_id      = ls_entity-AlumniId
        first_name     = ls_entity-FirstName
        last_name      = ls_entity-LastName
        grad_year      = ls_entity-GradYear
        degree_program = ls_entity-DegreeProgram
        email_address  = ls_entity-EmailAddress
        reg_status     = 'PENDING'
        created_by     = sy-uname
      ).
      GET TIME STAMP FIELD ls_db-created_at.
      APPEND ls_db TO zcl_alumni_utility=>mt_alumni_create.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zalumni_reg WHERE alumni_id = @ls_entity-AlumniId INTO @DATA(ls_db).
      IF ls_entity-%control-FirstName = if_abap_behv=>mk-on. ls_db-first_name = ls_entity-FirstName. ENDIF.
      IF ls_entity-%control-LastName = if_abap_behv=>mk-on. ls_db-last_name = ls_entity-LastName. ENDIF.
      IF ls_entity-%control-GradYear = if_abap_behv=>mk-on. ls_db-grad_year = ls_entity-GradYear. ENDIF.
      IF ls_entity-%control-DegreeProgram = if_abap_behv=>mk-on. ls_db-degree_program = ls_entity-DegreeProgram. ENDIF.
      IF ls_entity-%control-EmailAddress = if_abap_behv=>mk-on. ls_db-email_address = ls_entity-EmailAddress. ENDIF.
      IF ls_entity-%control-RegStatus = if_abap_behv=>mk-on. ls_db-reg_status = ls_entity-RegStatus. ENDIF.

      ls_db-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_db-last_changed_at.
      APPEND ls_db TO zcl_alumni_utility=>mt_alumni_update.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE zalumni_reg( alumni_id = ls_key-AlumniId ) TO zcl_alumni_utility=>mt_alumni_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM zalumni_reg FOR ALL ENTRIES IN @keys WHERE alumni_id = @keys-AlumniId INTO TABLE @DATA(lt_db).
      LOOP AT lt_db INTO DATA(ls_db).
        APPEND VALUE #(
            AlumniId      = ls_db-alumni_id
            FirstName     = ls_db-first_name
            LastName      = ls_db-last_name
            GradYear      = ls_db-grad_year
            DegreeProgram = ls_db-degree_program
            EmailAddress  = ls_db-email_address
            RegStatus     = ls_db-reg_status
        ) TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Degrees.
  ENDMETHOD.

  METHOD cba_Degrees.
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        DATA(ls_db) = VALUE zalumni_degrees(
            client      = sy-mandt
            alumni_id   = ls_cba-AlumniId
            degree_id   = ls_target-DegreeId
            degree_name = ls_target-DegreeName
            grad_year   = ls_target-GradYear
            created_by  = sy-uname
        ).
        GET TIME STAMP FIELD ls_db-created_at.
        APPEND ls_db TO zcl_alumni_utility=>mt_degree_create.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  " ====================================================================
  " ACTIONS: Approve & Reject (Fixed Timestamps!)
  " ====================================================================
  METHOD approvealumni.
    GET TIME STAMP FIELD DATA(lv_ts). " <--- The syntax fix!

    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni FIELDS ( AlumniId RegStatus ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_alumni).

    LOOP AT lt_alumni ASSIGNING FIELD-SYMBOL(<ls>).
      IF <ls>-RegStatus = 'ACTIVE'.
        APPEND VALUE #( %tky = <ls>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                      text     = |Alumni { <ls>-AlumniId } is already active.| )
                      ) TO reported-Alumni.
        APPEND VALUE #( %tky = <ls>-%tky ) TO failed-Alumni.
      ENDIF.
    ENDLOOP.

    LOOP AT failed-Alumni INTO DATA(ls_fail).
      DELETE lt_alumni WHERE %tky = ls_fail-%tky.
    ENDLOOP.

    CHECK lt_alumni IS NOT INITIAL.

    MODIFY ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni
        UPDATE FIELDS ( RegStatus LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #( FOR ls IN lt_alumni (
            %tky               = ls-%tky
            RegStatus          = 'ACTIVE'
            LastChangedBy      = sy-uname
            LastChangedAt      = lv_ts
            LocalLastChangedAt = lv_ts
          ) ).

    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni ALL FIELDS WITH CORRESPONDING #( lt_alumni ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls IN lt_result ( %tky = ls-%tky %param = ls ) ).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lr>).
      APPEND VALUE #( %tky = <lr>-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Alumni { <lr>-AlumniId } approved successfully.| )
                    ) TO reported-Alumni.
    ENDLOOP.
  ENDMETHOD.

  METHOD rejectalumni.
    GET TIME STAMP FIELD DATA(lv_ts). " <--- The syntax fix!

    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni FIELDS ( AlumniId RegStatus ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_alumni).

    LOOP AT lt_alumni ASSIGNING FIELD-SYMBOL(<ls>).
      IF <ls>-RegStatus = 'REJECTED'.
        APPEND VALUE #( %tky = <ls>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                      text     = |Alumni { <ls>-AlumniId } is already rejected.| )
                      ) TO reported-Alumni.
        APPEND VALUE #( %tky = <ls>-%tky ) TO failed-Alumni.
      ENDIF.
    ENDLOOP.

    LOOP AT failed-Alumni INTO DATA(ls_fail_rej).
      DELETE lt_alumni WHERE %tky = ls_fail_rej-%tky.
    ENDLOOP.

    CHECK lt_alumni IS NOT INITIAL.

    MODIFY ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni
        UPDATE FIELDS ( RegStatus LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #( FOR ls IN lt_alumni (
            %tky               = ls-%tky
            RegStatus          = 'REJECTED'
            LastChangedBy      = sy-uname
            LastChangedAt      = lv_ts
            LocalLastChangedAt = lv_ts
          ) ).

    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni ALL FIELDS WITH CORRESPONDING #( lt_alumni ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls IN lt_result ( %tky = ls-%tky %param = ls ) ).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lr>).
      APPEND VALUE #( %tky = <lr>-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Alumni { <lr>-AlumniId } rejected successfully.| )
                    ) TO reported-Alumni.
    ENDLOOP.
  ENDMETHOD.

  " ====================================================================
  " DYNAMIC FEATURE CONTROL (Hides/Shows Buttons)
  " ====================================================================
  METHOD get_instance_features.
    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni FIELDS ( RegStatus ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_alumni).

    result = VALUE #(
      FOR ls IN lt_alumni (
        %tky = ls-%tky
        %action-approvealumni = COND #( WHEN ls-RegStatus = 'ACTIVE'   THEN if_abap_behv=>fc-o-disabled
                                        WHEN ls-RegStatus = 'REJECTED' THEN if_abap_behv=>fc-o-disabled
                                        ELSE                                if_abap_behv=>fc-o-enabled )

        %action-rejectalumni = COND #( WHEN ls-RegStatus = 'REJECTED' THEN if_abap_behv=>fc-o-disabled
                                       WHEN ls-RegStatus = 'INACTIVE' THEN if_abap_behv=>fc-o-disabled
                                       ELSE                                if_abap_behv=>fc-o-enabled )
        %action-reviewalumni = COND #( WHEN ls-RegStatus = 'REVIEW' THEN if_abap_behv=>fc-o-disabled
                                       WHEN ls-RegStatus = 'ACTIVE' THEN if_abap_behv=>fc-o-disabled
                                       ELSE                              if_abap_behv=>fc-o-enabled )

        %action-deactivatealumni = COND #( WHEN ls-RegStatus = 'INACTIVE' THEN if_abap_behv=>fc-o-disabled
                                           ELSE                                if_abap_behv=>fc-o-enabled )
      )
    ).
  ENDMETHOD.

  METHOD reviewalumni.
    GET TIME STAMP FIELD DATA(lv_ts).
    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni FIELDS ( AlumniId RegStatus ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_alumni).

    MODIFY ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni
        UPDATE FIELDS ( RegStatus LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #( FOR ls IN lt_alumni (
            %tky               = ls-%tky
            RegStatus          = 'REVIEW'
            LastChangedBy      = sy-uname
            LastChangedAt      = lv_ts
            LocalLastChangedAt = lv_ts
          ) ).

    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni ALL FIELDS WITH CORRESPONDING #( lt_alumni ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls IN lt_result ( %tky = ls-%tky %param = ls ) ).

    " --- Added Success Message ---
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lr>).
      APPEND VALUE #( %tky = <lr>-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Alumni { <lr>-AlumniId } status changed to Review.| )
                    ) TO reported-Alumni.
    ENDLOOP.
  ENDMETHOD.

  METHOD deactivatealumni.
    GET TIME STAMP FIELD DATA(lv_ts).
    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni FIELDS ( AlumniId RegStatus ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_alumni).

    MODIFY ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni
        UPDATE FIELDS ( RegStatus LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #( FOR ls IN lt_alumni (
            %tky               = ls-%tky
            RegStatus          = 'INACTIVE'
            LastChangedBy      = sy-uname
            LastChangedAt      = lv_ts
            LocalLastChangedAt = lv_ts
          ) ).

    READ ENTITIES OF ZI_AlumniRegistration IN LOCAL MODE
      ENTITY Alumni ALL FIELDS WITH CORRESPONDING #( lt_alumni ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls IN lt_result ( %tky = ls-%tky %param = ls ) ).

    " --- Added Success Message ---
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lr>).
      APPEND VALUE #( %tky = <lr>-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Alumni { <lr>-AlumniId } deactivated successfully.| )
                    ) TO reported-Alumni.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
