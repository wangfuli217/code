Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: checkbook.bas
'
'  Summary: Calc actuals from checkbooks for a variety of time periods.
'
'           2004-01-07 obsolete, see checkbook.xls
'
'  Created: Fri 02 Mar 2001 22:21:35 (Bob Heckel)
' Modified: Mon 18 Nov 2002 13:11:52 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Config settings.
Sub Main()
  Dim pds_arr As Variant      ' budget periods in months
  Dim offset_arr As Variant   ' spreadsheet cell offsets
  Dim rng_arr As Variant      ' range of cells from Salary to Util:Water
  Dim budsheet As Worksheet   ' the budget sheet in checkbook.xls
  Dim ckgacct_arr As Variant  ' the worksheets that are used in budgeting
  Dim i as Integer            ' loop counter
  
  pds_arr = Array(1, 3, 6, 12)
  offset_arr = Array(-2, -6, -10, -14)
  rng_arr = Array("c2:c20", "g2:g20", "k2:k20", "o2:o20")
  ckgacct_arr = Array("Centura")

  Set budsheet = Sheets("Budget")

  For i = 0 To UBound(pds_arr)
    ' Months, sheet name to write, range to write, range to write's offset from
    ' the Category column.
    GetActs pds_arr(i), budsheet.Name, rng_arr(i), offset_arr(i), ckgacct_arr
  Next
  MsgBox "Done"
End Sub


Sub GetActs(ByVal mo As Integer, bud_sheet As String, _
            ByVal bud_col_rng As String,  ByVal offs As Integer, _
            ckgacct_arr As Variant)
  On Error GoTo ENTROPY
  Dim bud_category As String
  Dim summed As Double
  Dim ckgacctsht As WorkSheet
  Dim ckg_dt_rng As String
  Dim categorycell As Object
  Dim the_row As Object
  Dim err_msg As String
  ' TODO remove
  Dim foo As Worksheet
  Dim bar As Object

  '''Debug.Print mo & " and " & bud_sheet & " and " & bud_col_rng & _
  '''" and " & offs & " and " & ckgacct_arr(0)

  ' TODO
  '''For Each s In ckgacct_arr
    ' Add to sheet collection
  '''Next
  
  ' Put calculated total in each of these cells.
  For Each the_row In Sheets(bud_sheet).Range(bud_col_rng)
    ' Determine the budget item's category name (e.g. Salary)
    bud_category = the_row.Offset(0, offs).Value
    summed = 0
    ' TODO remove
    Set foo = Sheets("Centura")
    ckg_dt_rng = ActsPd(mo, foo)
    Set bar = foo.Range(ckg_dt_rng)
'''debug.print "DEB " & period & " and " & cka.name
    '''For Each categorycell In ckgacctsht.Range(ckg_dt_rng)
    For Each categorycell In bar
      If categorycell.Value = bud_category Then
         summed = summed + categorycell.Offset(0, 2).Value
         summed = summed - categorycell.Offset(0, 1).Value
      End If
    Next
    the_row.Value = summed
  Next

  Exit Sub
ENTROPY:
  If Err.Number <> 0 Then
    err_msg = "Error # " & Str(Err.Number) & " was generated by " _
           & Err.Source & Chr(13) & "Description: " & Err.Description
    MsgBox err_msg, , "An xerror has occurred in Function " & _
    "GetActs " & Erl, Err.HelpFile, Err.HelpContext
  End If
End Sub


