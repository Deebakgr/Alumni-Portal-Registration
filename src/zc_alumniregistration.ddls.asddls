@EndUserText.label: 'Alumni Registration - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Alumni',
  typeNamePlural: 'Alumni List',
  title:          { type: #STANDARD, value: 'AlumniId'  },
  description:    { type: #STANDARD, value: 'FirstName' }
}

/* ── NEW: Define the Filter Variants for the UI ────────────────── */
@UI.selectionVariant: [
  { 
    qualifier: 'SVActive', 
    text: 'Active', 
    filter: 'RegStatus EQ ''ACTIVE''' 
  },
  { 
    qualifier: 'SVPending', 
    text: 'Pending', 
    filter: 'RegStatus EQ ''PENDING''' 
  },
  { 
    qualifier: 'SVRejected', 
    text: 'Rejected', 
    filter: 'RegStatus EQ ''REJECTED''' 
  }
]

define root view entity ZC_AlumniRegistration
  provider contract transactional_query
  as projection on ZI_AlumniRegistration
{
      @UI.facet: [
        {
          id:            'AlumniHeader',
          purpose:       #HEADER,
          type:          #FIELDGROUP_REFERENCE,
          targetQualifier: 'HeaderGroup'
        },
        {
          id:            'GeneralInfo',
          label:         'General Information',
          purpose:       #STANDARD,
          type:          #FIELDGROUP_REFERENCE,
          targetQualifier: 'GeneralGroup',
          position:      10
        },
        {
          id:            'DegreesFacet',
          label:         'Degrees',
          purpose:       #STANDARD,
          type:          #LINEITEM_REFERENCE,
          position:      20,
          targetElement: '_Degrees'
        },
        {
          id:            'AdminFacet',
          label:         'Administrative Data',
          purpose:       #STANDARD,
          type:          #FIELDGROUP_REFERENCE,
          targetQualifier: 'AdminGroup',
          position:      30
        }
      ]

      @UI.fieldGroup: [{ qualifier: 'HeaderGroup', position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem:       [{ position: 10, label: 'Alumni ID' }]
      @ObjectModel.text.element: ['AlumniIdDisplay']   // <-- Fixed missing bracket here
  key AlumniId,
  
      // --- NEW: Expose the display field so the UI can use it! ---
      AlumniIdDisplay,

      @UI.fieldGroup: [{ qualifier: 'GeneralGroup', position: 10 }]
      @UI.selectionField: [{ position: 20 }]
      @UI.lineItem:       [{ position: 20, label: 'First Name' }]
      FirstName,

      @UI.fieldGroup: [{ qualifier: 'GeneralGroup', position: 20 }]
      @UI.selectionField: [{ position: 30 }]
      @UI.lineItem:       [{ position: 30, label: 'Last Name' }]
      LastName,

      @UI.fieldGroup: [{ qualifier: 'GeneralGroup', position: 30 }]
      @UI.selectionField: [{ position: 40 }]
      @UI.lineItem:       [{ position: 40, label: 'Graduation Year' }]
      GradYear,

      @UI.fieldGroup: [{ qualifier: 'GeneralGroup', position: 40 }]
      @UI.selectionField: [{ position: 50 }]
      @UI.lineItem:       [{ position: 50, label: 'Degree Program' }]
      DegreeProgram,

      @UI.fieldGroup: [{ qualifier: 'GeneralGroup', position: 50 }]
      @UI.lineItem:       [{ position: 60, label: 'Email Address' }]
      EmailAddress,

      @UI.fieldGroup:     [{ qualifier: 'GeneralGroup', position: 60 }]
      @UI.selectionField: [{ position: 60 }]
      @UI.lineItem:       [{ position: 70, label: 'Status' }]
      RegStatus,
      
      /* expose criticality — hidden from UI, used by framework */
      @UI.hidden: true
      RegStatusCriticality,

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
      _Degrees : redirected to composition child ZC_AlumniDegrees
}
