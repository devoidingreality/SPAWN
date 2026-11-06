-------------------------------------------------------------------------
         nil Dimension I-�� FastTravel Software User Manual
                            January -∞
-------------------------------------------------------------------------

                              nil, -∞

        ------------------------------------------------------
                     Warnings & Safety Notices
        ------------------------------------------------------

  Definition. "Contact" in this manual means physical touch with a
  Terminal's touchscreen, directly or through a chain of other objects
  (an object touching the screen, anything touching that object, and so
  on). Anything in contact when a teleport is initiated is teleported.
  The Terminal itself and Dimension I-�� infrastructure are never
  teleported.

  a. Non-integer teleports (teleporting to coordinates whose X and/or Y
     values are not whole numbers) can yield unpredictable results, most
     commonly partial temporal misalignment of body segments. The data
     packet is sent BEFORE validation fails, and no Terminal
     acknowledges it (see Diagnostic Code 0x0005). Operators are
     strongly advised not to execute non-integer teleports while any
     organic matter is in contact with the touchscreen.

  b. Everything in contact with the touchscreen at the moment of a
     teleport (see Definition) will also be teleported.

  c. To prevent overloading, a teleport fails if the distance between
     the current and destination coordinates is greater than 100 Ru
     (exactly 100 Ru succeeds). See "Maximum Travel Distance" below.


        ------------------------------------------------------
                          What is Included
        ------------------------------------------------------

  All FastTravel points ("Terminals") are bundled with a modified
installation of Microsoft Windows 95 with an added touchscreen. The
repository for this modified installation can be found at [link
removed]. Note: the repository contains only patches and scripts, not
the operating system image.

  Installations were downgraded from Microsoft Windows 10 to reduce
system overhead and minimize latency. Later operating systems were also
found to be incompatible with the Terminal driver. Later interface
layers are emulated or preserved for operator familiarity and legacy
compatibility. This is stupid. It now runs slower.

  The repository for this program can be found at [link removed].


        ------------------------------------------------------
          How to Use Dimension I-�� FastTravel Software
        ------------------------------------------------------

  Approach a Terminal; the LCD will turn on in response to proximity.
If a Terminal's screen won't turn on or is unnaturally dim, restart it
with the Restart button on the back. If the issue persists after 15
seconds, it is likely faulty. Contact a repair technician at
maintenance@the-interstice.org and provide your coordinates, as shown
on your Personal Digital Assistant (PDA), which you have presumably
been provided upon entering Dimension I-��. If you do NOT have a PDA,
provide the four universe IDs of any adjacent Room, found on the signs
above the doorways of each Portal. Photos are accepted.

  When the Terminal is on, you will see a window named "FastTravel.exe"
containing VBA CommandButtons ("Buttons") and TextBoxes ("Text boxes").

                        ==== Commands ====

  Buttons:
    1. TP button    - Short for "Teleport." After typing coordinates
                      into the X and Y text boxes, tap this button to
                      transport everything in contact with the
                      touchscreen (see Warnings and Safety Notices,
                      Definition and b).

    2. ? (question) - Displays a copy of this document. Close it by
                      tapping the X button in the top-right corner of
                      the Notepad window.

    3. C button     - Displays a copy of the GNU General Public
                      License version 3. Close it the same way.

  Text boxes:
    1. X coordinate - Your desired X coordinate. See "Room Unit".

    2. Y coordinate - Your desired Y coordinate. See "Room Unit".


                        ==== Room Unit ====

  One Room ("Ru") in Dimension I-�� is a 72x72 stud area. Room
coordinates are expressed as { X = %d, Y = %d }, where %d is an integer.
Entering 50 for X and -100 for Y teleports you to { X = 50, Y = -100 }.
-0 is always set to 0 internally.

  Room X and Y correspond to world X and Z respectively. World Y is
height, and is unaffected by teleporting.

  Without external add-ins, a teleport only succeeds if both X and Y
