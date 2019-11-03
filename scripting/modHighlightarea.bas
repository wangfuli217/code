Attribute VB_Name = "modHighlightarea"
Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: highlight_area.bas
'
'      Summary: Based on a starting cell value and an ending cell value,
'               highlight the area for later processing, copying, etc.
'               Start & End cells must be in Col. A.
'               There is a possibility of not selecting the proper range if
'               rows above the Grand Tot line extend further left (i.e.
'               columnwise) than the data on the Grand Tot line.
'
'               TODO make into object for select or copy methods...
'
'      Created: Wed Mar 10 1999 10:46:51 (Bob Heckel)
'     Modified: Tue Jun 08 1999 16:39:40 (Bob Heckel--pass parameters, error
'                                         trap)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function HighlightArea(vDept As Variant, sEndWord As String, _
                       iColsRightward As Integer, Optional iRealEnd _
                       As Integer) As Boolean
  On Error GoTo ENTROPY
  Dim iPegRowTopLeft As Long
  Dim iPegRowBotLeft As Long
  Dim sMsg As String

  ' Normally the row with the string sEndWord will be the bottom but in some
  ' cases, the bottom is one row down.
  If IsMissing(iRealEnd) Then
    iRealEnd = 0
  End If
  ' Peg top left and bottom left to start select.  Finds 5401596.
  Cells.Find(What:=vDept).Activate
  iPegRowTopLeft = ActiveCell.Row
  ' Finds line with TOTAL NET EXPENSE then goes down one to catch
  ' e.g. the ===== line if necessary, based on Optional Parameter.
  iPegRowBotLeft = Cells.Find(What:=sEndWord, after:=ActiveCell).Row + _
                   iRealEnd

  ' Assumes want row A (i.e. 1).
  Range(Cells(iPegRowTopLeft, 1), Cells(iPegRowBotLeft, iColsRightward)).Select

  HighlightArea = True

DAMAGEDEXIT:
  Exit Function

ENTROPY:
  If Err.Number <> 0 Then
    sMsg = "Error # " & Str(Err.Number) & " was generated by " _
              & Err.Source & Chr(13) & "Description: " & Err.Description
    MsgBox sMsg, , "An error has occurred in Function HighlightArea.", Err.Helpfile, Err.HelpContext
  End If
  Resume DAMAGEDEXIT
End Function