' Return a string representing a range of a budget period, based on date.
' TODO There's probably a much better way to do this with objects.
Function ActsPd(period As Integer, cka As Worksheet) as Variant
  On Error GoTo ENTROPY
  Dim daterng As String
  Dim dtcell As Object
  Dim start_erow As Variant
  Dim end_erow As Variant
  Dim categ_rng As Variant
  Dim wanted_startdt As Date
  Dim err_msg As String
  Dim wanted_enddt As Date

  ' Default is an empty cell.
  categ_rng = "e2:e2"
    
  If period = 1 Then
    CellsInPd 0, wanted_startdt, wanted_enddt, start_erow, end_erow, cka
  ElseIf period = 3 Then
    CellsInPd 3, wanted_startdt, wanted_enddt, start_erow, end_erow, cka
  ElseIf period = 6 Then
    CellsInPd 6, wanted_startdt, wanted_enddt, start_erow, end_erow, cka
  ElseIf period = 12 Then
    CellsInPd 12, wanted_startdt, wanted_enddt, start_erow, end_erow, cka
  Else
    Err.Raise 666, , "Unknown period.  Try 1, 3, 6, or 12 mos."
    Exit Function
  End If
  
  ' Dates are in col B on the Centura worksheet.
  '''daterng = "b3:b" & end_erow
  daterng = "b" & start_erow & ":b" & end_erow
  For Each dtcell In cka.Range(daterng)
    ' Older dates evaluate to less-than newer dates:
    ' ? #1/5/2002# < #1/6/2002#
    ' True
    '  E.g. 10/16/2000 10/1/2000              10/16/2000 11/1/2000
    '     must be newer than startdt         must be older than enddt
    '         therefore greater                 therefore less
    If (dtcell.Value >= wanted_startdt) And (dtcell.Value < wanted_enddt) Then
      categ_rng = "e" & start_erow & ":e" & end_erow
      ActsPd = categ_rng
      Exit Function
    End If
  Next

  ActsPd = categ_rng
  ' TODO return a real Range object (set...)
  Exit Function
ENTROPY:
  If Err.Number <> 0 Then
    err_msg = "Error # " & Str(Err.Number) & " was generated by " _
              & Err.Source & Chr(13) & "Description: " & Err.Description
    MsgBox err_msg, , "An yerror has occurred in Function " & _
      "ActsPd " & Erl, Err.HelpFile, Err.HelpContext
  End If
End Function


Sub CellsInPd(month_pd As Integer, _
              wanted_beg As Date, wanted_end As Date, _
              startrow As Variant, endrow As Variant, _
              ckgsht As Worksheet)
  Dim rc As Boolean

  ' E.g. today is 9/4/2002 with month_pd being 3:
  ' ?CDate(DateSerial(Year(Now), Month(Now) - 3, 1))
  ' 6/1/2002
  wanted_beg = CDate(DateSerial(Year(Now), Month(Now) - month_pd, 1))

  ' E.g. today is 9/4/2002 with month_pd being 3:
  ' ?CDate(DateSerial(Year(Now), Month(Now), 0))
  ' 8/31/2002
  If month_pd = 0 Then
    ' Current month is treated differently than 3, 6, 12 history months.
    ' We're only interested in 9/1/2002 thru 9/30/2002
    wanted_end = CDate(DateSerial(Year(Now), Month(Now) + 1, 0))
  Else
    wanted_end = CDate(DateSerial(Year(Now), Month(Now), 0))
  End If
  
  ' startrow is passed as empty, filled by FindRow()
  '      e.g.  11/21/2002
  rc = FindRow(wanted_beg, startrow, "find startrow", ckgsht)
  
  ' The last row number with the desired ending date.
  If month_pd = 0 Then
    ' Capture the row number of the bottom most used cell.
    ' 1 mo budget always goes to the most recent line entered in checkbook.
    '''endrow = Sheets("Centura").Cells.SpecialCells(xlCellTypeLastCell).Row
    endrow = ckgsht.Cells.SpecialCells(xlCellTypeLastCell).Row
  Else
    ' Capture the row number of the last day in the desired mo., going
    ' backwards (e.g. 10/31/2002, 10/30/2002, 10/29/2002, ...) if necessary.
    While Not FindRow(wanted_end, endrow, "find endrow", ckgsht)
      wanted_end = wanted_end - 1
    Wend
  End If
End Sub


' Determine the first start row number or the last end row number based on the
' date passed in.  Returns True if found, populates arow with the row number.
Function FindRow(wanted As Date, arow As Variant, rowtype As String, _
                 ckg As Worksheet) As Boolean
  Dim cell As Range
  Dim bot As Integer

  bot = ckg.Cells.SpecialCells(xlCellTypeLastCell).Row
  '''For Each cell In Sheets("Centura").Range("b1:b999")
  ' TODO use a global to hold date col letter "b"
  For Each cell In ckg.Range("b1:b" & bot) 
    ' Skip header row and unanticipated garbage in the Date column.
    If IsDate(cell.Value) Then
      If rowtype = "find startrow" Then
        If cell.Value >= wanted Then
          arow = cell.Row
          ' Only want the first one.
          Exit For
        End If
      ElseIf rowtype = "find endrow" Then
        If cell.Value = wanted Then
          arow = cell.Row
        End If
      End If
    End If
  Next

  If arow = "" Then
    FindRow = False
  Else
    FindRow = True
  End If
End Function
