Attribute VB_Name = "FastTravelConversion"
Option Explicit

' Reference implementation: Ru <-> world conversion.
' Enable "Roblox and Luau Type Library" in your Project References.

#If VBA7 Then
    Private Declare PtrSafe Sub CopyMemory Lib "kernel32" _
        Alias "RtlMoveMemory" (Destination As Any, Source As Any, _
        ByVal Length As LongPtr)
#Else
    Private Declare Sub CopyMemory Lib "kernel32" _
        Alias "RtlMoveMemory" (Destination As Any, Source As Any, _
        ByVal Length As Long)
#End If

Public Function IsNonFinite(ByVal Value As Double) As Boolean
    Dim Parts(0 To 1) As Long
    CopyMemory Parts(0), Value, 8
    IsNonFinite = ((Parts(1) And &H7FF00000) = &H7FF00000)
End Function

' Rounds halves away from zero, like Luau's math.round.
' Please do not replace with VBA's Math.Round. It's banker's rounding.
' Many have complained that rounding is inconsistent between versions.
' They all replaced the rounding with Math.Round.
Private Function RoundHalfAway(ByVal Value As Double) As Double
    Dim Whole As Double
    Whole = Fix(Value)
    If Abs(Value - Whole) >= 0.5 Then Whole = Whole + Sgn(Value)
    RoundHalfAway = Whole + 0
End Function

Public Function ToWorld(Optional ByVal Ru As Vector2 = Nothing, _
        Optional ByVal YAxis As Double = 0, _
        Optional ByVal WorldUnit As String = "Vector3") As Object
    Dim RuX As Double, RuY As Double
    If Not Ru Is Nothing Then
        RuX = Ru.X
        RuY = Ru.Y
    End If

    If IsNonFinite(RuX) Then
        Debug.Print "Ru.X is not a finite number"
        RuX = 0
    End If
    If IsNonFinite(RuY) Then
        Debug.Print "Ru.Y is not a finite number"
        RuY = 0
    End If

    RuX = RoundHalfAway(RuX) * 72
    RuY = RoundHalfAway(RuY) * 72
    
    Dim Result As Object
    If WorldUnit = "Vector3" Then
        Set Result = New Vector3
    Else
        Set Result = New CFrame
    End If

    Result.X = RuX
    Result.Y = YAxis
    Result.Z = RuY
    Set ToWorld = Result
End Function

Public Function ToRoom(ByVal World As Object) As Vector2
    Dim Result As Vector2
    Set Result = New Vector2

    If TypeName(World) <> "Vector3" And TypeName(World) <> "CFrame" Then
        Debug.Print "invalid data type " & TypeName(World)
        Result.X = 0
        Result.Y = 0
        Set ToRoom = Result
        Exit Function
    End If

    ' No support for tuples, so World.Y is discarded instead.
    Result.X = RoundHalfAway(World.X / 72)
    Result.Y = RoundHalfAway(World.Z / 72)
    Set ToRoom = Result
End Function
