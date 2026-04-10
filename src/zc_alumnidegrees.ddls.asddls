@EndUserText.label: 'Alumni Degrees - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

define view entity ZC_AlumniDegrees 
  as projection on ZI_AlumniDegrees
{
      @UI.lineItem:   [{ position: 10, label: 'Alumni ID' }]
      @UI.fieldGroup: [{ qualifier: 'DegreeGroup', position: 10 }]
  key AlumniId,

      @UI.lineItem:   [{ position: 20, label: 'Degree ID' }]
      @UI.fieldGroup: [{ qualifier: 'DegreeGroup', position: 20 }]
  key DegreeId,

      @UI.lineItem:   [{ position: 30, label: 'Degree Name' }]
      @UI.fieldGroup: [{ qualifier: 'DegreeGroup', position: 30 }]
      @UI.selectionField: [{ position: 10 }]
      DegreeName,

      @UI.lineItem:   [{ position: 40, label: 'Graduation Year' }]
      @UI.fieldGroup: [{ qualifier: 'DegreeGroup', position: 40 }]
      GradYear,

      @UI.fieldGroup: [{ qualifier: 'AdminGroup', position: 10 }]
      CreatedBy,

      @UI.fieldGroup: [{ qualifier: 'AdminGroup', position: 20 }]
      CreatedAt,

      @UI.fieldGroup: [{ qualifier: 'AdminGroup', position: 30 }]
      LastChangedBy,

      @UI.fieldGroup: [{ qualifier: 'AdminGroup', position: 40 }]
      LastChangedAt,

      LocalLastChangedAt,

      /* Association */
      _AlumniRegistration : redirected to parent ZC_AlumniRegistration
}