are divisible by 10. Terminals can only transport objects to other
Terminals, and Terminals only exist where both X and Y modulo 10 equal
0. (Non-integer inputs are partially processed: the packet is sent
before validation fails.)

  The program will not crash if you enter a float such as
{ X = -2.5, Y = 5.5 }. It will warn you to remove any organic matter in
contact with the Terminal. You are strongly advised not to perform a
non-integer teleport (see Warnings and Safety Notices, a).

                   ==== Maximum Travel Distance ====

  A teleport succeeds only if:

      sqrt( (X2 - X1)^2 + (Y2 - Y1)^2 )  <=  100

  Examples, starting from { X = 0, Y = 0 }:

      { X = 60,  Y = 80 }  -> distance exactly 100: succeeds.
      { X = 70,  Y = 80 }  -> distance about 106.3: fails (0x0002).

  To travel farther, teleport in several hops. For example, to reach
{ X = 250, Y = 0 } from { X = 0, Y = 0 }:

      { 0, 0 } -> { 100, 0 } -> { 200, 0 } -> { 250, 0 }

  Each hop must land on a Terminal (X and Y divisible by 10). Certain
external add-ins loosen or remove the 100 Ru limit; see [link removed].


                   ==== Diagnostic Codes ====

    0x0000 - Operation completed successfully.
    0x0001 - No working Terminal at the destination (for example,
             X or Y is not divisible by 10).
    0x0002 - Destination exceeds maximum travel distance (100 Ru).
    0x0003 - Destination is the current location.
    0x0004 - Invalid coordinate format (X or Y is not a number or is
             blank).
    0x0005 - Non-integer coordinates. Packet dispatched, no Terminal
             acknowledged it. Do not touch the touchscreen.
    0xFFFF - Contact maintenance.


                   ==== Reference Implementation ====

  The reference implementation demonstrates safe canonical conversion
only; the Terminal runtime itself does not enforce rounding.

  Ru to Vector3 or CFrame:

  local function ToWorld(
      Ru: { X: number, Y: number }?, y: number?, m: string?
  ): (CFrame | Vector3)
      local r = Ru or { X = 0, Y = 0 }
      local c = { X = r.X, Y = r.Y }
      y = y or 0
      m = m or "Vector3"

      if c.X ~= c.X or math.abs(c.X) == math.huge then
          warn("Ru.X is not a finite number")
          c.X = 0
      end
      if c.Y ~= c.Y or math.abs(c.Y) == math.huge then
          warn("Ru.Y is not a finite number")
          c.Y = 0
      end

      -- "+ 0" normalizes -0 to 0.
      c.X = math.round(c.X) + 0
      c.Y = math.round(c.Y) + 0

      c.X *= 72
      c.Y *= 72

      return m == "Vector3" and Vector3.new(c.X, y, c.Y)
          or CFrame.new(c.X, y, c.Y)
  end


  And vice versa:

  local function ToRoom(World: CFrame | Vector3): ({ X: number, Y: number }, number)
      if typeof(World) ~= "Vector3" and typeof(World) ~= "CFrame" then
          warn("invalid data type", typeof(World))
          return { X = 0, Y = 0 }, 0
      end

      local x, y = World.X / 72, World.Z / 72
      local yWorld = World.Y

      x = math.round(x) + 0
      y = math.round(y) + 0

      return { X = x, Y = y }, yWorld
  end


  VBA equivalent. Enable "Roblox and Luau Type Library" as a Reference
in your Project.
  https://www.github.com/devoidingreality/


        ------------------------------------------------------
                     Copyright & Permissions
        ------------------------------------------------------

  This program is licensed under the GNU General Public License version
3. To view a copy, visit https://www.gnu.org/licenses/gpl-3.0.en.html .
Yes, interdimensional teleportation is open-sourced.

  Roblox and Luau Type Library written by asherself and originally
published on VBForums and the Roblox Developer Forum: [link removed]
[link removed]. Its repository can be found here: [link removed]

  We are not affiliated with the creators of SmileOS 1.0 and SmileOS 2.0
or Arsi "Hakita" Patala. The Terminals are not powered by blood of any
kind.


        ------------------------------------------------------
        Where Else to Find Dimension I-�� FastTravel Software
        ------------------------------------------------------

  don't
