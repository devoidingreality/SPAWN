           -------------------------------------------------------------------
                  ����� Dimension I-�� FastTravel Software User Manual
                                  January -13787229443
           -------------------------------------------------------------------

                                ����������, -13787229443

                 ------------------------------------------------------
                                    What is Included
                 ------------------------------------------------------

	All FastTravel points ("Terminals") are bundled with a modified installation of
Microsoft Windows 95 with an added touchscreen. The repository for this modified
installation can be found at nil.

	Installations were downgraded from Microsoft Windows 10 to reduce system overhead
and minimize latency. Incompatibilities in later operating systems have also been
observed. ALTHOUGH, later interface layers are emulated or preserved for operator
familiarity and legacy compatibility. 

	The repository for this program can be found at nil.


                 ------------------------------------------------------
                     How to Use Dimension I-�� FastTravel Software
                 ------------------------------------------------------

	Approach a Terminal; the LCD will turn on in response to proximity. In the rare
case a Terminal's screen won't turn on or is unnaturally dim, restart it by pressing the
Restart button to the LCD's right. If the issue persists, it is likely faulty. In that
case, contact a repair technician by calling the number nil and providing your coordinates,
as shown in your Personal Digital Assistant (Which you have assumedly been provided upon
entering Dimension I-��.)

	When the Terminal is on, you will be greeted by a menu ("Window") named 
"FastTravel.exe." On the window are multiple VBA CommandButtons ("Buttons") and TextBoxes
("Text boxes"), all of which will be highlighted in this following section:

	                          ==== Commands ====
        Buttons:
     1. TP button    - Its caption stands for "Teleport." Upon typing coordinates into the
	               X and Y text boxes, tapping this button will transport anything
	               making contact with the Terminal's touchscreen to those coordinates.

     2. ? (question) - This is the user manual button. The Terminal will display a copy of
	               document upon tapping it. It can then be closed by tapping the X
	               button in the top-right corner of the displayed Notepad window.

     3. C button     - Similarly, the Terminal will display a copy of the GNU General Public
	               License version 3 upon tapping it. It can be closed the same way.

	Text boxes:
     1. X coordinate - Related to Coordinates. Read the Room Unit section for more information.
	               Input your desired X coordinate.
     
     2. Y coordinate - Ditto. Input your desired Y coordinate.


	                        ==== Room Unit ====

	Generally, one Room ("Ru") is measured as a 72x72 stud area. Room coordinates are
represented with the dictionary { X = %d, Y = %d } where "%d" represents an
integer (whole number).
	
	This means that inputting 50 on the X text box and -100 on the Y text box
will teleport you to { X = 50, Y = -100 }. At the moment, teleports will
only succeed if you enter integers that are divisible by 10 without the help of
"external add-ons." This is because Terminals can only transport objects to other
Terminals; and a Terminal is only present in Rooms whose coordinates are both divisible
by 10 (or -10).

	The program will not crash if you input a float (decimal number) into any
text box (for example: { X = -2.5, Y = 5.5 }). Teleporting to non-integer
coordinates, however, yields unpredictable results, most commonly partial
temporal misalignment of body segments.

	Due to limitations, Terminals can only transport objects to Terminals within 100
Ru in any axis for each teleport. Certain "external add-ons" may make optimizations
that can loosen or remove this restriction. This does not stop or disallow teleporting
more than 100 Ru by FastTraveling in bursts.


	    			 ==== Reference Implementation ====

	Ru can be converted to Vector3 and CFrame with this function:
	--
	local function ToWorld(Ru: { X: number, Y: number }, y: number?, m: string?): (CFrame | Vector3)
		local Ru = Ru or { X = 0, Y = 0 }
		local y = y or 0
		local m = m or "Vector3"
		
		if Ru.X ~= Ru.X then
			warn("Ru.X is not a number")
			Ru.X = 0
		end
		if Ru.Y ~= Ru.Y then
			warn("Ru.Y is not a number")
			Ru.Y = 0
		end
		
		Ru.X = math.round(Ru.X)
		Ru.Y = math.round(Ru.Y)
		
		Ru.X *= 72
		Ru.Y *= 72

		return m == "Vector3" and Vector3.new(Ru.X, y, Ru.Y) or CFrame.new(Ru.X, y, Ru.Y)
	end
	--
	And vice-versa:
	--
	local function ToRoom(World: CFrame | Vector3): ({ X: number, Y: number }, number)
		if typeof(World) ~= "Vector3" and typeof(World) ~= "CFrame" then
			warn("invalid data type", typeof(World))
			return
		end
		
		local x, y = World.X, World.Z
		local yWorld = World.Y

		x /= 72
		y /= 72

		x = math.round(x)
		y = math.round(y)

		return { X = x, Y = y }, yWorld
	end


                 ------------------------------------------------------
                                Copyright & Permissions
                 ------------------------------------------------------

	This program is licensed under the GNU General Public License version 3. To view
a copy of this license, visit https://www.gnu.org/licenses/gpl-3.0.en.html .


                 ------------------------------------------------------
                 Where Else to Find Dimension I-�� FastTravel Software
                 ------------------------------------------------------
	
	please don't.
