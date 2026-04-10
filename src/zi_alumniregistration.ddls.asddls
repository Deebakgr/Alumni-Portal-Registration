
@EndUserText.label: 'Alumni Registration - Interface View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

define root view entity ZI_AlumniRegistration
  as select from zalumni_reg
  composition [0..*] of ZI_AlumniDegrees as _Degrees
{
@ObjectModel.text.element: ['AlumniIdDisplay']

  key alumni_id                        as AlumniId,
  cast( alumni_id as abap.char(3) ) as AlumniIdDisplay,
      first_name                       as FirstName,
      last_name                        as LastName,
      grad_year                        as GradYear,
      degree_program                   as DegreeProgram,
      email_address                    as EmailAddress,
      reg_status                       as RegStatus,

      /* ── Criticality Calculation ─────────────────────────────────
         0 = grey  (neutral)
         1 = red   (negative)
         2 = orange/yellow (critical)
         3 = green (positive)
      ──────────────────────────────────────────────────────────── */
      case reg_status
        when 'ACTIVE'    then 3   -- green
        when 'PENDING'   then 2   -- orange
        when 'REVIEW'    then 2   -- orange
        when 'REJECTED'  then 1   -- red
        when 'INACTIVE'  then 1   -- red
        else                  0   -- grey
      end                          as RegStatusCriticality,

      @Semantics.user.createdBy: true
      created_by                   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by              as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at              as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at        as LocalLastChangedAt,

      /* Association */
      _Degrees
}
