@EndUserText.label: 'Alumni Degrees - Interface View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view entity ZI_AlumniDegrees
  as select from zalumni_degrees
  association to parent ZI_AlumniRegistration as _AlumniRegistration
    on $projection.AlumniId = _AlumniRegistration.AlumniId
{
  key alumni_id                        as AlumniId,
  key degree_id                        as DegreeId,
      degree_name                      as DegreeName,
      grad_year                        as GradYear,

      @Semantics.user.createdBy: true
      created_by                       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                       as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                  as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                  as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at            as LocalLastChangedAt,

      /* Association */
      _AlumniRegistration
}
