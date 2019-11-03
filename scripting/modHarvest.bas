Attribute VB_Name = "modHarvest"
Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: harvest_deptnos.bas
'
'      Summary: Based on passed spdsht, search for pattern and create an array.
'               TODO use parameters for Likestring, length of string e.g. 7
'
'      Created: Thu Jun 10 1999 16:10:37 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Array of Dept Numbers.  TODO use classes.
Public gDeptnos As Variant

Function Harvest(sXlsname As String) As Boolean
  On Error GoTo ENTROPY
  Dim sMsg As String

  Dim c  'what datatype??
  Dim sLookfor As String
  Dim i, iBottomrow As Long
  Dim sMyrange As String
  Dim vaMyarray()
  Dim sTrimmed As String
  Dim iJustnums As Integer
  Dim sCropped As String
 
  ' TODO Assumes an open matrix.xls so check for it.

  ' Using LIKE below.
  sLookfor = "*Ent-Dept*540####*"
  
  iBottomrow = Cells.SpecialCells(xlCellTypeLastCell).Row
  sMyrange = "a1:a" & iBottomrow

  i = 0
  For Each c In ActiveSheet.Cells.Range(sMyrange)
    If c.Value Like sLookfor Then
      sTrimmed = Trim(c.Value)
      Debug.Print sTrimmed
      ' Now know where to start Mid. 540 should be the start of each successful find.
      iJustnums = InStr(sTrimmed, "540")
      Debug.Print iJustnums
      ' E.g. 5401234 is 7 chars long.
      sCropped = Mid$(sTrimmed, iJustnums, 7)
      Debug.Print sCropped
      ' Populate the array.
      '''ReDim Preserve vaMyarray(i + 1)
      ReDim Preserve vaMyarray(i)
      vaMyarray(i) = sCropped
      i = i + 1
      Debug.Print vaMyarray(i - 1)
    End If
  Next

  ' Array available to all modules now.
  gDeptnos = vaMyarray()
  Harvest = True

DAMAGEDEXIT:
  Exit Function

ENTROPY:
  If Err.Number <> 0 Then
    sMsg = "Error # " & Str(Err.Number) & " was generated by " _
              & Err.Source & Chr(13) & "Description: " & Err.Description
  MsgBox sMsg, , "An error has occurred in Function " & _
         "Harvest. " & erl, Err.Helpfile, Err.HelpContext
  End If
  Resume DAMAGEDEXIT
End Function

